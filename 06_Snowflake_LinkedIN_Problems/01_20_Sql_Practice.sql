create or replace database LINKEDIN;

CREATE OR REPLACE SCHEMA SQL_PRACTICE;

USE DATABASE LINKEDIN;

USE SCHEMA SQL_PRACTICE;
-----
CREATE TABLE famous (user_id INT, follower_id INT);

INSERT INTO famous VALUES
(1, 2), (1, 3), (2, 4), (5, 1), (5, 3), 
(11, 7), (12, 8), (13, 5), (13, 10), 
(14, 12), (14, 3), (15, 14), (15, 13);


SELECT * FROM FAMOUS;


-- A table named “famous” has two columns called user id and follower id. 
-- It represents each user ID has a particular follower ID. These follower IDs are also users of hashtag#Facebook / hashtag#Meta. Then, 
-- find the famous percentage of each user. 
-- Famous Percentage = number of followers a user has / total number of users on the platform.

SELECT * FROM FAMOUS;

WITH CTE_1 AS (
SELECT USER_ID , COUNT(*) AS TOTAL_COUNT  
FROM FAMOUS GROUP BY USER_ID )
SELECT DISTINCT(USER_ID), TOTAL_COUNT/
FROM CTE_1 order by USER_ID, TOTAL_COUNT desc;


WITH CTE1 AS(
SELECT USER_ID , COUNT(*) AS FOLLOWER_ID_CNT FROM FAMOUS
GROUP BY USER_ID
)
SELECT USER_ID, 
ROUND(FOLLOWER_ID_CNT/(SELECT COUNT(DISTINCT USER_ID) FROM FAMOUS ),2) AS TOT_PER
FROM CTE1 ORDER BY USER_ID ;


SELECT USER_ID FROM FAMOUS
UNION
SELECT FOLLOWER_ID AS FAMOUS_ID FROM FAMOUS;

WITH DISTINCT_USER AS (
SELECT USER_ID FROM FAMOUS
UNION 
SELECT FOLLOWER_ID AS FAMOUS_ID FROM FAMOUS),
FOLLOW_CNT AS(
SELECT USER_ID, COUNT(FOLLOWER_ID) AS FOLLOWERS
FROM FAMOUS GROUP BY USER_ID)
SELECT USER_ID, 
(FOLLOWERS*100.0) / (SELECT COUNT(*) AS TOTAL FROM DISTINCT_USER) AS TOTAL_PER 
FROM FOLLOW_CNT
ORDER BY USER_ID;


SELECT * FROM FAMOUS
ORDER BY USER_ID, FOLLOWER_ID;










CREATE TABLE sf_transactions(id INT, created_at datetime, value INT, purchase_id INT);

INSERT INTO sf_transactions VALUES
(1, '2019-01-01 00:00:00',  172692, 43), (2,'2019-01-05 00:00:00',  177194, 36),(3, '2019-01-09 00:00:00',  109513, 30),(4, '2019-01-13 00:00:00',  164911, 30),(5, '2019-01-17 00:00:00',  198872, 39), (6, '2019-01-21 00:00:00',  184853, 31),(7, '2019-01-25 00:00:00',  186817, 26), (8, '2019-01-29 00:00:00',  137784, 22),(9, '2019-02-02 00:00:00',  140032, 25), (10, '2019-02-06 00:00:00', 116948, 43), (11, '2019-02-10 00:00:00', 162515, 25), (12, '2019-02-14 00:00:00', 114256, 12), (13, '2019-02-18 00:00:00', 197465, 48), (14, '2019-02-22 00:00:00', 120741, 20), (15, '2019-02-26 00:00:00', 100074, 49), (16, '2019-03-02 00:00:00', 157548, 19), (17, '2019-03-06 00:00:00', 105506, 16), (18, '2019-03-10 00:00:00', 189351, 46), (19, '2019-03-14 00:00:00', 191231, 29), (20, '2019-03-18 00:00:00', 120575, 44), (21, '2019-03-22 00:00:00', 151688, 47), (22, '2019-03-26 00:00:00', 102327, 18), (23, '2019-03-30 00:00:00', 156147, 25);


SELECT * FROM sf_transactions;

WITH YEAR_MONTH AS(
SELECT 
ID,
TO_CHAR(CREATED_AT, 'YYYY-MM') AS DATE_MONTH,
VALUE
FROM sf_transactions
),
TOTAL_SAL AS(
SELECT  DATE_MONTH, SUM(VALUE) AS TOTAL_SALES FROM YEAR_MONTH
GROUP BY DATE_MONTH)

SELECT DATE_MONTH,TOTAL_SALES,
(TOTAL_SALES - LAG(TOTAL_SALES) OVER (ORDER BY DATE_MONTH))/(LAG(TOTAL_SALES) OVER (ORDER BY DATE_MONTH))*100 AS SALE_DIFF
FROM TOTAL_SAL;

SELECT 
ID,
CREATED_AT,
TO_CHAR(CREATED_AT, 'YYYY-MM') AS DATE_MONTH,
TO_DATE(TO_VARCHAR(CREATED_AT, 'YYYY-MM'),'YYYY-MM') AS DATE_MONTH,
CAST(CREATED_AT AS TIME) AS TIME_FORMAT,
DAY(CREATED_AT) AS DATE_MONTH,
MONTH(CREATED_AT) AS DATE_MONTH,
YEAR(CREATED_AT) AS DATE_MONTH,
VALUE
FROM sf_transactions;

SELECT TO_CHAR('2019-01-01'::timestamp, 'YYYY-MM-DD HH24:MI:SS') AS formatted; 
-- 2019-01-01 00:00:00


