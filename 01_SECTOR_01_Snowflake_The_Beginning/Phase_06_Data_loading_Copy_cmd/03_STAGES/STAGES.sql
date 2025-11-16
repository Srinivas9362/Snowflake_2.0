USE SCHEMA SECTOR_01.PHASE_01;



--INTERNAL STAGE 
CREATE OR REPLACE STAGE my_csv_stage
  FILE_FORMAT = ff_csv;

--TABLE CREATIONS
create or replace TABLE SECTOR_01.PHASE_01.EMPLOYEES_01 (
	EMP_ID NUMBER(38,0) autoincrement start 1 increment 1 noorder,
	name VARCHAR(16777216),
	department VARCHAR(16777216),
	SALARY NUMBER(10,2)
);



--COPY COMMAND
COPY INTO EMPLOYEES_01
FROM @my_csv_stage
ON_ERROR = 'CONTINUE';


SELECT * FROM SECTOR_01.PHASE_01.EMPLOYEES_01;

LIST @my_csv_stage;


--USER STGAE
LIST @~;

LIST @~/raw;

--to connect to snowflkae from the snowsql
-- snowsql -u Srinivas9362 -a COIKTPX-FW70546


-- PUT file://D:\Snowflake_Advance_Data_Engineering\01_SECTOR_01_Snowflake_The_Beginning\Phase_06_Data_loading_Copy_cmd\01_FILES\employees.csv @~ AUTO_COMPRESS=TRUE;

--COPY FROM THE USER STAGE
COPY INTO EMPLOYEES_01
FROM @~
FILE_FORMAT = 'ff_csv'
ON_ERROR = 'CONTINUE';

SELECT * FROM  EMPLOYEES_01;


SHOW STAGES;

LIST @~;

SELECT $1, $2, $3
FROM @~/employees.csv.gz (FILE_FORMAT => 'FF_CSV');

--TABLE STAGE
LIST @%EMPLOYEES_01;

--COPY FROM THE USER STAGE
COPY INTO EMPLOYEES_01
FROM @%EMPLOYEES_01
FILE_FORMAT = 'ff_csv'
-- FILE_FORMAT=(TYPE=CSV FIELD_DELIMITER=',' SKIP_HEADER=1)
ON_ERROR = 'CONTINUE'
FORCE = TRUE
;

-- FORCE = TRUE TO ALLOW TO LOAD THE DATA AGAIN 

SELECT * FROM EMPLOYEES_01;


SELECT $1, $2, $3
FROM @%EMPLOYEES_01/employees.csv.gz (FILE_FORMAT => 'FF_CSV');


SHOW STAGES;


-- VALIDATE IT IN THE INFORMATION SCHEMA
SELECT * 
FROM INFORMATION_SCHEMA.STAGES;

SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.STAGES;


GRANT READ ON STAGE my_csv_stage TO ROLE SYSADMIN;
GRANT WRITE ON STAGE my_csv_stage TO ROLE SYSADMIN;
GRANT ALL PRIVILEGES ON STAGE my_csv_stage TO ROLE SYSADMIN;

SHOW GRANTS ON STAGE my_csv_stage;

SHOW GRANTS TO ROLE SYSADMIN;

SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_ON = 'STAGE'
AND NAME = 'MY_CSV_STAGE';


SHOW PARAMETERS LIKE 'DATA_RETENTION_TIME_IN_DAYS' IN ACCOUNT;
SHOW PARAMETERS LIKE 'DATA_RETENTION_TIME_IN_DAYS' IN DATABASE SECTOR_01;
SHOW PARAMETERS LIKE 'DATA_RETENTION_TIME_IN_DAYS' IN SCHEMA PHASE_01;



desc stage @my_csv_stage;



USE SCHEMA SECTOR_01.PHASE_01;

list @my_csv_Stage;


CREATE STORAGE INTEGRATION my_s3_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::123456789012:role/snowflake-s3-role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://emplyee_csv/raw/');

show integrations like '%my_s3_integration';
  
DESC INTEGRATION my_s3_integration;


CREATE OR REPLACE STAGE ext_stage_mydata
  URL = 's3://emplyee_csv/raw/'
  STORAGE_INTEGRATION = my_s3_integration
  FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = ',' SKIP_HEADER = 1);

LIST @ext_stage_mydata;


SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.STAGES
where stage_name='EXT_STAGE_MYDATA';


SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.COPY_HISTORY;





--to get the files from the internal stage to the local
GET @my_csv_stage/employees.csv file://D:\Snowflake_Advance_Data_Engineering\01_SECTOR_01_Snowflake_The_Beginning\Phase_06_Data_loading_Copy_cmd\03_STAGES\ 

| Intent                                             | Command to run                                                                           | Runs where          | Notes                                          |
| -------------------------------------------------- | ---------------------------------------------------------------------------------------- | ------------------- | ---------------------------------------------- |
| See who has access to a stage                      | `SHOW GRANTS ON STAGE my_csv_stage;`                                                     | Snowflake worksheet | Use ACCOUNT_USAGE.GRANTS_TO_ROLES for auditing |
| See stage metadata (URL, integration, file format) | `DESC STAGE my_csv_stage;` or `SHOW STAGES` or `SELECT * FROM INFORMATION_SCHEMA.STAGES` | worksheet           | For external stages shows cloud URL            |
| See retention parameter for tables                 | `SHOW PARAMETERS LIKE 'DATA_RETENTION_TIME_IN_DAYS' IN ACCOUNT;`                         | worksheet           | Not applicable to stages                       |
| Download stage file to local                       | `GET @mystage/file.csv file://./`                                                        | SnowSQL (client)    | Requires proper privileges and internal stage  |





