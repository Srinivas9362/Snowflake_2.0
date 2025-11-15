use schema sector_01.phase_01;

--to create table permanent tables
CREATE OR REPLACE TABLE EMPLOYEES (
  EMP_ID INT AUTOINCREMENT,
  EMP_NAME STRING,
  DEPARTMENT STRING,
  SALARY NUMBER(10,2),
  JOIN_DATE DATE
);


--to creat the transient table
CREATE OR REPLACE TRANSIENT TABLE STG_SALES (
  SALE_ID INT,
  PRODUCT STRING,
  AMOUNT NUMBER(10,2),
  REGION STRING
);

--to create the temp table
CREATE TEMPORARY TABLE TMP_USER_SESSION (
  USER_ID STRING,
  LOGIN_TIME TIMESTAMP,
  DEVICE_TYPE STRING
);

--to list the tables
show tables;

--to know more about the table
describe table employees;
describe table STG_SALES;
describe table TMP_USER_SESSION;

show tables in schema phase_01;


show parameters like 'data_retention_time_in_days' in table employees; 
show parameters like 'data_retention_time_in_days' in table STG_SALES ;
show parameters like 'data_retention_time_in_days' in table TMP_USER_SESSION;


--to create table permanent tables with data_retention period
CREATE OR REPLACE TABLE EMPLOYEES (
  EMP_ID INT AUTOINCREMENT,
  EMP_NAME STRING,
  DEPARTMENT STRING,
  SALARY NUMBER(10,2),
  JOIN_DATE DATE
)data_retention_time_in_days =15;


--to creat the transient table 
--we cant set the data_retention_time for transiaent table
CREATE OR REPLACE TRANSIENT TABLE STG_SALES (
  SALE_ID INT,
  PRODUCT STRING,
  AMOUNT NUMBER(10,2),
  REGION STRING
)DATA_RETENTION_TIME_IN_DAYS =15;

--to create the temp table
--valid till for the session
CREATE or replace TEMPORARY TABLE TMP_USER_SESSION (
  USER_ID STRING,
  LOGIN_TIME TIMESTAMP,
  DEVICE_TYPE STRING
)DATA_RETENTION_TIME_IN_DAYS =15;

show tables;
-- name
-- EMPLOYEES  --15
-- STG_SALES --1
-- TMP_USER_SESSION - 1


--set data retention time manually

alter table EMPLOYEES set DATA_RETENTION_TIME_IN_DAYS = 20; --permanen table

alter table STG_SALES set DATA_RETENTION_TIME_IN_DAYS = 20; --transient table
--invalid value [20] for parameter 'DATA_RETENTION_TIME_IN_DAYS'

alter table STG_SALES set TMP_USER_SESSION = 20; --temp table
--invalid property 'TMP_USER_SESSION' for 'TABLE'

--CL0NING
CREATE OR REPLACE TABLE EMPLOYEES_CLNE CLONE  EMPLOYEES; --PERMANENET TABLES CLONE

CREATE OR REPLACE TEMP TABLE EMPLOYEES_CLNE CLONE  EMPLOYEES; --TEMP TABLES CLONE

 -- Transient object cannot be cloned to a permanent object.
CREATE OR REPLACE TRANSIENT TABLE STG_SALES_CLNE CLONE  STG_SALES;  -- TRANSIANT TABLE
--CAN BE CLONED WITH SAME TRANSIENT OR LOWER THAN IT

--NOTE SQL compilation error: Temp table cannot be cloned to a permanent table; clone to a transient table instead.
CREATE OR REPLACE TEMP TABLE TMP_USER_SESSION_CLNE CLONE  TMP_USER_SESSION;  --TEMP TABLE
--CAN BE CLONED WITH  TRANSIENT OR LOWER THAN IT


-- THE CLONED TABLE ALSO CONTAINS THE SAME TIME TRAVEL AS THE FROM CLONED TABLE;

