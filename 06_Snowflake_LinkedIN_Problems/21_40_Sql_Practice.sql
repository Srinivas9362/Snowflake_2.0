-- Find the total number of downloads for paying and non-paying users by date. Include only records where non-paying customers have more downloads than paying customers. The output should be sorted by earliest date first and contain 3 columns date, non-paying downloads, paying downloads. 

CREATE TABLE ms_user_dimension (user_id INT PRIMARY KEY,acc_id INT);
INSERT INTO ms_user_dimension (user_id, acc_id) VALUES (1, 101),(2, 102),(3, 103),(4, 104),(5, 105);

CREATE TABLE ms_acc_dimension (acc_id INT PRIMARY KEY,paying_customer VARCHAR(10));
INSERT INTO ms_acc_dimension (acc_id, paying_customer) VALUES (101, 'Yes'),(102, 'No'),(103, 'Yes'),(104, 'No'),(105, 'No');

CREATE TABLE ms_download_facts (date DATETIME,user_id INT,downloads INT);
INSERT INTO ms_download_facts (date, user_id, downloads) VALUES ('2024-10-01', 1, 10),('2024-10-01', 2, 15),('2024-10-02', 1, 8),('2024-10-02', 3, 12),('2024-10-02', 4, 20),('2024-10-03', 2, 25),('2024-10-03', 5, 18);

SELECT * FROM ms_user_dimension;

SELECT * FROM ms_acc_dimension;

SELECT * FROM ms_download_facts;

WITH USER_LIST AS (
SELECT D.DATE,
SUM(CASE WHEN ACC.PAYING_CUSTOMER = 'Yes' then d.downloads else 0 end) as PAYTING_CUSTOMER,
SUM(CASE WHEN ACC.PAYING_CUSTOMER = 'No' then d.downloads else 0 end) as NON_PAYTING_CUSTOMER
FROM ms_user_dimension U
JOIN ms_acc_dimension ACC ON 
U.ACC_ID = ACC.ACC_ID
JOIN ms_download_facts D ON 
D.USER_ID = U.USER_ID
GROUP BY D.DATE)
SELECT DATE,  
PAYTING_CUSTOMER, NON_PAYTING_CUSTOMER
FROM USER_LIST
WHERE NON_PAYTING_CUSTOMER > PAYTING_CUSTOMER
ORDER BY DATE;


WITH cte AS (SELECT CAST(date as DATE) as date,
SUM(CASE WHEN paying_customer='yes' THEN downloads ELSE 0 END) as paying_downloads,
SUM(CASE WHEN paying_customer='No' THEN downloads ELSE 0 END) as non_paying_downloads
FROM ms_acc_dimension ms_a
INNER JOIN ms_user_dimension ms_u
ON ms_a.acc_id=ms_u.acc_id
INNER JOIN ms_download_facts ms_d
ON ms_u.user_id=ms_d.user_id
GROUP BY date)

SELECT * FROM cte 
WHERE non_paying_downloads>paying_downloads
ORDER BY date;



--
-- Find managers with at least 7 direct reporting employees. In situations where user is reporting to himself/herself, count that also.
-- Output first names of managers.

CREATE TABLE employees (id INT PRIMARY KEY,first_name VARCHAR(50),last_name VARCHAR(50),age INT,sex VARCHAR(10),employee_title VARCHAR(50),department VARCHAR(50),salary INT,target INT,bonus INT,email VARCHAR(100),city VARCHAR(50),address VARCHAR(255),manager_id INT);

INSERT INTO employees (id, first_name, last_name, age, sex, employee_title, department, salary, target, bonus, email, city, address, manager_id) VALUES(1, 'Alice', 'Smith', 40, 'F', 'Manager', 'Sales', 90000, 100000, 15000, 'alice.smith@example.com', 'New York', '123 Main St', 1),(2, 'Bob', 'Johnson', 35, 'M', 'Team Lead', 'Sales', 80000, 95000, 12000, 'bob.johnson@example.com', 'Chicago', '456 Oak St', 1),(3, 'Carol', 'Williams', 30, 'F', 'Sales Executive', 'Sales', 70000, 85000, 10000, 'carol.williams@example.com', 'New York', '789 Pine St', 1),(4, 'David', 'Brown', 28, 'M', 'Sales Executive', 'Sales', 68000, 80000, 9000, 'david.brown@example.com', 'Chicago', '101 Maple St', 1),(5, 'Emma', 'Jones', 32, 'F', 'Sales Executive', 'Sales', 71000, 86000, 9500, 'emma.jones@example.com', 'New York', '202 Cedar St', 1),(6, 'Frank', 'Miller', 45, 'M', 'Manager', 'Engineering', 95000, 105000, 16000, 'frank.miller@example.com', 'San Francisco', '303 Spruce St', 6),(7, 'Grace', 'Davis', 29, 'F', 'Engineer', 'Engineering', 73000, 87000, 11000, 'grace.davis@example.com', 'San Francisco', '404 Willow St', 6);


SELECT ID, FIRST_NAME, MANAGER_ID FROM employees;


SELECT E.FIRST_NAME AS MANAGER_NAME
FROM employees E
JOIN EMPLOYEES M
ON  M.MANAGER_ID = E.ID 
GROUP BY E.id,E.FIRST_NAME
HAVING COUNT(M.ID)>=5;

SELECT M.FIRST_NAME AS MANAGER_NAME
FROM employees E
JOIN EMPLOYEES M
ON  M.MANAGER_ID =E.ID 
GROUP BY M.id,M.FIRST_NAME
HAVING COUNT(E.ID)>=5;

SELECT 
    M.FIRST_NAME AS MANAGER_NAME
FROM 
    employees E
JOIN 
    employees M
ON 
    E.MANAGER_ID = M.ID
GROUP BY 
    M.ID, M.FIRST_NAME
HAVING 
    COUNT(E.ID) >= 5;




SELECT 
    e.first_name
FROM 
    employees e
JOIN 
    employees m
ON 
    e.id = m.manager_id
GROUP BY 
    e.id, e.first_name
HAVING 
    COUNT(m.id) >= 6;


SELECT EE1.Mgr_id, EE1.Mgr_first_name,
COUNT(DISTINCT EE1.emp_id) AS reportee_count
FROM
(SELECT *, E1.emp_id AS Mgr_id, 
E1.first_name as Mgr_first_name
FROM Employees E 
LEFT JOIN Employees E1
ON E.manager_id = E1.emp_id) EE1
GROUP BY EE1.Mgr_id
HAVING reportee_count>=7;


