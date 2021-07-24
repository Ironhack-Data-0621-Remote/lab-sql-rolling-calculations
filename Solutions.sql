USE sakila;

-- 1. Get number of monthly active customers.

-- CREATE VIEW and JOIN tables customer and rental to have all required data
-- MAC = monthly active customers

create or replace view sakila.customer_activity as 
select c.customer_id,
		convert(r.rental_date, date) as activity_date,
        date_format(convert(r.rental_date, date), '%m') as activity_month,
        date_format(convert(r.rental_date, date), '%Y') as activity_year
from customer c
JOIN rental r ON c.customer_id = r.customer_id;
create or replace view sakila.monthly_customer_activity as 
select activity_year, activity_month, count(customer_id) as active_customer
from sakila.customer_activity
group by activity_year, activity_month
order by activity_year, activity_month;
SELECT *
FROM sakila.monthly_customer_activity;

-- 2. Active users in the previous month.

create or replace view sakila.monthly_customer_activity_mom as 
select activity_year,
		activity_month,
        active_customer,
        lag(active_customer) over(order by activity_year, activity_month) as last_month
FROM sakila.monthly_customer_activity;
SELECT * FROM sakila.monthly_customer_activity_mom;

-- 3. Percentage change in the number of active customers.

create or replace view sakila.monthly_customer_activity_diff as 
select *, (1-(last_month / active_customer)) as diff
FROM sakila.monthly_customer_activity_mom;
SELECT * FROM sakila.monthly_customer_activity_diff;

-- 4. Retained customers every month.

create or replace view sakila.customer_retention as 
select DISTINCT c.customer_id,
		convert(r.rental_date, date) as activity_date,
        date_format(convert(r.rental_date, date), '%m') as activity_month,
        date_format(convert(r.rental_date, date), '%Y') as activity_year
from customer c
JOIN rental r ON c.customer_id = r.customer_id;
create or replace view sakila.monthly_customer_retention as 
select activity_year, activity_month, count(customer_id) as active_customer
from sakila.customer_activity
group by activity_year, activity_month
order by activity_year, activity_month;
SELECT *
FROM sakila.monthly_customer_activity;
