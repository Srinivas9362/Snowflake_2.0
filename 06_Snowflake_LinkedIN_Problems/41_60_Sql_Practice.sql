-- Find all posts which were reacted to with a heart. For such posts output all columns from facebook_posts table.

CREATE TABLE facebook_reactions (poster INT, friend INT, reaction VARCHAR(50), date_day INT, post_id INT);

INSERT INTO facebook_reactions (poster, friend, reaction, date_day, post_id) VALUES  (1, 2, 'heart', 20240101, 101), (2, 3, 'heart', 20240102, 102), (3, 4, 'like', 20240103, 103), (4, 5, 'heart', 20240104, 104), (5, 6, 'laugh', 20240105, 105), (6, 7, 'heart', 20240106, 106);

CREATE TABLE facebook_posts (post_id INT PRIMARY KEY, poster INT, post_text VARCHAR(500), post_keywords VARCHAR(200), post_date DATETIME);

INSERT INTO facebook_posts (post_id, poster, post_text, post_keywords, post_date) VALUES (101, 1, 'Had a great day at the park!', 'park, fun', '2024-01-01 08:00:00'), (102, 2, 'Enjoying the new book I bought.', 'book, reading', '2024-01-02 09:00:00'), (103, 3, 'Looking forward to the weekend!', 'weekend, plans', '2024-01-03 10:00:00'), (104, 4, 'Just finished a workout session!', 'workout, fitness', '2024-01-04 11:00:00'), (105, 5, 'Great movie night with friends!', 'movie, friends', '2024-01-05 12:00:00'), (106, 6, 'Cooking dinner at home tonight.', 'cooking, food', '2024-01-06 13:00:00');

SELECT * FROM facebook_reactions;

SELECT * FROM facebook_posts;

SELECT P.* FROM 
facebook_posts P
JOIN facebook_reactions R
ON P.POST_ID = R.POST_ID
WHERE R.REACTION = 'heart';


--42
-- Write a query that returns the company (customer id column) with highest number of users that use desktop only.

CREATE TABLE fact_events_01 (id INT PRIMARY KEY, time_id DATETIME, user_id VARCHAR(50), customer_id VARCHAR(50), client_id VARCHAR(50), event_type VARCHAR(50), event_id INT);

INSERT INTO fact_events_01 (id, time_id, user_id, customer_id, client_id, event_type, event_id) VALUES  (1, '2024-12-01 10:00:00', 'U1', 'C1', 'desktop', 'click', 101), (2, '2024-12-01 11:00:00', 'U2', 'C1', 'mobile', 'view', 102), (3, '2024-12-01 12:00:00', 'U3', 'C2', 'desktop', 'click', 103), (4, '2024-12-01 13:00:00', 'U1', 'C1', 'desktop', 'click', 104), (5, '2024-12-01 14:00:00', 'U2', 'C1', 'tablet', 'view', 105), (6, '2024-12-01 15:00:00', 'U4', 'C3', 'desktop', 'click', 106), (7, '2024-12-01 16:00:00', 'U3', 'C2', 'desktop', 'click', 107), (8, '2024-12-01 17:00:00', 'U5', 'C4', 'desktop', 'click', 108), (9, '2024-12-01 18:00:00', 'U6', 'C4', 'mobile', 'view', 109), (10, '2024-12-01 19:00:00', 'U7', 'C5', 'desktop', 'click', 110);



WITH DesktopOnlyUsers AS (
    SELECT 
        user_id,
        customer_id
    FROM fact_events_01
    GROUP BY 
        user_id, 
        customer_id
    HAVING 
        COUNT(DISTINCT client_id) = 1
        AND MIN(client_id) = 'desktop'
)
SELECT top 1
    customer_id,
    COUNT(DISTINCT user_id) AS desktop_only_user_count
FROM DesktopOnlyUsers
GROUP BY customer_id
ORDER BY desktop_only_user_count DESC;
LIMIT 1;


SELECT CURRENT_LOCATION();

-- Step 1: Create a test table
CREATE OR REPLACE TABLE sample_data (
    id INT,
    name STRING,
    comment STRING,
    notes STRING
);

-- Step 2: Insert sample data with nulls, empty strings, quotes, and pipes
INSERT INTO sample_data VALUES
(1, 'Alice', 'Hello, world', NULL),
(2, '', 'Empty string example', 'Some note'),
(3, NULL, 'This has null in name', ''),
(4, 'Bob "The Builder"', 'He said "Hi"', 'Uses | pipe symbol'),
(5, 'Charlie', NULL, NULL);

-- Step 3: Create an internal stage
CREATE OR REPLACE STAGE my_internal_stage;



-- Step 4: Unload data from the table into the stage as a CSV file
COPY INTO @my_internal_stage/sample_data.csv
FROM sample_data
FILE_FORMAT = (
  TYPE = CSV,
  FIELD_DELIMITER = '|',
  -- FIELD_OPTIONALLY_ENCLOSED_BY = '"',
  ESCAPE_UNENCLOSED_FIELD = '\\',
  NULL_IF = ('NULL'),
  EMPTY_FIELD_AS_NULL = FALSE
);

-- Step 5: Verify the file was created
LIST @my_internal_stage;

-- my_internal_stage/sample_data.csv_0_0_0.csv.gz

-- Step 6 (Optional): Preview how Snowflake wrote the data
SELECT 
  $1 AS id, 
  $2 AS name, 
  $3 AS comment, 
  $4 AS notes
FROM @my_internal_stage/sample_data.csv_0_0_0.csv.gz
(FILE_FORMAT => (
  TYPE = 'CSV', 
  FIELD_DELIMITER = '|'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  ESCAPE_UNENCLOSED_FIELD = '\\'
NULL_IF = ('NULL')
EMPTY_FIELD_AS_NULL = FALSE;
  
));
----

