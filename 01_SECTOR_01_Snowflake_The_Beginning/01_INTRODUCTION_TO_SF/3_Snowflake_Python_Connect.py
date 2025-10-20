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


cur.execute("SHOW DATABASES;")
print(cur.fetchone())

# Close
cur.close()
conn.close()
