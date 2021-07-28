use sakila;
-- 1. Get number of monthly active customers.
select year(rental_date) as year, month(rental_date) as month, count(customer_id) as active_customers
from rental
group by year(rental_date), month(rental_date);

-- 2. Active users in the previous month.
select 
	year(rental_date) as year,
	month(rental_date) as month,
	count(customer_id) as active_customers,
    lag(count(customer_id)) over (order by year(rental_date), month(rental_date) asc) as prevous_month_users
from rental
group by year(rental_date), month(rental_date);

-- alternative:
with cte1 as(
select 
	year(rental_date) as year,
	month(rental_date) as month,
	count(customer_id) as active_customers
from rental
group by year(rental_date), month(rental_date)
)
select *, lag(active_customers) over (order by year, month asc) as previous_month_users
from cte1;
-- 3. Percentage change in the number of active customers.
with cte1 as(
select 
	year(rental_date) as year,
	month(rental_date) as month,
	count(customer_id) as active_customers
from rental
group by year(rental_date), month(rental_date)
),
cte2 as(
select *, lag(active_customers) over (order by year, month asc) as previous_month_users
from cte1)
select * , ((active_customers-previous_month_users)/previous_month_users)*100 as evolution
from cte2;

-- 4. Retained customers every month 
-- (assuming retention is next months users - actual months users)

with cte1 as(
select 
	year(rental_date) as year,
	month(rental_date) as month,
	count(customer_id) as active_customers
from rental
group by year(rental_date), month(rental_date)
),
cte2 as(
select *, lead(active_customers) over (order by year, month asc) as next_month_users
from cte1)
select * , (next_month_users - active_customers)  as retained
from cte2;