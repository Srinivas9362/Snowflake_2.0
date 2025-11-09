-- ✅ Databases are Account-level objects.
-- ACCOUNT
--    ├── DATABASE
--    │      ├── SCHEMA
--    │      │      ├── TABLE / VIEW / SEQUENCE / FILE FORMAT / STAGE / FUNCTION / PROCEDURE
--    │      │      └── (and more)
--    │      └── (Schemas are containers inside databases)
--    └── WAREHOUSE

--TO KNOW THE ACCOUNT AND OTHER INFORMATION
SELECT CURRENT_ACCOUNT(), CURRENT_REGION(),CURRENT_USER(), CURRENT_ROLE(), CURRENT_DATABASE(), CURRENT_SCHEMA(), CURRENT_TIMESTAMP();

CREATE OR REPLACE DATABASE SECTOR_01;


--IT SHOW ALL THE DATABASES INSIDE MY ACCOUNT;
SHOW DATABASES;

--LIST ALL THE SCHEMAS INSIDE THE DATABASE
DESCRIBE DATABASE SECTOR_01;
-- created_on	name	kind
-- 2025-11-08 22:08:12.898 -0800	INFORMATION_SCHEMA	SCHEMA
-- 2025-11-08 22:07:03.519 -0800	PUBLIC	SCHEMA


--TO KNOW ALL THE PARAMS AND INFO ABOUT THE DATABASE
SHOW PARAMETERS IN DATABASE SECTOR_01;

--TO KNOW THE SECTOR_01 DATABASE DATA RETENTION TIME
SHOW PARAMETERS LIKE '%DATA_RETENTION_TIME_IN_DAYS' IN  DATABASE SECTOR_01;

--TO KNOW THE FILE_SAFE, AND IMMUTABLE
SHOW PARAMETERS LIKE '%MAX_DATA_EXTENSION_TIME_IN_DAYS' IN  DATABASE SECTOR_01;


--TO KNOW ABOUT THE DATABSE
SHOW DATABASES LIKE 'SECTOR_01';

--CREATE THE DATABASE WITH THE CUSTOMIZED TIMETRAVEL MAX UPTO 90 DAYS
CREATE OR REPLACE DATABASE SECTOR_01 DATA_RETENTION_TIME_IN_DAYS=90;

--AFTER SETTING THE DATARETENTION_TIME_IN_DAYS
SHOW DATABASES LIKE 'SECTOR_01';

SHOW PARAMETERS LIKE 'DATA_RETENTION_TIME_IN_DAYS' IN DATABASE SECTOR_01;
-- key	value	default	level	description	type
-- DATA_RETENTION_TIME_IN_DAYS	90	1	DATABASE	number of days to retain the old version of deleted/updated data	NUMBER


--TO ALTER THE DATA_RETENTITION_TIME_IN_DAYS
ALTER DATABASE SECTOR_01 SET DATA_RETENTION_TIME_IN_DAYS = 20;

--AFTER ALTERING THE SECTOR DATABASE
SHOW PARAMETERS LIKE 'DATA_RETENTION_TIME_IN_DAYS' IN DATABASE SECTOR_01;
-- key	value	default	level	description	type
-- DATA_RETENTION_TIME_IN_DAYS	20	1	DATABASE	number of days to retain the old version of deleted/updated data	NUMBER

--TO KNOW HOW MANY DATABASE IN ACCOUNT()

-- Step 1: Run SHOW command
SHOW DATABASES;

-- Step 2: Query the result
SELECT COUNT(*) AS DB_COUNT
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));


-- Step 1: Show accessible databases
SHOW DATABASES;

-- Step 2: Get counts and context
SELECT 
    COUNT(*) AS DATABASE_COUNT,
    CURRENT_ACCOUNT() AS ACCOUNT_NAME,
    CURRENT_REGION() AS REGION_NAME,
    CURRENT_ROLE() AS ROLE_NAME
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

USE ROLE ACCOUNTADMIN;

--CLONE THE DATABASE
CREATE OR REPLACE DATABASE SECTOR_01_CLNE  CLONE SECTOR_01;

--NOTE
-- SECTOR_01_CLNE is an exact snapshot of SECTOR_01 at the moment of cloning.
-- It contains all schemas, tables, views, and data — but no physical duplication of the data at the time of creation.

--NOTE IMP
-- 💡 2️⃣ What “Zero-Copy Clone” Means
-- When you clone an object (database/schema/table), Snowflake does not duplicate the underlying data.
-- Instead, it creates metadata pointers to the original micro-partitions.
-- So:
-- Both the original (SECTOR_01) and clone (SECTOR_01_CLNE) share the same data blocks initially.
-- No additional storage cost yet.
-- Only when changes happen, Snowflake starts to diverge the storage.

