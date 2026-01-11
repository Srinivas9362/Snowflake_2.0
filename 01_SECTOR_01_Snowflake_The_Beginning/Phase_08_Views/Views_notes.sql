A — VIEWS (Regular & Materialized)
1. What a view is

A view is a named SQL query stored as metadata.

It does not store rows; querying a view runs its underlying SELECT at runtime.

Use cases: logical abstraction, reuse query logic, hide complexity, convenience for joins/aggregations.

2. Types of views

Regular (standard) view — defined by CREATE VIEW. Query executed at runtime.

Materialized view — stores precomputed results (physical). Faster reads, but storage & maintenance costs.

3. Basic syntax & examples
Create a simple view
-- must have CREATE VIEW on schema and USAGE on DB/schema and SELECT on referenced tables
CREATE OR REPLACE VIEW analytics.customer_orders AS
SELECT
  c.customer_id,
  c.name,
  SUM(o.amount)       AS total_spent,
  COUNT(o.order_id)   AS orders_count
FROM raw.customers c
JOIN raw.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

Use the view
SELECT * FROM analytics.customer_orders WHERE total_spent > 1000;

Show and describe
SHOW VIEWS IN SCHEMA analytics;
DESCRIBE VIEW analytics.customer_orders;   -- lists columns
SELECT GET_DDL('VIEW','ANALYTICS.CUSTOMER_ORDERS'); -- shows SQL (unless secure)

4. Create materialized view — syntax & caveats

Materialized views persist results so queries reading them are faster.

CREATE OR REPLACE MATERIALIZED VIEW analytics.mv_customer_orders
CLUSTER BY (customer_id) AS
SELECT
  c.customer_id,
  SUM(o.amount) AS total_spent,
  COUNT(*)      AS orders_count
FROM raw.orders o
GROUP BY c.customer_id;


Notes / restrictions

Materialized views are supported only for certain types of queries (aggregations, group by, deterministic). Complex constructs (like certain window functions, non-deterministic UDFs, some joins) may be disallowed.

They incur storage charges and maintenance compute when base tables change (Snowflake maintains them incrementally where possible).

Use when read-performance benefits outweigh storage/maintenance cost.

To refresh explicitly (rare): ALTER MATERIALIZED VIEW ... REFRESH (Snowflake normally keeps them up-to-date automatically for supported cases).

5. Privileges (who can create / query / manage views)

To create view: role needs CREATE VIEW on the schema (or CREATE on schema) and USAGE on database+schema; also SELECT (or necessary privileges) on the referenced objects.

To query a view: USAGE on the schema and SELECT on the view. For regular views, users often also need access to underlying tables unless access is granted via a secure view (see below).

To manage (drop/alter): OWNERSHIP of the view or the ability to DROP objects in the schema.

Examples:

-- grant create view permission
GRANT CREATE VIEW ON SCHEMA analytics TO ROLE data_engineer;

-- allow analyst to query view
GRANT USAGE ON SCHEMA analytics TO ROLE analyst;
GRANT SELECT ON VIEW analytics.customer_orders TO ROLE analyst;

6. Dependency tracking & maintenance

To see what objects a view depends on:

SELECT *
FROM TABLE(OBJECT_DEPENDENCIES('ANALYTICS.CUSTOMER_ORDERS')); -- if available


or use SHOW OBJECTS / GET_DDL / account usage views.

When underlying table columns change (dropped/renamed), view may break — watch for errors on SELECT.

When cloning databases, views are cloned as metadata pointers (clones reuse micro-partitions of base tables until changed).

7. Performance considerations

Regular view: no storage, but every query executes underlying SQL — can be slow for expensive joins/aggregates.

Materialized view: much faster for queries that can use the precomputed result.

Use clustering keys and materialized views for high-cardinality aggregation patterns.

For heavy read workloads, test both strategies and measure query times and maintenance costs.

8. Versioning, definitions and auditing

GET_DDL('VIEW','schema.view') returns CREATE VIEW SQL.

