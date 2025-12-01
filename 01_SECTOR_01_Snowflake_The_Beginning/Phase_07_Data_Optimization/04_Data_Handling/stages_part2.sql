============================================================
⭐ What Does “Implementation of Stages & File Formats” Mean?
============================================================

It means:

✔ Creating stages (internal & external)
✔ Adding file formats to stages
✔ Uploading files using PUT
✔ Loading data using COPY INTO
✔ Managing, monitoring, and optimizing pipeline
✔ Choosing correct stage + file format based on use case

This is FOUNDATION for Snowflake ETL / ELT pipelines.

============================================================
⭐ 1. WHAT IS A STAGE?
============================================================

A stage is a storage location where Snowflake expects files before loading/unloading.

There are 3 kinds:

1️⃣ Internal Stage

Snowflake-managed storage

Types:
✔ User Stage (@~)
✔ Table Stage (@%table)
✔ Named Stage (@stage_name)

2️⃣ External Stage

Cloud storage
✔ S3
✔ Azure Blob
✔ GCS

3️⃣ Unstructured Stage

For images, PDFs, binary files

Supports secure URLs

============================================================
⭐ 2. WHAT IS A FILE FORMAT?
============================================================

A file format tells Snowflake how to interpret a file.

Includes rules like:

delimiter

header handling

quoting

escape characters

compression

null interpretation

Supported file formats:

✔ CSV
✔ JSON
✔ PARQUET
✔ AVRO
✔ ORC
✔ XML

============================================================
⭐ 3. IMPLEMENTATION FLOW (High-Level)
============================================================
Files (local/cloud)
      ↓
Stage (internal/external)
      ↓
File Format (interpret rules)
      ↓
COPY INTO Table
      ↓
Validation / Monitoring

============================================================
⭐ 4. IMPLEMENTATION: INTERNAL STAGE + FILE FORMAT
============================================================

Let's build a real pipeline.

🟦 Step 1 — Create Table
CREATE OR REPLACE TABLE sector_01.phase_01.sales_raw (
    id INT,
    sale_date DATE,
    customer STRING,
    amount NUMBER(10,2)
);

🟦 Step 2 — Create File Format (CSV Example)
CREATE OR REPLACE FILE FORMAT ff_csv_sales
TYPE = CSV
FIELD_DELIMITER = ','
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
NULL_IF = ('NULL','N/A','')
EMPTY_FIELD_AS_NULL = TRUE;

🟦 Step 3 — Create Named Internal Stage
CREATE OR REPLACE STAGE stg_sales
FILE_FORMAT = ff_csv_sales;


✔ This binds file format to stage (recommended for production)
✔ COPY INTO becomes simpler

🟦 Step 4 — Upload Files FROM local → stage
PUT file:///"D:\SalesData\*.csv" @stg_sales AUTO_COMPRESS=TRUE;


✔ Files now exist inside Snowflake stage
✔ View them:

LIST @stg_sales;

🟦 Step 5 — Load Data
COPY INTO sector_01.phase_01.sales_raw
FROM @stg_sales;


Because file format is attached to stage, no need to specify it.

🟦 Step 6 — Validate Load
SELECT COUNT(*) FROM sector_01.phase_01.sales_raw;

🟦 Step 7 — Monitor Load History
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.COPY_HISTORY
WHERE TABLE_NAME = 'SALES_RAW'
ORDER BY LAST_LOAD_TIME DESC;

============================================================
⭐ 5. IMPLEMENTATION: TABLE STAGE + FILE FORMAT
============================================================

Snowflake automatically provides a table stage:

@%sales_raw

Upload:
PUT file:///"D:\SalesData\*.csv" @%sales_raw;

Copy:
COPY INTO sales_raw
FROM @%sales_raw
FILE_FORMAT = ff_csv_sales;


Best for small tables or quick micro-batch loads.

============================================================
⭐ 6. IMPLEMENTATION: USER STAGE + FILE FORMAT
============================================================

User stage = @~

Upload:
PUT file:///"D:\files\sample.csv" @~;

Copy:
COPY INTO sales_raw
FROM @~
FILE_FORMAT = ff_csv_sales;


Not recommended for production.

============================================================
⭐ 7. IMPLEMENTATION: EXTERNAL STAGE + FILE FORMAT
============================================================

For S3:

CREATE OR REPLACE STAGE stg_s3_sales
URL='s3://bucket/path/'
CREDENTIALS=(AWS_KEY_ID='xxx' AWS_SECRET_KEY='yyy')
FILE_FORMAT = ff_csv_sales;

Load:
COPY INTO sales_raw
FROM @stg_s3_sales;

============================================================
⭐ 8. IMPLEMENTATION: SEMI-STRUCTURED FILE FORMAT
============================================================
JSON:
CREATE OR REPLACE FILE FORMAT ff_json
TYPE = JSON
STRIP_OUTER_ARRAY = TRUE;

Stage:
CREATE OR REPLACE STAGE stg_json FILE_FORMAT = ff_json;

Load:
COPY INTO json_table FROM @stg_json;

PARQUET:
CREATE OR REPLACE FILE FORMAT ff_parquet TYPE=PARQUET;

============================================================
⭐ 9. USING FILE FORMATS DIRECTLY IN COPY INTO (No Stage Binding)
============================================================
COPY INTO sales_raw
FROM @stg_sales
FILE_FORMAT = (TYPE=CSV SKIP_HEADER=1);


✔ Quick testing
✖ Not recommended for production

============================================================
⭐ 10. BEST PRACTICES (SnowPro-Level)
============================================================
✔ 1. Always create Named Stages for production

Good governance

Easy permission control

Reusable

✔ 2. Always create FILE FORMAT objects

Centralised

Reusable

Ensures consistency

Mandatory for Snowpipe

✔ 3. Use compression

gzip preferred

Smaller storage cost

Faster upload/download

✔ 4. Keep file sizes between 10 MB to 100 MB

Maximum parallel loading performance

✔ 5. Use ON_ERROR='CONTINUE' for ingestion pipelines

Avoid stopping jobs

Capture bad rows separately

✔ 6. Use COPY_HISTORY for monitoring
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.COPY_HISTORY;

✔ 7. Use DIRECTORY table for unstructured ingestion
CREATE OR REPLACE DIRECTORY my_dir ON STAGE stg_images;

============================================================
⭐ 11. REAL WORLD PIPELINE IMPLEMENTATION (END-TO-END)
============================================================
Step 1 — Files arrive from different teams
CSV → Sales  
JSON → API logs  
PARQUET → Analytics  

Step 2 — Upload into dedicated stages
@stg_sales  
@stg_logs  
@stg_parquet  

Step 3 — File formats applied
ff_csv_sales  
ff_json_logs  
ff_parquet  

Step 4 — COPY INTO RAW tables
sales_raw  
api_raw  
analytics_raw  

Step 5 — Transform into curated tables
sales_curated  
dim_customer  
fact_sales  

Step 6 — Data accessible by BI

Power BI / Tableau / Looker

============================================================
⭐ 12. INTERVIEW-LEVEL QUESTIONS YOU MUST MASTER
============================================================
❓ Difference between user stage, table stage, named stage?
❓ Why use file formats instead of defining inline?
❓ How does COPY INTO behave when file formats mismatch?
❓ Why attach file format to stage?
❓ How does Snowflake parallelize file loading?
❓ When should you use PARQUET instead of CSV?
❓ What is STRIP_OUTER_ARRAY?
❓ How do you handle bad rows?
❓ How do you list files in stage?
❓ Can internal stages store unstructured files? (YES)