✔️ 1.1 ON_ERROR Parameter (MOST IMPORTANT)

Controls what Snowflake should do if it encounters errors during data load.

| Value                       | Meaning                             | Use Case            |
| --------------------------- | ----------------------------------- | ------------------- |
| `ABORT_STATEMENT` (default) | Entire COPY fails                   | Safe loads          |
| `CONTINUE`                  | Skip bad rows, load good ones       | Ingestion pipelines |
| `SKIP_FILE`                 | Skip entire file if 1 row has error | Strict file quality |
| `SKIP_FILE_NUM`             | Skip file if errors exceed N rows   | Flexible load       |
| `SKIP_FILE_PERCENT`         | Skip file if bad % > threshold      | Mixed data quality  |


🧪 Example 1 — Skip bad rows and load others
COPY INTO sector_01.phase_01.sales_raw
FROM @my_internal_stage
ON_ERROR = 'CONTINUE';


➡️ Bad rows are ignored
➡️ Good rows are loaded

🧪 Example 2 — Skip entire file if any row fails
COPY INTO sector_01.phase_01.sales_raw
FROM @my_internal_stage
ON_ERROR = 'SKIP_FILE';

🧪 Example 3 — Allow up to 10 errors per file
ON_ERROR = 'SKIP_FILE_10';

🧪 Example 4 — Skip file if >5% rows contain errors
ON_ERROR = 'SKIP_FILE_5%';

✔️ 1.2 VALIDATION_MODE

Helps debug errors without loading data.

🧪 Example — Check what errors will occur
COPY INTO sector_01.phase_01.sales_raw
FROM @my_internal_stage
VALIDATION_MODE = 'RETURN_ERRORS';


Output columns:

row_number

row_text

error_message

Perfect for debugging bad files.

🧪 Example — Count errors
COPY INTO sector_01.phase_01.sales_raw
FROM @my_internal_stage
VALIDATION_MODE = 'RETURN_N_ROWS'
LIMIT 10;

✔️ 1.3 LOAD REJECTION REPORT (Snowflake)

After COPY:

SELECT * FROM table(validate('SECTOR_01.PHASE_01.SALES_RAW', job_id => 'LAST_COPY_JOB'));

✔️ 1.4 COPY_HISTORY (Admin Monitoring)
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.COPY_HISTORY
WHERE TABLE_NAME = 'SALES_RAW'
ORDER BY LAST_LOAD_TIME DESC;


Shows:

Success/failures

Row count

File name

Error code

Load time

🔶 SECTION 2 — PARALLEL LOADS in Snowflake

Snowflake can load data in parallel automatically, without you doing anything.

Snowflake parallelism depends on:

✔ Number of files

More files = more threads

✔ Warehouse size

Bigger warehouse = more parallel workers

📌 2.1 How Parallel Loading Works

Snowflake assigns one thread per file

If you have more files → more threads

If your warehouse is larger → more threads can run simultaneously

💡 BEST PRACTICE

Use 10–100 MB compressed files for maximum parallel performance.

🧪 Example — Parallel Load with 100 Files

Assume you have 100 files in internal stage:

file_001.csv.gz
file_002.csv.gz
...
file_100.csv.gz

COPY INTO runs 100 threads:
COPY INTO sector_01.phase_01.sales_raw
FROM @my_internal_stage
FILE_FORMAT = (TYPE='CSV')
PATTERN = '.*\.csv\.gz';


➡ Each file loads independently
➡ More files = better parallelism
➡ Faster load = cheaper warehouse cost

🔶 SECTION 3 — PARALLEL = SPEED + COST OPTIMIZATION
| Files            | Warehouse | Threads | Load Time |
| ---------------- | --------- | ------- | --------- |
| 1 file (2GB)     | XL        | 1       | Slow      |
| 20 files (100MB) | XL        | 20      | Fast      |
| 100 files (20MB) | XL        | 100     | Very Fast |


🔶 SECTION 4 — IMPACT OF FILE COMPRESSION ON PARALLEL LOADS

Compression reduces network + stage storage cost
but affects parallelism:

| Compression | Splittable? | Parallel Impact           |
| ----------- | ----------- | ------------------------- |
| gzip (.gz)  | ❌ No        | One file → one thread     |
| bzip2       | ❌ No        | slow                      |
| snappy      | ✔ Yes       | best parallelism          |
| parquet     | ✔ Yes       | best format for analytics |


🔶 SECTION 5 — IMPACT OF FILE SIZE ON LOADING
| File Size         | Speed   | Cost | Notes           |
| ----------------- | ------- | ---- | --------------- |
| Small (<1MB)      | ❌ Slow  | High | Too many files  |
| Medium (10–100MB) | ⭐ Best  | Low  | Balanced        |
| Large (>500MB)    | ⚠️ Slow | High | Low parallelism |


🔶 SECTION 6 — FULL REAL-WORLD PROJECT EXAMPLE
Scenario:

100 CSV files in internal stage
Need to load into table with:

Error skipping

Parallel processing

Step 1 — Load with error handling
COPY INTO sector_01.phase_01.sales_raw
FROM @my_internal_stage
FILE_FORMAT = (TYPE='CSV')
ON_ERROR = 'CONTINUE';

Step 2 — See Failed Rows
COPY INTO sector_01.phase_01.sales_raw
FROM @my_internal_stage
VALIDATION_MODE = 'RETURN_ERRORS';

Step 3 — Check COPY History
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.COPY_HISTORY
WHERE TABLE_NAME='SALES_RAW';

Step 4 — Check Stage Files
LIST @my_internal_stage;

🔥 SECTION 7 — INTERVIEW QUESTIONS

(You will ACE these)

❓ Why does Snowflake recommend 10–100 MB file size?

Because:

maximizes parallelism

balances cost

efficient micro-partitioning

❓ How does ON_ERROR='CONTINUE' behave?

Skips bad rows, loads good rows.

❓ What is VALIDATION_MODE?

Debug mode — checks errors without loading.

❓ Does Snowflake auto-parallelize COPY INTO?

YES — based on number of files and warehouse size.