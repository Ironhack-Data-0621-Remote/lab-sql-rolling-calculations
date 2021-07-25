use sakila;

-- 1. Get number of monthly active customers.
create or replace view active_customer as 
select customer_id from customer
where active = 1; 

select * from active_customer;

create or replace view cust_activity as 
select customer_id, 
        date_format(convert(rental_date, date), '%m') as activity_month
from rental
where customer_id in (select * from active_customer);

select * from cust_activity;

create or replace view monthly_active_cust as
select activity_month, count(customer_id) as active_cust
from cust_activity
group by activity_month
order by activity_month;

select * from monthly_active_cust;

-- 2. Active users in the previous month.
select activity_month,
        active_cust,
        lag(active_cust) over(order by activity_month) as last_month
from monthly_active_cust;

-- 3. Percentage change in the number of active customers.
create or replace view diff_monthly_active_cust as
with cte_view as (
select activity_month,
        active_cust,
        lag(active_cust) over(order by activity_month) as last_month
from monthly_active_cust
)
select activity_month,
        active_cust,
        last_month,
        (active_cust - last_month) as difference,
        ((active_cust - last_month)/last_month)*100 as per_growth
from cte_view;

select * from diff_monthly_active_cust;

-- 4. Retained customers every month.
select *, ((last_month - difference)/active_cust)*100 as retained_cust 
from diff_monthly_active_cust;