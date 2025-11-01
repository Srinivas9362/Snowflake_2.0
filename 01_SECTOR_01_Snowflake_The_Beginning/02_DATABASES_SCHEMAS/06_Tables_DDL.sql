
-- Step 3 — Tables Basics (types, create, alter, clone, rename, drop, undrop)
-- Table Types & Purpose

-- Permanent: default, supports Time Travel & Fail-safe.

-- Transient: no Fail-safe, intended for temporary persistent data — cheaper storage retention.

-- Temporary: session-scoped; automatically dropped at session end.

-- External: references external files (S3/GCS/Azure) — not stored internally.

-- Temporary vs Transient: Temporary = session only. Transient = persists across sessions but less retention.

-- Create / Alter / Rename / Drop / Undrop / Clone Syntax
-- Permanent table
CREATE TABLE demo_db.raw.events (
  event_id INT,
  user_id VARCHAR,
  ts TIMESTAMP_LTZ,
  payload VARIANT
);

-- Transient table
CREATE TRANSIENT TABLE demo_db.raw.tmp_events (id INT);

-- Temporary table (session)
CREATE TEMPORARY TABLE tmp_session (id INT);

-- Add column
ALTER TABLE demo_db.raw.events ADD COLUMN source VARCHAR;

-- Rename table
ALTER TABLE demo_db.raw.events RENAME TO demo_db.raw.events_v1;

-- Drop & Undrop
DROP TABLE demo_db.raw.events_v1;
UNDROP TABLE demo_db.raw.events_v1;

-- Clone table
CREATE TABLE demo_db.raw.events_clone CLONE demo_db.raw.events;

Table Metadata & Health Checks
-- show table details
DESCRIBE TABLE demo_db.raw.events;
SHOW TABLES IN SCHEMA demo_db.raw;

-- table size / micro-partition stats
SELECT * FROM TABLE(INFORMATION_SCHEMA.TABLE_STORAGE_METRICS()) WHERE TABLE_NAME='EVENTS' AND TABLE_SCHEMA='RAW' AND TABLE_CATALOG='DEMO_DB';
-- (or use ACCOUNT_USAGE.TABLES/ STORAGE_HISTORY)

-- Advanced: Clustering & Micro-partitions

Snowflake auto micro-partitions data. For query performance on large tables, use CLUSTER BY keys (manual clustering) or automatic clustering (if enabled in account).

CREATE TABLE demo_db.raw.events_clustered (
  event_id INT, user_id VARCHAR, ts TIMESTAMP_LTZ
)
CLUSTER BY (user_id);


-- Monitor clustering depth and maintenance via SYSTEM$CLUSTERING_INFORMATION('schema.table').

-- Common Table Questions (framed)

-- When to use transient vs permanent? Transient if you don't need fail-safe and want lower storage cost for shorter retention.

-- How to check table storage usage?

-- SNOWFLAKE.ACCOUNT_USAGE.TABLES and TABLE_STORAGE_METRICS.

-- How to prevent accidental drops?

-- Use roles to restrict DROP; use Time Travel to recover within retention.

-- How to rename without downtime?

-- ALTER TABLE ... RENAME TO ... is metadata-only, low downtime.

-- Mini Project — Tables

-- Goal: Create permanent/transient/temporary/external tables and test cloning, Time Travel, and recovery.

-- Steps

Create three tables: permanent events, transient tmp_events, and temp session_events:

CREATE TABLE demo_db.raw.events (id INT, name VARCHAR);
CREATE TRANSIENT TABLE demo_db.raw.tmp_events (id INT);
CREATE TEMPORARY TABLE session_events (id INT);


Insert data into events, clone it, drop original, undrop, verify clone unchanged.

Create a simple external table (if you have S3 access) or simulate with small file on internal stage (see Data Loading step).

-- Deliverable: Commands run + screenshots/outputs showing clone and undrop results.