SHOW GRANTS ON VIEW schema.view shows who can access.

SNOWFLAKE.ACCOUNT_USAGE.OBJECT_DEPENDENCIES and ACCESS_HISTORY help audit usage and who queried views.

9. Example patterns
View for masking / transformation (regular)
CREATE OR REPLACE VIEW analytics.customer_contact AS
SELECT customer_id,
       name,
       CASE WHEN CURRENT_ROLE() IN ('CUSTOMER_SUPPORT') THEN phone ELSE 'REDACTED' END AS phone
FROM raw.customers;


Good for simple security but not fully secure — a user with access to underlying table may still see raw data; use secure views or masking policies for stronger protection.

B — SECURE VIEWS
1. What is a Secure View?

SECURE VIEW is a view variant that provides security boundaries:

Consumers can run SELECT on the secure view without needing SELECT privileges on the underlying base tables. The view acts as a controlled access layer.

The view definition (the underlying SQL text) is protected: only the view owner (or higher roles) can see its query definition. This prevents consumers from seeing business logic or sensitive column expressions.

Secure views also prevent certain optimizations (like result cache visibility?) — their behavior is tuned to security needs (Snowflake docs: secure objects are more controlled regarding access and metadata exposure).

Main benefit: share curated data to roles/users without granting underlying object access.

2. Syntax & example
-- Create a secure view
CREATE OR REPLACE SECURE VIEW analytics.sec_customer_orders AS
SELECT
  c.customer_id,
  CASE WHEN CURRENT_ROLE() IN ('SALES_LEAD') THEN c.email ELSE 'REDACTED' END AS email,
  SUM(o.amount) AS total_spent
FROM raw.customers c
JOIN raw.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.email;


Behavioral points

When you GRANT SELECT ON VIEW analytics.sec_customer_orders TO ROLE analyst; the analyst can query the view without being granted SELECT on raw.customers or raw.orders.

The owner of the view must have the necessary privileges on underlying objects at creation time; the view runs with the owner's privileges (acts like an access proxy).

3. Grants for Secure View usage

To query secure view:

GRANT USAGE ON SCHEMA analytics TO ROLE analyst;
GRANT SELECT ON VIEW analytics.sec_customer_orders TO ROLE analyst;


Analyst does not need SELECT on raw.customers/raw.orders.

4. Visibility and metadata protection

GET_DDL('VIEW','analytics.sec_customer_orders') may be restricted; only owner or higher role can retrieve the exact SQL text.

SHOW VIEWS and DESCRIBE VIEW still list the view, but not necessarily full underlying logic for non-owner roles.

5. Secure Views vs Masking Policies vs Row Access Policies

Secure View: access boundary + hides SQL; good when you want to share curated results and hide logic and underlying tables.

Dynamic Data Masking (Masking Policy): applied to columns; masks data value depending on role at query time. Works at column level.

Row Access Policy: restricts rows visible based on role or attributes.

You can combine them: e.g., use a secure view that returns masked columns and enforces row access policies for strong access control.

Example combination:

CREATE MASKING POLICY mask_email AS (email string) RETURNS string ->
  CASE WHEN CURRENT_ROLE() IN ('DATA_PRIV') THEN email ELSE '***' END;

ALTER TABLE raw.customers MODIFY COLUMN email SET MASKING POLICY mask_email;

CREATE OR REPLACE SECURE VIEW analytics.sec_customer AS
SELECT customer_id, email FROM raw.customers;


Here, consumers of the secure view will see masked emails unless their role is allowed.

6. Performance & Transparent behavior

Secure views execute under the owner's privileges — this is how users without direct object privileges can still read the view.

Because access runs with owner privileges, audit logs (ACCESS_HISTORY) show which user/role executed the query and underlying access; monitor these carefully.

Secure views may disallow some optimizations or result sharing due to security constraints — test performance.

7. Materialized Secure Views?

