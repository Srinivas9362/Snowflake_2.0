-- Create a database (with explicit time travel retention)
CREATE DATABASE my_db DATA_RETENTION_TIME_IN_DAYS = 7;  -- allowed depending on edition

-- Use database
USE DATABASE my_db;

-- Rename database
ALTER DATABASE my_db RENAME TO my_db_v2;

-- Drop database (goes to Time Travel)
DROP DATABASE my_db_v2;


-- create clone of an existing database (instant)
CREATE DATABASE my_db_clone CLONE my_db;

-- If dropped, and within Time Travel window:
UNDROP DATABASE my_db_v2;   -- recovers the dropped DB

-- Transfer ownership from one role to another
-- Example: make ROLE_NEW the owner
GRANT OWNERSHIP ON DATABASE my_db TO ROLE ROLE_NEW REVOKE CURRENT GRANTS;

SHOW DATABASES;
SHOW SCHEMAS IN DATABASE my_db;
DESCRIBE DATABASE my_db;

CREATE DATABASE my_db DATA_RETENTION_TIME_IN_DAYS = 7;
CREATE TABLE my_db.raw.events (id INT) DATA_RETENTION_TIME_IN_DAYS = 7;

-- Query table as of 2 hours ago
SELECT * FROM my_db.raw.events AT (OFFSET => -7200); -- seconds
-- or using TIMESTAMP
SELECT * FROM my_db.raw.events AT (TIMESTAMP => '2025-10-01 10:00:00');

-- If table dropped within retention
UNDROP TABLE my_db.raw.events;

SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES ORDER BY CREATED_ON DESC;
-- or
SHOW DATABASES;

SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASE_STORAGE_USAGE_HISTORY WHERE DATABASE_NAME = 'MY_DB' ORDER BY USAGE_DATE DESC;


-- Who owns a DB

SELECT DATABASE_NAME, OWNER FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES WHERE DATABASE_NAME='MY_DB';

-- Check tables count for a DB

SELECT COUNT(*) AS table_count
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLES
WHERE DATABASE_NAME = 'MY_DB' AND DELETED IS NULL;


-- Mini Project — Databases (Practice)

-- Goal: Create a database, explore Time Travel, clone it, change retention, and recover a dropped object.--


CREATE DATABASE demo_db DATA_RETENTION_TIME_IN_DAYS = 1;
CREATE SCHEMA demo_db.raw;

USE DATABASE demo_db;
CREATE TABLE raw.events (id INT, name VARCHAR);
INSERT INTO raw.events VALUES (1, 'a'), (2, 'b');
SELECT * FROM raw.events;


CREATE DATABASE demo_db_clone CLONE demo_db;
SELECT COUNT(*) FROM demo_db_clone.raw.events;

DROP TABLE demo_db.raw.events;
-- Verify dropped:
SHOW TABLES IN SCHEMA demo_db.raw;
-- Recover
UNDROP TABLE demo_db.raw.events;
SELECT * FROM demo_db.raw.events;


-- Change retention and observe:

ALTER DATABASE demo_db SET DATA_RETENTION_TIME_IN_DAYS = 3;
SELECT DATA_RETENTION_TIME_IN_DAYS FROM INFORMATION_SCHEMA.DATABASES WHERE CATALOG_NAME='DEMO_DB';
