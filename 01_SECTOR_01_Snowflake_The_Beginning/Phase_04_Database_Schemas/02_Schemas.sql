use database sector_01;

--TO CREATE THE SCHEMA
CREATE OR REPLACE SCHEMA PHASE_01;

--TO GET THE DETAILS OF SCHEMAS IN SECTOR_01 DATABASE
SHOW SCHEMAS;

SHOW SCHEMAS LIKE '%PHASE_01';


--TO CHECK THE DATA RETENTION TIME IN DAYS
SHOW PARAMETERS LIKE 'DATA_RETENTION_TIME_IN_DAYS' IN SCHEMA PHASE_01;--20

--TO KNOW ALL THE PARAMETERS IN THE SCHEMA
SHOW PARAMETERS IN SCHEMA PHASE_01;

--CREATE SCEHMA WITH TIME TRAVEL
CREATE OR REPLACE SCHEMA PHASE_01 DATA_RETENTION_TIME_IN_DAYS = 15;

SHOW PARAMETERS LIKE 'DATA_RETENTION_TIME_IN_DAYS' IN SCHEMA PHASE_01;
--15

--ALTER THE DATA RETENTIONE TIME 
ALTER SCHEMA PHASE_01 SET DATA_RETENTION_TIME_IN_DAYS = 10;

SHOW PARAMETERS LIKE 'DATA_RETENTION_TIME_IN_DAYS' IN SCHEMA PHASE_01;
--10DAYS

--CLONE THE SCHEMA
CREATE OR REPLACE SCHEMA PHASE_01_CLNE CLONE PHASE_01;

SHOW SCHEMAS;
-- INFORMATION_SCHEMA
-- PHASE_01
-- PHASE_01_CLNE
-- PUBLIC

SHOW SCHEMAS LIKE '%PHASE%';
-- PHASE_01
-- PHASE_01_CLNE


--TO KNOW THE SCHEMAS DETAILS IN THE INFORMATION_SCHEMA
SELECT * FROM SECTOR_01.INFORMATION_SCHEMA.SCHEMATA;

--TO KNWO THE DETAILS OF SCHEMAS IN THE ACCOUNT USAGE SCHEMA
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.SCHEMATA
WHERE CATALOG_NAME = 'SECTOR_01';

--DROP AND UNDROP THE SCEHMA
DROP SCHEMA PHASE_01_CLNE;

SHOW SCHEMAS LIKE '%PHASE%';
--PHASE_01

UNDROP SCHEMA PHASE_01_CLNE;

SHOW SCHEMAS LIKE '%PHASE%';
-- PHASE_01
-- PHASE_01_CLNE


--TO KNOW THE TOTAL sCHEMA COUNT
--STEP-01
SHOW SCHEMAS;

-STEP-02
SELECT COUNT(*) AS TOTAL_SCHEMAS
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));
--4

--TO CHECK THE GRANTS ON THIS SCHEMA
SHOW GRANTS ON SCHEMA PHASE_01;
-- OWNERSHIP WITH ACCOUNTADMIN

GRANT ALL PRIVILEGES ON SCHEMA PHASE_01 TO ROLE SYSADMIN;

| No.    | Topic                                | Description                                                              |
| ------ | ------------------------------------ | ------------------------------------------------------------------------ |
| 1️⃣    | **Switching Database Context**       | `USE DATABASE SECTOR_01;`                                                |
| 2️⃣    | **Creating Schema**                  | `CREATE OR REPLACE SCHEMA PHASE_01;`                                     |
| 3️⃣    | **Viewing Schemas**                  | `SHOW SCHEMAS;` and `SHOW SCHEMAS LIKE '%PHASE_01%';`                    |
| 4️⃣    | **Checking Retention Policy**        | `SHOW PARAMETERS LIKE 'DATA_RETENTION_TIME_IN_DAYS' IN SCHEMA PHASE_01;` |
| 5️⃣    | **Viewing All Schema Parameters**    | `SHOW PARAMETERS IN SCHEMA PHASE_01;`                                    |
| 6️⃣    | **Creating Schema with Time Travel** | `CREATE OR REPLACE SCHEMA PHASE_01 DATA_RETENTION_TIME_IN_DAYS = 15;`    |
| 7️⃣    | **Altering Retention Policy**        | `ALTER SCHEMA PHASE_01 SET DATA_RETENTION_TIME_IN_DAYS = 10;`            |
| 8️⃣    | **Schema Cloning**                   | `CREATE OR REPLACE SCHEMA PHASE_01_CLNE CLONE PHASE_01;`                 |
| 9️⃣    | **Listing Schemas**                  | `SHOW SCHEMAS LIKE '%PHASE%';`                                           |
| 🔟     | **Querying Schema Metadata**         | From `INFORMATION_SCHEMA.SCHEMATA` and `ACCOUNT_USAGE.SCHEMATA`          |
| 1️⃣1️⃣ | **Dropping Schema**                  | `DROP SCHEMA PHASE_01_CLNE;`                                             |
| 1️⃣2️⃣ | **Undropping Schema**                | `UNDROP SCHEMA PHASE_01_CLNE;`                                           |
| 1️⃣3️⃣ | **Counting Schemas**                 | Using `RESULT_SCAN(LAST_QUERY_ID())`                                     |
| 1️⃣4️⃣ | **Checking Grants**                  | `SHOW GRANTS ON SCHEMA PHASE_01;`                                        |
| 1️⃣5️⃣ | **Granting Privileges**              | `GRANT ALL PRIVILEGES ON SCHEMA PHASE_01 TO ROLE SYSADMIN;`              |