Snowflake does not typically support creating materialized secure views (i.e., CREATE SECURE MATERIALIZED VIEW), at least historically; materialized views imply internal stored results and security handling differs. Check current Snowflake docs if needed in your environment. (If this is important for your exam or environment, verify with latest docs.)

8. Auditing & Monitoring

Use SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY to find who queried a view:

SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY
WHERE OBJECT_NAME = 'SEC_CUSTOMER_ORDERS'
  AND OBJECT_DOMAIN = 'VIEW'
ORDER BY ACCESS_TIME DESC;


Use SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY to see statements that accessed the view.

9. Errors & Debugging

If someone tries to SELECT the secure view and gets insufficient privileges, ensure:

USAGE on schema

SELECT on view granted

The view owner still has privileges on underlying objects (or the view was created correctly).

If a secure view suddenly fails after underlying table changes, check underlying object ownership/privileges and whether columns used in the view were dropped/renamed.

10. Admin Checklist & Best Practices (what an admin should know)

Use secure views for data products: share curated sensitive datasets without exposing base tables.

Least privilege: grant SELECT on the view — do not grant underlying table rights to consumers.

Combine with masking & row policies for defense in depth.

Ownership: maintain ownership discipline. If a view owner is dropped, reassign ownership using GRANT OWNERSHIP careful with COPY CURRENT GRANTS.

Audit view usage via ACCESS_HISTORY and QUERY_HISTORY.

Avoid embedding secrets in view definitions; secure views hide SQL text from consumers but still treat view definition as sensitive.

Document view schema & logic for maintainers; use private developer docs since consumers won’t see definition.

Test perf for secure views; compare to materialized views or transformations if repeated heavy reads are expected.

Use SHOW GRANTS ON VIEW to verify who has access.

11. Quick reference commands

Create view:

CREATE [OR REPLACE] [SECURE] VIEW schema.view_name AS <select>;


Drop view:

DROP VIEW IF EXISTS schema.view_name;


Create materialized view:

CREATE MATERIALIZED VIEW schema.mv_name AS <select>;


Describe:

DESCRIBE VIEW schema.view_name;


Show views:

SHOW VIEWS IN SCHEMA schema;


Grants:

GRANT USAGE ON SCHEMA schema TO ROLE r;
GRANT SELECT ON VIEW schema.view_name TO ROLE r;
SHOW GRANTS ON VIEW schema.view_name;
SHOW GRANTS TO ROLE r;


Get DDL:

SELECT GET_DDL('VIEW', 'schema.view_name');

12. Example end-to-end: secure view used for sharing sensitive data

Data owners create tables in secure_prod.raw.

Create masking policy and row policy.

Create secure view that applies masking and filters:

CREATE OR REPLACE SECURE VIEW secure_prod.sales_summary AS
SELECT
  c.customer_id,
  CASE WHEN CURRENT_ROLE() IN ('ANALYST_PRIV') THEN c.email ELSE '***' END AS email,
  SUM(o.amount) AS total_spent
FROM secure_prod.customers c
JOIN secure_prod.orders o ON c.customer_id = o.customer_id
WHERE o.order_date >= DATEADD(month, -12, CURRENT_DATE())
GROUP BY c.customer_id, c.email;


Grant SELECT on view to ANALYST role; do NOT grant SELECT on underlying tables.

Monitor usage and audit.

13. Common interview/real-world questions (prep)

How is a secure view different from a normal view?

When would you prefer materialized view vs secure view?

Can you grant SELECT on a secure view without granting SELECT on base tables? (Yes)

How do you audit who queried a secure view? (ACCESS_HISTORY)

What limitations exist for materialized views? (query restrictions, maintenance costs)

How to hide business logic from downstream consumers? (secure view + restrict GET_DDL)

Final short checklist for creating a secure sharing layer

Create role for owners & maintainers.

Implement masking & row policies as needed.

Create secure views encapsulating logic.

Grant SELECT on views to consumer roles only.

Monitor access & performance.