WITH YEAR_MONTH AS(
SELECT 
ID,
TO_CHAR(CREATED_AT, 'YYYY-MM') AS DATE_MONTH,
VALUE
FROM sf_transactions
),

TOTAL_SAL AS(
SELECT  DATE_MONTH, SUM(VALUE) AS TOTAL_SALES FROM YEAR_MONTH
GROUP BY DATE_MONTH),

PREV_SALES AS (
SELECT DATE_MONTH,TOTAL_SALES,
LAG(TOTAL_SALES) OVER (ORDER BY DATE_MONTH) PREV_SALES
FROM TOTAL_SAL)

SELECT DATE_MONTH, TOTAL_SALES, 
(TOTAL_SALES-PREV_SALES) / PREV_SALES*100 AS SALES_DIFF 
FROM PREV_SALES;
use database linkedin;
use schema sql_practice;

CREATE TABLE users(user_id INT, user_name varchar(30));
INSERT INTO users VALUES (1, 'Karl'), (2, 'Hans'), (3, 'Emma'), 
(4, 'Emma'), (5, 'Mike'), (6, 'Lucas'), (7, 'Sarah'), (8, 'Lucas'), (9, 'Anna'), (10, 'John');

CREATE TABLE friends(user_id INT, friend_id INT);
INSERT INTO friends VALUES (1,3),(1,5),(2,3),(2,4),(3,1),(3,2),(3,6),(4,7),(5,8),(6,9),(7,10),(8,6),(9,10),(10,7),(10,9);

select * from users;
select * from friends;

----------------------------------------------------------------------------

select f.user_id, u.user_name, f.friend_id 
from users u
left join friends f on 
u.user_id = f.user_id
where f.user_id in (1,2)
order by u.user_id;


with karl_friends as(
select u.user_id, u.user_name, f.friend_id
from users u
join friends f on f.user_id = u.user_id
where u.user_name = 'Karl'
),
hans_friends as(
select u.user_id, u.user_name, f.friend_id
from users u
join friends f on f.user_id = u.user_id
where u.user_name = 'Hans'
)
select * from users where user_id = (
select h.friend_id from  
hans_friends h
inner join  karl_friends k 
on h.friend_id = k.friend_id)
;


select * from friends;
select * from users;







select u.user_id, u.user_name 
from friends f1
join friends f2 
on f1.FRIEND_ID = f2.FRIEND_ID
join users u
on u.user_id = f1.FRIEND_ID
WHERE f1.user_id = (SELECT user_id FROM users WHERE user_name = 'Karl')
AND f2.user_id = (SELECT user_id FROM users WHERE user_name = 'Hans');








select u.user_id, u.user_name 
from friends f1
join friends f2 on f1.friend_id = f2.friend_id
join users u on u.user_id = f1.friend_id
where f1.user_id = (select user_id from users where user_name = 'Karl')
and f2.user_id = (select user_id from users where user_name = 'Hans');


SELECT f.friend_id
FROM friends f
JOIN users u ON u.user_id = f.user_id
WHERE u.user_name = 'Karl'
intersect
SELECT f.friend_id
FROM friends f
JOIN users u ON u.user_id = f.user_id
WHERE u.user_name = 'Hans';

-- Some forecasting methods are extremely simple and surprisingly effective. Naïve forecast is one of them. To create a naïve forecast for "distance per dollar" (defined as distance_to_travel/monetary_cost), first sum the "distance to travel" and "monetary cost" values monthly. This gives the actual value for the current month. For the forecasted value, use the previous month's value. After obtaining both actual and forecasted values, calculate the root mean squared error (RMSE) using the formula RMSE = sqrt(mean(square(actual - forecast))). Report the RMSE rounded to two decimal places.


CREATE TABLE uber_request_logs(request_id int, request_date datetime, request_status varchar(10), distance_to_travel float, monetary_cost float, driver_to_client_distance float);

INSERT INTO uber_request_logs VALUES (1,'2020-01-09','success', 70.59, 6.56,14.36), (2,'2020-01-24','success', 93.36, 22.68,19.9), (3,'2020-02-08','fail', 51.24, 11.39,21.32), (4,'2020-02-23','success', 61.58,8.04,44.26), (5,'2020-03-09','success', 25.04,7.19,1.74), (6,'2020-03-24','fail', 45.57, 4.68,24.19), (7,'2020-04-08','success', 24.45,12.69,15.91), (8,'2020-04-23','success', 48.22,11.2,48.82), (9,'2020-05-08','success', 56.63,4.04,16.08), (10,'2020-05-23','fail', 19.03,16.65,11.22), (11,'2020-06-07','fail', 81,6.56,26.6), (12,'2020-06-22','fail', 21.32,8.86,28.57), (13,'2020-07-07','fail', 14.74,17.76,19.33), (14,'2020-07-22','success',66.73,13.68,14.07), (15,'2020-08-06','success',32.98,16.17,25.34), (16,'2020-08-21','success',46.49,1.84,41.9), (17,'2020-09-05','fail', 45.98,12.2,2.46), (18,'2020-09-20','success',3.14,24.8,36.6), (19,'2020-10-05','success',75.33,23.04,29.99), (20,'2020-10-20','success', 53.76,22.94,18.74);


select * from uber_request_logs;

WITH CTE_1 AS(
select *,
to_varchar(request_date, 'YYYY-MM') AS YEAR_MONTH
from uber_request_logs),
CTE_2 AS (
SELECT YEAR_MONTH, 
SUM(DISTANCE_TO_TRAVEL)/sum(MONETARY_COST) AS TOTAL_Cost
FROM  CTE_1 
GROUP BY 1
),
forcasted_cte as(
SELECT 
*, lag(total_cost) over (order by year_month) as forcasted_cost
FROM CTE_2)
SELECT 
ROUND(SQRT(AVG(POWER(total_cost - forcasted_cost, 2))), 2) AS RMSE
FROM forcasted_cte;

