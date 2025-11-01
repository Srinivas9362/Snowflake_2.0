-- Step 2 — Schemas (Beginner → Advanced)

-- Concept Overview

-- A Schema is a namespace inside a database that groups related objects (tables, views, file formats, stages). Schemas help organize objects by function, team, or sensitivity.

-- Why create schemas?

-- Separation of concerns (raw vs curated)

-- Access control by role

-- Easier lifecycle management (DROP schema to remove a set of objects)

-- Syntax & Examples
-- Create & use
CREATE SCHEMA demo_db.raw;
USE SCHEMA demo_db.raw;

-- Create schema with comment
CREATE SCHEMA demo_db.analytics COMMENT = 'Curated analytics datasets';

-- Rename schema
ALTER SCHEMA demo_db.raw RENAME TO demo_db.raw_v2;

-- Drop schema
DROP SCHEMA demo_db.raw_v2;  -- will remove all objects (subject to Time Travel)

Ownership & Grants
-- Grant usage to role
GRANT USAGE ON SCHEMA demo_db.raw TO ROLE data_eng;

-- Grant create privileges
GRANT CREATE TABLE ON SCHEMA demo_db.raw TO ROLE data_eng;

-- Transfer ownership
GRANT OWNERSHIP ON SCHEMA demo_db.raw TO ROLE new_owner_role REVOKE CURRENT GRANTS;

-- How to Inspect Schemas and Objects
SHOW SCHEMAS IN DATABASE demo_db;
SELECT * FROM demo_db.INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'RAW';

-- Advanced Schema Topics

Schema cloning: clone a schema instead of the whole DB:

CREATE SCHEMA demo_db.raw_clone CLONE demo_db.raw;


-- Schema-level grants & role hierarchies: use roles to limit CREATE, USAGE, MODIFY.

-- Default file formats & stages can be bound at schema level by naming and using fully qualified names.

-- Common Q&A

-- Can schema names be reused across DBs? Yes, schemas are scoped to DBs.

-- Will dropping a schema drop external stages? It will remove schema objects; external stage references remain in cloud but metadata removed.

-- How to list objects in schema?

SELECT OBJECT_NAME, OBJECT_TYPE FROM INFORMATION_SCHEMA.OBJECTS WHERE OBJECT_SCHEMA='RAW' AND OBJECT_DATABASE='DEMO_DB';

-- Mini Project — Schemas

-- Goal: Organize a DB into raw, curated, analytics, set role privileges, and test access.

-- Steps

Create schemas:

CREATE SCHEMA demo_db.raw;
CREATE SCHEMA demo_db.curated;
CREATE SCHEMA demo_db.analytics;


Create roles and grant:

CREATE ROLE data_eng;
GRANT USAGE ON DATABASE demo_db TO ROLE data_eng;
GRANT USAGE ON SCHEMA demo_db.raw TO ROLE data_eng;
GRANT CREATE TABLE ON SCHEMA demo_db.raw TO ROLE data_eng;


-- As data_eng role, create a table in raw and attempt to create in analytics (should be denied unless granted).

-- Deliverable: A list of commands and confirmation that role privileges work as expected.