CREATE OR REPLACE FILE FORMAT my_csv_format
TYPE = 'CSV'
FIELD_DELIMITER = '|'
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
ESCAPE_UNENCLOSED_FIELD = '\\'
NULL_IF = ('NULL')
EMPTY_FIELD_AS_NULL = FALSE;


SELECT 
  $1 AS id, 
  $2 AS name, 
  $3 AS comment, 
  $4 AS notes
FROM @my_internal_stage/sample_data.csv_0_0_0.csv.gz
(FILE_FORMAT => my_csv_format);

-- Find the number of Apple product users and the number of total users with a device and group the counts by language. Assume Apple products are only MacBook-Pro, iPhone 5s, and iPad-air. Output the language along with the total number of Apple users and users with any device. Order your results based on the number of total users in descending order.


CREATE TABLE playbook_users (user_id INT PRIMARY KEY,created_at DATETIME,company_id INT,language VARCHAR(50),activated_at DATETIME,state VARCHAR(50));

INSERT INTO playbook_users (user_id, created_at, company_id, language, activated_at, state) VALUES
(1, '2024-01-01 08:00:00', 101, 'English', '2024-01-05 10:00:00', 'Active'),
(2, '2024-01-02 09:00:00', 102, 'Spanish', '2024-01-06 11:00:00', 'Inactive'),
(3, '2024-01-03 10:00:00', 103, 'French', '2024-01-07 12:00:00', 'Active'),
(4, '2024-01-04 11:00:00', 104, 'English', '2024-01-08 13:00:00', 'Active'),
(5, '2024-01-05 12:00:00', 105, 'Spanish', '2024-01-09 14:00:00', 'Inactive');

CREATE TABLE playbook_events ( user_id INT, occurred_at DATETIME, event_type VARCHAR(50), event_name VARCHAR(50), location VARCHAR(100), device VARCHAR(50));

INSERT INTO playbook_events (user_id, occurred_at, event_type, event_name, location, device) VALUES
(1, '2024-01-05 14:00:00', 'Click', 'Login', 'USA', 'MacBook-Pro'),
(2, '2024-01-06 15:00:00', 'View', 'Dashboard', 'Spain', 'iPhone 5s'),
(3, '2024-01-07 16:00:00', 'Click', 'Logout', 'France', 'iPad-air'),
(4, '2024-01-08 17:00:00', 'Purchase', 'Subscription', 'USA', 'Windows-Laptop'), (5, '2024-01-09 18:00:00', 'Click', 'Login', 'Spain', 'Android-Phone');



WITH APPLE_USER_CTE AS (
SELECT  U.LANGUAGE,U.USER_ID,
CASE 
WHEN E.DEVICE IN ('MacBook-Pro', 'iPhone 5s', 'iPad-air') THEN 1 
ELSE 0
END AS is_apple_user
FROM playbook_users U
JOIN playbook_events E
ON U.USER_ID = E.USER_ID)
SELECT LANGUAGE,
COUNT(DISTINCT CASE WHEN IS_APPLE_USER = 1 THEN USER_ID END) AS apple_users_count,
COUNT(DISTINCT USER_ID) total_users_with_device
FROM APPLE_USER_CTE
GROUP BY language
ORDER BY total_users_with_device DESC;


--47
-- Produce a table consisting of three columns: left_page_number, left_title and right_title. The k-th row (counting from 0), should contain the number and the title of the page with the number 2×k in the first and second columns respectively, and the title of the page with the number 2×k+1 in the third column.

-- Each page contains at most 1 recipe. If the page does not contain a recipe, the appropriate cell should remain empty (NULL value). Page 0 (the internal side of the front cover) is guaranteed to be empty.

CREATE TABLE cookbook_titles (page_number INT PRIMARY KEY,title VARCHAR(255));

INSERT INTO cookbook_titles (page_number, title) VALUES (1, 'Scrambled eggs'), (2, 'Fondue'), (3, 'Sandwich'), (4, 'Tomato soup'), (6, 'Liver'), (11, 'Fried duck'), (12, 'Boiled duck'), (15, 'Baked chicken');


select l.page_number as left_page_number,
l.title as left_title,
r.title as right_title
from
(select page_number, title FROM cookbook_titles WHERE page_number % 2 = 0
union all select 0, null) l
left join cookbook_titles r
on  r.page_number = l.page_number+1
order by l.page_number; 


----

-- Identify the top 3 areas with the highest customer density. Customer density = (total number of unique customers in the area / area size).
-- Your output should include the area name and its calculated customer density.


CREATE TABLE transaction_records (customer_id BIGINT, store_id BIGINT, transaction_amount BIGINT, transaction_date DATETIME, transaction_id BIGINT PRIMARY KEY);

INSERT INTO transaction_records (customer_id, store_id, transaction_amount, transaction_date, transaction_id) VALUES (101, 1, 500, '2024-01-01 10:15:00', 10001), (102, 2, 1500, '2024-01-02 12:30:00', 10002), (103, 1, 700, '2024-01-03 14:00:00', 10003), (104, 3, 1200, '2024-01-04 09:45:00', 10004), (105, 2, 800, '2024-01-05 11:20:00', 10005);

CREATE TABLE stores (area_name VARCHAR(20), area_size BIGINT, store_id BIGINT PRIMARY KEY, store_location TEXT, store_open_date DATETIME);

INSERT INTO stores (area_name, area_size, store_id, store_location, store_open_date) VALUES ('Downtown', 1000, 1, 'Main Street', '2020-01-01'), ('Uptown', 1500, 2, 'Park Avenue', '2021-06-15'), ('Midtown', 1200, 3, 'Broadway', '2019-11-20'), ('Suburbs', 2000, 4, 'Elm Street', '2018-08-10');