-- Find the total number of available beds per hosts' nationality.
-- Output the nationality along with the corresponding total number of available beds. Sort records by the total available beds in descending order.

CREATE TABLE airbnb_apartments(host_id int,apartment_id varchar(5),apartment_type varchar(10),n_beds int,n_bedrooms int,country varchar(20),city varchar(20));
INSERT INTO airbnb_apartments VALUES(0,'A1','Room',1,1,'USA','NewYork'),(0,'A2','Room',1,1,'USA','NewJersey'),(0,'A3','Room',1,1,'USA','NewJersey'),(1,'A4','Apartment',2,1,'USA','Houston'),(1,'A5','Apartment',2,1,'USA','LasVegas'),(3,'A7','Penthouse',3,3,'China','Tianjin'),(3,'A8','Penthouse',5,5,'China','Beijing'),(4,'A9','Apartment',2,1,'Mali','Bamako'),(5,'A10','Room',3,1,'Mali','Segou');

CREATE TABLE airbnb_hosts(host_id int,nationality  varchar(15),gender varchar(5),age int);
INSERT INTO airbnb_hosts  VALUES(0,'USA','M',28),(1,'USA','F',29),(2,'China','F',31),(3,'China','M',24),(4,'Mali','M',30),(5,'Mali','F',30);

select * from airbnb_apartments;
SELECT * FROM airbnb_hosts;

SELECT   AH.NATIONALITY  ,SUM(AA.N_BEDS) TOTAL_BEDS
FROM airbnb_hosts AH
JOIN airbnb_apartments AA
ON AA.HOST_ID = AH.HOST_ID
GROUP BY AH.NATIONALITY ORDER BY TOTAL_BEDS DESC;

CREATE TABLE ms_projects(id int, title varchar(15), budget int);
INSERT INTO ms_projects VALUES (1, 'Project1',  29498),(2, 'Project2',  32487),(3, 'Project3',  43909),(4, 'Project4',  15776),(5, 'Project5',  36268),(6, 'Project6',  41611),(7, 'Project7',  34003),(8, 'Project8',  49284),(9, 'Project9',  32341),(10, 'Project10',    47587),(11, 'Project11',    11705),(12, 'Project12',    10468),(13, 'Project13',    43238),(14, 'Project14',    30014),(15, 'Project15',    48116),(16, 'Project16',    19922),(17, 'Project17',    19061),(18, 'Project18',    10302),(19, 'Project19',    44986),(20, 'Project20',    19497);

CREATE TABLE ms_emp_projects(emp_id int, project_id int);
INSERT INTO ms_emp_projects VALUES (10592,  1),(10593,  2),(10594,  3),(10595,  4),(10596,  5),(10597,  6),(10598,  7),(10599,  8),(10600,  9),(10601,  10),(10602, 11),(10603, 12),(10604, 13),(10605, 14),(10606, 15),(10607, 16),(10608, 17),(10609, 18),(10610, 19),(10611, 20);

select * from ms_projects;

select * from ms_emp_projects;

select e.emp_id, e.project_id, p.title, p.budget
from ms_emp_projects e
inner join ms_projects p
on e.project_id = p.id;

SELECT P.TITLE , 
ROUND(P.BUDGET/COUNT(E.EMP_ID),0) AS BUDGET
FROM ms_emp_projects E
inner join ms_projects P
on E.project_id = P.id
GROUP BY P.TITLE,P.BUDGET
ORDER BY 2 DESC;




SELECT B.title, ROUND(B.budget/COUNT(A.emp_id),0) AS BUDGET FROM ms_projects B 
INNER JOIN ms_emp_projects A ON A.project_id = B.id
GROUP BY B.title, B.budget
ORDER BY budget DESC;

-- IBM is working on a new feature to analyze user purchasing behavior for all Fridays in the first quarter of the year. For each Friday separately, calculate the average amount users have spent per order. The output should contain the week number of that Friday and average amount spent.

CREATE TABLE user_purchases(user_id int, date date, amount_spent float, day_name varchar(15));

INSERT INTO user_purchases VALUES(1047,'2023-01-01',288,'Sunday'),(1099,'2023-01-04',803,'Wednesday'),(1055,'2023-01-07',546,'Saturday'),(1040,'2023-01-10',680,'Tuesday'),(1052,'2023-01-13',889,'Friday'),(1052,'2023-01-13',596,'Friday'),(1016,'2023-01-16',960,'Monday'),(1023,'2023-01-17',861,'Tuesday'),(1010,'2023-01-19',758,'Thursday'),(1013,'2023-01-19',346,'Thursday'),(1069,'2023-01-21',541,'Saturday'),(1030,'2023-01-22',175,'Sunday'),(1034,'2023-01-23',707,'Monday'),(1019,'2023-01-25',253,'Wednesday'),(1052,'2023-01-25',868,'Wednesday'),(1095,'2023-01-27',424,'Friday'),(1017,'2023-01-28',755,'Saturday'),(1010,'2023-01-29',615,'Sunday'),(1063,'2023-01-31',534,'Tuesday'),(1019,'2023-02-03',185,'Friday'),(1019,'2023-02-03',995,'Friday'),(1092,'2023-02-06',796,'Monday'),(1058,'2023-02-09',384,'Thursday'),(1055,'2023-02-12',319,'Sunday'),(1090,'2023-02-15',168,'Wednesday'),(1090,'2023-02-18',146,'Saturday'),(1062,'2023-02-21',193,'Tuesday'),(1023,'2023-02-24',259,'Friday');


SELECT * FROM user_purchases;


