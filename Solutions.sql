USE sakila;

-- 1. Get number of monthly active customers.

CREATE OR REPLACE VIEW active_customer AS 
SELECT customer_id AS active_customer, 
CONVERT(rental_date, date) AS activity_date,
date_format(CONVERT(rental_date, date), '%Y''%m') AS activity_month
FROM rental;

SELECT activity_month, count(distinct active_customer) AS active_customer
FROM active_customer
GROUP BY activity_month
ORDER BY active_customer DESC;


-- 2. Active users in the previous month.


CREATE OR REPLACE VIEW  active_customer_2 AS
SELECT activity_month, 
count(distinct active_customer) AS active_customers
FROM active_customer
GROUP BY activity_month 
ORDER BY activity_month;

SELECT  activity_month, active_customers,
LAG(active_customers) OVER(ORDER BY activity_month) AS last_month
FROM active_customer_2;


-- 3. Percentage change in the number of active customers.
CREATE OR REPLACE VIEW  active_customer_3 AS
SELECT activity_month, active_customers,
LAG (active_customers) OVER(ORDER BY activity_month) AS last_month
FROM active_customer_2;

CREATE OR REPLACE VIEW  active_customer_4 AS
SELECT activity_month, active_customers, last_month, 
(active_customers - last_month) AS difference,
round(((active_customers - last_month)/last_month)*100, 2) AS per_growth
FROM active_customer_3;

SELECT * FROM  active_customer_4; 

-- 4. Retained customers every month.

SELECT *, round(((last_month - difference)/active_customers)*100, 2) AS retained_customer 
FROM active_customer_4;
