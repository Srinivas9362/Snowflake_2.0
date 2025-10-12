Step 3: SnowSQL Basics

SnowSQL is the CLI tool to interact with Snowflake.

Install SnowSQL:

# Windows
https://docs.snowflake.com/en/user-guide/snowsql-install-config.html


Connect to Snowflake via CLI:

snowsql -a <account_name> -u <username> -r <role_name> -w <warehouse_name>




Basic commands:

-- Show databases
SHOW DATABASES;

-- Create a database
CREATE DATABASE mydb;

-- Use a database
USE DATABASE mydb;

Step 4: Connect via Python

Install Snowflake Connector:

pip install snowflake-connector-python


Python Example:

import snowflake.connector

# Connect
conn = snowflake.connector.connect(
    user='your_user',
    password='your_password',
    account='your_account',
    warehouse='my_warehouse',
    database='mydb',
    schema='public'
)

# Query
cur = conn.cursor()
cur.execute("SELECT CURRENT_VERSION();")
print(cur.fetchone())

# Close
cur.close()
conn.close()