SELECT USER_ID, weekofyear(DATE) AS WEEK_NUM,date, ROUND(AVG(AMOUNT_SPENT),2) AVG_AMOUNT
FROM user_purchases
WHERE DAY_NAME='Friday' AND QUARTER(DATE) =1
GROUP BY USER_ID, DATE,WEEK_NUM;

-- You are given a table of product launches by company by year. Write a query to count the net difference between the number of products companies launched in 2020 with the number of products companies launched in the previous year. Output the name of the companies and a net difference of net products released for 2020 compared to the previous year.

CREATE TABLE car_launches(year int, company_name varchar(15), product_name varchar(30));

INSERT INTO car_launches VALUES(2019,'Toyota','Avalon'),(2019,'Toyota','Camry'),(2020,'Toyota','Corolla'),(2019,'Honda','Accord'),(2019,'Honda','Passport'),(2019,'Honda','CR-V'),(2020,'Honda','Pilot'),(2019,'Honda','Civic'),(2020,'Chevrolet','Trailblazer'),(2020,'Chevrolet','Trax'),(2019,'Chevrolet','Traverse'),(2020,'Chevrolet','Blazer'),(2019,'Ford','Figo'),(2020,'Ford','Aspire'),(2019,'Ford','Endeavour'),(2020,'Jeep','Wrangler');



select * from car_launches WHERE COMPANY_NAME='Toyota';

SELECT COMPANY_NAME,
SUM(CASE WHEN YEAR=2020 THEN 1 ELSE 0 END) AS YEAR_2020,
SUM(CASE WHEN YEAR=2019 THEN 1 ELSE 0 END) AS YEAR_2019
FROM car_launches
WHERE YEAR IN (2019, 2020)
GROUP BY COMPANY_NAME;

WITH CTE1 AS(
SELECT COMPANY_NAME,
CASE WHEN YEAR=2020 THEN 1 ELSE 0 END AS YEAR_2020,
CASE WHEN YEAR=2019 THEN 1 ELSE 0 END AS YEAR_2019
FROM car_launches
WHERE YEAR IN (2019, 2020)
GROUP BY COMPANY_NAME, YEAR)
SELECT COMPANY_NAME, SUM(YEAR_2020) AS YEAR_2020, SUM(YEAR_2019) AS YEAR_2019
FROM CTE1
GROUP BY COMPANY_NAME;





WITH PRODUCT_COUNT_CTE AS (
SELECT YEAR, COMPANY_NAME, COUNT(PRODUCT_NAME) AS PRODUCT_COUNT
FROM car_launches 
GROUP BY YEAR, COMPANY_NAME
),
PREV_YEAR_CTE AS(
SELECT *,
LAG(PRODUCT_COUNT,1,0) OVER (PARTITION BY COMPANY_NAME ORDER BY COMPANY_NAME, YEAR) AS PREVIOUS_YEAR 
FROM PRODUCT_COUNT_CTE)
SELECT COMPANY_NAME, 
(PRODUCT_COUNT-PREVIOUS_YEAR)AS TOTAL_SALE_DIFF 
FROM  PREV_YEAR_CTE WHERE YEAR = 2020
ORDER BY TOTAL_SALE_DIFF DESC;

-- Find the genre of the person with the most number of oscar winnings.
-- If there are more than one person with the same number of oscar wins, return the first one in alphabetic order based on their name. Use the names as keys when joining the tables.

CREATE TABLE nominee_information(name varchar(20), amg_person_id varchar(10), top_genre varchar(10), birthday datetime, id int);

INSERT INTO nominee_information VALUES('Jennifer Lawrence','P562566','Drama','1990-08-15',755),('Jonah Hill','P418718','Comedy','1983-12-20',747),('Anne Hathaway', 'P292630','Drama', '1982-11-12',744),('Jennifer Hudson','P454405','Drama', '1981-09-12',742),('Rinko Kikuchi', 'P475244','Drama', '1981-01-06', 739);

CREATE TABLE oscar_nominees(year int, category varchar(30), nominee varchar(20), movie varchar(30), winner int, id int);

INSERT INTO oscar_nominees VALUES(2008,'actress in a leading role','Anne Hathaway','Rachel Getting Married',0,77),(2012,'actress in a supporting role','Anne HathawayLes','Mis_rables',1,78),(2006,'actress in a supporting role','Jennifer Hudson','Dreamgirls',1,711),(2010,'actress in a leading role','Jennifer Lawrence','Winters Bone',1,717),(2012,'actress in a leading role','Jennifer Lawrence','Silver Linings Playbook',1,718),(2011,'actor in a supporting role','Jonah Hill','Moneyball',0,799),(2006,'actress in a supporting role','Rinko Kikuchi','Babel',0,1253);

select * from nominee_information;

select *  from oscar_nominees;


select N.NAME, N.TOP_GENRE, SUM(O.WINNER) AS TOTAL_WINS
FROM nominee_information N
JOIN oscar_nominees O 
ON N.NAME = O.NOMINEE
GROUP BY N.NAME, N.TOP_GENRE
ORDER BY TOTAL_WINS DESC, NAME 
LIMIT 1;


create or replace temporary table vartab (id integer, v
varchar);
insert into vartab (id, v) values
(1, '[-1, 12, 289, 2188, false,]'),
(2, '{ "x" : "abc", "y" : false, "z": 10} '),
(3, '[ "x" : "def", "y" : true, "z": 11 '),
(4, '[-1, 12, 289, 2188], NULL');
select id, try_parse_json(v)
from vartab
order by id;

--Write a query that'll identify returning active users. A returning active user is a user that has made a second purchase within 7 days of any other of their purchases. Output a list of user_ids of these returning active users.

