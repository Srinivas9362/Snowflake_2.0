🧭 DOMAIN 1.0 — DATA MOVEMENT

Goal: You should be able to load, ingest, transform, and share data efficiently using Snowflake’s ecosystem.

🔹 STEP 1: Data Loading Basics (1.1)
Topics to Learn:

Data Loading Considerations

File size (optimal: 100–250 MB compressed)

File format (CSV, JSON, Parquet, Avro, ORC, XML)

Compression (GZIP, BZIP2, SNAPPY)

Network and warehouse sizing (compute cost)

Parallel loading (multi-file load for performance)

Error handling (ON_ERROR clause)

Data Loading Features & Impacts

COPY INTO command

Data validation and transformation during load

Impact on performance, storage, and cost

Time travel and cloning effects on load

📘 Start here:

Learn COPY INTO in depth (from internal & external stages).

Practice loading data from local files, S3, and Azure Blob.

🔹 STEP 2: Ingesting Various Data Formats (1.2)
Topics to Learn:

File Formats

Create file formats using CREATE FILE FORMAT

Parameters: FIELD_DELIMITER, SKIP_HEADER, COMPRESSION, etc.

Data Types by Format

Structured: CSV, Parquet

Semi-structured: JSON, XML, Avro

Unstructured: images, PDFs, etc. (stored via external stages)

Stages

Internal stages: user, table, named stages

External stages: S3, GCS, Azure

LIST, PUT, GET, and REMOVE commands

📘 Hands-on:

Create FILE FORMAT objects.

Load JSON & Parquet into VARIANT columns.

Query semi-structured data with FLATTEN().

🔹 STEP 3: Troubleshooting Ingestion (1.3)
Topics to Learn:

Common ingestion issues:

File format mismatch

Permissions (stage or role-based)

Incorrect COPY syntax

Corrupted files

Duplicate file loads

Debugging methods:

View LOAD_HISTORY()

Use VALIDATE_PIPE_LOAD()

Check stage file access

Understand the meaning of error codes

📘 Hands-on:
Use VALIDATION_MODE = RETURN_ERRORS and ON_ERROR options.

🔹 STEP 4: Continuous Data Pipelines (1.4)
Topics to Learn:

Stages – where raw data lands.

Streams – change tracking (CDC).

Tasks – automation (scheduled or event-driven SQL).

Snowpipe

Auto-ingest (event-based via cloud notification)

REST API (manual trigger)

Snowpipe Streaming

Near real-time ingestion (Kafka/Snowpark streaming)

📘 Hands-on:

Create a stream + task pipeline for incremental loads.

Compare Snowpipe vs. Tasks for automation.

Practice auto-ingest setup on AWS S3.

🔹 STEP 5: Data Pipeline Design (1.5)
Topics to Learn:

Pipeline Types

Batch vs. Streaming vs. Micro-batch.

ELT using Snowflake’s compute.

User Defined Functions (UDFs)

SQL UDFs

JavaScript UDFs

Python UDFs (via Snowpark)

Snowflake SQL API

Query submission via API

Job monitoring and status retrieval

Snowpark Pipelines

Write transformations using Python, Scala, or Java

DataFrame API

Deploy using stored procedures or tasks

📘 Hands-on:

Write a simple Python Snowpark pipeline.

Create and call SQL/JS UDFs.

🔹 STEP 6: Connectors (1.6)
Topics to Learn:

Kafka Connector

Snowflake Kafka Sink Connector

Auto-ingest streaming messages

Topic → Table mapping

Spark Connector

Read/write Snowflake data via Spark jobs

sfURL, sfDatabase, sfWarehouse, etc.

Python Connector

snowflake.connector library

Execute queries, load/unload data

📘 Hands-on:

Write Python code to connect & insert data into Snowflake.

🔹 STEP 7: Data Sharing (1.7)
Topics to Learn:

Data Shares

Secure data sharing (no data copy)

CREATE SHARE, ADD DATABASE, GRANT USAGE

Views

Secure views

Row-level security (RLS)

Snowflake Marketplace

Public & private listings

Listings

Sharing datasets as listings for organizations

📘 Hands-on:

Create a secure view and share with another account.

🔹 STEP 8: External Tables & Unload (1.8)
Topics to Learn:

External Tables

Define tables over files in S3, Azure, GCS

Used for querying raw data without loading

REFRESH command for metadata updates

Iceberg Tables

For open table formats (ACID + external storage)

Schema Evolution

How Snowflake handles column changes in external tables

Unload Data

Use COPY INTO @stage to export data from Snowflake to S3

📘 Hands-on:

Create and query an external table on S3.

Practice COPY INTO unloads as JSON and CSV.

🧩 Recommended Learning Flow (Simplified)
---
| Order | Topic                             | Skill Level           | Why                             |
| :---- | :-------------------------------- | :-------------------- | :------------------------------ |
| 1️⃣   | Data Loading Concepts             | Beginner              | Foundation for everything else  |
| 2️⃣   | File Formats & Stages             | Beginner              | Essential for ingestion         |
| 3️⃣   | Troubleshooting Ingestion         | Intermediate          | Real-world importance           |
| 4️⃣   | Streams, Tasks, Snowpipe          | Intermediate          | Automation backbone             |
| 5️⃣   | UDFs, Snowpark, SQL API           | Intermediate–Advanced | Coding/data transformation      |
| 6️⃣   | Connectors (Kafka, Spark, Python) | Advanced              | Integration with external tools |
| 7️⃣   | Data Sharing                      | Advanced              | Cross-account collaboration     |
| 8️⃣   | External Tables & Unload          | Advanced              | Hybrid & open data architecture |