SELECT  TOP 3 
S.AREA_NAME, 
COUNT(DISTINCT T.CUSTOMER_ID)/S.AREA_SIZE AS TOTAL_CUST_DENSITY
FROM  STORES S
JOIN transaction_records T
ON T.STORE_ID = S.STORE_ID
GROUP BY S.AREA_NAME,S.AREA_SIZE
ORDER BY TOTAL_CUST_DENSITY DESC;


--46
-- In a marathon, gun time is counted from the moment of the formal start of the race while net time is counted from the moment a runner crosses a starting line. Both variables are in seconds.

-- You are asked to check if the interval between the two times is different for male and female runners. First, calculate the average absolute difference between the gun time and net time. Group the results by available genders (male and female). Output the absolute difference between those two values.


CREATE TABLE marathon_male (age BIGINT, div_tot TEXT, gun_time BIGINT, hometown TEXT, net_time BIGINT, num BIGINT, pace BIGINT, person_name TEXT, place BIGINT);

INSERT INTO marathon_male (age, div_tot, gun_time, hometown, net_time, num, pace, person_name, place) VALUES (25, '1/100', 3600, 'New York', 3400, 101, 500, 'John Doe', 1), (30, '2/100', 4000, 'Boston', 3850, 102, 550, 'Michael Smith', 2), (22, '3/100', 4200, 'Chicago', 4150, 103, 600, 'David Johnson', 3);

CREATE TABLE marathon_female (age BIGINT, div_tot TEXT, gun_time BIGINT, hometown TEXT, net_time BIGINT, num BIGINT, pace BIGINT, person_name TEXT, place BIGINT);

INSERT INTO marathon_female (age, div_tot, gun_time, hometown, net_time, num, pace, person_name, place) VALUES (28, '1/100', 3650, 'San Francisco', 3600, 201, 510, 'Jane Doe', 1), (26, '2/100', 3900, 'Los Angeles', 3850, 202, 530, 'Emily Davis', 2), (24, '3/100', 4100, 'Seattle', 4050, 203, 590, 'Anna Brown', 3);

SELECT * FROM marathon_male;

SELECT * FROM marathon_female;


WITH ABS_CTE AS(
SELECT 
'MALE' AS GENDER,
AVG(ABS(GUN_TIME - NET_TIME)) AS AVG_TIME_DIFF
FROM marathon_male
UNION ALL
SELECT 
'FEMALE' AS GENDER,
AVG(ABS(GUN_TIME - NET_TIME)) AS AVG_TIME_DIFF
FROM marathon_female)
SELECT 
ABS(
1000(CASE WHEN GENDER = 'MALE' THEN AVG_TIME_DIFF END)-
1000(CASE WHEN GENDER = 'FEMALE' THEN AVG_TIME_DIFF END) )
 AS ABS_DIFF
FROM ABS_CTE
;

SELECT 
 ABS(
 (SELECT AVG(ABS(gun_time - net_time)) FROM marathon_female)-
 (SELECT  AVG(ABS(gun_time - net_time)) FROM marathon_male) 
 ) AS absolute_diff;


 --47
-- Find the top two hotels with the most negative reviews.
-- Output the hotel name along with the corresponding number of negative reviews. Negative reviews are all the reviews with text under negative review different than "No Negative". Sort records based on the number of negative reviews in descending order.

 
CREATE TABLE hotel_reviews_01 
(additional_number_of_scoring BIGINT, 
average_score FLOAT, 
days_since_review VARCHAR(255), 
hotel_address VARCHAR(255), hotel_name VARCHAR(255), lat FLOAT, lng FLOAT, negative_review VARCHAR(1000), positive_review VARCHAR(1000), review_date DATETIME, review_total_negative_word_counts BIGINT, review_total_positive_word_counts BIGINT, reviewer_nationality VARCHAR(255), reviewer_score FLOAT, tags VARCHAR(1000), total_number_of_reviews BIGINT, total_number_of_reviews_reviewer_has_given BIGINT);

INSERT INTO hotel_reviews_01 VALUES
(25, 8.7, '15 days ago', '123 Street, City A', 'Hotel Alpha', 12.3456, 98.7654, 'Too noisy at night', 'Great staff and clean rooms', '2024-12-01', 5, 15, 'USA', 8.5, '["Couple"]', 200, 10), (30, 9.1, '20 days ago', '456 Avenue, City B', 'Hotel Beta', 34.5678, 76.5432, 'Old furniture', 'Excellent location', '2024-12-02', 4, 12, 'UK', 9.0, '["Solo traveler"]', 150, 8), (12, 8.3, '10 days ago', '789 Boulevard, City C', 'Hotel Gamma', 23.4567, 67.8901, 'No Negative', 'Friendly staff', '2024-12-03', 0, 10, 'India', 8.3, '["Family"]', 100, 5), (15, 8.0, '5 days ago', '321 Lane, City D', 'Hotel Delta', 45.6789, 54.3210, 'Uncomfortable bed', 'Affordable price', '2024-12-04', 6, 8, 'Germany', 7.8, '["Couple"]', 120, 7),
(20, 7.9, '8 days ago', '654 Road, City E', 'Hotel Alpha', 67.8901, 12.3456, 'Poor room service', 'Good breakfast', '2024-12-05', 7, 9, 'France', 7.5, '["Solo traveler"]', 180, 6), (18, 9.3, '18 days ago', '987 Highway, City F', 'Hotel Beta', 34.5678, 76.5432, 'No Negative', 'Amazing facilities', '2024-12-06', 0, 20, 'USA', 9.2, '["Couple"]', 250, 15);


