✅ GOAL

Automatically load files from an AWS S3 bucket into a Snowflake table using Snowpipe.

📌 PREREQUISITES

AWS account with permissions for S3 + IAM

Snowflake account with ACCOUNTADMIN or SYSADMIN role

Snowflake warehouse (optional for Snowpipe, but good for testing)

⭐ STEP 1: Create AWS S3 Bucket

Go to AWS Console → S3

Click Create bucket

Bucket name example:

mycompany-snowflake-ingestion


Keep defaults → Create bucket.

Inside the bucket, create folder:

raw/data/

⭐ STEP 2: Create an IAM Role for Snowflake

Snowflake will need access to S3 via IAM role + external ID trust.

2.1 Get Snowflake Account Identifier

In Snowflake run:

SELECT CURRENT_ACCOUNT();
SELECT CURRENT_REGION();


Format becomes:

<account_locator>.<region>.aws


Example:

xyz12345.us-east-1.aws

2.2 Create IAM Role in AWS

Go to AWS → IAM → Roles → Create Role

Select: AWS Account → Another AWS Account

Enter the Snowflake Account ID.

Add External ID (required).

You get this from Snowflake:

SELECT SYSTEM$GET_SNOWFLAKE_EXTERNAL_ID();


Use this value in the AWS role as External ID.

Attach policy → Create a custom policy:

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::mycompany-snowflake-ingestion",
        "arn:aws:s3:::mycompany-snowflake-ingestion/*"
      ]
    }
  ]
}


Create role.
Copy the IAM Role ARN, e.g.:

arn:aws:iam::123456789012:role/snowflake_s3_access_role

⭐ STEP 3: Create Storage Integration in Snowflake
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE STORAGE INTEGRATION s3_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::123456789012:role/snowflake_s3_access_role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://mycompany-snowflake-ingestion/raw/data/');


Check integration:

DESC INTEGRATION s3_int;


Snowflake gives a Snowflake_IAM_User ARN → add this as a trust relationship in AWS role (AWS should already enforce trust).

⭐ STEP 4: Create Stage in Snowflake
CREATE OR REPLACE STAGE my_s3_stage
  STORAGE_INTEGRATION = s3_int
  URL = 's3://mycompany-snowflake-ingestion/raw/data/'
  FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER=',' SKIP_HEADER=1);


Test listing:

LIST @my_s3_stage;

⭐ STEP 5: Create Target Table
CREATE OR REPLACE TABLE employees (
    id INTEGER,
    name STRING,
    dept STRING,
    salary NUMBER
);

⭐ STEP 6: Create the Snowpipe

This pipe automatically loads new files from S3 → Snowflake table.

CREATE OR REPLACE PIPE my_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO employees
  FROM @my_s3_stage
  FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER=1);


Verify pipe:

DESC PIPE my_pipe;


You will get notification channel ARN like:

aws:sns:us-east-1:123456789012:snowflake_s3_my_pipe

⭐ STEP 7: Configure S3 → SNS → Snowpipe Event Notifications

Snowpipe needs S3 events → SNS → Snowpipe integration.

7.1 In AWS SNS: Create Topic

Go to SNS → Create Topic → Standard

Name: snowpipe_topic

Copy ARN

7.2 Subscribe Snowflake to SNS Topic

Use the SNS ARN from Snowflake DESC PIPE output.

In AWS SNS → Subscriptions → Create Subscription

Protocol: HTTPS

Endpoint: Snowflake's notification_channel from DESC PIPE.

Example:

https://xyz12345.us-east-1.aws.snowflakecomputing.com/v1/pipeNotifications?...

7.3 Give S3 Permission To Send Notifications

Go to S3 → bucket → Properties → Event Notifications
Create rule:

Event Type: PUT
Prefix: raw/data/
Destination: SNS Topic → snowpipe_topic

Save.

⭐ STEP 8: Test Snowpipe Automation

Upload a file to S3:

File: employee_01.csv

1,Srikanth,IT,50000
2,Ravi,Sales,40000
3,Kiran,HR,45000


Upload to bucket:
s3://mycompany-snowflake-ingestion/raw/data/employee_01.csv

⭐ STEP 9: Check Snowpipe Load History
SELECT * FROM SNOWPIPE.PIPE_USAGE_HISTORY WHERE PIPE_NAME = 'MY_PIPE';


Or:

SELECT * FROM TABLE(INFORMATION_SCHEMA.LOAD_HISTORY(@my_s3_stage));


Check the table:

SELECT * FROM employees;


You should see 3 records automatically loaded.

🎉 PIPE CREATED SUCCESSFULLY
📌 COMPLETE FLOW DIAGRAM

AWS S3 → S3 Event → SNS Topic → Snowflake Pipe → COPY INTO → Target Table


-- for schema evolution
Snowflake will NOT add the column, but Snowflake will map existing columns correctly:

COPY INTO sales
FROM @my_stage
FILE_FORMAT = (TYPE = CSV)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;