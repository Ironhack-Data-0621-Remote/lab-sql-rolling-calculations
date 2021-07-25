-- lab-sql-rolling-calculations
USE sakila;
-- Get number of monthly active customers.

CREATE OR REPLACE VIEW sakila.customer_activity AS
SELECT customer_id, convert(rental_date, DATE) AS activity_date,
date_format(CONVERT(rental_date, DATE), '%m') AS activity_month
FROM sakila.rental;

SELECT * FROM sakila.customer_activity;

CREATE OR REPLACE VIEW sakila.monthly_active_customers AS
SELECT activity_month, COUNT(DISTINCT(customer_id)) AS active_customers
FROM sakila.customer_activity
GROUP BY activity_month
ORDER BY activity_month DESC;

SELECT * FROM sakila.monthly_active_customers;

-- Active users in the previous month.

SELECT activity_month, active_customers, 
LAG(active_customers) OVER (ORDER BY activity_month) AS last_month
FROM sakila.monthly_active_customers;

-- Percentage change in the number of active customers.

WITH cte_diff_monthly_active_customers AS 
(
SELECT activity_month, active_customers, 
LAG(active_customers) OVER (ORDER BY activity_month) AS last_month
FROM sakila.monthly_active_customers
)
SELECT activity_month, active_customers, last_month, 
   (active_customers - last_month)/active_customers*100 AS diff_percentage 
FROM cte_diff_monthly_active_customers
WHERE last_month IS NOT NULL;

-- Retained customers every month.

SELECT activity_month, COUNT(DISTINCT(customer_id)) AS retained_customers 
FROM sakila.customer_activity
WHERE customer_id IS NOT NULL
GROUP BY activity_month;