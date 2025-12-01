============================================================
11️⃣ UNSTRUCTURED DATA HANDLING (Images, Documents, PDFs, Audio)
============================================================

Until 2023, Snowflake could only store:

Structured data (columns)

Semi-structured data (VARIANT, XML, JSON, Parquet)

Now Snowflake supports handling UNSTRUCTURED DATA (BLOBs like images, PDFs, docs, videos) via:

⭐ Unstructured Data Storage (UDS)

You can now store:

Images (.png, .jpg)

PDFs

Word / Excel files

ZIP files

Videos

Any binary file

Snowflake supports:

✔ Storing files in internal stages
✔ Secure access through Snowflake Signed URLs
✔ EXTERNAL FUNCTION ↔ ML model workflows
✔ Unstructured file metadata (size, type)
✔ Preview and DOWNLOAD from Snowsight

📌 11.1 Storing Unstructured Data in Internal Stage
Example — Upload an image
PUT file:///"D:\images\profile.png" @user_stage AUTO_COMPRESS=FALSE;


→ AUTO_COMPRESS=FALSE because image should not be GZIP’d.

📌 11.2 Query Metadata About the File
SELECT *
FROM DIRECTORY(@user_stage);


Output fields:

Column	Meaning
FILE_URL	Temporary URL for download
FILE_SIZE	Size in bytes
FILE_TYPE	MIME type
LAST_MODIFIED	Timestamp
📌 11.3 Generate Secure URL (Download Link)
SELECT build_scoped_file_url(@user_stage, 'profile.png');


You can send this URL to users (valid only for your session or time-limited).

📌 11.4 Using Unstructured Data in ML / Apps

Example: Send image to ML model using external function

SELECT ai.analyze_image(build_scoped_file_url(@assets, 'dog.png'));

📌 11.5 Best Practices

✔ Use internal stages for sensitive unstructured data
✔ Use DIRECTORY TABLE for metadata
✔ Use role-based URL generation
✔ Keep images binary, not VARIANT

🚀 Real-World Use Case Examples
Banking

Store scanned cheques & KYC documents.

Healthcare

Store radiology images (X-Ray, MRI).

Social Media

Store user profile images & content.

============================================================
12️⃣ INTERNAL STAGES (USER, TABLE, NAMED)
============================================================

Internal stages are Snowflake-managed storage for loading/unloading files.

⭐ TYPES OF INTERNAL STAGES
Type	Location	Purpose
USER Stage	@~	Temp per-user staging
TABLE Stage	@%table_name	Per-table staging
NAMED Stage	@stage_name	Recommended for pipelines
========================================================
👉 12.1 USER STAGE (@~)
========================================================

Each user has its own private stage.

Upload file
PUT file:///"D:\files\emp.csv" @~ AUTO_COMPRESS=TRUE;

Query files
LIST @~;

Load into table
COPY INTO employees
FROM @~ FILE_FORMAT = (TYPE=CSV);


✔ No need to create
✔ Good for testing
✔ Not recommended for production

========================================================
👉 12.2 TABLE STAGE (@%table_name)
========================================================

Attached to a table automatically.

Example — table stage for EMPLOYEES table:
@%employees

Upload
PUT file:///"D:\files\*.csv" @%employees;

Load
COPY INTO employees FROM @%employees;


✔ Keeps data close to table
✔ Best for micro-batch loads
✔ Auto-created, no need to create

========================================================
👉 12.3 NAMED INTERNAL STAGES
========================================================

BEST PRACTICE FOR ALL PIPELINES.

Create Named Stage
CREATE OR REPLACE STAGE stg_sales
FILE_FORMAT = (TYPE=CSV SKIP_HEADER=1);

Upload
PUT file:///"D:\sales\*.csv" @stg_sales;

Load
COPY INTO sales
FROM @stg_sales;


✔ Provides governance
✔ Can attach FILE_FORMAT
✔ Can attach ENCRYPTION
✔ Must be created manually

============================================================
13️⃣ EXTERNAL STAGES (S3, Azure, GCS)
============================================================

External stages reference cloud storage:

AWS S3

Azure Blob

Google Cloud Storage

Used for:

Large pipelines

Cross-cloud sharing

Low-cost storage

⭐ EXTERNAL STAGE ON AWS S3
Syntax
CREATE OR REPLACE STAGE stg_s3_sales
URL = 's3://mybucket/sales/'
CREDENTIALS = (AWS_KEY_ID='xxxx' AWS_SECRET_KEY='yyyy')
FILE_FORMAT = (TYPE=CSV SKIP_HEADER=1);

⭐ EXTERNAL STAGE ON AZURE
CREATE STAGE stg_azure_files
URL='azure://mycontainer.blob.core.windows.net/data/'
CREDENTIALS=(AZURE_SAS_TOKEN='<sas-token>')
FILE_FORMAT=(TYPE=JSON);

⭐ EXTERNAL STAGE ON GCS
CREATE STAGE stg_gcs
URL='gcs://mybucket/data/'
CREDENTIALS=(GCS_KEY='xxxxx')
FILE_FORMAT=(TYPE=PARQUET);

⭐ WHY USE EXTERNAL STAGES?

✔ Cloud-native pipelines
✔ Long-term archived data
✔ Minimize Snowflake storage cost
✔ Required for Snowpipe Auto-ingest

⭐ BEST PRACTICES

Use S3 lifecycle policies to control cost

Use object versioning for traceability

Use IAM roles instead of keys

Use Parquet for fast load and analytics

============================================================
14️⃣ STAGE COMMANDS — PUT, GET, LIST, REMOVE
============================================================

These commands are used through SnowSQL or Snowsight Worksheets.

⭐ PUT (Upload File → Stage)
PUT file:///"D:\files\emp.csv" @stg_sales AUTO_COMPRESS=TRUE;


✔ Uploads to internal stage
✔ Compresses file automatically

⭐ GET (Download File ← Stage)
GET @stg_sales file:///"D:\downloads\";


✔ Downloads stage files to your local system

⭐ LIST (View Stage Files)
LIST @stg_sales;


Output fields:

file name

size

compressed?

last modified

⭐ REMOVE (Delete Stage Files)
REMOVE @stg_sales PATTERN='.*\.csv.gz';


✔ Deletes matching files
✔ Reduces storage usage

============================================================
⭐ REAL-WORLD PROJECT EXAMPLE (All Topics Combined)
============================================================
Use Case: Ingest sales data + customer images + logs
1. Upload CSV to named internal stage
PUT file:///"D:\sales\*.csv" @stg_sales;

2. Load structured CSV
COPY INTO sales_raw FROM @stg_sales FILE_FORMAT=ff_csv;

3. Upload customer images (unstructured)
PUT file:///"D:\images\*.png" @stg_customer_image AUTO_COMPRESS=FALSE;

4. Store JSON logs from S3 external stage
COPY INTO logs_raw
FROM @s3_logs
FILE_FORMAT=ff_json;

5. Build secure download URLs
SELECT build_scoped_file_url(@stg_customer_image, 'cust_123.png');