-- CASE-01
-- You insert/update/delete data in clone
-- New micro-partitions created
-- 💰 You pay for new data only

--CASE-02
-- You modify original DB
-- Same behavior — only changed partitions are newly stored
-- 💰 Minimal

--CASE-03
-- You drop original DB
-- Clone still has its data — so that data becomes “owned” by the clone
-- 💰 Still charged for what’s kept

SHOW DATABASES; 
SHOW PARAMETERS LIKE 'DATA_RETENTION_TIME_IN_DAYS' IN DATABASE SECTOR_01_CLNE;


-- At database level
SELECT *
FROM SECTOR_01.SNOWFLAKE.ACCOUNT_USAGE
WHERE DATABASE_NAME = 'SECTOR_01_CLNE'
ORDER BY USAGE_DATE DESC;

-- Or at table level
SHOW TABLES IN DATABASE SECTOR_01_CLNE;


--NOT EVEN WE CAN ALTER THE CLONED DATABASE AS WELL
ALTER DATABASE SECTOR_01_CLNE SET DATA_RETENTION_TIME_IN_DAYS = 10;

--CLONING THE LINKEDIN DB
CREATE DATABASE LINKEDIN_CLONE
CLONE LINKEDIN AT (OFFSET => -60*60*24);


--KNWO THE COUNT IN THE LINKEDIN_DB
SHOW TABLES IN DATABASE LINKEDIN;

SELECT COUNT(*) AS TOTAL_COUNT_IN_LINKEDIN_DB
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));  
--68

-- TO  KNOW THE COUNT OF DBS IN THE CLONED DB BEFORE 1 DAY
SHOW TABLES IN DATABASE LINKEDIN_CLONE;

SELECT COUNT(*) AS TOTAL_COUNT_IN_LINKEDIN_DB
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));  
--64

--DROP AND UNDROP THE DATABSE
DROP DATABASE SECTOR_01_CLNE;

SHOW DATABASES LIKE 'SECTOR_01_CLNE';
--NO RECORDS

-- TO UNDROP THE DATABSE
UNDROP DATABASE SECTOR_01_CLNE;

SHOW DATABASES LIKE 'SECTOR_01_CLNE';
--ONE RECORD

-- 🔄 2️⃣ When You UNDROP DATABASE SECTOR_01_CLNE
-- When you recover it:
-- UNDROP DATABASE SECTOR_01_CLNE;
-- ➡️ Snowflake simply restores the metadata pointers and reactivates the same micro-partitions that were previously marked inactive.

-- 🧩 1️⃣ Snowflake Stores Metadata in Two Places

-- There are two main ways to inspect object metadata:

-- Layer	Description	Access Example
-- Information Schema	Per-database system view (ANSI SQL style)	SECTOR_01.INFORMATION_SCHEMA.TABLES
-- Account Usage	Account-wide history & usage metadata	SNOWFLAKE.ACCOUNT_USAGE.TABLES

-- Count total objects by type in the LINKEDIN database

SELECT 'LINKEDIN' AS DB_NAME, TABLE_SCHEMA, COUNT(TABLE_NAME) AS TOTL_TABLE_CNT
FROM LINKEDIN.INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE LIKE '%BASE TABLE' AND TABLE_SCHEMA = 'SQL_PRACTICE'
GROUP BY TABLE_SCHEMA;

-- Count total objects by type in the LINKEDIN database
SELECT TABLE_TYPE AS OBJECT_TYPE,
       COUNT(*) AS TOTAL_OBJECTS
FROM LINKEDIN.INFORMATION_SCHEMA.TABLES
GROUP BY 1;

SELECT * FROM  LINKEDIN.INFORMATION_SCHEMA.STAGES;

-- --
-- | Object Type    | View Name                         | Example                          |
-- | -------------- | --------------------------------- | -------------------------------- |
-- | Tables & Views | `INFORMATION_SCHEMA.TABLES`       | `SELECT * FROM ...TABLES;`       |
-- | Stages         | `INFORMATION_SCHEMA.STAGES`       | `SELECT * FROM ...STAGES;`       |
-- | File Formats   | `INFORMATION_SCHEMA.FILE_FORMATS` | `SELECT * FROM ...FILE_FORMATS;` |
-- | Sequences      | `INFORMATION_SCHEMA.SEQUENCES`    | `SELECT * FROM ...SEQUENCES;`    |
-- | Tasks          | `INFORMATION_SCHEMA.TASKS`        | `SELECT * FROM ...TASKS;`        |
-- | Streams        | `INFORMATION_SCHEMA.STREAMS`      | `SELECT * FROM ...STREAMS;`      |
-- | Pipes          | `INFORMATION_SCHEMA.PIPES`        | `SELECT * FROM ...PIPES;`        |
-- | Procedures     | `INFORMATION_SCHEMA.PROCEDURES`   | `SELECT * FROM ...PROCEDURES;`   |
-- | Functions      | `INFORMATION_SCHEMA.FUNCTIONS`    | `SELECT * FROM ...FUNCTIONS;`    |
--

