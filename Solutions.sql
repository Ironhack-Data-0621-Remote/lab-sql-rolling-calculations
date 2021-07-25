use sakila;

-- 1. Get number of monthly active customers.

create or replace view sakila_user_activity as
select customer_id,
date_format(convert(payment_date,date), '%m') as Activity_Month,
date_format(convert(payment_date,date), '%Y') as Activity_year
from payment;


create or replace view monthly_active_customers as
select Activity_year, Activity_Month, count(customer_id) as Active_customers
from sakila_user_activity
group by Activity_year, Activity_Month
order by Activity_year asc, Activity_Month asc;

select * from monthly_active_customers;

-- this view shows us the count of active customers per month

-- 2. Active users in the previous month.

select 
   Activity_year, 
   Activity_month,
   Active_customers, 
   lag(Active_customers) over (order by Activity_year, Activity_Month) as Last_month
from monthly_active_customers;

-- 3. Percentage change in the number of active customers.

create or replace view customer_flow as
select 
   Activity_year, 
   Activity_month,
   Active_customers, 
   lag(Active_customers) over (order by Activity_year, Activity_month) as Last_month,
   (Active_customers - (lag(Active_customers) over (order by Activity_year, Activity_month))) as Difference
   from monthly_active_customers;

select 
Activity_year, 
Activity_month,
Active_customers, 
Last_month,
Difference,
round(((Active_customers - Last_month) / Active_customers),2) *100 as Percent_change
from customer_flow;

-- this shows us the percent change month on month

-- 4. Retained customers every month.

-- to calculate this we need to know how many new customers were acquired per month but I don't think we can find that out based on these tables.
