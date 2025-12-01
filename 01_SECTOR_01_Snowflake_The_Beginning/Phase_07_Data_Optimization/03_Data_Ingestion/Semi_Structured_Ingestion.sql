============================================================
🔟 SEMI-STRUCTURED INGESTION (JSON, AVRO, XML)
============================================================

Semi-structured data does not follow a fixed schema.

Snowflake stores and processes it using VARIANT column type.

⭐ REAL-WORLD SOURCES
Source	Format
REST APIs	JSON
Kafka	JSON / Avro
Mobile Apps	JSON
Logs	JSON
Telecom systems	XML
Banking systems	XML
============================================================
⭐ 10.1 INGESTING JSON
============================================================
🟧 SAMPLE JSON FILE
{"id":1,"name":"Ravi","skills":["python","sql"],"salary":55000}
{"id":2,"name":"Sneha","skills":["aws","java"],"salary":62000}

🟧 STEP 1 — TARGET TABLE
CREATE OR REPLACE TABLE emp_json (data VARIANT);

🟧 STEP 2 — FILE FORMAT
CREATE OR REPLACE FILE FORMAT ff_json
TYPE = JSON
STRIP_OUTER_ARRAY = TRUE;

🟧 STEP 3 — LOAD JSON
COPY INTO emp_json
FROM @stg_json
FILE_FORMAT = ff_json
ON_ERROR = 'CONTINUE';

🟧 STEP 4 — QUERY JSON
SELECT
  data:id::int AS id,
  data:name::string AS name,
  data:skills[0] AS skill1,
  data:salary::number AS salary
FROM emp_json;

⭐ JSON — ADVANCED FEATURES
✔ Flattening Arrays
SELECT
  e.data:id,
  f.value AS skill
FROM emp_json e,
LATERAL FLATTEN(INPUT => e.data:skills) f;

✔ Schema Detection
SELECT *
FROM TABLE(INFER_SCHEMA(LOCATION=>'@stg_json', FILE_FORMAT=>'ff_json'));

============================================================
⭐ 10.2 INGESTING XML
============================================================
🔹 SAMPLE XML FILE
<employee id="1">
    <name>Ravi</name>
    <salary>60000</salary>
</employee>

🔹 STEP 1 — TARGET TABLE
CREATE OR REPLACE TABLE emp_xml (data VARIANT);

🔹 STEP 2 — FILE FORMAT
CREATE OR REPLACE FILE FORMAT ff_xml
TYPE = XML;

🔹 STEP 3 — COPY INTO
COPY INTO emp_xml
FROM @stg_xml
FILE_FORMAT = ff_xml;

🔹 STEP 4 — Query XML
SELECT
   data:"@id"::int AS id,
   data:"name"::string AS name,
   data:"salary"::number AS salary
FROM emp_xml;

⭐ XML COMPLEX STRUCTURES

Use FLATTEN:

SELECT f.value
FROM emp_xml t,
LATERAL FLATTEN(input => t.data:"employee") f;

============================================================
⭐ 10.3 INGESTING AVRO
============================================================
🔸 Used in Kafka pipelines
🔸 Contains embedded schema
🔸 Snowflake auto-detects schema
🟪 STEP 1 — AVRO TARGET TABLE
CREATE OR REPLACE TABLE emp_avro(data VARIANT);

🟪 STEP 2 — FILE FORMAT
CREATE OR REPLACE FILE FORMAT ff_avro
TYPE = AVRO;

🟪 STEP 3 — LOAD AVRO
COPY INTO emp_avro
FROM @stg_avro
FILE_FORMAT = ff_avro;

🟪 STEP 4 — Query AVRO
SELECT
  data:name,
  data:id,
  data:salary
FROM emp_avro;

============================================================
⭐ ADVANCED SEMI-STRUCTURED PIPELINE EXAMPLE
============================================================
Use Case: Ingest API JSON for Employee Profiles
1. API response saved as JSON file
2. Upload to internal stage
3. Load into RAW VARIANT table
4. FLATTEN arrays
5. Transform into Relational Fact/Dim tables
🟧 RAW TABLE
CREATE OR REPLACE TABLE emp_profile_raw(data VARIANT);

🟧 COPY INTO
COPY INTO emp_profile_raw
FROM @api_stage
FILE_FORMAT = ff_json;

🟧 TRANSFORMATION (flatten skills)
CREATE OR REPLACE TABLE emp_profile_flat AS
SELECT
  data:id::int AS emp_id,
  f.value::string AS skill
FROM emp_profile_raw,
LATERAL FLATTEN(input => data:skills) f;

============================================================
⭐ ADMIN-LEVEL MONITORING (IMPORTANT)
============================================================
✔ COPY_HISTORY
SELECT * 
FROM SNOWFLAKE.ACCOUNT_USAGE.COPY_HISTORY
WHERE FILE_NAME LIKE '%json%';

✔ STAGE STORAGE
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.STAGE_STORAGE_USAGE_HISTORY;

✔ LOAD Errors
COPY INTO emp_json
FROM @stg_json
FILE_FORMAT = ff_json
VALIDATION_MODE='RETURN_ERRORS';

============================================================
🎓 INTERVIEW QUESTIONS — YOU WILL MASTER THIS
============================================================
❓ CSV vs JSON loading difference?

CSV = structured, requires fixed schema
JSON = flexible schema, uses VARIANT

❓ What is STRIP_OUTER_ARRAY?

Removes [ ] from JSON array wrapper.

❓ Why use VARIANT?

Supports:

Nested

Dynamic

Schema-on-read

❓ Which is faster: JSON or Parquet?

➡ Parquet (columnar + compressed)

❓ How to flatten nested JSON?

➡ Use LATERAL FLATTEN()

❓ Best file size for ingestion?

➡ 10MB–100MB compressed