--csv file format with (,) seperated
CREATE OR REPLACE FILE FORMAT ff_csv
  TYPE = CSV
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1;


USE SCHEMA SECTOR_01.PHASE_01;

list @my_csv_Stage;


select count(*) from 
table(
result_scan(last_query_id()));

PUT file://D:\Snowflake_Advance_Data_Engineering\01_SECTOR_01_Snowflake_The_Beginning\Phase_06_Data_loading_Copy_cmd\01_FILES\emp_double_quotes.csv @my_csv_stage AUTO_COMPRESS=TRUE;

CREATE OR REPLACE FILE FORMAT my_csv_double_ff
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  EMPTY_FIELD_AS_NULL = TRUE
  NULL_IF = ('')
  TRIM_SPACE = TRUE
  RECORD_DELIMITER = '\n'
  ESCAPE = '\\';



select $1, $2, $3,$4,$5
from @my_csv_stage/emp_double_quotes.csv
(file_format=>'my_csv_double_ff');


create or replace TABLE EMPLOYEES_02 (
	EMP_ID NUMBER(38,0) autoincrement start 1 increment 1 noorder,
	NAME VARCHAR(16777216),
	DEPARTMENT VARCHAR(16777216),
	SALARY varchar,
    city varchar(255)
);


copy into employees_02
from @my_csv_stage/emp_double_quotes.csv
file_format = 'my_csv_double_ff'
on_error = continue;

-- Numeric value '85,000' is not recognized;

select * from employees_02;

create or replace TABLE EMPLOYEES_02 (
	EMP_ID NUMBER(38,0) autoincrement start 1 increment 1 noorder,
	NAME VARCHAR(16777216),
	DEPARTMENT VARCHAR(16777216),
	SALARY NUMBER(38,0),
    city varchar(255)
);

truncate table EMPLOYEES_02;
COPY INTO EMPLOYEES_02
FROM (
    SELECT 
        $1 as EMP_ID,
        $2 AS NAME,
        $3 AS DEPARTMENT,
        REPLACE($4, ',', '') AS SALARY,
        $5 AS CITY
    FROM @my_csv_stage/emp_double_quotes.csv
)
FILE_FORMAT = (FORMAT_NAME='my_csv_double_ff')
ON_ERROR = CONTINUE;


select * from EMPLOYEES_02;



-- 3 — Important FILE FORMAT OPTIONS (what they do & common values)

-- TYPE
-- CSV — required for CSV files.

-- FIELD_DELIMITER
-- Character or string separating columns. Typical: ',', '\t' for TSV, | for pipe-delimited.

-- RECORD_DELIMITER
-- Default newline \n. Use \r\n if Windows CRLF.

-- SKIP_HEADER
-- Number of header lines to skip (e.g., 1 when file has column names).

-- FIELD_OPTIONALLY_ENCLOSED_BY
-- Quoting character used around fields (e.g., '"'). If fields may be enclosed in quotes.

-- ESCAPE
-- Escape character to allow special characters inside fields, e.g. \ or ".

-- NULL_IF
-- List of string values that should be treated as SQL NULL (e.g., ('NULL','NA','')).

-- EMPTY_FIELD_AS_NULL
-- TRUE or FALSE. If TRUE, empty field becomes NULL. Useful with , , patterns.

-- TRIM_SPACE
-- TRUE trims leading/trailing spaces from fields.

-- DATE_FORMAT, TIMESTAMP_FORMAT, TIME_FORMAT
-- Format strings for parsing dates/timestamps if not standard. Important for non-ISO dates.

-- ENCODING
-- Character encoding: 'UTF8' (default), 'UTF16', 'ISO-8859-1', etc.

-- SKIP_BLANK_LINES
-- TRUE to ignore blank lines between records.

-- COMPRESSION (on stage upload or COPY INTO)
-- 'GZIP', 'BZIP2', 'NONE' etc; Snowflake auto-detects common compressed extensions .gz, .bz2.

-- COMMENT
-- Skip lines starting with this character (rarely used for CSV).

-- SAMPLE
-- For VALIDATE and COPY, to sample rows for type inference (advanced).

-- ERROR_HANDLING / ON_ERROR
-- Not a file_format option — used in COPY INTO (CONTINUE, SKIP_FILE, ABORT_STATEMENT, SKIP_FILE_...).