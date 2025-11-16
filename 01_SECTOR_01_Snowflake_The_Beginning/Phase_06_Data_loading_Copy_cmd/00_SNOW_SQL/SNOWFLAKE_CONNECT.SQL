--to connect to snowflkae from the snowsql
snowsql -u Srinivas9362 -a COIKTPX-FW70546

--TO PUT THE FILE TO USER_sTAGE (~)

Q: What is a Snowflake USER stage?
A Snowflake user stage (@~) is an internal storage area automatically created for each user.
It is private to the user and used to temporarily store files for loading/unloading operations.

Q: Why is it useful?
Because it avoids setup — perfect for quick tests, demos, and development.

Q: How do you upload files?
Using the PUT command:

PUT file://localpath @~;

PUT file://D:\Snowflake_Advance_Data_Engineering\01_SECTOR_01_Snowflake_The_Beginning\Phase_06_Data_loading_Copy_cmd\01_FILES\employees.csv @~ AUTO_COMPRESS=TRUE;

PUT file://D:\Snowflake_Advance_Data_Engineering\01_SECTOR_01_Snowflake_The_Beginning\Phase_06_Data_loading_Copy_cmd\01_FILES\emp_double_quotes.csv @my_csv_stage AUTO_COMPRESS=TRUE;


D:\Snowflake_Advance_Data_Engineering\01_SECTOR_01_Snowflake_The_Beginning\Phase_06_Data_loading_Copy_cmd\01_FILES\emp_double_quotes.csv

🎨 Difference Between USER STAGE vs TABLE STAGE
| Feature      | USER STAGE                           | TABLE STAGE                        |
| ------------ | ------------------------------------ | ---------------------------------- |
| Created for  | Each user                            | Each table                         |
| Syntax       | `@~`                                 | `@%table_name`                     |
| Best for     | User-specific testing, storing files | Loading/unloading a specific table |
| Shared among | Only one user                        | Users with table access            |
| When used    | Ad-hoc operations                    | Production ETL operations          |


📘 When Should You Use a Table Stage?

Use TABLE STAGE when:

✔ Data you are loading is meant ONLY for that table
✔ You want isolation between tables
✔ You want to unload table data securely
✔ You want to avoid managing external stages

Avoid TABLE STAGE when:

❌ You need multiple tables to access the same files
❌ You want a permanent location like S3 for long-term storage