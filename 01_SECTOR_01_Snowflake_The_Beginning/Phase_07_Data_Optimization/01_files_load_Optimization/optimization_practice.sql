CREATE OR REPLACE TABLE sector_01.phase_01.sales_raw (
    id INT,
    date DATE,
    amount NUMBER(10,2),
    region STRING
);


show stages;

CREATE OR REPLACE STAGE my_internal_stage
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY='"');

LIST @my_internal_stage;

select * from sales_raw;

COPY INTO sector_01.phase_01.sales_raw
FROM @my_internal_stage
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY='"' skip_header= 'True')
ON_ERROR = 'CONTINUE'
;

SELECT COUNT(*) FROM sector_01.phase_01.sales_raw;




SELECT * 
FROM SNOWFLAKE.ACCOUNT_USAGE.COPY_HISTORY
WHERE TABLE_NAME = 'SALES_RAW'
ORDER BY LAST_LOAD_TIME DESC;

COPY INTO sector_01.phase_01.sales_raw
FROM @my_internal_stage
VALIDATION_MODE = 'RETURN_ERRORS';


COPY INTO sector_01.phase_01.sales_raw
FROM @my_internal_stage
ON_ERROR = 'CONTINUE';

COPY INTO sector_01.phase_01.sales_raw
FROM @my_internal_stage
ON_ERROR = 'SKIP_FILE';


COPY INTO sector_01.phase_01.sales_raw
FROM @my_internal_stage
ON_ERROR = 'SKIP_FILE_10';


COPY INTO sector_01.phase_01.sales_raw
FROM @my_internal_stage
ON_ERROR = 'SKIP_FILE_5%';

COPY INTO sector_01.phase_01.sales_raw
FROM @my_internal_stage
VALIDATION_MODE = 'RETURN_ERRORS';

SELECT * FROM table(validate('SECTOR_01.PHASE_01.SALES_RAW', job_id => 'LAST_COPY_JOB'));


SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.COPY_HISTORY
WHERE TABLE_NAME = 'SALES_RAW'
ORDER BY LAST_LOAD_TIME DESC;


-- 💡 BEST PRACTICE

-- Use 10–100 MB compressed files for maximum parallel performance.