--23
-- Write a query that compares each employee's salary to their manager's and the average department salary (excluding the manager's salary). Display the department, employee ID, employee's salary, manager's salary, and department average salary. Order by department, then by employee salary (highest to lowest).


CREATE TABLE employee_o (id INT PRIMARY KEY,first_name VARCHAR(50),last_name VARCHAR(50),age INT,gender VARCHAR(10),employee_title VARCHAR(50),department VARCHAR(50),salary INT,manager_id INT);

INSERT INTO employee_o (id, first_name, last_name, age, gender, employee_title, department, salary, manager_id) VALUES(1, 'Alice', 'Smith', 45, 'F', 'Manager', 'HR', 9000, 1),(2, 'Bob', 'Johnson', 34, 'M', 'Assistant', 'HR', 4500, 1),(3, 'Charlie', 'Williams', 28, 'M', 'Coordinator', 'HR', 4800, 1),(4, 'Diana', 'Brown', 32, 'F', 'Manager', 'IT', 12000, 4),(5, 'Eve', 'Jones', 27, 'F', 'Analyst', 'IT', 7000, 4),(6, 'Frank', 'Garcia', 29, 'M', 'Developer', 'IT', 7500, 4),(7, 'Grace', 'Miller', 30, 'F', 'Manager', 'Finance', 10000, 7),(8, 'Hank', 'Davis', 26, 'M', 'Analyst', 'Finance', 6200, 7),(9, 'Ivy', 'Martinez', 31, 'F', 'Clerk', 'Finance', 5900, 7),(10, 'John', 'Lopez', 36, 'M', 'Manager', 'Marketing', 11000, 10),(11, 'Kim', 'Gonzales', 29, 'F', 'Specialist', 'Marketing', 6800, 10),(12, 'Leo', 'Wilson', 27, 'M', 'Coordinator', 'Marketing', 6600, 10);


SELECT * FROM employee_o;


SELECT DEPARTMENT, ID, SALARY,  SALARY AS MANAGER_SALARY, MANAGER_ID
FROM EMPLOYEE_O;

WITH DEPT_AVG AS (
SELECT DEPARTMENT, ROUND(AVG(SALARY)) AS AVG_DEPT_SAL
FROM EMPLOYEE_O
WHERE EMPLOYEE_O.ID!= EMPLOYEE_O.MANAGER_ID 
GROUP BY DEPARTMENT
)
SELECT E.DEPARTMENT, E.ID, E.SALARY AS EMP_SAL, 
CASE WHEN E.ID = E.MANAGER_ID THEN null else M.salary end as manger_Sal, 
E.MANAGER_ID, D.AVG_DEPT_SAL
FROM EMPLOYEE_O E 
JOIN DEPT_AVG D
ON E.DEPARTMENT = D.DEPARTMENT
join employee_o m
on E.MANAGER_ID = M.ID
order by e.department , E.SALARY desc;


SELECT 
    E.DEPARTMENT,
    E.ID,
    E.SALARY AS EMP_SAL,
    CASE 
        WHEN E.ID = E.MANAGER_ID THEN NULL 
        ELSE M.SALARY 
    END AS MANAGER_SAL,
    E.MANAGER_ID
FROM EMPLOYEE_O E
left JOIN EMPLOYEE_O M
    ON E.MANAGER_ID = M.ID
ORDER BY E.DEPARTMENT, E.ID;


SELECT 
    E.DEPARTMENT,
    E.ID,
    E.SALARY AS EMP_SAL,
    CASE 
        WHEN E.ID = E.MANAGER_ID THEN NULL 
        ELSE M.SALARY 
    END AS MANAGER_SAL,
    E.MANAGER_ID
FROM EMPLOYEE_O E
INNER JOIN EMPLOYEE_O M
    ON E.MANAGER_ID = M.ID
ORDER BY E.DEPARTMENT, E.ID;

SELECT 
    E.first_name AS employee_name,
    M.first_name AS manager_name,
    E.salary AS emp_salary,
    M.salary AS manager_salary
FROM employee_o E
JOIN employee_o M
    ON E.manager_id = M.id;


--26

CREATE TABLE innerwear_amazon_com (product_name VARCHAR(255),mrp VARCHAR(50),price VARCHAR(50),pdp_url VARCHAR(255),brand_name VARCHAR(100),product_category VARCHAR(100),retailer VARCHAR(100),description VARCHAR(255),rating FLOAT,review_count INT,style_attributes VARCHAR(255),total_sizes VARCHAR(50),available_size VARCHAR(50),color VARCHAR(50));

CREATE TABLE innerwear_macys_com (product_name VARCHAR(255),mrp VARCHAR(50),price VARCHAR(50),pdp_url VARCHAR(255),brand_name VARCHAR(100),product_category VARCHAR(100),retailer VARCHAR(100),description VARCHAR(255),rating FLOAT,review_count FLOAT,style_attributes VARCHAR(255),total_sizes VARCHAR(50),available_size VARCHAR(50),color VARCHAR(50));

CREATE TABLE innerwear_topshop_com (product_name VARCHAR(255),mrp VARCHAR(50),price VARCHAR(50),pdp_url VARCHAR(255),brand_name VARCHAR(100),product_category VARCHAR(100),retailer VARCHAR(100),description VARCHAR(255),rating FLOAT,review_count FLOAT,style_attributes VARCHAR(255),total_sizes VARCHAR(50),available_size VARCHAR(50),color VARCHAR(50));


INSERT INTO innerwear_topshop_com (product_name, mrp, price, pdp_url, brand_name, product_category, retailer, description, rating, review_count, style_attributes, total_sizes, available_size, color) VALUES ('ProductB', '200', '190', 'url7', 'BrandB', 'Category1', 'TopShop', 'DescriptionB', 4.1, 95, 'StyleB', 'S,M,L', 'M', 'Blue'),('ProductF', '100', '90', 'url8', 'BrandF', 'Category3', 'TopShop', 'DescriptionF', 3.5, 50, 'StyleF', 'XS,S', 'S', 'Pink'),('ProductG', '300', '270', 'url9', 'BrandG', 'Category5', 'TopShop', 'DescriptionG', 4.3, 70, 'StyleG', 'M,L,XL', 'M', 'Purple');

INSERT INTO innerwear_amazon_com (product_name, mrp, price, pdp_url, brand_name, product_category, retailer, description, rating, review_count, style_attributes, total_sizes, available_size, color) VALUES ('ProductA', '100', '80', 'url1', 'BrandA', 'Category1', 'Amazon', 'DescriptionA', 4.5, 100, 'StyleA', 'M,L', 'M', 'Red'),('ProductB', '200', '180', 'url2', 'BrandB', 'Category1', 'Amazon', 'DescriptionB', 4.2, 150, 'StyleB', 'S,M,L', 'S', 'Blue'),('ProductC', '300', '250', 'url3', 'BrandC', 'Category2', 'Amazon', 'DescriptionC', 4.8, 200, 'StyleC', 'L,XL', 'L', 'Green');

INSERT INTO innerwear_macys_com (product_name, mrp, price, pdp_url, brand_name, product_category, retailer, description, rating, review_count, style_attributes, total_sizes, available_size, color) VALUES ('ProductA', '100', '85', 'url4', 'BrandA', 'Category1', 'Macys', 'DescriptionA', 4.5, 90, 'StyleA', 'M,L', 'M', 'Red'),('ProductD', '150', '130', 'url5', 'BrandD', 'Category3', 'Macys', 'DescriptionD', 4.0, 80, 'StyleD', 'S,M', 'S', 'Yellow'),('ProductE', '250', '210', 'url6', 'BrandE', 'Category4', 'Macys', 'DescriptionE', 3.9, 60, 'StyleE', 'M,L', 'L', 'Black');


-- Find products which are exclusive to only Amazon and therefore not sold at Top Shop and Macy's. Your output should include the product name, brand name, price, and rating.

SELECT * FROM innerwear_topshop_com;

SELECT * FROM innerwear_amazon_com;

SELECT * FROM innerwear_macys_com;


select PRODUCT_NAME, BRAND_NAME, PRICE, RATING
from innerwear_amazon_com where PRODUCT_NAME not in(
SELECT A.PRODUCT_NAME
FROM innerwear_amazon_com A
JOIN innerwear_topshop_com T
ON A.PRODUCT_NAME = T.PRODUCT_NAME
union all
SELECT A.PRODUCT_NAME
FROM innerwear_amazon_com A
JOIN innerwear_macys_com M
ON M.PRODUCT_NAME = A.PRODUCT_NAME);


SELECT 
A.PRODUCT_NAME,
A.BRAND_NAME, 
A.PRICE, 
A.RATING
FROM innerwear_amazon_com A
LEFT JOIN innerwear_macys_com M
ON M.PRODUCT_NAME = A.PRODUCT_NAME
LEFT JOIN innerwear_topshop_com T
ON A.PRODUCT_NAME = T.PRODUCT_NAME
WHERE M.PRODUCT_NAME IS NULL AND T.PRODUCT_NAME IS NULL;


--
CREATE TABLE customers (id INT,first_name VARCHAR(50),last_name VARCHAR(50),city VARCHAR(100),address VARCHAR(200),phone_number VARCHAR(20));

INSERT INTO customers (id, first_name, last_name, city, address, phone_number) VALUES(1, 'Jill', 'Doe', 'New York', '123 Main St', '555-1234'),(2, 'Henry', 'Smith', 'Los Angeles', '456 Oak Ave', '555-5678'),(3, 'William', 'Johnson', 'Chicago', '789 Pine Rd', '555-8765'),(4, 'Emma', 'Daniel', 'Houston', '321 Maple Dr', '555-4321'),(5, 'Charlie', 'Davis', 'Phoenix', '654 Elm St', '555-6789');

CREATE TABLE card_orders (order_id INT,cust_id INT,order_date DATETIME,order_details VARCHAR(255),total_order_cost INT);

INSERT INTO card_orders (order_id, cust_id, order_date, order_details, total_order_cost) VALUES(1, 1, '2024-11-01 10:00:00', 'Electronics', 200),(2, 2, '2024-11-02 11:30:00', 'Groceries', 150),(3, 1, '2024-11-03 15:45:00', 'Clothing', 120),(4, 3, '2024-11-04 09:10:00', 'Books', 90),(8, 3, '2024-11-08 10:20:00', 'Groceries', 130),(9, 1, '2024-11-09 12:00:00', 'Books', 180),(10, 4, '2024-11-10 11:15:00', 'Electronics', 200),(11, 5, '2024-11-11 14:45:00', 'Furniture', 150),(12, 2, '2024-11-12 09:30:00', 'Furniture', 180);


SELECT * FROM customers;

SELECT * FROM card_orders;

-- American Express is reviewing their customers' transactions, and you have been tasked with locating the customer who has the third highest total transaction amount. The output should include the customer's id, as well as their first name and last name. For ranking the customers, use type of ranking with no gaps between subsequent ranks.




WITH ORDERS_SUM AS (
SELECT CUST_ID, SUM(O.TOTAL_ORDER_COST) AS ORDER_VALUE
FROM card_orders O
GROUP BY CUST_ID),
 RANK_CTE AS(
SELECT *, 
DENSE_RANK() OVER (ORDER BY ORDER_VALUE DESC) AS RANKS 
FROM ORDERS_SUM)
SELECT C.ID, C.FIRST_NAME, C.LAST_NAME
FROM customers C
JOIN RANK_CTE R
ON C.ID = R.CUST_ID
WHERE R.RANKS = 3;


SELECT C.ID, C.FIRST_NAME, C.LAST_NAME, SUM(O.TOTAL_ORDER_COST) AS ORDER_VALUE
FROM customers C
JOIN card_orders O
ON C.ID = O.CUST_ID
GROUP BY ID, C.FIRST_NAME, C.LAST_NAME;


--26
-- Consider all LinkedIn users who, at some point, worked at Microsoft. For how many of them was Google their next employer right after Microsoft (no employers in between)?

CREATE TABLE linkedin_users (user_id INT,employer VARCHAR(255),position VARCHAR(255),start_date DATETIME,end_date DATETIME);

INSERT INTO linkedin_users (user_id, employer, position, start_date, end_date) VALUES(1, 'Microsoft', 'developer', '2020-04-13', '2021-11-01'),(1, 'Google', 'developer', '2021-11-01', NULL),(2, 'Google', 'manager', '2021-01-01', '2021-01-11'),(2, 'Microsoft', 'manager', '2021-01-11', NULL),(3, 'Microsoft', 'analyst', '2019-03-15', '2020-07-24'),(3, 'Amazon', 'analyst', '2020-08-01', '2020-11-01'),(3, 'Google', 'senior analyst', '2020-11-01', '2021-03-04'),(4, 'Google', 'junior developer', '2018-06-01', '2021-11-01'),(4, 'Google', 'senior developer', '2021-11-01', NULL),(5, 'Microsoft', 'manager', '2017-09-26', NULL),(6, 'Google', 'CEO', '2015-10-02', NULL);


SELECT * FROM Linkedin_users;

WITH NEXT_EMP_CTE AS (
SELECT USER_ID, START_DATE, END_DATE,EMPLOYER AS CURRENT_EMPLOYER,
LEAD(EMPLOYER) OVER(PARTITION BY USER_ID ORDER BY START_DATE ASC) AS NEXT_EMPLOYER
FROM linkedin_users)
SELECT USER_ID,CURRENT_EMPLOYER,NEXT_EMPLOYER
FROM NEXT_EMP_CTE
WHERE CURRENT_EMPLOYER ='Microsoft' AND NEXT_EMPLOYER = 'Google';

-- You are given a day worth of scheduled departure and arrival times of trains at one train station. One platform can only accommodate one train from the beginning of the minute it's scheduled to arrive until the end of the minute it's scheduled to depart. Find the minimum number of platforms necessary to accommodate the entire scheduled traffic.

CREATE TABLE train_arrivals (train_id INT, arrival_time DATETIME);

INSERT INTO train_arrivals (train_id, arrival_time) VALUES(1, '2024-11-17 08:00'),(2, '2024-11-17 08:05'),(3, '2024-11-17 08:05'),(4, '2024-11-17 08:10'),(5, '2024-11-17 08:10'),(6, '2024-11-17 12:15'),(7, '2024-11-17 12:20'),(8, '2024-11-17 12:25'),(9, '2024-11-17 15:00'),(10, '2024-11-17 15:00'),(11, '2024-11-17 15:00'),(12, '2024-11-17 15:06'),(13, '2024-11-17 20:00'),(14, '2024-11-17 20:10');

CREATE TABLE train_departures (train_id INT, departure_time DATETIME);

INSERT INTO train_departures (train_id, departure_time) VALUES(1, '2024-11-17 08:15'),(2, '2024-11-17 08:10'),(3, '2024-11-17 08:20'),(4, '2024-11-17 08:25'),(5, '2024-11-17 08:20'),(6, '2024-11-17 13:00'),(7, '2024-11-17 12:25'),(8, '2024-11-17 12:30'),(9, '2024-11-17 15:05'),(10, '2024-11-17 15:10'),(11, '2024-11-17 15:15'),(12, '2024-11-17 15:15'),(13, '2024-11-17 20:15'),(14, '2024-11-17 20:15');

SELECT * FROM train_arrivals;

SELECT * FROM train_departures;

WITH TRAIN_CTE AS (
SELECT TRAIN_ID,  ARRIVAL_TIME AS event_time,
1 AS event_type
FROM train_arrivals
UNION ALL 
SELECT TRAIN_ID,  DEPARTURE_TIME AS event_time,
-1 AS event_type
FROM train_departures )
SELECT MAX(PLATFORMS_NEEDED) AS TOTAL_PLATFORMS FROM (
SELECT TRAIN_ID,event_time ,event_type, 
SUM(event_type) OVER (ORDER BY event_time ASC) AS PLATFORMS_NEEDED 
FROM TRAIN_CTE
);


WITH TrainTimes AS (
    SELECT arrival_time AS event_time,
           1 AS event_type
    FROM train_arrivals
    UNION ALL
    SELECT departure_time AS event_time,
           -1 AS event_type
    FROM train_departures
)
SELECT MAX(platforms_needed) AS min_platforms
FROM (
    SELECT event_time,
           SUM(event_type) OVER (ORDER BY event_time) AS platforms_needed
    FROM TrainTimes
) AS PlatformCount;



--28

CREATE TABLE employee(id INT,first_name VARCHAR(50),last_name VARCHAR(50),age INT,sex VARCHAR(1),employee_title VARCHAR(50),department VARCHAR(50),salary INT,target INT,bonus INT,email VARCHAR(100),city VARCHAR(50),address VARCHAR(100),manager_id INT);

INSERT INTO employee (id, first_name, last_name, age, sex, employee_title, department, salary, target, bonus, email, city, address, manager_id)VALUES(5, 'Max', 'George', 26, 'M', 'Sales', 'Sales', 1300, 200, 150, 'Max@company.com', 'California', '2638 Richards Avenue', 1),(13, 'Katty', 'Bond', 56, 'F', 'Manager', 'Management', 150000, 0, 300, 'Katty@company.com', 'Arizona', NULL, 1),(11, 'Richerd', 'Gear', 57, 'M', 'Manager', 'Management', 250000, 0, 300, 'Richerd@company.com', 'Alabama', NULL, 1),(10, 'Jennifer', 'Dion', 34, 'F', 'Sales', 'Sales', 1000, 200, 150, 'Jennifer@company.com', 'Alabama', NULL, 13),(19, 'George', 'Joe', 50, 'M', 'Manager', 'Management', 250000, 0, 300, 'George@company.com', 'Florida', '1003 Wyatt Street', 1),(18, 'Laila', 'Mark', 26, 'F', 'Sales', 'Sales', 1000, 200, 150, 'Laila@company.com', 'Florida', '3655 Spirit Drive', 11),(20, 'Sarrah', 'Bicky', 31, 'F', 'Senior Sales', 'Sales', 2000, 200, 150, 'Sarrah@company.com', 'Florida', '1176 Tyler Avenue', 19);


-- Find the highest salary among salaries that appears only once.
SELECT * FROM employee;

select max(salary) as salary from(
select  salary, count(*) as total_count
from employee 
group by salary) 
where total_count = 1;


--
-- Convert the first letter of each word found in content_text to uppercase, while keeping the rest of the letters lowercase. Your output should include the original text in one column and the modified text in another column.

CREATE TABLE user_content (content_id INT PRIMARY KEY,customer_id INT,content_type VARCHAR(50),content_text VARCHAR(255));

INSERT INTO user_content (content_id, customer_id, content_type, content_text) VALUES(1, 2, 'comment', 'hello world! this is a TEST.'),(2, 8, 'comment', 'what a great day'),(3, 4, 'comment', 'WELCOME to the event.'),(4, 2, 'comment', 'e-commerce is booming.'),(5, 6, 'comment', 'Python is fun!!'),(6, 6, 'review', '123 numbers in text.'),(7, 10, 'review', 'special chars: @#$$%^&*()'),(8, 4, 'comment', 'multiple CAPITALS here.'),(9, 6, 'review', 'sentence. and ANOTHER sentence!'),(10, 2, 'post', 'goodBYE!');


SELECT * FROM user_content;

select content_text, 
upper(left(lower_content, 1))||substr(content_text,2) as modified_text 
from(select content_text, lower(content_text) as lower_content
from user_content);


SELECT content_text,
UPPER(LEFT(content_text, 1)) || LOWER(SUBSTR(content_text, 2)) AS modified_text
FROM user_content;


SELECT
content_text AS original_text,
INITCAP(content_text) AS modified_text
FROM user_content;



--30

-- Given the users' sessions logs on a particular day, calculate how many hours each user was active that day. Note: The session starts when state=1 and ends when state=0.

CREATE TABLE customer_state_log (cust_id VARCHAR(10),state INT,timestamp TIME);

INSERT INTO customer_state_log (cust_id, state, timestamp) VALUES('c001', 1, '07:00:00'),('c001', 0, '09:30:00'),('c001', 1, '12:00:00'),('c001', 0, '14:30:00'),('c002', 1, '08:00:00'),('c002', 0, '09:30:00'),('c002', 1, '11:00:00'),('c002', 0, '12:30:00'),('c002', 1, '15:00:00'),('c002', 0, '16:30:00'),('c003', 1, '09:00:00'),('c003', 0, '10:30:00'),('c004', 1, '10:00:00'),('c004', 0, '10:30:00'),('c004', 1, '14:00:00'),('c004', 0, '15:30:00'),('c005', 1, '10:00:00'),('c005', 0, '14:30:00'),('c005', 1, '15:30:00'),('c005', 0, '18:30:00');

SELECT * FROM customer_state_log;

WITH CUST_IN_OUT_CTE AS (
SELECT CUST_ID, 
CASE WHEN STATE = 1 THEN TIMESTAMP END AS CUST_IN,
CASE WHEN STATE = 0 THEN TIMESTAMP END AS CUST_OUT
FROM customer_state_log),
CUSTOMER_DIFF_CTE AS(
SELECT CUST_ID, 
CUST_IN,
LEAD(CUST_OUT) OVER (PARTITION BY CUST_ID ORDER BY CUST_ID) AS CUSTOMER_OUT
FROM CUST_IN_OUT_CTE),
 MINUTES_DIFF AS(
SELECT CUST_ID,CUST_IN, CUSTOMER_OUT,
DATEDIFF(MINUTE, CUST_IN::TIME,CUSTOMER_OUT::TIME) AS TOTAL_MINS
FROM CUSTOMER_DIFF_CTE
WHERE CUST_IN IS NOT NULL)
SELECT CUST_ID,
ROUND(SUM(TOTAL_MINS)/60,1) AS TOTAL_HOURS
FROM MINUTES_DIFF
GROUP BY CUST_ID 
ORDER BY CUST_ID;

WITH session_pairs AS (
SELECT cust_id,
timestamp AS start_time,
LEAD(timestamp) OVER (PARTITION BY cust_id ORDER BY timestamp) AS end_time,
state
FROM customer_state_log
)
SELECT cust_id,
ROUND(SUM(DATEDIFF('minute', start_time, end_time)) / 60, 1) AS total_hours
FROM session_pairs
WHERE state = 1  
GROUP BY cust_id
ORDER BY cust_id;

--31
-- Find the number of days a US track has stayed in the 1st position for both the US and worldwide rankings on the same day. Output the track name and the number of days in the 1st position. Order your output alphabetically by track name. If the region 'US' appears in dataset, it should be included in the worldwide ranking


CREATE TABLE spotify_daily_rankings_2017_us (position INT,trackname VARCHAR(255),artist VARCHAR(255),streams INT,url VARCHAR(255),date DATETIME);

INSERT INTO spotify_daily_rankings_2017_us (position, trackname, artist, streams, url, date)VALUES(1, 'Track A', 'Artist 1', 500000, 'https://url1.com', '2017-01-01'),(2, 'Track B', 'Artist 2', 400000, 'https://url2.com', '2017-01-01'),(1, 'Track A', 'Artist 1', 520000, 'https://url1.com', '2017-01-02'),(3, 'Track C', 'Artist 3', 300000, 'https://url3.com', '2017-01-02'),(1, 'Track D', 'Artist 4', 600000, 'https://url4.com', '2017-01-03');

CREATE TABLE spotify_worldwide_daily_song_ranking (id INT,position INT,trackname VARCHAR(255),artist VARCHAR(255),streams INT,url VARCHAR(255),date DATETIME,region VARCHAR(50));

INSERT INTO spotify_worldwide_daily_song_ranking (id, position, trackname, artist, streams, url, date, region)VALUES(1, 1, 'Track A', 'Artist 1', 550000, 'https://url1.com', '2017-01-01', 'US'),(2, 2, 'Track B', 'Artist 2', 450000, 'https://url2.com', '2017-01-01', 'US'),(3, 1, 'Track A', 'Artist 1', 530000, 'https://url1.com', '2017-01-02', 'US'),(4, 1, 'Track D', 'Artist 4', 610000, 'https://url4.com', '2017-01-03', 'US'),(5, 3, 'Track C', 'Artist 3', 320000, 'https://url3.com', '2017-01-03', 'US');


SELECT * FROM spotify_daily_rankings_2017_us;
SELECT * FROM spotify_worldwide_daily_song_ranking;


SELECT U.TRACKNAME, COUNT(*) AS FIRST_POSITION_COUNT
FROM spotify_daily_rankings_2017_us U
JOIN spotify_worldwide_daily_song_ranking W
ON U.TRACKNAME = W.TRACKNAME AND
U.DATE = W.DATE
WHERE U.POSITION =1 AND W.POSITION = 1 
AND W.REGION = 'US'
GROUP BY U.TRACKNAME
ORDER BY TRACKNAME;

-- 1	Track A	Artist 1	500000	https://url1.com	2017-01-01 00:00:00.000
-- 1	Track A	Artist 1	520000	https://url1.com	2017-01-02 00:00:00.000
-- 1	Track D	Artist 4	600000	https://url4.com	2017-01-03 00:00:00.000

-- 1	1	Track A	Artist 1	550000	https://url1.com	2017-01-01 00:00:00.000	US
-- 3	1	Track A	Artist 1	530000	https://url1.com	2017-01-02 00:00:00.000	US
-- 4	1	Track D	Artist 4	610000	https://url4.com	2017-01-03 00:00:00.000	US



--32


-- Following a recent advertising campaign, the marketing department wishes to classify its efforts based on the total number of units sold for each product.

-- You have been tasked with calculating the total number of units sold for each product and categorizing ad performance based on the following criteria for items sold:

-- Outstanding: 30+
-- Satisfactory: 20 - 29
-- Unsatisfactory: 10 - 19
-- Poor: 1 - 9


CREATE TABLE marketing_campaign (user_id INT,created_at DATETIME,product_id INT,quantity INT,price INT);

INSERT INTO marketing_campaign (user_id, created_at, product_id, quantity, price) VALUES(1, '2020-01-01', 101, 25, 200),(2, '2020-01-01', 102, 5, 150),(3, '2020-01-02', 103, 15, 300),(4, '2020-01-03', 101, 10, 200),(5, '2020-01-04', 102, 22, 150),(6, '2020-01-05', 104, 8, 120),(7, '2020-01-06', 105, 18, 250),(8, '2020-01-07', 101, 30, 200),(9, '2020-01-08', 103, 20, 300),(10, '2020-01-09', 104, 9, 120);


select * from marketing_campaign;


WITH TOTAL_QTY_CTE AS (
SELECT PRODUCT_ID, SUM(QUANTITY) AS TOTAL_QUANTITY_SOLD
FROM marketing_campaign
GROUP BY PRODUCT_ID)
SELECT *, 
CASE 
WHEN TOTAL_QUANTITY_SOLD >= 30 THEN 'Outstanding'
WHEN TOTAL_QUANTITY_SOLD  BETWEEN 20 AND 29 THEN 'Satisfactory'
WHEN TOTAL_QUANTITY_SOLD  BETWEEN 10 AND 19 THEN 'Unsatisfactory'
WHEN TOTAL_QUANTITY_SOLD  BETWEEN 1 AND 9 THEN 'POOR'
ELSE 'NO_SLAES' END AS RATINGS 
FROM TOTAL_QTY_CTE
ORDER BY TOTAL_QUANTITY_SOLD DESC;


--32

-- Calculate the average session distance traveled by Google Fit users using GPS data for two scenarios:
--  Considering Earth's curvature (Haversine formula).
--  Assuming a flat surface.
-- For each session, use the distance between the highest and lowest step IDs, and ignore sessions with only one step. Calculate and output the average distance for both scenarios and the difference between them.

-- Formulas:
-- 1. Curved Earth: d=6371×arccos(sin(ϕ1​)×sin(ϕ2​)+cos(ϕ1​)×cos(ϕ2​)×cos(λ2​−λ1​))
-- 2. Flat Surface: d=111×(lat2​−lat1​)2+(lon2​−lon1​)


CREATE TABLE google_fit_location (user_id VARCHAR(50),session_id INT,step_id INT,day INT,latitude FLOAT,longitude FLOAT,altitude FLOAT);

INSERT INTO google_fit_location (user_id, session_id, step_id, day, latitude, longitude, altitude)VALUES('user_1', 101, 1, 1, 37.7749, -122.4194, 15.0),('user_1', 101, 2, 1, 37.7750, -122.4195, 15.5),('user_1', 101, 3, 1, 37.7751, -122.4196, 16.0),('user_1', 102, 1, 1, 34.0522, -118.2437, 20.0),('user_1', 102, 2, 1, 34.0523, -118.2438, 20.5),('user_2', 201, 1, 1, 40.7128, -74.0060, 5.0),('user_2', 201, 2, 1, 40.7129, -74.0061, 5.5),('user_2', 202, 1, 1, 51.5074, -0.1278, 10.0),('user_2', 202, 2, 1, 51.5075, -0.1279, 10.5),('user_3', 301, 1, 1, 48.8566, 2.3522, 25.0),('user_3', 301, 2, 1, 48.8567, 2.3523, 25.5);


select * from google_fit_location;


WITH endpoints AS (
SELECT user_id,SESSION_ID, MIN(STEP_ID) AS MIN_STEP, MAX(STEP_ID) AS MAX_STEP
FROM google_fit_location
GROUP BY user_id,SESSION_ID
HAVING COUNT(*) > 1),
COORDS AS(
SELECT 
E.USER_ID, E.SESSION_ID, 
MN.LATITUDE AS LAT1, MN.LONGITUDE AS LON1, MX.LATITUDE AS LAT2, MX.LONGITUDE AS LON2
FROM endpoints E
JOIN google_fit_location MN
ON E.USER_ID = MN.USER_ID AND E.SESSION_ID=MN.SESSION_ID AND E.MIN_STEP = MN.STEP_ID
JOIN google_fit_location MX
ON E.USER_ID = MX.USER_ID AND E.SESSION_ID=MX.SESSION_ID AND E.MAX_STEP = MX.STEP_ID),
per_session AS (
SELECT
user_id,session_id,
6371 * ACOS(
SIN(RADIANS(lat1)) * SIN(RADIANS(lat2))
+ COS(RADIANS(lat1)) * COS(RADIANS(lat2)) * COS(RADIANS(lon2 - lon1))
) AS dist_curved_km,
111 * SQRT( POWER(lat2 - lat1, 2) + POWER(lon2 - lon1, 2) ) AS dist_flat_km
FROM COORDS)
SELECT COUNT(USER_ID) AS TOTAL_USERS,
AVG(DIST_CURVED_KM) AS AVERAGE_CURVED_KM,
AVG(DIST_FLAT_KM) AS AVGERAGE_FLAT_KM,
AVG(DIST_CURVED_KM) - AVG(DIST_FLAT_KM) AS avg_difference_km
FROM per_session;







---34


CREATE TABLE hotel_address (hotel_address VARCHAR(255),additional_number_of_scoring INT,review_date DATETIME,average_score FLOAT,
hotel_name VARCHAR(255),reviewer_nationality VARCHAR(50),negative_review VARCHAR(MAX),review_total_negative_word_counts INT,total_number_of_reviews INT,positive_review VARCHAR(MAX),review_total_positive_word_counts INT,total_number_of_reviews_reviewer_has_given INT,reviewer_score FLOAT,tags VARCHAR(255),days_since_review VARCHAR(50),lat FLOAT,lng FLOAT);

INSERT INTO hotel_address (hotel_address, additional_number_of_scoring, review_date, average_score, hotel_name, reviewer_nationality, negative_review, review_total_negative_word_counts, total_number_of_reviews, positive_review, review_total_positive_word_counts, total_number_of_reviews_reviewer_has_given, reviewer_score, tags, days_since_review, lat, lng)VALUES('123 Ocean Ave, Miami, FL', 3, '2024-11-10', 4.2, 'Ocean View', 'American', 'Room small, but clean.', 5, 150, 'Great location and friendly staff!', 8, 30, 4.5, 'beachfront, family-friendly', '5 days', 25.7617, -80.1918),('456 Mountain Rd, Boulder, CO', 2, '2024-11-12', 3.9, 'Mountain Lodge', 'Canadian', 'wifi slow.', 3, 120, 'nice rooms.', 10, 20, 4.0, 'scenic, nature', '3 days', 40.015, -105.2705),('789 Downtown St, New York, NY', 5, '2024-11-15', 4.7, 'Central Park Hotel', 'British', 'Noisy, sleep.', 7, 200, 'Perfect location near Central Park.', 12, 50, 4.7, 'luxury, city-center', '1 day', 40.7831, -73.9712),('101 Lakeside Blvd, Austin, TX', 1, '2024-11-08', 4.0, 'Lakeside Inn', 'Mexican', 'food avg.', 4, 80, 'Nice, friendly service.', 6, 15, 3.8, 'relaxing, family', '10 days', 30.2672, -97.7431),('202 River Ave, Nashville, TN', 4, '2024-11-13', 4.5, 'Riverside', 'German', 'Limited parking', 2, 175, 'Great rooms.', 9, 25, 4.2, 'riverfront, peaceful', '2 days', 36.1627, -86.7816);


-- Find the three ten hotels with the highest ratings. Output the hotel name along with the corresponding average score. Sort records based on the average score in descending order.


CREATE TABLE hotel_address (hotel_address VARCHAR(255),additional_number_of_scoring INT,review_date DATETIME,average_score FLOAT,
hotel_name VARCHAR(255),reviewer_nationality VARCHAR(50),negative_review VARCHAR(255),review_total_negative_word_counts INT,total_number_of_reviews INT,positive_review VARCHAR(244),review_total_positive_word_counts INT,total_number_of_reviews_reviewer_has_given INT,reviewer_score FLOAT,tags VARCHAR(255),days_since_review VARCHAR(50),lat FLOAT,lng FLOAT);

INSERT INTO hotel_address (hotel_address, additional_number_of_scoring, review_date, average_score, hotel_name, reviewer_nationality, negative_review, review_total_negative_word_counts, total_number_of_reviews, positive_review, review_total_positive_word_counts, total_number_of_reviews_reviewer_has_given, reviewer_score, tags, days_since_review, lat, lng)VALUES('123 Ocean Ave, Miami, FL', 3, '2024-11-10', 4.2, 'Ocean View', 'American', 'Room small, but clean.', 5, 150, 'Great location and friendly staff!', 8, 30, 4.5, 'beachfront, family-friendly', '5 days', 25.7617, -80.1918),('456 Mountain Rd, Boulder, CO', 2, '2024-11-12', 3.9, 'Mountain Lodge', 'Canadian', 'wifi slow.', 3, 120, 'nice rooms.', 10, 20, 4.0, 'scenic, nature', '3 days', 40.015, -105.2705),('789 Downtown St, New York, NY', 5, '2024-11-15', 4.7, 'Central Park Hotel', 'British', 'Noisy, sleep.', 7, 200, 'Perfect location near Central Park.', 12, 50, 4.7, 'luxury, city-center', '1 day', 40.7831, -73.9712),('101 Lakeside Blvd, Austin, TX', 1, '2024-11-08', 4.0, 'Lakeside Inn', 'Mexican', 'food avg.', 4, 80, 'Nice, friendly service.', 6, 15, 3.8, 'relaxing, family', '10 days', 30.2672, -97.7431),('202 River Ave, Nashville, TN', 4, '2024-11-13', 4.5, 'Riverside', 'German', 'Limited parking', 2, 175, 'Great rooms.', 9, 25, 4.2, 'riverfront, peaceful', '2 days', 36.1627, -86.7816);


SELECT HOTEL_NAME,AVERAGE_SCORE FROM (
SELECT HOTEL_NAME,AVERAGE_SCORE, 
DENSE_RANK() OVER ( ORDER BY AVERAGE_SCORE DESC)AS RNK
FROM hotel_address) WHERE RNK<=3;


SELECT  AVG(AVERAGE_SCORE) AS AVERAGE_SCORE
FROM hotel_address;
ORDER BY 2 DESC;

SELECT 
  hotel_name,
  ROUND(AVG(average_score), 2) AS avg_score
FROM hotel_address
GROUP BY hotel_name
ORDER BY avg_score DESC
LIMIT 10;



--35

-- Find the top three distinct salaries for each department. Output the department name and the top 3 distinct salaries by each department. Order your results alphabetically by department and then by highest salary to lowest.

CREATE TABLE employees_01 (id INT PRIMARY KEY,first_name VARCHAR(50), last_name VARCHAR(50), age INT, sex VARCHAR(1), employee_title VARCHAR(50), department VARCHAR(50), salary INT, target INT, bonus INT, city VARCHAR(50), address VARCHAR(50), manager_id INT);

INSERT INTO employees_01 (id, first_name, last_name, age, sex, employee_title, department, salary, target, bonus, city, address, manager_id) VALUES (1, 'Allen', 'Wang', 55, 'F', 'Manager', 'Management', 200000, 0, 300, 'California', '23St', 1),(13, 'Katty', 'Bond', 56, 'F', 'Manager', 'Management', 150000, 0, 300, 'Arizona', NULL, 1),(19, 'George', 'Joe', 50, 'M', 'Manager', 'Management', 100000, 0, 300, 'Florida', '26St', 1),(11, 'Richerd', 'Gear', 57, 'M', 'Manager', 'Management', 250000, 0, 300, 'Alabama', NULL, 1),(10, 'Jennifer', 'Dion', 34, 'F', 'Sales', 'Sales', 100000, 200, 150, 'Alabama', NULL, 13),(18, 'Laila', 'Mark', 26, 'F', 'Sales', 'Sales', 100000, 200, 150,  'Florida', '23St', 11),(20, 'Sarrah', 'Bicky', 31, 'F', 'Senior Sales', 'Sales', 200000, 200, 150, 'Florida', '53St', 19),(21, 'Suzan', 'Lee', 34, 'F', 'Sales', 'Sales', 130000, 200, 150,  'Florida', '56St', 19),(22, 'Mandy', 'John', 31, 'F', 'Sales', 'Sales', 130000, 200, 150,  'Florida', '45St', 19),(17, 'Mick', 'Berry', 44, 'M', 'Senior Sales', 'Sales', 220000, 200, 150, 'Florida', NULL, 11),(12, 'Shandler', 'Bing', 23, 'M', 'Auditor', 'Audit', 110000, 200, 150, 'Arizona', NULL, 11),(14, 'Jason', 'Tom', 23, 'M', 'Auditor', 'Audit', 100000, 200, 150, 'Arizona', NULL, 11),(16, 'Celine', 'Anston', 27, 'F', 'Auditor', 'Audit', 100000, 200, 150, 'Colorado', NULL, 11),(15, 'Michale', 'Jackson', 44, 'F', 'Auditor', 'Audit', 70000, 150, 150, 'Colorado', NULL, 11),(6, 'Molly', 'Sam', 28, 'F', 'Sales', 'Sales', 140000, 100, 150, 'Arizona', '24St', 13),(7, 'Nicky', 'Bat', 33, 'F', 'Sales', 'Sales', NULL, NULL, NULL, NULL, NULL, NULL);


WITH RANK_CTE AS (
SELECT DEPARTMENT, SALARY,
DENSE_RANK() OVER (PARTITION BY DEPARTMENT ORDER BY SALARY DESC) AS RNK
FROM EMPLOYEES_01
WHERE SALARY IS NOT NULL)
SELECT DISTINCT DEPARTMENT, SALARY 
FROM RANK_CTE
WHERE RNK <=3
ORDER BY DEPARTMENT ASC, SALARY DESC;

-- Find the most profitable location. Write a query that calculates the average signup duration and average transaction amount for each location, and then compare these two measures together by taking the ratio of the average transaction amount and average duration for each location.

-- Your output should include the location, average duration, average transaction amount, and ratio. Sort your results from highest ratio to lowest.



CREATE TABLE signups (signup_id INT PRIMARY KEY, signup_start_date DATETIME, signup_stop_date DATETIME, plan_id INT, location VARCHAR(100));

INSERT INTO signups (signup_id, signup_start_date, signup_stop_date, plan_id, location) VALUES (1, '2020-01-01 10:00:00', '2020-01-01 12:00:00', 101, 'New York'), (2, '2020-01-02 11:00:00', '2020-01-02 13:00:00', 102, 'Los Angeles'), (3, '2020-01-03 10:00:00', '2020-01-03 14:00:00', 103, 'Chicago'), (4, '2020-01-04 09:00:00', '2020-01-04 10:30:00', 101, 'San Francisco'), (5, '2020-01-05 08:00:00', '2020-01-05 11:00:00', 102, 'New York');

CREATE TABLE transactions (transaction_id INT PRIMARY KEY,signup_id INT,transaction_start_date DATETIME,amt FLOAT,FOREIGN KEY (signup_id) REFERENCES signups(signup_id));

INSERT INTO transactions (transaction_id, signup_id, transaction_start_date, amt) VALUES (1, 1, '2020-01-01 10:30:00', 50.00), (2, 1, '2020-01-01 11:00:00', 30.00), (3, 2, '2020-01-02 11:30:00', 100.00), (4, 2, '2020-01-02 12:00:00', 75.00), (5, 3, '2020-01-03 10:30:00', 120.00), (6, 4, '2020-01-04 09:15:00', 80.00), (7, 5, '2020-01-05 08:30:00', 90.00);


SELECT * FROM signups;

SELECT * FROM transactions;

WITH signup_metrics AS (
SELECT S.LOCATION,S.SIGNUP_ID,
DATEDIFF(MINUTE, S.SIGNUP_START_DATE, S.SIGNUP_STOP_DATE) AS DURATION_MINUTES,
AVG(T.AMT) AS AVG_AMT_PER_SIGNUP
FROM SIGNUPS S
JOIN transactions T 
ON S.SIGNUP_ID = T.SIGNUP_ID
GROUP BY S.LOCATION, S.SIGNUP_ID, S.SIGNUP_START_DATE, S.SIGNUP_STOP_DATE
)
SELECT
  location,
  ROUND(AVG(duration_minutes), 2) AS avg_duration_minutes,
  ROUND(AVG(avg_amt_per_signup), 2) AS avg_transaction_amount,
  ROUND(AVG(avg_amt_per_signup) / AVG(duration_minutes), 4) AS ratio
FROM signup_metrics
GROUP BY location
ORDER BY ratio DESC;


WITH signup_metrics AS (
  SELECT 
    s.location,
    s.signup_id,
    DATEDIFF(MINUTE, s.signup_start_date, s.signup_stop_date) AS duration_minutes,
    AVG(t.amt) AS avg_amt_per_signup
  FROM signups s
  JOIN transactions t ON s.signup_id = t.signup_id
  GROUP BY s.location, s.signup_id, s.signup_start_date, s.signup_stop_date
)
SELECT
  location,
  ROUND(AVG(duration_minutes), 2) AS avg_duration_minutes,
  ROUND(AVG(avg_amt_per_signup), 2) AS avg_transaction_amount,
  ROUND(AVG(avg_amt_per_signup) / AVG(duration_minutes), 4) AS ratio
FROM signup_metrics
GROUP BY location
ORDER BY ratio DESC;


SELECT 
    s.location,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, s.signup_start_date, s.signup_stop_date)), 2) AS avg_duration_minutes,
    ROUND(AVG(t.amt), 2) AS avg_transaction_amount,
    ROUND(AVG(t.amt) / AVG(TIMESTAMPDIFF(MINUTE, s.signup_start_date, s.signup_stop_date)), 4) AS ratio