SELECT * FROM hotel_reviews_01;

SELECT TOP 2
HOTEL_NAME, COUNT(*) AS TOTAL_COUNT
FROM hotel_reviews_01
WHERE NEGATIVE_REVIEW != 'No Negative'
group by hotel_name
order by TOTAL_COUNT desc;



--48
-- Find all employees who have or had a job title that includes manager.
-- Output the first name along with the corresponding title.

CREATE TABLE workers (department VARCHAR(100), first_name VARCHAR(50), joining_date DATE, last_name VARCHAR(50), salary BIGINT, worker_id BIGINT PRIMARY KEY);

INSERT INTO workers (department, first_name, joining_date, last_name, salary, worker_id) VALUES  ('HR', 'Alice', '2020-01-15', 'Smith', 60000, 1), ('Engineering', 'Bob', '2019-03-10', 'Johnson', 80000, 2), ('Sales', 'Charlie', '2021-07-01', 'Brown', 50000, 3), ('Engineering', 'David', '2018-12-20', 'Wilson', 90000, 4), ('Marketing', 'Emma', '2020-06-30', 'Taylor', 70000, 5);

CREATE TABLE titles ( affected_from DATE, worker_ref_id BIGINT, worker_title VARCHAR(100), FOREIGN KEY (worker_ref_id) REFERENCES workers(worker_id));

INSERT INTO titles (affected_from, worker_ref_id, worker_title) VALUES  ('2020-01-15', 1, 'HR Manager'), ('2019-03-10', 2, 'Software Engineer'), ('2021-07-01', 3, 'Sales Representative'), ('2018-12-20', 4, 'Engineering Manager'), ('2020-06-30', 5, 'Marketing Specialist'), ('2022-01-01', 5, 'Marketing Manager');


SELECT * FROM WORKERS;
SELECT * FROM titles;

SELECT W.FIRST_NAME, T.WORKER_TITLE
FROM WORKERS W
JOIN titles T
ON W.WORKER_ID = T.worker_ref_id 
where lower(T.WORKER_TITLE) LIKE '%manager%';


--49
-- You work for a multinational company that wants to calculate total sales across all their countries they do business in
-- You have 2 tables, one is a record of sales for all countries and currencies the company deals with, and the other holds currency exchange rate information. Calculate the total sales, per quarter, for the first 2 quarters in 2020, and report the sales in USD currency.



CREATE TABLE sf_exchange_rate ( date DATE, exchange_rate FLOAT, source_currency VARCHAR(10), target_currency VARCHAR(10));

INSERT INTO sf_exchange_rate (date, exchange_rate, source_currency, target_currency) VALUES ('2020-01-15', 1.1, 'EUR', 'USD'), ('2020-01-15', 1.3, 'GBP', 'USD'), ('2020-02-05', 1.2, 'EUR', 'USD'), ('2020-02-05', 1.35, 'GBP', 'USD'), ('2020-03-25', 1.15, 'EUR', 'USD'), ('2020-03-25', 1.4, 'GBP', 'USD'), ('2020-04-15', 1.2, 'EUR', 'USD'), ('2020-04-15', 1.45, 'GBP', 'USD'), ('2020-05-10', 1.1, 'EUR', 'USD'), ('2020-05-10', 1.3, 'GBP', 'USD'), ('2020-06-05', 1.05, 'EUR', 'USD'), ('2020-06-05', 1.25, 'GBP', 'USD');

CREATE TABLE sf_sales_amount ( currency VARCHAR(10), sales_amount BIGINT, sales_date DATE);

INSERT INTO sf_sales_amount (currency, sales_amount, sales_date) VALUES ('USD', 1000, '2020-01-15'), ('EUR', 2000, '2020-01-20'), ('GBP', 1500, '2020-02-05'), ('USD', 2500, '2020-02-10'), ('EUR', 1800, '2020-03-25'), ('GBP', 2200, '2020-03-30'), ('USD', 3000, '2020-04-15'), ('EUR', 1700, '2020-04-20'), ('GBP', 2000, '2020-05-10'), ('USD', 3500, '2020-05-25'), ('EUR', 1900, '2020-06-05'), ('GBP', 2100, '2020-06-10');

select * from sf_exchange_rate;

SELECT 
DATE_PART(QUARTER, S.SALES_DATE ) AS SALES_QUARTER,
SUM(E.EXCHANGE_RATE * S.SALES_AMOUNT) AS TOTAL_SALES_USD
FROM sf_exchange_rate E
JOIN sf_sales_amount S 
ON S.CURRENCY = E.SOURCE_CURRENCY
AND E.TARGET_CURRENCY = 'USD'
AND E.DATE = S.SALES_DATE
WHERE S.SALES_DATE >= '2020-01-01' AND S.SALES_DATE < '2020-07-01'
GROUP BY DATE_PART(QUARTER, S.SALES_DATE ) ;


--50
-- Market penetration is an important metric for Spotify's growth in different regions. As part of the analytics team, calculate the active user penetration rate in specific countries. Active Users must meet these criteria:
-- Interacted with Spotify within the last 30 days (last_active_date >= 2024-01-01). At least 5 sessions. At least 10 listening hours.

-- Formula: Active User Penetration Rate = (Number of Active Spotify Users in the Country / Total Users in the Country)
-- Output: country, active_user_penetration_rate (rounded to 2 decimals).

CREATE TABLE penetration_analysis ( country VARCHAR(20), last_active_date DATETIME, listening_hours BIGINT, sessions BIGINT, user_id BIGINT);