SELECT 'TABLE' AS OBJECT_TYPE, COUNT(*) AS TOTAL_OBJECTS
FROM SECTOR_01.INFORMATION_SCHEMA.TABLES
UNION ALL
SELECT 'VIEW', COUNT(*) FROM SECTOR_01.INFORMATION_SCHEMA.VIEWS
UNION ALL
SELECT 'STAGE', COUNT(*) FROM SECTOR_01.INFORMATION_SCHEMA.STAGES
UNION ALL
SELECT 'SEQUENCE', COUNT(*) FROM SECTOR_01.INFORMATION_SCHEMA.SEQUENCES
UNION ALL
SELECT 'PIPE', COUNT(*) FROM SECTOR_01.INFORMATION_SCHEMA.PIPES;



--TO KNOW DATABSES IN EACH ROLE AND COUNT
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES;
--CUSTOMIZE IT
SELECT DATABASE_OWNER, COUNT(*) AS TOTAL_DB_CNT_PER_ROLE
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES
GROUP BY 1;

--TO KNOW THE STORAGE OF EACH OBJECT IN THE DATABASE
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASE_STORAGE_USAGE_HISTORY;


-- 🧠 Key Concept

-- The view SNOWFLAKE.ACCOUNT_USAGE.DATABASE_STORAGE_USAGE_HISTORY
-- only lists databases that have consumed measurable storage — i.e.,
-- databases containing tables, stages, or data that occupy actual bytes.

-- | Case                                 | Action                                           | Appears in `DATABASE_STORAGE_USAGE_HISTORY`? | Reason                                                   |
-- | ------------------------------------ | ------------------------------------------------ | -------------------------------------------- | -------------------------------------------------------- |
-- | ✅ Database with tables               | Created tables or loaded data                    | ✔️ Yes                                       | Storage bytes > 0                                        |
-- | ⚙️ Empty database                    | Just created, no tables, no data                 | ❌ No                                         | 0 bytes storage                                          |
-- | 🧬 Cloned database (no changes)      | Clone made from existing DB, no new data written | ❌ No                                         | Only metadata snapshot; no physical storage until change |
-- | 🧩 Cloned DB (after updates/inserts) | Updated or inserted rows                         | ✔️ Yes                                       | Changed micro-partitions stored separately               |




SELECT 
  USAGE_DATE,
  SUM(AVERAGE_DATABASE_BYTES)/1024/1024/1024 AS TOTAL_STORAGE_GB
FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASE_STORAGE_USAGE_HISTORY
GROUP BY USAGE_DATE
ORDER BY USAGE_DATE DESC;

CREATE OR REPLACE SCHEMA SECTOR_01.PHASE_01;

CREATE OR REPLACE TABLE SECTOR_01.PHASE_01.STUDENT(
NAME STRING,
AGE INT
);

INSERT INTO   SECTOR_01.PHASE_01.STUDENT VALUES
('sRINVIAS', 23),
('RAM',25);




---PREVILEGES ACCESS

--TO GRANT  SPECIFIC PRIVILEGES
GRANT USAGE, MODIFY ON DATABASE SECTOR_01 TO ROLE SYSADMIN;

--TO GRANT ALL PREVILEGES
GRANT ALL PRIVILEGES ON DATABASE SECTOR_01 TO ROLE SYSADMIN;


GRANT USAGE ON ALL SCHEMAS IN DATABASE SECTOR_01 TO ROLE SYSADMIN;

GRANT CREATE TABLE, CREATE VIEW ON ALL SCHEMAS IN DATABASE SECTOR_01 TO ROLE SYSADMIN;


--✅ To see all grants on a database
show grants on database sector_01;

-- ✅ To see what grants a role has
SHOW GRANTS TO ROLE SYSADMIN;
SHOW GRANTS ON ROLE SYSADMIN;

SHOW GRANTS ON TABLE SECTOR_01.PHASE_01.STUDENT;

--TO KNOW REVOKKE THE PREVILEGES ON THE DATABASE
REVOKE USAGE ON DATABASE SECTOR_01 FROM ROLE SYSADMIN;

REVOKE ALL PRIVILEGES ON DATABASE SECTOR_01 FROM ROLE SYSADMIN;

-- ✅ To see all grants on a database
show grants on database sector_01;

SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES
WHERE GRANTED_BY = 'ACCOUNTADMIN'
  AND GRANTED_TO = 'ROLE' AND GRANTEE_NAME = 'SYSADMIN'
  AND TABLE_CATALOG = 'SECTOR_01';