SHOW TABLES LIKE '%CLNE%';


--INFROMATION SCHEMA
-- TABLE_STORAGE_METRICS
SELECT * FROM SECTOR_01.INFORMATION_SCHEMA.TABLE_STORAGE_METRICS WHERE TABLE_NAME LIKE 'STG_SALES'; 
WHERE TABLE_NAME LIKE '%CLNE%';

SELECT * FROM SECTOR_01.INFORMATION_SCHEMA.TABLE_PRIVILEGES
WHERE  TABLE_NAME LIKE '%CLNE%'; 

SELECT * FROM SECTOR_01.INFORMATION_SCHEMA.TABLES
WHERE  TABLE_NAME LIKE '%CLNE%';


SELECT * FROM SECTOR_01.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE 'STG_SALES';


--ACCOUNT USAGE SCHEMA
SELECT * 
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLES
WHERE table_schema = 'PHASE_01'; 

SELECT table_name, active_bytes, time_travel_bytes, failsafe_bytes
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE TABLE_NAME LIKE 'EMPLOYEE'
ORDER BY active_bytes DESC;

SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE TABLE_NAME LIKE 'EMPLOYEE';


SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_DML_HISTORY
WHERE TABLE_NAME LIKE 'EMPLOYEE';


--CLUSTER THE TABLE
ALTER TABLE EMPLOYEES CLUSTER BY (DEPARTMENT);

SELECT * FROM EMPLOYEES;

SELECT GET_DDL('TABLE','EMPLOYEES');


INSERT INTO EMPLOYEES (EMP_NAME, DEPARTMENT, SALARY, JOIN_DATE) VALUES
('John Doe', 'HR', 55000, '2020-01-10'),
('Jane Smith', 'HR', 62000, '2019-03-15'),
('Robert Brown', 'HR', 58000, '2021-06-20'),
('Emily Davis', 'HR', 60000, '2018-11-05'),
('Michael Wilson', 'HR', 65000, '2022-02-18'),
('Sarah Johnson', 'HR', 54000, '2023-04-01'),
('David Miller', 'HR', 59000, '2020-09-14'),
('Linda Martinez', 'HR', 63000, '2021-12-30'),
('Daniel Anderson', 'HR', 61000, '2022-07-21'),
('Sophia Thomas', 'HR', 57000, '2023-05-11'),

('Kevin Lee', 'IT', 70000, '2020-01-22'),
('Laura Harris', 'IT', 72000, '2019-04-30'),
('Justin Clark', 'IT', 75000, '2021-08-12'),
('Amanda Lewis', 'IT', 77000, '2022-03-17'),
('Ryan Walker', 'IT', 69000, '2018-10-25'),
('Olivia Hall', 'IT', 74000, '2020-06-19'),
('Ethan Young', 'IT', 76000, '2021-11-02'),
('Grace King', 'IT', 70000, '2019-12-29'),
('Benjamin Wright', 'IT', 79000, '2022-09-09'),
('Chloe Scott', 'IT', 71000, '2023-03-07'),

('Samuel Green', 'Finance', 65000, '2020-05-14'),
('Victoria Adams', 'Finance', 68000, '2019-07-19'),
('Andrew Baker', 'Finance', 69000, '2021-01-23'),
('Zoe Carter', 'Finance', 72000, '2022-06-01'),
('Nathan Mitchell', 'Finance', 64000, '2018-09-17'),
('Ella Perez', 'Finance', 67000, '2020-02-05'),
('Jack Roberts', 'Finance', 71000, '2021-10-28'),
('Hannah Turner', 'Finance', 76000, '2022-01-14'),
('Luke Phillips', 'Finance', 69000, '2023-08-03'),
('Aria Campbell', 'Finance', 73000, '2021-03-22'),

