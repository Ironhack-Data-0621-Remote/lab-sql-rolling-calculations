-- 1. Get number of monthly active customers.
use sakila;
create or replace view active_customers as 
select customer_id from customer
where active = 1; 

create or replace view activity_customers as 
select count(distinct(customer_id)) as active_customers_per_month, date_format(convert(rental_date, date), '%m') as month_of_activity, date_format(convert(rental_date, date), '%y') as year_of_activity
from rental
where customer_id in (select * from active_customers)
group by month_of_activity
order by month_of_activity;
select * from activity_customers;

-- 2. Active users in the previous month.
select month_of_activity, year_of_activity, active_customers_per_month, lag(month_of_activity) over() as previous_month
from activity_customers;
-- 3. Percentage change in the number of active customers.
select month_of_activity, year_of_activity, lag(active_customers_per_month) over() as last_month, active_customers_per_month, concat(round((active_customers_per_month/lag(active_customers_per_month) over())*100,2),'%') as growth_percentage
from activity_customers;
-- 4. Retained customers every month.
-- difference of customers
select month_of_activity, year_of_activity, lag(active_customers_per_month) over() as last_month, active_customers_per_month, concat('-',(active_customers_per_month - lag(active_customers_per_month) over())) as difference_customers
from activity_customers;
-- I am not sure how to find the difference from months..  tried but this does not make sense:
create or replace view activity_customers2 as 
select distinct(customer_id) as active_customerIDs_per_month, date_format(convert(rental_date, date), '%d') as day_of_activity, date_format(convert(rental_date, date), '%m') as month_of_activity, date_format(convert(rental_date, date), '%y') as year_of_activity
from rental
where customer_id in (select * from active_customers)
order by customer_id; -- order by customer is not right 
select * from activity_customers2;