CREATE TABLE amazon_transactions(id int, user_id int, item varchar(15), created_at datetime, revenue int);

INSERT INTO amazon_transactions VALUES (1,109,'milk','2020-03-03 00:00:00',123),(2,139,'biscuit','2020-03-18 00:00:00', 421), (3,120,'milk','2020-03-18 00:00:00',176), (4,108,'banana','2020-03-18 00:00:00',862), (5,130,'milk','2020-03-28 00:00:00',333), (6,103,'bread','2020-03-29 00:00:00',862), (7,122,'banana','2020-03-07 00:00:00',952), (8,125,'bread','2020-03-13 00:00:00',317), (9,139,'bread','2020-03-30 00:00:00',929), (10,141,'banana','2020-03-17 00:00:00',812), (11,116,'bread','2020-03-31 00:00:00',226), (12,128,'bread','2020-03-04 00:00:00',112), (13,146,'biscuit','2020-03-04 00:00:00',362), (14,119,'banana','2020-03-28 00:00:00',127), (15,142,'bread','2020-03-09 00:00:00',503), (16,122,'bread','2020-03-06 00:00:00',593), (17,128,'biscuit','2020-03-24 00:00:00',160), (18,112,'banana','2020-03-24 00:00:00',262), (19,149,'banana','2020-03-29 00:00:00',382), (20,100,'banana','2020-03-18 00:00:00',599);

SELECT * FROM amazon_transactions;

CREATE TABLE amazon_transactions(id int, user_id int, item varchar(15), created_at datetime, revenue int);

INSERT INTO amazon_transactions VALUES (100,122,'pAPER','2020-03-08 00:00:00',5930);




SELECT distinct A.USER_ID
FROM amazon_transactions A
JOIN amazon_transactions B ON
A.USER_ID = B.USER_ID
WHERE A.CREATED_AT < B.CREATED_AT
AND DATEDIFF('DAY', A.CREATED_AT,B.CREATED_AT)<=7;


WITH LAG_CTE AS(
SELECT USER_ID, DATE(CREATED_AT) AS previous_purchase,
LEAD(DATE(CREATED_AT)) OVER (PARTITION BY USER_ID ORDER BY CREATED_AT ) AS latest_purchase
FROM amazon_transactions)
SELECT distinct user_id, 
FROM LAG_CTE 
WHERE latest_purchase IS NOT NULL
and DATEDIFF('DAY',previous_purchase, latest_purchase) <=7;


SELECT DATEDIFF('day', '2020-03-18', '2020-03-30') AS diff_in_days;




--
-- Find the number of transactions that occurred for each product. Output the product name along with the corresponding number of transactions and order records by the product id in ascending order. You can ignore products without transactions.


CREATE TABLE excel_sql_inventory_data (product_id INT,product_name VARCHAR(50),product_type VARCHAR(50),unit VARCHAR(20),price_unit FLOAT,wholesale FLOAT,current_inventory INT);

INSERT INTO excel_sql_inventory_data (product_id, product_name, product_type, unit, price_unit, wholesale, current_inventory) 
VALUES(1, 'strawberry', 'produce', 'lb', 3.28, 1.77, 13),(2, 'apple_fuji', 'produce', 'lb', 1.44, 0.43, 2),(3, 'orange', 'produce', 'lb', 1.02, 0.37, 2),(4, 'clementines', 'produce', 'lb', 1.19, 0.44, 44),(5, 'blood_orange', 'produce', 'lb', 3.86, 1.66, 19);

CREATE TABLE excel_sql_transaction_data (transaction_id INT PRIMARY KEY,time DATETIME,product_id INT);

INSERT INTO excel_sql_transaction_data (transaction_id, time, product_id) 
VALUES(153, '2016-01-06 08:57:52', 1),(91, '2016-01-07 12:17:27', 1),(31, '2016-01-05 13:19:25', 1),(24, '2016-01-03 10:47:44', 3),(4, '2016-01-06 17:57:42', 3),(163, '2016-01-03 10:11:22', 3),(92, '2016-01-08 12:03:20', 2),(32, '2016-01-04 19:37:14', 4),(253, '2016-01-06 14:15:20', 5),(118, '2016-01-06 14:27:33', 5);

SELECT * FROM excel_sql_inventory_data;

SELECT * FROM excel_sql_transaction_data;

SELECT P.PRODUCT_NAME,COUNT(P.PRODUCT_NAME) AS PRODUCT_CUNT
FROM excel_sql_inventory_data P
JOIN excel_sql_transaction_data T ON
P.PRODUCT_ID = T.PRODUCT_ID
GROUP BY P.PRODUCT_ID ,P.PRODUCT_NAME
ORDER BY P.PRODUCT_ID;

CREATE TABLE file_metadata (
    folder STRING,
    file_name STRING,
    size_bytes NUMBER,
    last_modified TIMESTAMP,
    file_type STRING,
    extension STRING
);



select * from file_metadata;

CREATE OR REPLACE TABLE file_metadata (
    folder          STRING,        -- Full folder path
    file_name       STRING,        -- File name
    file_path       STRING,        -- Absolute file path
    size_bytes      NUMBER,        -- File size in bytes
    last_modified   STRING,        -- Last modified timestamp as string
    created_time    STRING,        -- File creation timestamp as string
    accessed_time   STRING,        -- Last accessed timestamp as string
    file_type       STRING,        -- Software, Document, Media, Other
    extension       STRING,        -- File extension like .csv, .sql
    md5_hash        STRING,        -- File checksum for validation
    is_empty        BOOLEAN,       -- True if file size is 0
    depth           NUMBER,        -- Folder depth relative to input path
    scan_timestamp  STRING         -- Timestamp of scan
);