FROM signups s
JOIN transactions t 
    ON s.signup_id = t.signup_id
GROUP BY s.location
ORDER BY ratio DESC;


--37
-- Find all the users who were active for 3 consecutive days or more.


CREATE TABLE sf_events (date DATETIME,account_id VARCHAR(10),user_id VARCHAR(10));

INSERT INTO sf_events (date, account_id, user_id) VALUES('2021-01-01', 'A1', 'U1'),('2021-01-01', 'A1', 'U2'),('2021-01-06', 'A1', 'U3'),('2021-01-02', 'A1', 'U1'),('2020-12-24', 'A1', 'U2'),('2020-12-08', 'A1', 'U1'),('2020-12-09', 'A1', 'U1'),('2021-01-10', 'A2', 'U4'),('2021-01-11', 'A2', 'U4'),('2021-01-12', 'A2', 'U4'),('2021-01-15', 'A2', 'U5'),('2020-12-17', 'A2', 'U4'),('2020-12-25', 'A3', 'U6'),('2020-12-25', 'A3', 'U6'),('2020-12-25', 'A3', 'U6'),('2020-12-06', 'A3', 'U7'),('2020-12-06', 'A3', 'U6'),('2021-01-14', 'A3', 'U6'),('2021-02-07', 'A1', 'U1'),('2021-02-10', 'A1', 'U2'),('2021-02-01', 'A2', 'U4'),('2021-02-01', 'A2', 'U5'),('2020-12-05', 'A1', 'U8');


