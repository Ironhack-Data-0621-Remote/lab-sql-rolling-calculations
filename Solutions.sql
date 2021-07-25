USE sakila;
-- 1. Get number of monthly active customers.
SELECT * FROM rental;
-- step 1: create a view with all the data
CREATE OR REPLACE VIEW sakila.customer_activity AS
SELECT customer_id, convert(rental_date, DATE) AS activity_date,
date_format(CONVERT(rental_date, DATE), '%m') AS activity_month,
date_format(CONVERT(rental_date, DATE), '%Y') AS activity_year
FROM sakila.rental;
SELECT * FROM sakila.customer_activity;
-- step 2: getting the total number of active customers per month and year
CREATE OR REPLACE VIEW sakila.monthly_active_customers AS
SELECT activity_year, activity_month, COUNT(DISTINCT(customer_id)) AS active_customers
FROM sakila.customer_activity
GROUP BY activity_year, activity_month
ORDER BY activity_year ASC, activity_month ASC;
SELECT * FROM sakila.monthly_active_customers;

-- 2. Active users in the previous month.
-- step 3: using LAG() to get the customers from previous month
SELECT activity_year, activity_month, active_customers, 
LAG(active_customers) OVER (ORDER BY activity_year, activity_month) AS last_month
FROM sakila.monthly_active_customers;

-- 3. Percentage change in the number of active customers.
WITH cte_diff_monthly_active_customers AS 
(
SELECT activity_year, activity_month, active_customers, 
LAG(active_customers) OVER (ORDER BY activity_year, activity_month) AS last_month
FROM sakila.monthly_active_customers)
SELECT activity_year, activity_month, active_customers, last_month, 
   (active_customers - last_month)/active_customers*100 AS diff_percentage 
FROM cte_diff_monthly_active_customers
WHERE last_month IS NOT NULL;

-- 4. Retained customers every month.
SELECT ca1.activity_month, COUNT(DISTINCT(ca1.customer_id)) AS retained_customers 
FROM sakila.customer_activity ca1
LEFT JOIN sakila.customer_activity ca2
ON ca1.activity_year = ca2.activity_year
AND ca1.customer_id = ca2.customer_id
AND ca1.activity_month = ca2.activity_month +1 
WHERE ca2.customer_id IS NOT NULL
GROUP BY ca1.activity_month;
-- not really sure if this is the right query and/or answer