INSERT INTO penetration_analysis (country, last_active_date, listening_hours, sessions, user_id) VALUES ('USA', '2024-01-25', 15, 7, 101), ('USA', '2023-12-20', 5, 3, 102), ('USA', '2024-01-20', 25, 10, 103), ('India', '2024-01-28', 12, 6, 201), ('India', '2023-12-15', 8, 4, 202), ('India', '2024-01-15', 20, 7, 203), ('UK', '2024-01-29', 18, 9, 301), ('UK', '2023-12-30', 9, 4, 302), ('UK', '2024-01-22', 30, 12, 303), ('Canada', '2024-01-01', 11, 6, 401), ('Canada', '2023-11-15', 3, 2, 402), ('Canada', '2024-01-15', 22, 8, 403), ('Germany', '2024-01-10', 14, 7, 501), ('Germany', '2024-01-30', 10, 5, 502), ('Germany', '2024-01-01', 5, 3, 503);


SELECT * FROM penetration_analysis;

WITH USER_ACTIVITY AS(
SELECT COUNTRY, USER_ID,
SUM(LISTENING_HOURS) AS TOTAL_LISTENING_HRS,
SUM(SESSIONS) AS TOTAL_SESSIONS,
MAX(LAST_ACTIVE_DATE) AS LAST_ACTIVE_DATE
FROM penetration_analysis
GROUP BY COUNTRY, USER_ID),
user_flags AS (
SELECT COUNTRY, USER_ID,
CASE WHEN LAST_ACTIVE_DATE >= DATEADD(DAY,-30,'2024-01-31')
AND TOTAL_SESSIONS >= 5 AND TOTAL_LISTENING_HRS >= 10 THEN 1 ELSE 0 END AS ACTIVE_USER
FROM USER_ACTIVITY)
SELECT COUNTRY,
ROUND(SUM(ACTIVE_USER)*100 / COUNT(*),2) AS active_user_penetration_rate
FROM user_flags
GROUP BY COUNTRY
;






SELECT DISTINCT
 country,
 ROUND(
 CAST(
 SUM(CASE 
 WHEN last_active_date >= DATEADD(DAY, -30, '2024-01-31')
 AND sessions >= 5
 AND listening_hours >= 10
 THEN 1 
 ELSE 0 
 END
 ) OVER (PARTITION BY country) AS FLOAT
 ) / COUNT(*) OVER (PARTITION BY country) * 100, 2
 ) AS active_user_penetration_rate
FROM 
 penetration_analysis;


 



WITH user_activity AS (
SELECT 
country,
user_id,
SUM(listening_hours) AS total_listening_hours,
SUM(sessions) AS total_sessions,
MAX(last_active_date) AS last_active_date
FROM penetration_analysis
GROUP BY country, user_id
),
user_flags AS (
    SELECT
        country,
        user_id,
        CASE 
            WHEN last_active_date >= DATEADD(DAY, -30, '2024-01-31')
                 AND total_sessions >= 5
                 AND total_listening_hours >= 10
            THEN 1 ELSE 0
        END AS is_active
    FROM user_activity
)

select * from user_flags;
SELECT
    country,
    ROUND(
        (SUM(is_active) * 100.0) / COUNT(*), 
        2
    ) AS active_user_penetration_rate
FROM user_flags
GROUP BY country
ORDER BY country;

--51
-- You have been asked to find the fifth highest salary without using TOP or LIMIT. Note: Duplicate salaries should not be removed.

CREATE TABLE com_worker ( worker_id BIGINT PRIMARY KEY, department VARCHAR(25), first_name VARCHAR(25), last_name VARCHAR(25), joining_date DATETIME, salary BIGINT);

INSERT INTO com_worker (worker_id, department, first_name, last_name, joining_date, salary) VALUES  (1, 'HR', 'John', 'Doe', '2020-01-15', 50000), (2, 'IT', 'Jane', 'Smith', '2019-03-10', 60000), (3, 'Finance', 'Emily', 'Jones', '2021-06-20', 75000), (4, 'Sales', 'Michael', 'Brown', '2018-09-05', 60000), (5, 'Marketing', 'Chris', 'Johnson', '2022-04-12', 70000), (6, 'IT', 'David', 'Wilson', '2020-11-01', 80000), (7, 'Finance', 'Sarah', 'Taylor', '2017-05-25', 45000), (8, 'HR', 'James', 'Anderson', '2023-01-09', 65000), (9, 'Sales', 'Anna', 'Thomas', '2020-02-18', 55000), (10, 'Marketing', 'Robert', 'Jackson', '2021-07-14', 60000);




SELECT * FROM com_worker;

SELECT DISTINCT SALARY FROM(
SELECT  SALARY, DENSE_RANK() OVER ( ORDER BY SALARY DESC)
AS RANKS
FROM com_worker) WHERE RANKS=5;

WITH cte AS (SELECT salary,DENSE_RANK() OVER(ORDER BY salary DESC) AS rank
FROM com_worker)
SELECT DISTINCT salary
FROM cte 
WHERE rank=5;

SELECT salary
FROM (
    SELECT 
        salary,
        DENSE_RANK() OVER (ORDER BY salary DESC) AS salary_rank
    FROM com_worker
)
WHERE salary_rank = 5;


--52
-- The company you are working for wants to anticipate their staffing needs by identifying their top two busiest times of the week. To find this, each day should be segmented into differents parts using following criteria:

-- Morning: Before 12 p.m. (not inclusive)
-- Early afternoon: 12 -15 p.m.
-- Late afternoon: after 15 p.m. (not inclusive)

-- Your output should include the day and time of day combination for the two busiest times, i.e. the combinations with the most orders, along with the number of orders (e.g. top two results could be Friday Late afternoon with 12 orders and Sunday Morning with 10 orders). The company has also requested that the day be displayed in text format (i.e. Monday).