SELECT * FROM sf_events;

WITH PREV_NEXT_CTE AS(
SELECT USER_ID, 
LAG(DATE) OVER (PARTITION BY USER_ID ORDER BY USER_ID, DATE)AS PREV_DATE,
DATE AS PRESENT_DAY,
LEAD(DATE) OVER (PARTITION BY USER_ID ORDER BY USER_ID, DATE) AS NEXT_DATE
FROM SF_EVENTS)
SELECT DISTINCT USER_ID
FROM PREV_NEXT_CTE
WHERE
DATEDIFF('DAY',PREV_DATE,PRESENT_DAY ) = 1 AND
DATEDIFF('DAY',PRESENT_DAY,NEXT_DATE ) = 1;



--38

-- Estimate the growth of Airbnb each year using the number of hosts registered as the growth metric. The rate of growth is calculated by taking ((number of hosts registered in the current year - number of hosts registered in the previous year) / the number of hosts registered in the previous year) * 100. Output the year, number of hosts in the current year, number of hosts in the previous year, and the rate of growth. Round the rate of growth to the nearest percent and order the result in the ascending order based on the year. 

CREATE TABLE airbnb_search_details ( id INT, price FLOAT, property_type VARCHAR(100), room_type VARCHAR(100), amenities VARCHAR(200), accommodates INT, bathrooms INT, bed_type VARCHAR(50), cancellation_policy VARCHAR(50), cleaning_fee int, city VARCHAR(100), host_identity_verified VARCHAR(10), host_response_rate VARCHAR(10), host_since DATETIME, neighbourhood VARCHAR(100), number_of_reviews INT, review_scores_rating FLOAT, zipcode INT, bedrooms INT, beds INT);