-- Write a query that calculates the difference between the highest salaries found in the marketing and engineering departments. Output just the absolute difference in salaries.

CREATE TABLE db_employee (id INT,first_name VARCHAR(50),last_name VARCHAR(50),salary INT,department_id INT);

INSERT INTO db_employee (id, first_name, last_name, salary, department_id) VALUES(10306, 'Ashley', 'Li', 28516, 4),(10307, 'Joseph', 'Solomon', 19945, 1),(10311, 'Melissa', 'Holmes', 33575, 1),(10316, 'Beth', 'Torres', 34902, 1),(10317, 'Pamela', 'Rodriguez', 48187, 4),(10320, 'Gregory', 'Cook', 22681, 4),(10324, 'William', 'Brewer', 15947, 1),(10329, 'Christopher', 'Ramos', 37710, 4),(10333, 'Jennifer', 'Blankenship', 13433, 4),(10339, 'Robert', 'Mills', 13188, 1);

CREATE TABLE db_dept (id INT,department VARCHAR(50));

INSERT INTO db_dept (id, department) VALUES(1, 'engineering'),(2, 'human resource'),(3, 'operation'),(4, 'marketing');


SELECT * FROM db_employee;

SELECT * FROM db_dept;

SELECT MAX(E.SALARY) AS MAX_SAL , D.DEPARTMENT,
FROM db_dept D
JOIN db_employee E ON
D.ID = E.DEPARTMENT_ID WHERE D.DEPARTMENT IN('marketing','engineering')
GROUP BY D.DEPARTMENT;

SELECT 
ABS(MAX(CASE WHEN D.DEPARTMENT='marketing' THEN E.SALARY END)-
MAX(CASE WHEN D.DEPARTMENT = 'engineering' THEN E.SALARY END)) AS SALARY_DIFF
FROM db_dept D
JOIN db_employee E ON
 D.ID = E.DEPARTMENT_ID;

 SELECT  D.DEPARTMENT,E.LAST_NAME,E.FIRST_NAME,
CASE WHEN D.DEPARTMENT = 'engineering' THEN E.FIRST_NAME ELSE E.LAST_NAME END AS TESTING
 FROM db_dept D
JOIN db_employee E ON
 D.ID = E.DEPARTMENT_ID;

 CREATE TABLE hotel_reviews (hotel_address VARCHAR(255),additional_number_of_scoring INT,review_date DATETIME,average_score FLOAT,hotel_name VARCHAR(100),reviewer_nationality VARCHAR(100),negative_review TEXT,review_total_negative_word_counts INT,total_number_of_reviews INT,positive_review TEXT,review_total_positive_word_counts INT,total_number_of_reviews_reviewer_has_given INT,reviewer_score FLOAT,tags VARCHAR(255),days_since_review VARCHAR(50),lat FLOAT,lng FLOAT);

-- Find the number of rows for each review score earned by 'Hotel Arena'. Output the hotel name (which should be 'Hotel Arena'), review score along with the corresponding number of rows with that score for the specified hotel.

INSERT INTO hotel_reviews (hotel_address, additional_number_of_scoring,review_date, average_score, hotel_name, reviewer_nationality,negative_review,review_total_negative_word_counts, total_number_of_reviews,positive_review,review_total_positive_word_counts, total_number_of_reviews_reviewer_has_given, reviewer_score, tags, days_since_review, lat, lng) VALUES('123 Main St', 5, '2024-01-01', 8.5, 'Hotel Arena', 'American', 'Noisy room', 3, 200, 'Great staff', 5, 10, 8.0, 'Family stay', '100 days', 40.7128, -74.0060),('123 Main St', 2, '2024-01-02', 8.5, 'Hotel Arena', 'British', 'Small bathroom', 2, 200, 'Clean room', 6, 5, 9.0, 'Solo traveler', '95 days', 40.7128, -74.0060),('123 Main St', 3, '2024-01-03', 8.5, 'Hotel Arena', 'Canadian', 'Slow service', 4, 200, 'Nice view', 7, 3, 6.0, 'Couple stay', '90 days', 40.7128, -74.0060);

SELECT * FROM hotel_reviews;


SELECT 
HOTEL_NAME, REVIEWER_SCORE,
COUNT(*) AS TOTAL_COUNT
FROM hotel_reviews
WHERE HOTEL_NAME = 'Hotel Arena'
GROUP BY HOTEL_NAME,REVIEWER_SCORE;



----

-- What is the total sales revenue of Samantha and Lisa?

CREATE TABLE sales_performance (salesperson VARCHAR(50),widget_sales INT,sales_revenue INT,id INT PRIMARY KEY);

INSERT INTO sales_performance (salesperson, widget_sales, sales_revenue, id) VALUES('Jim', 810, 40500, 1),('Bobby', 661, 33050, 2),('Samantha', 1006, 50300, 3),('Taylor', 984, 49200, 4),('Tom', 403, 20150, 5),('Pat', 715, 35750, 6),('Lisa', 1247, 62350, 7);


SELECT * FROM sales_performance;


SELECT  SUM(SALES_REVENUE) AS TOTAL_SALES
FROM sales_performance
WHERE SALESPERSON IN ('Samantha','Lisa');


---

CREATE TABLE google_gmail_emails (id INT PRIMARY KEY,from_user VARCHAR(50),to_user VARCHAR(50),day INT);