CREATE TABLE sales_log (order_id BIGINT PRIMARY KEY,product_id BIGINT,timestamp DATETIME);

INSERT INTO sales_log (order_id, product_id, timestamp) VALUES  (1, 101, '2024-12-15 09:30:00'), (2, 102, '2024-12-15 11:45:00'), (3, 103, '2024-12-15 12:10:00'), (4, 104, '2024-12-15 13:15:00'), (5, 105, '2024-12-15 14:20:00'), (6, 106, '2024-12-15 15:30:00'), (7, 107, '2024-12-15 16:40:00'), (8, 108, '2024-12-16 09:50:00'), (9, 109, '2024-12-16 10:30:00'), (10, 110, '2024-12-16 12:05:00'), (11, 111, '2024-12-16 13:50:00'), (12, 112, '2024-12-16 14:15:00'), (13, 113, '2024-12-16 15:30:00'), (14, 114, '2024-12-17 09:45:00'), (15, 115, '2024-12-17 11:20:00'), (16, 116, '2024-12-17 12:25:00'), (17, 117, '2024-12-17 13:30:00'), (18, 118, '2024-12-17 14:55:00'), (19, 119, '2024-12-17 15:10:00'), (20, 120, '2024-12-18 10:40:00');




WITH DAY_TIME_CTE AS(
SELECT ORDER_ID, PRODUCT_ID, TIMESTAMP, DAYNAME(TIMESTAMP)  AS WEEK_DAY,
CASE 
WHEN DATE_PART('HOUR', TIMESTAMP) < 12  THEN 'Morning'
WHEN DATE_PART('HOUR', TIMESTAMP) < 15 THEN 'Early Afternoon'
else 'Late afternoon' end as BUSSINESS_TIME
FROM sales_log),
TOTAL_ORDS_CTE AS(
SELECT WEEK_DAY, BUSSINESS_TIME, COUNT(ORDER_ID) AS TOTAL_ORDERS
FROM DAY_TIME_CTE
GROUP BY WEEK_DAY, BUSSINESS_TIME
)
,RANK_CTE AS
(SELECT *, ROW_NUMBER() OVER( ORDER BY TOTAL_ORDERS DESC) AS CNT_RANK
FROM TOTAL_ORDS_CTE)
SELECT WEEK_DAY, BUSSINESS_TIME, TOTAL_ORDERS
FROM RANK_CTE WHERE CNT_RANK <=2;




--53
-- Calculate the average net earnings per order grouped by weekday (in text format, e.g., Monday) and hour from customer_placed_order_datetime. The net earnings are computed as: order_total + tip_amount - discount_amount - refunded_amount. Round the result to 2 decimals.

CREATE TABLE doordash_delivery (consumer_id BIGINT, customer_placed_order_datetime DATETIME, delivered_to_consumer_datetime DATETIME, delivery_region NVARCHAR(255), discount_amount BIGINT, driver_at_restaurant_datetime DATETIME, driver_id INT, is_asap INT, is_new INT, order_total FLOAT,  placed_order_with_restaurant_datetime DATETIME, refunded_amount FLOAT, restaurant_id BIGINT, tip_amount FLOAT);

INSERT INTO doordash_delivery (consumer_id, customer_placed_order_datetime, delivered_to_consumer_datetime, delivery_region, discount_amount, driver_at_restaurant_datetime, driver_id, is_asap, is_new, order_total, placed_order_with_restaurant_datetime, refunded_amount, restaurant_id, tip_amount)
VALUES (1, '2024-01-15 10:30:00', '2024-01-15 11:00:00', 'Region A', 5, '2024-01-15 10:40:00', 101, 1, 1, 50.00, '2024-01-15 10:25:00', 0, 201, 5.00), (2, '2024-01-15 12:15:00', '2024-01-15 12:45:00', 'Region B', 10, '2024-01-15 12:20:00', 102, 1, 0, 40.00, '2024-01-15 12:10:00', 5.00, 202, 3.00), (3, '2024-01-16 08:45:00', '2024-01-16 09:15:00', 'Region C', 0, '2024-01-16 08:50:00', 103, 0, 1, 30.00, '2024-01-16 08:40:00', 0, 203, 2.00), (4, '2024-01-16 19:20:00', '2024-01-16 19:50:00', 'Region D', 8, '2024-01-16 19:30:00', 104, 1, 0, 60.00, '2024-01-16 19:15:00', 0, 204, 4.00), (5, '2024-01-17 15:10:00', '2024-01-17 15:40:00', 'Region E', 12, '2024-01-17 15:20:00', 105, 1, 0, 70.00, '2024-01-17 15:05:00', 0, 205, 6.00), (6, '2024-01-17 11:30:00', '2024-01-17 12:00:00', 'Region F', 3, '2024-01-17 11:40:00', 106, 0, 1, 45.00, '2024-01-17 11:25:00', 5.00, 206, 2.00), (7, '2024-01-18 21:15:00', '2024-01-18 21:45:00', 'Region G', 6, '2024-01-18 21:20:00', 107, 1, 0, 55.00, '2024-01-18 21:10:00', 0, 207, 3.50), (8, '2024-01-19 14:45:00', '2024-01-19 15:15:00', 'Region H', 0, '2024-01-19 14:50:00', 108, 1, 1, 35.00, '2024-01-19 14:40:00', 0, 208, 2.50), (9, '2024-01-20 13:30:00', '2024-01-20 14:00:00', 'Region I', 7, '2024-01-20 13:40:00', 109, 1, 0, 65.00, '2024-01-20 13:25:00', 0, 209, 4.00), (10, '2024-01-21 09:20:00', '2024-01-21 09:50:00', 'Region J', 15, '2024-01-21 09:30:00', 110, 0, 0, 80.00, '2024-01-21 09:15:00', 0, 210, 10.00);