INSERT INTO airbnb_search_details (id, price, property_type, room_type, amenities, accommodates, bathrooms, bed_type, cancellation_policy, cleaning_fee, city, host_identity_verified, host_response_rate, host_since, neighbourhood, number_of_reviews, review_scores_rating, zipcode, bedrooms, beds)VALUES(1, 100, 'Apartment', 'Entire home/apt', 'WiFi, Kitchen', 2, 1, 'Real Bed', 'Flexible', 1, 'New York', 'Yes', '90%', '2019-01-15', 'Manhattan', 120, 4.8, 10001, 1, 1),(2, 75, 'House', 'Private room', 'WiFi, Parking', 3, 1, 'Queen Bed', 'Moderate', 0, 'Los Angeles', 'Yes', '80%', '2018-06-22', 'Hollywood', 80, 4.5, 90001, 2, 1),(3, 50, 'Shared Room', 'Shared room', 'WiFi', 1, 1, 'Single Bed', 'Strict', 0, 'Chicago', 'No', '70%', '2019-03-10', 'Lincoln Park', 40, 3.8, 60614, 1, 1),(4, 200, 'Villa', 'Entire home/apt', 'Pool, WiFi', 6, 3, 'King Bed', 'Flexible', 1, 'Miami', 'Yes', '95%', '2020-07-05', 'Miami Beach', 300, 4.9, 33139, 3, 4),(5, 120, 'Apartment', 'Entire home/apt', 'WiFi, Kitchen, Parking', 4, 2, 'Double Bed', 'Moderate', 1, 'San Francisco', 'Yes', '85%', '2021-09-18', 'Downtown', 150, 4.7, 94102, 2, 2),(6, 80, 'Apartment', 'Private room', 'WiFi', 2, 1, 'Queen Bed', 'Strict', 0, 'Austin', 'No', '75%', '2020-11-22', 'Downtown', 100, 4.4, 78701, 1, 1),
(7, 150, 'House', 'Entire home/apt', 'WiFi, Kitchen', 5, 2, 'Queen Bed', 'Flexible', 1, 'Seattle', 'Yes', '90%', '2019-05-30', 'Capitol Hill', 200, 4.6, 98102, 2, 3),(8, 60, 'Apartment', 'Shared room', 'WiFi', 1, 1, 'Single Bed', 'Moderate', 0, 'Boston', 'Yes', '80%', '2018-04-18', 'Beacon Hill', 50, 4.2, 02108, 1, 1),(9, 90, 'House', 'Private room', 'WiFi, Parking', 3, 2, 'King Bed', 'Strict', 1, 'Denver', 'No', '85%', '2021-02-10', 'Downtown', 75, 4.0, 80202, 1, 2),(10, 250, 'Villa', 'Entire home/apt', 'Pool, WiFi, Kitchen', 8, 4, 'King Bed', 'Flexible', 1, 'Las Vegas', 'Yes', '95%', '2022-06-15', 'The Strip', 400, 4.9, 89109, 4, 5);


