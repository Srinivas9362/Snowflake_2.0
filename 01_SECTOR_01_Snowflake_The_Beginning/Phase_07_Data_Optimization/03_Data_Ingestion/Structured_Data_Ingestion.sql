Below is the complete advanced-level explanation of:

9️⃣ Structured Data Ingestion
🔟 Semi-Structured Data Ingestion (JSON, Avro, XML)

This covers:

✔ Real-world pipelines
✔ Internal stage only
✔ Best practices
✔ Syntax for COPY INTO
✔ File formats
✔ Flattening and querying
✔ Advanced transformations
✔ Admin-level monitoring

This is the exact depth expected from a Senior Snowflake Data Engineer and SnowPro Core / Advance Certification.

============================================================
✅ 9. STRUCTURED DATA INGESTION (CSV / PARQUET / TABLES)
============================================================
⭐ What is Structured Data?

Structured data has:

Fixed schema

Well-defined rows & columns

Consistent data types

Examples:

CSV

Excel (converted to CSV)

Parquet (columnar but structured)

SQL tables

RDBMS exports

⭐ REAL-WORLD USE CASES
Source	Structured Data Example
ERP	Products.csv
CRM	Customers.csv
Finance	Transactions.parquet
Snowflake ETL	Clean dimension or fact tables
⭐ INTERNAL STAGE INGESTION WORKFLOW
Local Files → Internal Stage → Snowflake Table → Transform → Consumption Layer

🟦 STEP 1 — CREATE STAGE (INTERNAL)
CREATE OR REPLACE STAGE stg_structured;

🟦 STEP 2 — CREATE TARGET TABLE
CREATE OR REPLACE TABLE sales_raw (
    sale_id NUMBER,
    sale_date DATE,
    customer STRING,
    amount NUMBER(10,2)
);

🟦 STEP 3 — UPLOAD FILES (CSV)

Your files are in:

D:\Snowflake_Files\structured\


Upload:

PUT file:///"D:\Snowflake_Files\structured\*.csv" @stg_structured AUTO_COMPRESS=TRUE;

🟦 STEP 4 — DEFINE FILE FORMAT FOR CSV
CREATE OR REPLACE FILE FORMAT ff_csv
TYPE = CSV
FIELD_DELIMITER = ','
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
NULL_IF = ('NULL', 'N/A', '');

🟦 STEP 5 — COPY INTO TABLE (Bulk Load)
COPY INTO sales_raw
FROM @stg_structured
FILE_FORMAT = ff_csv
ON_ERROR = 'CONTINUE';

🟦 STEP 6 — VALIDATE LOAD
SELECT * FROM sales_raw LIMIT 10;

⭐ ADVANCED FEATURES FOR STRUCTURED DATA
✔ Schema Evolution

Snowflake requires consistent schemas.

If CSV columns change:

Use ALTER TABLE

Or load into VARIANT first

✔ PARALLEL LOADING

50 CSV files = 50 parallel threads.

✔ COPY_HISTORY Monitoring
SELECT * 
FROM SNOWFLAKE.ACCOUNT_USAGE.COPY_HISTORY
WHERE TABLE_NAME = 'SALES_RAW'
ORDER BY LAST_LOAD_TIME DESC;

✔ COLUMNAR LOAD (PARQUET)

Parquet loads are faster and preserve data types.

COPY INTO sales_raw
FROM @stg_structured
FILE_FORMAT = (TYPE=PARQUET);

⭐ REAL WORLD PIPELINE EXAMPLE (Structured)

Business sends Sales_2025_01.csv daily

File lands in internal stage

COPY into RAW layer

Transform into CURATED layer

Load into dashboards