SELECT * FROM doordash_delivery;


SELECT DAYNAME(DELIVERED_TO_CONSUMER_DATETIME) AS DAY_NAME,
HOUR(CUSTOMER_PLACED_ORDER_DATETIME) AS ORDER_HOUR,
ROUND(AVG(order_total + tip_amount - discount_amount - refunded_amount),2) AS AVG_NET_EARNINGS
FROM doordash_delivery
GROUP BY DAYNAME(DELIVERED_TO_CONSUMER_DATETIME), HOUR(CUSTOMER_PLACED_ORDER_DATETIME) 
ORDER BY DAY_NAME,ORDER_HOUR ;



--54
-- The sales department has given you the sales figures for the first two months of 2023. You've been tasked with determining the percentage of weekly sales on the first and last day of every week. Consider Sunday as last day of week and Monday as first day of week.

-- In your output, include the week number, percentage sales for the first day of the week, and percentage sales for the last day of the week. Both proportions should be rounded to the nearest whole number.


CREATE TABLE early_sales ( invoicedate DATETIME, invoiceno BIGINT, quantity BIGINT, stockcode NVARCHAR(50), unitprice FLOAT);

INSERT INTO early_sales (invoicedate, invoiceno, quantity, stockcode, unitprice) VALUES ('2023-01-01 10:00:00', 1001, 5, 'A001', 20.0), ('2023-01-01 15:30:00', 1002, 3, 'A002', 30.0), ('2023-01-02 09:00:00', 1003, 10, 'A003', 15.0), ('2023-01-02 11:00:00', 1004, 2, 'A004', 50.0), ('2023-01-08 10:30:00', 1005, 4, 'A005', 25.0), ('2023-01-08 14:45:00', 1006, 7, 'A006', 18.0), ('2023-01-15 08:00:00', 1007, 6, 'A007', 22.0), ('2023-01-15 16:00:00', 1008, 8, 'A008', 12.0), ('2023-01-22 09:30:00', 1009, 3, 'A009', 40.0), ('2023-01-22 18:00:00', 1010, 5, 'A010', 35.0), ('2023-02-01 10:00:00', 1011, 9, 'A011', 20.0), ('2023-02-01 12:00:00', 1012, 2, 'A012', 60.0), ('2023-02-05 09:30:00', 1013, 4, 'A013', 25.0), ('2023-02-05 13:00:00', 1014, 6, 'A014', 18.0), ('2023-02-12 10:00:00', 1015, 7, 'A015', 22.0), ('2023-02-12 14:00:00', 1016, 5, 'A016', 28.0);




WITH sales AS (
    SELECT
        invoicedate,
        invoiceno,
        quantity,
        unitprice,
        quantity * unitprice AS amount,
        DATE_PART(week, invoicedate) AS week_num,
        DATE_PART(weekday, invoicedate) AS weekday_num  -- Mon=1, Sun=0
    FROM early_sales
),

weekly_sales AS (
    SELECT
        week_num,
        SUM(amount) AS total_week_sales,
        SUM(CASE WHEN weekday_num = 1 THEN amount ELSE 0 END) AS monday_sales,
        SUM(CASE WHEN weekday_num = 0 THEN amount ELSE 0 END) AS sunday_sales
    FROM sales
    GROUP BY week_num
)
SELECT
    week_num,
    ROUND((monday_sales / total_week_sales) * 100) AS monday_percentage,
    ROUND((sunday_sales / total_week_sales) * 100) AS sunday_percentage
FROM weekly_sales
ORDER BY week_num;






--55
-- Find the 3-month rolling average of total revenue from purchases given a table with users, their purchase amount, and date purchased. Do not include returns which are represented by negative purchase values. Output the year-month (YYYY-MM) and 3-month rolling average of revenue, sorted from earliest month to latest month.

-- A 3-month rolling average is defined by calculating the average total revenue from all user purchases for the current month and previous two months. The first two months will not be a true 3-month rolling average since we are not given data from last year. Assume each month has at least one purchase.


CREATE TABLE amazon_purchases ( created_at DATETIME, purchase_amt BIGINT, user_id BIGINT);

INSERT INTO amazon_purchases (created_at, purchase_amt, user_id) VALUES ('2023-01-05', 1500, 101), ('2023-01-15', -200, 102), ('2023-02-10', 2000, 103), ('2023-02-20', 1200, 101), ('2023-03-01', 1800, 104), ('2023-03-15', -100, 102), ('2023-04-05', 2200, 105), ('2023-04-10', 1400, 103), ('2023-05-01', 2500, 106), ('2023-05-15', 1700, 107), ('2023-06-05', 1300, 108), ('2023-06-15', 1900, 109);


select * from amazon_purchases;

WITH TOTAL_PURCHASE_CTE AS(
SELECT TO_VARCHAR(CREATED_AT,'YYYY-MM') AS YEAR_MONTH,
SUM(CASE WHEN purchase_amt > 0 THEN purchase_amt ELSE 0 END) AS TotalRevenue
FROM amazon_purchases
GROUP BY TO_VARCHAR(CREATED_AT,'YYYY-MM'))
SELECT *, AVG(TotalRevenue) OVER 
(ORDER BY YEAR_MONTH ROWS BETWEEN 2  PRECEDING AND CURRENT ROW) AS AVG_ROLLING 
FROM TOTAL_PURCHASE_CTE
;



--56
-- Find the quarterback who threw the longest throw in 2016. Output the quarterback name along with their corresponding longest throw.
-- The 'lg' column contains the longest completion by the quarterback.

