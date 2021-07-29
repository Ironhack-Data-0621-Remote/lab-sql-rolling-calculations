-- 1. Get number of monthly active customers.
use sakila;
-- Here I define 'active customers' as who rented the films

SELECT * FROM rental;

-- USING CTE
WITH cte1 as (
SELECT *, convert(rental_date, date) as rent_date,
date_format(convert(rental_date, date), '%m') as rent_month,
date_format(convert(rental_date, date), '%Y') as rent_year
FROM rental
),
cte2 as (
SELECT rent_month, count(DISTINCT customer_id)
FROM cte1
GROUP BY rent_month)
SELECT * FROM cte2;

-- USING VIEW

CREATE OR REPLACE VIEW sakila_customer_rental AS
	SELECT *, convert(rental_date, date) as rent_date,
	date_format(convert(rental_date, date), '%m') as rent_month,
	date_format(convert(rental_date, date), '%Y') as rent_year
	FROM rental;
    
CREATE OR REPLACE VIEW sakila_monthly_active_customer AS
	SELECT rent_month, count(DISTINCT customer_id) as active_customer
	FROM sakila_customer_rental
	GROUP BY rent_month;
    
SELECT * FROM sakila_monthly_active_customer ;
    
-- 2. Active users in the previous month.
-- USE THE LAG() FUNCTION
CREATE OR REPLACE VIEW sakila_monthly_difference_active_customer AS
SELECT rent_month, active_customer, LAG(active_customer) over(order by rent_month) as last_month
FROM sakila_monthly_active_customer;
SELECT * FROM sakila_monthly_difference_active_customer;

-- 3. Percentage change in the number of active customers.


SELECT *, (active_customer - last_month) as difference, (active_customer - last_month)/last_month * 100 as percent_growth
FROM sakila_monthly_difference_active_customer;

-- DOUBLE CHECK WHICH MONTH EXISTS IN THE ORIGINAL TABLE
SELECT DISTINCT rent_month
FROM sakila_customer_rental ;
-- 4. Retained customers every month.
-- Identify new customers by DISTINCT customer_id and JOIN to the previous month table and check the null values(=new customer)

WITH cte1 as (
SELECT DISTINCT customer_id as may
FROM sakila_customer_rental
WHERE rent_month = 05
),
cte2 as (
SELECT DISTINCT customer_id as june
FROM sakila_customer_rental
WHERE rent_month = 06
),
cte3 as (
SELECT DISTINCT customer_id as july
FROM sakila_customer_rental
WHERE rent_month = 07
)
SELECT count(1) - COUNT(june)as new_cus_june -- count(null)
FROM cte1 c1
LEFT JOIN cte2 c2
ON c1.may = c2.june
;