SELECT * FROM airbnb_search_details;


WITH HOST_YR_CTE AS(
SELECT YEAR(HOST_SINCE) AS HOST_YEAR, COUNT(*) AS CURRENT_YEAR_IDS
FROM airbnb_search_details
GROUP BY  YEAR(HOST_SINCE)),
CURR_PREV_CTE AS(
SELECT HOST_YEAR, CURRENT_YEAR_IDS,
LAG(CURRENT_YEAR_IDS,1,NULL) OVER (ORDER BY HOST_YEAR) AS PREV_YEAR_IDS
FROM HOST_YR_CTE
ORDER BY HOST_YEAR)
SELECT *, 
ROUND((CURRENT_YEAR_IDS-PREV_YEAR_IDS)/PREV_YEAR_IDS*100,2) AS RATE_GROWTH
FROM CURR_PREV_CTE;



--39
-- Find the best selling item for each month (no need to separate months by year) where the biggest total invoice was paid. The best selling item is calculated using the formula (unitprice * quantity). Output the month, the description of the item along with the amount paid.

CREATE TABLE online_retail (invoiceno VARCHAR(50),stockcode VARCHAR(50),description VARCHAR(255),quantity INT,invoicedate DATETIME,unitprice FLOAT,customerid FLOAT,country VARCHAR(100));