CREATE TABLE qbstats_2015_2016 (att BIGINT, cmp BIGINT, game_points BIGINT, home_away VARCHAR(10), "int" BIGINT, lg VARCHAR(10), loss BIGINT, qb VARCHAR(40), rate FLOAT, sack BIGINT, td BIGINT, yds BIGINT, year BIGINT, ypa FLOAT);

INSERT INTO qbstats_2015_2016 (att, cmp, game_points, home_away, "int", lg, loss, qb, rate, sack, td, yds, year, ypa) VALUES (40, 25, 21, 'home', 1, '85', 0, 'Tom Brady', 105.5, 2, 3, 315, 2016, 7.8), (35, 20, 14, 'away', 2, '67', 1, 'Aaron Rodgers', 98.2, 3, 2, 280, 2016, 6.5), (50, 30, 27, 'home', 0, '75', 0, 'Drew Brees', 112.3, 1, 4, 350, 2016, 7.0), (28, 18, 17, 'away', 1, '60', 1, 'Russell Wilson', 96.7, 2, 1, 220, 2016, 6.8), (45, 28, 24, 'home', 2, '78', 0, 'Matt Ryan', 101.5, 1, 3, 300, 2016, 7.2), (38, 22, 20, 'away', 1, '90', 0, 'Ben Roethlisberger', 110.0, 0, 2, 340, 2016, 8.0), (30, 18, 16, 'home', 1, '63', 1, 'Philip Rivers', 92.5, 3, 2, 240, 2016, 7.1);

SELECT * FROM qbstats_2015_2016;

SELECT TOP 1
    QB AS QUARTERBACK,
    MAX(CAST(LG AS INTEGER)) AS LONGEST_THROW
FROM qbstats_2015_2016
WHERE YEAR = 2016
GROUP BY QB
ORDER BY LONGEST_THROW DESC;


--57

-- Find the top 3 most common letters across all the words from both the tables (ignore filename column). Output the letter along with the number of occurrences and order records in descending order based on the number of occurrences.

CREATE TABLE google_file_store (contents VARCHAR(255), filename VARCHAR(255));

INSERT INTO google_file_store (contents, filename) VALUES ('This is a sample content with some words.', 'file1.txt'), ('Another file with more words and letters.', 'file2.txt'), ('Text for testing purposes with various characters.', 'file3.txt');

CREATE TABLE google_word_lists ( words1 VARCHAR(255), words2 VARCHAR(255));

INSERT INTO google_word_lists (words1, words2) VALUES ('apple banana cherry', 'dog elephant fox'), ('grape honeydew kiwi', 'lemon mango nectarine'), ('orange papaya quince', 'raspberry strawberry tangerine');


select upper(contents) as words from google_file_store
union all
select upper(words1) as words from google_word_lists
union all
select upper(words2) as words from google_word_lists;

SELECT UPPER(SUBSTR(contents,n,1)) AS LETTER FROM google_file_store;

SELECT 
    UPPER(SUBSTR(contents, seq4(), 1)) AS letter
FROM google_file_store,
     TABLE(GENERATOR(ROWCOUNT => 10000)) g
WHERE seq4() < LENGTH(contents);

-- THIS IS A SAMPLE CONTENT WITH SOME WORDS.
-- ANOTHER FILE WITH MORE WORDS AND LETTERS.
-- TEXT FOR TESTING PURPOSES WITH VARIOUS CHARACTERS.


--58
-- You have a table of in-app purchases by user. Users that make their first in-app purchase are placed in a marketing campaign where they see call-to-actions for more in-app purchases. Find the number of users that made additional in-app purchases due to the success of the marketing campaign. 
-- The marketing campaign doesn't start until one day after the initial in-app purchase so users that only made one or multiple purchases on the first day do not count, nor do we count users that over time purchase only the products they purchased on the first day.


CREATE TABLE in_app_purchases ( created_at DATETIME, price BIGINT, product_id BIGINT, quantity BIGINT, user_id BIGINT);

INSERT INTO in_app_purchases (created_at, price, product_id, quantity, user_id) VALUES('2024-12-01 10:00:00', 500, 101, 1, 1),  ('2024-12-02 11:00:00', 700, 102, 1, 1),('2024-12-01 12:00:00', 300, 103, 1, 2), ('2024-12-03 14:00:00', 400, 103, 1, 2),('2024-12-02 09:30:00', 200, 104, 1, 3), ('2024-12-04 15:30:00', 600, 105, 2, 3),('2024-12-01 08:00:00', 800, 106, 1, 4), ('2024-12-05 18:00:00', 500, 107, 1, 4),('2024-12-06 16:00:00', 700, 108, 1, 5); 




WITH first_purchase AS (
SELECT user_id,
MIN(created_at) AS first_purchase_time
FROM in_app_purchases
GROUP BY user_id
),
day1_products AS (
SELECT 
p.user_id,
p.product_id
FROM in_app_purchases p
JOIN first_purchase fp 
ON p.user_id = fp.user_id 
AND DATE(p.created_at) = DATE(fp.first_purchase_time)
) ,
later_purchases AS (
SELECT p.user_id, p.product_id
FROM in_app_purchases p
JOIN first_purchase fp 
ON p.user_id = fp.user_id
AND p.created_at > fp.first_purchase_time + INTERVAL '1 day'
)select * from later_purchases;
SELECT COUNT(DISTINCT lp.user_id) AS marketing_success_users
FROM later_purchases lp
LEFT JOIN day1_products d1
ON lp.user_id = d1.user_id 
AND lp.product_id = d1.product_id
WHERE d1.product_id IS NULL;   


