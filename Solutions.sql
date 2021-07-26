USE sakila;

-- 1. Get number of monthly active customers.
-- STEP 1 : check the datas
SELECT customer_id, rental_date
FROM rental;
-- STEP 2 : create a view to shape the datas 
create or replace view customer_activity as 
select customer_id, 
		convert(rental_date, date) as activity_date,
        date_format(convert(rental_date, date), '%Y''%m') as activity_month
from rental;

SELECT * FROM customer_activity;

-- QUERY
SELECT activity_month, count(distinct customer_id)
FROM customer_activity
GROUP BY activity_month
ORDER BY activity_month;

-- 2. Active users in the previous month.
-- STEP 1 : create a view 
create or replace view monthly_active_customers as
SELECT activity_month, count(distinct customer_id) AS active_customers
FROM customer_activity
GROUP BY activity_month 
ORDER BY activity_month;
-- QUERY
select  activity_month,
        active_customers,
        lag(active_customers) over(order by activity_month) as last_month
from monthly_active_customers;

-- 3. Percentage change in the number of active customers.
with cte_view as (
select activity_month,
        active_customers,
        lag(active_customers) over(order by activity_month) as last_month
from monthly_active_customers
)
select 
		activity_month,
        active_customers,
        last_month,
        (active_customers - last_month) as difference,
        round(((active_customers - last_month)/last_month)*100, 2) as per_growth
from cte_view;

-- 4. Retained customers every month.

-- retained customers are the customers who rent films at least two times and we want to see them per month

-- The fuction COUNT gives us the total number of active customers and the fuction COUNT DISTINCT gives us the number 
-- of the unique active customers. The difference should give us the number of active customers more than once 
-- i.e the retained customers

-- STEP 1 : monthy_active_customers view shows us the number of unique customers by month
SELECT * FROM monthly_active_customers;

-- STEP 2 : creating a view to show the total number of customers by month
create or replace view NU_monthly_active_customers as
SELECT activity_month, count(customer_id) AS active_customers
FROM customer_activity
GROUP BY activity_month 
ORDER BY activity_month;

SELECT * FROM NU_monthly_active_customers;

-- STEP 3 : getting the retained customers by joinning the two views

SELECT monthly_active_customers.activity_month, NU_monthly_active_customers.active_customers AS nu_active_customers,
monthly_active_customers.active_customers, 
(NU_monthly_active_customers.active_customers - monthly_active_customers.active_customers) AS retained_customers
FROM monthly_active_customers
JOIN NU_monthly_active_customers
ON monthly_active_customers.activity_month = NU_monthly_active_customers.activity_month;




	




