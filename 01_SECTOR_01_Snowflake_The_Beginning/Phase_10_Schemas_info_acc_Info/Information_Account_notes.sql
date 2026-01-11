🔥 1) INFORMATION_SCHEMA — What it is

INFORMATION_SCHEMA is object-level metadata available within each database.

✔ Characteristics:

Scoped to the current database or schema, not entire account.

Always up-to-date / real-time metadata.

Contains DDL metadata like:

Tables, Views, Columns

Functions, Procedures

Stages, File Formats

Pipes, Tasks (but limited info)

Does NOT include historical usage, billing data, or long-term query history.

✔ Best for:

Checking object structure

Validating schemas

Monitoring real-time object existence

Querying column definitions

Checking privileges inside the database

🔥 2) ACCOUNT_USAGE — What it is

ACCOUNT_USAGE is a metadata layer provided by Snowflake at account level.

It contains historical + audit + usage information across the entire Snowflake account.

✔ Characteristics:

Cross-account data, not limited to one database.

Contains historical information:

Query history (365 days)

Login history

Pipe load history

Task history

Billing and credit usage

Storage usage

Warehouse usage

Has latency of ~45 minutes to 2 hours → NOT real-time.

Requires higher privileges:

MONITOR, ACCOUNTADMIN, or explicitly granted access.

✔ Best for:

Auditing

Billing & cost dashboards

Usage monitoring

Long-term operational history

Security analysis

Data engineering pipeline monitoring

🆚 3) Detailed Comparison Table

| Feature / Aspect            | **INFORMATION_SCHEMA**                                 | **ACCOUNT_USAGE (SNOWFLAKE.ACCOUNT_USAGE)**                 |
| --------------------------- | ------------------------------------------------------ | ----------------------------------------------------------- |
| **Location**                | Inside each database (e.g., `MYDB.INFORMATION_SCHEMA`) | Provided by Snowflake: `SNOWFLAKE.ACCOUNT_USAGE`            |
| **Scope**                   | Database-level or schema-level                         | Entire account (global scope)                               |
| **Latency**                 | **Real-time**                                          | **~45 min to 2-hour delay**                                 |
| **Historical Data**         | Very limited (mostly none)                             | Up to **365 days** of history (Queries, loads, tasks, etc.) |
| **Security / Permissions**  | Standard privileges                                    | Requires `ACCOUNTADMIN` or explicit grants                  |
| **Billing & Credits**       | ❌ Not available                                        | ✔ Available (`CREDIT_USAGE`, `WAREHOUSE_METERING_HISTORY`)  |
| **Query History**           | ❌ Not available                                        | ✔ Available (`QUERY_HISTORY`)                               |
| **Login History**           | ❌ Not available                                        | ✔ Available (`LOGIN_HISTORY`)                               |
| **Pipe / Snowpipe History** | Limited                                                | ✔ Detailed history (`PIPE_USAGE_HISTORY`)                   |
| **Task History**            | Limited                                                | ✔ Full history (`TASK_HISTORY`)                             |
| **Storage usage**           | ❌ Not available                                        | ✔ Available (`STORAGE_USAGE`)                               |
| **Warehouse Usage**         | ❌ Not available                                        | ✔ Available (`WAREHOUSE_METERING_HISTORY`)                  |
| **Object Metadata**         | ✔ Tables, columns, views, constraints                  | ✔ Some overlap but more operational info                    |
| **Pipeline Monitoring**     | Partially (pipe definitions only)                      | ✔ Complete ingestion history                                |
| **Latency Impact**          | Good for real-time dashboards                          | Not suitable for real-time, but best for audits             |
| **Use Case**                | **Schema exploration and design**                      | **Monitoring, billing, auditing, operations**               |
| **Performance Impact**      | Lighter                                                | Heavier (big data scans)                                    |


🎯 4) When to Use What? (Real-world Use Cases)
✔ Use INFORMATION_SCHEMA when:

| Use Case                                    | Why                |
| ------------------------------------------- | ------------------ |
| Validate column names, types                | Instant metadata   |
| Check objects list (tables, views, columns) | DB scoped and fast |
| Validate schema migration scripts           | No latency         |
| Check grants on objects in a schema         | Object-level only  |
| Real-time pipeline validations              | No delays          |

✔ Use ACCOUNT_USAGE when:
| Use Case                     | Why                                 |
| ---------------------------- | ----------------------------------- |
| Track credit consumption     | Includes credit tables              |
| Build usage dashboards       | Full account visibility             |
| Monitor Snowpipe loads       | `PIPE_USAGE_HISTORY`                |
| Audit data engineer activity | Query history, login history        |
| Cost optimization            | Warehouse metering history          |
| Security audits              | Role grants, logins, access history |

SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE USER_NAME = 'SRINIVAS'
ORDER BY START_TIME DESC;


SELECT QUERY_TEXT, USER_NAME, START_TIME
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE QUERY_TEXT ILIKE '%CUSTOMERS%'
AND START_TIME >= DATEADD(month, -1, CURRENT_TIMESTAMP);