🧭 Snowflake Advanced Data Engineer Certification — Domain 1.0: Data Movement

| **S.No** | **Topic**                                                              |    **Level**    |
| :------: | :--------------------------------------------------------------------- | :-------------: |
|     1    | Databases                                                              |   🟢 Beginner   |
|     2    | Schemas and Tables (basic structure for loading data)                  |   🟢 Beginner   |
|     3    | Data Loading Concepts                                                  |   🟢 Beginner   |
|     4    | COPY INTO command                                                      |   🟢 Beginner   |
|     5    | Data Loading Considerations (file size, compression, performance)      |   🟢 Beginner   |
|     6    | Data Loading Features & Impacts (error handling, parallel loads)       |   🟢 Beginner   |
|     7    | File Formats — CSV, JSON, Parquet, Avro, ORC, XML                      |   🟢 Beginner   |
|     8    | Create and Manage File Formats (`CREATE FILE FORMAT`)                  |   🟢 Beginner   |
|     9    | Structured Data Ingestion                                              |   🟢 Beginner   |
|    10    | Semi-Structured Data Ingestion (JSON, Avro, XML)                       |   🟢 Beginner   |
|    11    | Unstructured Data Handling (images, documents)                         |   🟢 Beginner   |
|    12    | Internal Stages (User, Table, Named)                                   |   🟢 Beginner   |
|    13    | External Stages (S3, Azure, GCS)                                       |   🟢 Beginner   |
|    14    | Stage Commands — PUT, GET, LIST, REMOVE                                |   🟢 Beginner   |
|    15    | Implementation of Stages and File Formats                              |   🟢 Beginner   |
|    16    | Creating and Managing Views                                            |   🟢 Beginner   |
|    17    | Using Secure Views                                                     |   🟢 Beginner   |
|    18    | Row-Level Security (basic understanding)                               |   🟢 Beginner   |
|    19    | Troubleshooting Data Ingestion                                         | 🟡 Intermediate |
|    20    | Identifying Causes of Ingestion Errors                                 | 🟡 Intermediate |
|    21    | Resolving Ingestion Errors                                             | 🟡 Intermediate |
|    22    | Tasks — Scheduling and Automation                                      | 🟡 Intermediate |
|    23    | Streams — Change Data Capture (CDC)                                    | 🟡 Intermediate |
|    24    | Snowpipe — Continuous Loading (Auto-ingest & REST API)                 | 🟡 Intermediate |
|    25    | Designing Continuous Data Pipelines (Stages + Tasks + Streams + Pipes) | 🟡 Intermediate |
|    26    | Differentiating Pipeline Types (Batch vs Streaming)                    | 🟡 Intermediate |
|    27    | Creating SQL and JavaScript UDFs                                       | 🟡 Intermediate |
|    28    | Python Connector Basics (`snowflake.connector`)                        | 🟡 Intermediate |
|    29    | Unloading Data using `COPY INTO @stage`                                | 🟡 Intermediate |
|    30    | General Table Management (CREATE, ALTER, DROP, REFRESH)                | 🟡 Intermediate |
|    31    | Implementing Row-Level Filtering                                       | 🟡 Intermediate |
|    32    | Implementing Secure Data Sharing (basic)                               | 🟡 Intermediate |
|    33    | Snowpipe Streaming (real-time ingestion)                               |   🟠 Advanced   |
|    34    | Snowflake SQL API (query submission and monitoring)                    |   🟠 Advanced   |
|    35    | Creating Data Pipelines in Snowpark (Python, Scala, Java)              |   🟠 Advanced   |
|    36    | Kafka Connector (Snowflake Sink)                                       |   🟠 Advanced   |
|    37    | Spark Connector (Read/Write integration)                               |   🟠 Advanced   |
|    38    | Advanced Python Connector (Parameterized Queries, Error Handling)      |   🟠 Advanced   |
|    39    | Implementing Secure Data Shares across Accounts                        |   🟠 Advanced   |
|    40    | Sharing Data via Snowflake Marketplace                                 |   🟠 Advanced   |
|    41    | Sharing Data using Listings (Public/Private)                           |   🟠 Advanced   |
|    42    | Managing External Tables (S3, GCS, Azure)                              |   🟠 Advanced   |
|    43    | Managing Schema Evolution in External Tables                           |   🟠 Advanced   |
|    44    | Managing Iceberg Tables (Open Table Format)                            |   🟠 Advanced   |
|    45    | Designing Hybrid Data Architectures (Internal + External Tables)       |    🔵 Expert    |
|    46    | Optimizing Data Pipelines (Performance, Cost, and Concurrency)         |    🔵 Expert    |
|    47    | Advanced Snowpipe + Stream Integration for Real-Time Analytics         |    🔵 Expert    |
