USE sakila;

-- 1. Get number of monthly active customers.
select count(customer_id) as active_customers, 
    year(rental_date) as year,
	month(rental_date) as month
from rental
group by year, month;

-- 2. Active users in the previous month.
select 
	year(rental_date) as year,
	month(rental_date) as month,
	count(customer_id) as active_customers,
    lag(count(customer_id)) over (order by year(rental_date), month(rental_date) asc) as users_previous_month
from rental
group by year, month;

-- 3. Percentage change in the number of active customers.
with c_monthly as(
select 
	year(rental_date) as year,
	month(rental_date) as month,
	count(customer_id) as active_customers
from rental
group by year, month
),
c_monthly2 as(
select *, lag(active_customers) over (order by year, month asc) as users_previous_month
from c_monthly)
select * , ((active_customers-users_previous_month)/users_previous_month)*100 as percentage_change
from c_monthly2;

-- 4. Retained customers every month.