('Henry Parker', 'Sales', 50000, '2020-07-11'),
('Mia Evans', 'Sales', 52000, '2019-08-16'),
('Logan Edwards', 'Sales', 58000, '2021-12-03'),
('Lily Collins', 'Sales', 55000, '2018-04-21'),
('Aiden Stewart', 'Sales', 53000, '2022-05-10'),
('Scarlett Morris', 'Sales', 56000, '2020-10-18'),
('Wyatt Rogers', 'Sales', 59000, '2021-09-09'),
('Victoria Reed', 'Sales', 54000, '2023-02-14'),
('Gabriel Cook', 'Sales', 51000, '2022-12-22'),
('Penelope Morgan', 'Sales', 57000, '2019-06-07'),

('Caleb Bell', 'Marketing', 62000, '2020-03-12'),
('Nora Murphy', 'Marketing', 64000, '2019-05-28'),
('Owen Bailey', 'Marketing', 66000, '2021-04-09'),
('Hazel Rivera', 'Marketing', 61000, '2018-06-14'),
('Anthony Cooper', 'Marketing', 68000, '2022-11-30'),
('Violet Richardson', 'Marketing', 59500, '2023-07-26'),
('Levi Cox', 'Marketing', 63000, '2020-01-17'),
('Camila Howard', 'Marketing', 65500, '2021-08-05'),
('Isaac Ward', 'Marketing', 64000, '2022-09-15'),
('Stella Flores', 'Marketing', 60000, '2019-10-11');



--CLUSTERING INFORMATION
SELECT SYSTEM$CLUSTERING_INFORMATION('SECTOR_01.PHASE_01.EMPLOYEES');
{
  "cluster_by_keys" : "LINEAR(DEPARTMENT)",
  "total_partition_count" : 1,
  "total_constant_partition_count" : 0,
  "average_overlaps" : 0.0,
  "average_depth" : 1.0,
  "partition_depth_histogram" : {
    "00000" : 0,
    "00001" : 1,
    "00002" : 0,
    "00003" : 0,
    "00004" : 0,
    "00005" : 0,
    "00006" : 0,
    "00007" : 0,
    "00008" : 0,
    "00009" : 0,
    "00010" : 0,
    "00011" : 0,
    "00012" : 0,
    "00013" : 0,
    "00014" : 0,
    "00015" : 0,
    "00016" : 0
  },
  "clustering_errors" : [ ]
}
;


INSERT INTO EMPLOYEES (EMP_NAME, DEPARTMENT, SALARY, JOIN_DATE)
SELECT 
   'Emp_' || SEQ4(),
   ARRAY_CONSTRUCT('HR','IT','Sales','Finance','Marketing')[UNIFORM(0,4,RANDOM())],
   UNIFORM(40000,120000,RANDOM())::NUMBER,
   DATEADD(DAY, UNIFORM(-2000,2000,RANDOM()), CURRENT_DATE())
FROM TABLE(GENERATOR(ROWCOUNT => 500000));



--TO TEST
SELECT COUNT(*) FROM EMPLOYEES;

SELECT * FROM EMPLOYEES;

--to check the cache
SHOW PARAMETERS LIKE 'USE_CACHED_RESULT';
--NOTES
-- 🎯 4. What GOOD Performance Statistics Look Like (Real Example)

-- Here is how a perfectly clustered FACT table might look:

-- Scan progress: 3%
-- Bytes scanned: 400MB
-- Percentage scanned from cache: 98%
-- Bytes written to result: 2MB
-- Partitions scanned: 500
-- Partitions total: 15,000


SELECT * FROM EMPLOYEES;

select * from employees where department = 'Sales' and salary > 88763.00;


ALTER TABLE EMPLOYEES
CLUSTER BY (DEPARTMENT, SALARY);

select * from employees where department = 'Sales' and salary > 88763.00;


--to set auto cluster
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.AUTOMATIC_CLUSTERING_HISTORY
WHERE TABLE_NAME = 'EMPLOYEES';