INSERT INTO google_gmail_emails (id, from_user, to_user, day) VALUES(0, '6edf0be4b2267df1fa', '75d295377a46f83236', 10),(1, '6edf0be4b2267df1fa', '32ded68d89443e808', 6),(2, '6edf0be4b2267df1fa', '55e60cfcc9dc49c17e', 10),(3, '6edf0be4b2267df1fa', 'e0e0defbb9ec47f6f7', 6),(4, '6edf0be4b2267df1fa', '47be2887786891367e', 1),(5, '6edf0be4b2267df1fa', '2813e59cf6c1ff698e', 6),(6, '6edf0be4b2267df1fa', 'a84065b7933ad01019', 8),(7, '6edf0be4b2267df1fa', '850badf89ed8f06854', 1),(8, '6edf0be4b2267df1fa', '6b503743a13d778200', 1),(9, '6edf0be4b2267df1fa', 'd63386c884aeb9f71d', 3),(10, '6edf0be4b2267df1fa', '5b8754928306a18b68', 2),(11, '6edf0be4b2267df1fa', '6edf0be4b2267df1fa', 8),(12, '6edf0be4b2267df1fa', '406539987dd9b679c0', 9),(13, '6edf0be4b2267df1fa', '114bafadff2d882864', 5),(14, '6edf0be4b2267df1fa', '157e3e9278e32aba3e', 2),(15, '75d295377a46f83236', '75d295377a46f83236', 6),(16, '75d295377a46f83236', 'd63386c884aeb9f71d', 8),(17, '75d295377a46f83236', '55e60cfcc9dc49c17e', 3),(18, '75d295377a46f83236', '47be2887786891367e', 10),(19, '75d295377a46f83236', '5b8754928306a18b68', 10),(20, '75d295377a46f83236', '850badf89ed8f06854', 7);


SELECT * FROM google_gmail_emails;

-- Find all records from days when the number of distinct users receiving emails was greater than the number of distinct users sending emails.

with distinct_ciunt as(
select day,
count(distinct to_user) as receiver,
count(distinct from_user) as sender
from google_gmail_emails
group  by day)
select dc.day, gm.from_user, gm.to_user,gm.id
from google_gmail_emails gm
join distinct_ciunt dc on gm.day = dc.day
where dc.receiver > dc.sender 
order by day;


select day ,count(to_user)
from google_gmail_emails
group by 1
order by 1;



SHOW PARAMETERS LIKE 'DATA_RETENTION_TIME_IN_DAYS' IN DATABASE LINKEDIN;

SHOW PARAMETERS LIKE 'DATA_RETENTION_TIME_IN_DAYS' IN SCHEMA SQL_PRACTICE;

SHOW PARAMETERS LIKE 'DATA_RETENTION_TIME_IN_DAYS' IN TABLE google_gmail_emails;

alter database linkedin set data_retention_time_in_days=90;

alter table google_gmail_emails set data_retention_time_in_days =90 ;


SELECT *
FROM snowflake.account_usage.query_history
WHERE query_text LIKE '%LINKEDIN%'
AND start_time > dateadd('day', -1, current_timestamp());


SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.DATABASES;

SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.COPY_HISTORY;


USE ROLE SYSADMIN;

alter table google_gmail_emails set data_retention_time_in_days =78;

CREATE TABLE boi_transactions (transaction_id INT PRIMARY KEY,time_stamp DATETIME NOT NULL);

INSERT INTO boi_transactions (transaction_id, time_stamp) VALUES(1051, '2022-12-03 10:15'),(1052, '2022-12-03 17:00'),(1053, '2022-12-04 10:00'),(1054, '2022-12-04 14:00'),(1055, '2022-12-05 08:59'),(1056, '2022-12-05 16:01'),(1057, '2022-12-06 09:00'),(1058, '2022-12-06 15:59'),(1059, '2022-12-07 12:00'),(1060, '2022-12-08 09:00'),(1061, '2022-12-09 10:00'),(1062, '2022-12-10 11:00'),(1063, '2022-12-10 17:30'),(1064, '2022-12-11 12:00'),(1065, '2022-12-12 08:59'),(1066, '2022-12-12 16:01'),(1067, '2022-12-25 10:00'),(1068, '2022-12-25 15:00'),(1069, '2022-12-26 09:00'),(1070, '2022-12-26 14:00'),(1071, '2022-12-26 16:30'),(1072, '2022-12-27 09:00'),(1073, '2022-12-28 08:30'),(1074, '2022-12-29 16:15'),(1075, '2022-12-30 14:00'),(1076, '2022-12-31 10:00');



SELECT * FROM boi_transactions;

-- Bank of Ireland has requested that you detect invalid transactions in December 2022. An invalid transaction is one that occurs outside of the bank's normal business hours. The following are the hours of operation for all branches:

-- Monday - Friday 09:00 - 16:00
-- Saturday & Sunday Closed
-- Irish Public Holidays 25th and 26th December
-- -- Determine the transaction ids of all invalid transactions.

WITH HOLIDAY_CTE AS(
SELECT *, DATE(TIME_STAMP) AS DATE_PRT, 
DAYNAME(TIME_STAMP) AS DAY_NAME, 
time(TIME_STAMP) as time_part
FROM boi_transactions
WHERE YEAR(TIME_STAMP) =2022 and MONTH(TIME_STAMP) =12 ),
 ANSWER_CTE AS(
SELECT * FROM HOLIDAY_CTE 
WHERE DATE_PRT IN ('2022-12-25' , '2022-12-26') OR DAY_NAME IN ('Sat','Sun') 
OR time_part NOT between '09:00:00' AND '16:00:00')
SELECT * from ANSWER_CTE;


WITH HOLIDAY_CTE AS(
SELECT *, DATE(TIME_STAMP) AS DATES, 
DAYNAME(TIME_STAMP) AS DAY_NAME, 
time(TIME_STAMP) as time_part
FROM boi_transactions
WHERE YEAR(TIME_STAMP) =2022  )
SELECT *,
CASE 
WHEN DAYNAME(TIME_STAMP) IN ('Sat','Sun') then 'Weekend'
WHEN DATES IN  ('2022-12-25' , '2022-12-26') THEN 'Holiday'
when time_part NOT between '09:00:00' AND '16:00:00' then 'Out_of_Timings' 
else 'Valid_Transactions' end as "In_Valid_Transactions"
from HOLIDAY_CTE;