INSERT INTO online_retail (invoiceno, stockcode, description, quantity, invoicedate, unitprice, customerid, country)VALUES('536365', '85123A', 'WHITE HANGING HEART T-LIGHT HOLDER', 10, '2021-01-15 10:00:00', 2.55, 17850, 'United Kingdom'),('536366', '71053', 'WHITE METAL LANTERN', 5, '2021-02-10 12:00:00', 3.39, 13047, 'United Kingdom'),('536367', '84406B', 'CREAM CUPID HEARTS COAT HANGER', 8, '2021-03-05 15:00:00', 2.75, 17850, 'United Kingdom'),('536368', '22423', 'REGENCY CAKESTAND 3 TIER', 2, '2021-04-12 16:30:00', 12.75, 13047, 'United Kingdom'),('536369', '85123A', 'WHITE HANGING HEART T-LIGHT HOLDER', 15, '2021-05-18 11:00:00', 2.55, 13047, 'United Kingdom'),('536370', '21730', 'GLASS STAR FROSTED T-LIGHT HOLDER', 12, '2021-06-25 14:00:00', 4.25, 17850, 'United Kingdom');


SELECT * FROM online_retail;

WITH TOTAL_AMT_CTE AS (
SELECT MONTH(INVOICEDATE) AS MONTH_NUM,DESCRIPTION, SUM(QUANTITY*UNITPRICE) AS TOTAL_AMT_PAID
FROM online_retail
GROUP BY MONTH(INVOICEDATE), DESCRIPTION),
RANKS_CTE AS(
SELECT *,
DENSE_RANK() OVER (PARTITION BY MONTH_NUM ORDER BY TOTAL_AMT_PAID DESC) AS RANKS
FROM TOTAL_AMT_CTE)
SELECT MONTH_NUM, DESCRIPTION, TOTAL_AMT_PAID
FROM RANKS_CTE
WHERE RANKS=1
ORDER BY MONTH_NUM;



