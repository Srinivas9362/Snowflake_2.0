Day 1 — Stepwise Deep Dive
Step 1 — Databases (Beginner → Advanced)
Concept Overview — What is a Database in Snowflake?

A Database in Snowflake is the top-level logical container for related objects: schemas, tables, views, stages, file formats, sequences, procedures, etc. It’s a logical namespace used to organize and secure data artifacts.

Why create databases? Where & how are they used?

Why: separation of environments (prod/dev/test), business domains (sales, finance), or lifecycle (raw/curated/analytics).

Where: created within your Snowflake account; metadata stored in Snowflake’s internal metadata services; data stored in Snowflake-managed cloud storage (encrypted).

How used: set USE DATABASE dbname; and run DDL/DML scoped to that DB.

Text Diagram — Database in Snowflake hierarchy
ACCOUNT
 └── DATABASE (my_db)
      ├── SCHEMA (raw)
      │    ├── TABLE (raw.events)
      │    └── FILE FORMAT, STAGE
      └── SCHEMA (analytics)
           ├── VIEW
           └── TABLE

Key Concepts to Know (list form)

Data retention (Time Travel & Fail-safe)

Cloning (zero-copy)

Ownership & GRANTS

Data location: cloud provider + region (managed by Snowflake)

Costs: storage (data + Time Travel), compute (warehouse usage)

Metadata queries: INFORMATION_SCHEMA, SNOWFLAKE.ACCOUNT_USAGE