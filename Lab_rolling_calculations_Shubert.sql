-- 1. Get number of monthly active customers.

create or replace view sakila.user_activity as
select c.customer_id, 
date_format(convert(r.rental_date,date), '%m') as activity_month,
date_format(convert(r.rental_date,date), '%y') as activity_year
from sakila.customer c
join rental r
on c.customer_id = r.customer_id
where active = 1 
group by activity_month
;

create or replace view sakila.monthly_activity_users as 
select activity_year, activity_month, count(customer_id) as active_users
from sakila.user_activity
group by activity_year, activity_month
order by activity_year, activity_month;

-- 2. Active users in the previous month.

with cte1 as (
select count(c.customer_id), date_format(convert(r.rental_date,date), '%m') as activity_month
from sakila.customer c
join rental r
on c.customer_id = r.customer_id
where active = 1 
group by activity_month
),
cte2 as (
select activity_month, count(customer_id) as active_users
from sakila.user_activity
group by activity_month
order by activity_month
)
select 
activity_month,
active_users,
lag(active_users) over(order by activity_month) as last_month
from monthly_activity_users
;

-- 3. Percentage change in the number of active customers.
with cte1 as (
select count(c.customer_id), date_format(convert(r.rental_date,date), '%m') as activity_month
from sakila.customer c
join rental r
on c.customer_id = r.customer_id
where active = 1 
group by activity_month
),
cte2 as (
select activity_month, count(customer_id) as active_users
from sakila.user_activity
group by activity_month
order by activity_month
),
cte3 as (
select 
activity_month,
active_users,
lag(active_users) over(order by activity_month) as last_month
from monthly_activity_users
)
select  
activity_month,
active_users,
last_month,
(active_users - last_month) as difference,
((active_users - last_month)/last_month)*100 as per_growth
from cte3;

-- 4. Retained customers every month.
select count(c.customer_id), date_format(convert(r.rental_date,date), '%m') as no_activity_month
from sakila.customer c
join rental r
on c.customer_id = r.customer_id
where active = 0
group by no_activity_month;