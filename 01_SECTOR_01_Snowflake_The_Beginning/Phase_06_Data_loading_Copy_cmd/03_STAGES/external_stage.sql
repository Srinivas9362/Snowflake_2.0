2 — Example: AWS S3 — Step-by-step
Assumptions

You have AWS account & S3 bucket s3://my-company-bucket/data/

You have Snowflake account admin access (ACCOUNTADMIN or SECURITYADMIN) to create the integration and stage.

Step A — Create an IAM role in AWS (trust Snowflake)

Create an IAM role (e.g., snowflake-s3-role) that Snowflake will assume.

Attach a policy allowing the role to s3:GetObject, s3:ListBucket, s3:PutObject (as required) for the bucket/prefix.

Configure the trust policy so Snowflake’s AWS principal (the Snowflake account’s external ID / principal) can assume this role.

Example IAM policy (permissions)
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowS3AccessToSnowflake",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::my-company-bucket",
        "arn:aws:s3:::my-company-bucket/*"
      ]
    }
  ]
}

Example trust policy (replace <SNOWFLAKE_ACCOUNT_ID> with Snowflake's value)

Snowflake supplies the AWS account and external ID to use for the trust. For a generic example:

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::xxxxxxxxxxxx:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        }
      }
    }
  ]
}


Important: Snowflake gives you STORAGE_AWS_EXTERNAL_ID and STORAGE_AWS_IAM_USER_ARN or STORAGE_AWS_ROLE_ARN values when you create the storage integration. Use those to set the trust policy precisely. See Snowflake docs for the exact values for your account/region.

Step B — Create the Storage Integration in Snowflake

Run as ACCOUNTADMIN (or role with CREATE INTEGRATION privilege):

CREATE STORAGE INTEGRATION my_s3_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::123456789012:role/snowflake-s3-role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://my-company-bucket/data/');


After you run this, Snowflake will return values you must copy into AWS trust policy (if required), such as STORAGE_AWS_IAM_USER_ARN or STORAGE_AWS_EXTERNAL_ID. Use those exact values when editing the IAM trust policy.

Step C — Verify the integration (optional)

Query Snowflake to inspect:

DESC INTEGRATION my_s3_integration;


Or:

SHOW INTEGRATIONS LIKE 'MY_S3_INTEGRATION';

Step D — Create the External Stage in Snowflake

Now create the stage that references the integration:

CREATE OR REPLACE STAGE ext_stage_mydata
  URL = 's3://my-company-bucket/data/'
  STORAGE_INTEGRATION = my_s3_integration
  FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1);


You can omit FILE_FORMAT or point to a named file format.

Step E — Test access & list files

If your bucket already has files:

LIST @ext_stage_mydata;


If you get an error, check:

IAM trust policy (external ID / principal)

Role ARN correctness

Allowed locations (prefix) inside integration

Step F — Load data with COPY INTO

Example:

COPY INTO my_schema.my_table
FROM @ext_stage_mydata/path_prefix/
FILE_FORMAT = (FORMAT_NAME = 'my_csv_format')
ON_ERROR = 'CONTINUE';


Check results:

SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.COPY_HISTORY
WHERE TABLE_NAME = 'MY_TABLE'
ORDER BY LAST_LOAD_TIME DESC;

Step G — Troubleshooting common AWS errors

AccessDenied from LIST/COPY: check S3 bucket policy, role permissions, integration allowed locations.

The trust relationship is invalid.: confirm the trust policy uses Snowflake's external ID returned by DESC INTEGRATION.

NoSuchBucket: wrong bucket or region mismatch.

SignatureDoesNotMatch: wrong region or clock skew on AWS side.
-- STORAGE_AWS_EXTERNAL_ID	String	RN93730_SFCRole=4_x0jtPnTrGIvrWuokY/hoj2QVYyo