--40
-- Identify users who started a session and placed an order on the same day. For these users, calculate the total number of orders and the total order value for that day. Your output should include the user, the session date, the total number of orders, and the total order value for that day.

CREATE TABLE sessions_01(session_id INT, user_id INT, session_date DATETIME);

INSERT INTO sessions_01 (session_id, user_id, session_date) VALUES (1, 1, '2024-01-01'), (2, 2, '2024-01-02'), (3, 3, '2024-01-05'), (4, 3, '2024-01-05'), (5, 4, '2024-01-03'), (6, 4, '2024-01-03'), (7, 5, '2024-01-04'), (8, 5, '2024-01-04'), (9, 3, '2024-01-05'), (10, 5, '2024-01-04');

CREATE TABLE order_summary_01 (order_id INT, user_id INT, order_value INT, order_date DATETIME);

INSERT INTO order_summary_01 (order_id, user_id, order_value, order_date) VALUES (1, 1, 152, '2024-01-01'), (2, 2, 485, '2024-01-02'), (3, 3, 398, '2024-01-05'), (4, 3, 320, '2024-01-05'), (5, 4, 156, '2024-01-03'), (6, 4, 121, '2024-01-03'), (7, 5, 238, '2024-01-04'), (8, 5, 70, '2024-01-04'), (9, 3, 152, '2024-01-05'), (10, 5, 171, '2024-01-04');


SELECT * FROM sessions_01;

SELECT * FROM order_summary_01;

SELECT S.USER_ID, DATE(S.SESSION_DATE) AS SESSION_DATE,
DATE(O.ORDER_DATE) AS ORDER_DATE,
COUNT(S.USER_ID) AS TOTAL_ORDERS_PLACED,
SUM(O.ORDER_VALUE) AS TOTAL_ORDER_VALUE
FROM sessions_01 S
JOIN order_summary_01 O
ON S.USER_ID = O.USER_ID
WHERE SESSION_DATE = ORDER_DATE
GROUP BY S.USER_ID, S.SESSION_DATE, O.ORDER_DATE
ORDER BY S.USER_ID;

