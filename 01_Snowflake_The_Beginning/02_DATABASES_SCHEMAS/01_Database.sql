CREATE DATABASE retail_db;
-- DROP DATABASE IF EXISTS retail_db;
UNDROP DATABASE RETAIL_DB;
SHOW DATABASES;
USE DATABASE retail_db;

-- Create with 90 days time travel
CREATE or replace DATABASE retail_db DATA_RETENTION_TIME_IN_DAYS = 2;
-- Clone a database
CREATE or replace DATABASE retail_db_clone CLONE retail_db;

show databases;

SHOW GRANTS ON DATABASE retail_db;
-- Grant usage to role
GRANT USAGE,MODIFY ON DATABASE retail_db TO ROLE SYSADMIN;

GRANT ALL PRIVILEGES ON DATABASE retail_db TO ROLE SYSADMIN;

-- Step 2: Allow SYSADMIN to use all schemas inside
GRANT USAGE ON ALL SCHEMAS IN DATABASE retail_db TO ROLE SYSADMIN;


-- Step 3: Allow SYSADMIN to create objects in schemas
GRANT CREATE TABLE, CREATE VIEW ON ALL SCHEMAS IN DATABASE retail_db TO ROLE SYSADMIN;

-- grant privileges on all future schemas or tables created in the database
GRANT USAGE ON FUTURE SCHEMAS IN DATABASE retail_db TO ROLE sysadmin;
GRANT SELECT ON FUTURE TABLES IN SCHEMA retail_db.public TO ROLE sysadmin;


-- top large tables in a database
SELECT table_catalog,table_schema, table_name, ACTIVE_BYTES/1024/1024/1024 AS gb
FROM retail_db.information_schema.table_storage_metrics
ORDER BY ACTIVE_BYTES DESC, table_schema asc
LIMIT 20;


-- TO CHECK THE TIME TRAVEL
SHOW PARAMETERS LIKE 'DATA_RETENTION_TIME_IN_DAYS' IN DATABASE retail_db;

SHOW PARAMETERS IN DATABASE RETAIL_TEMP;