---
CREATE TABLE my_uber_drives (start_date DATETIME,end_date DATETIME,category VARCHAR(50),startt VARCHAR(50),stop VARCHAR(50),miles FLOAT,purpose VARCHAR(50));

INSERT INTO my_uber_drives (start_date, end_date, category, startt, stop, miles, purpose) VALUES('2016-01-01 21:11', '2016-01-01 21:17', 'Business', 'Fort Pierce', 'Fort Pierce', 5.1, 'Meal/Entertain'),('2016-01-02 01:25', '2016-01-02 01:37', 'Business', 'Fort Pierce', 'Fort Pierce', 5, NULL),('2016-01-02 20:25', '2016-01-02 20:38', 'Business', 'Fort Pierce', 'Fort Pierce', 4.8, 'Errand/Supplies'),('2016-01-05 17:31', '2016-01-05 17:45', 'Business', 'Fort Pierce', 'Fort Pierce', 4.7, 'Meeting'),('2016-01-06 14:42', '2016-01-06 15:49', 'Business', 'Fort Pierce', 'West Palm Beach', 63.7, 'Customer Visit'),('2016-01-06 17:15', '2016-01-06 17:19', 'Business', 'West Palm Beach', 'West Palm Beach', 4.3, 'Meal/Entertain'),('2016-01-06 17:30', '2016-01-06 17:35', 'Business', 'West Palm Beach', 'Palm Beach', 7.1, 'Meeting');


SELECT * FROM my_uber_drives;

-- You’re given a table of Uber rides that contains the mileage and the purpose for the business expense.
-- You’re asked to find business purposes that generate the most miles driven for passengers that use Uber for their business transportation. Find the top 3 business purpose categories by total mileage.

SELECT TOP 3 PURPOSE, SUM(MILES) AS TOTAL_MILES
FROM my_uber_drives
WHERE category = 'Business'
GROUP BY PURPOSE 
ORDER BY TOTAL_MILES DESC;


---

CREATE TABLE worker(worker_id INT PRIMARY KEY,first_name VARCHAR(50),last_name VARCHAR(50),salary INT,joining_date DATETIME,department VARCHAR(50));

INSERT INTO worker(worker_id, first_name, last_name, salary, joining_date, department) VALUES(1, 'John', 'Doe', 80000, '2020-01-15', 'Engineering'),(2, 'Jane', 'Smith', 120000, '2019-03-10', 'Marketing'),(3, 'Alice', 'Brown', 120000, '2021-06-21', 'Sales'),(4, 'Bob', 'Davis', 75000, '2018-04-30', 'Engineering'),(5, 'Charlie', 'Miller', 95000, '2021-01-15', 'Sales');

CREATE TABLE title(worker_ref_id INT,worker_title VARCHAR(50),affected_from DATETIME);

INSERT INTO title(worker_ref_id, worker_title, affected_from) VALUES(1, 'Engineer', '2020-01-15'),(2, 'Marketing Manager', '2019-03-10'),(3, 'Sales Manager', '2021-06-21'),(4, 'Junior Engineer', '2018-04-30'),(5, 'Senior Salesperson', '2021-01-15');


SELECT * FROM WORKER;

SELECT * FROM title;

-- You have been asked to find the job titles of the highest-paid employees.
-- Your output should include the highest-paid title or multiple titles with the same salary.


SELECT T.WORKER_TITLE 
FROM WORKER W
JOIN TITLE T ON
W.WORKER_ID = T.WORKER_REF_ID WHERE W.SALARY = (
SELECT MAX(SALARY) FROM WORKER);


---

--

-- Write a query that returns the number of unique users per client per month

CREATE TABLE fact_events (id INT PRIMARY KEY,time_id DATETIME,user_id VARCHAR(20),customer_id VARCHAR(50),client_id VARCHAR(20),event_type VARCHAR(50),event_id INT);

INSERT INTO fact_events (id, time_id, user_id, customer_id, client_id, event_type, event_id) VALUES(1, '2020-02-28', '3668-QPYBK', 'Sendit', 'desktop', 'message sent', 3),(2, '2020-02-28', '7892-POOKP', 'Connectix', 'mobile', 'file received', 2),(3, '2020-04-03', '9763-GRSKD', 'Zoomit', 'desktop', 'video call received', 7),(4, '2020-04-02', '9763-GRSKD', 'Connectix', 'desktop', 'video call received', 7),(5, '2020-02-06', '9237-HQITU', 'Sendit', 'desktop', 'video call received', 7),(6, '2020-02-27', '8191-XWSZG', 'Connectix', 'desktop', 'file received', 2),(7, '2020-04-03', '9237-HQITU', 'Connectix', 'desktop', 'video call received', 7),(8, '2020-03-01', '9237-HQITU', 'Connectix', 'mobile', 'message received', 4),(9, '2020-04-02', '4190-MFLUW', 'Connectix', 'mobile', 'video call received', 7),(10, '2020-04-21', '9763-GRSKD', 'Sendit', 'desktop', 'file received', 2);


SELECT * FROM fact_events;


SELECT CLIENT_ID, 
TO_CHAR(TIME_ID, 'YYYY-MM') AS YEAR_MONTH, 
COUNT(DISTINCT USER_ID) AS USER_ID_CNT
FROM fact_events
GROUP BY CLIENT_ID, TO_CHAR(TIME_ID, 'YYYY-MM') 
ORDER BY 3 DESC;



