use sakila;
-- 1. Get number of monthly active customers.
select count(customer_id) as active_customers, 
    year(rental_date) as rental_year,
	month(rental_date) as rental_month
from rental
group by rental_year, rental_month;

-- 2. Active users in the previous month.
with monthly_customers as (
	select count(customer_id) as active_customers, 
		year(rental_date) as rental_year,
		month(rental_date) as rental_month
	from rental
	group by rental_year, rental_month
)
select *, lag(active_customers) over(order by rental_year, rental_month) as previous_month
from monthly_customers;

-- 3. Percentage change in the number of active customers.
with monthly_customers as (
	select year(rental_date) as rental_year,
		month(rental_date) as rental_month,
        count(customer_id) as active_customers
	from rental
	group by rental_year, rental_month
),
monthly_with_previous as (
	select *, lag(active_customers) over(order by rental_year, rental_month) as previous_month
	from monthly_customers
)
select *, round(((active_customers - previous_month) / previous_month) *100, 2) as per_growth
from monthly_with_previous;

-- 4. Retained customers every month.

-- I defined 'retained customers' as those who rented films the same amount or more than previous month.   
with monthly_customers as (
	select year(rental_date) as rental_year,
		month(rental_date) as rental_month,
		customer_id,
		count(customer_id) as number_of_rentals
	from rental
	group by rental_year, rental_month, customer_id
    order by customer_id
),
monthly_retained_customers as (
	select *, lag(number_of_rentals) over(order by rental_year, rental_month, customer_id) as previous_month
	from monthly_customers
)
select * from monthly_retained_customers
where (number_of_rentals - previous_month) >= 0;
