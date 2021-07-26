use sakila;

-- 1. Get number of monthly active customers.
select * from rental;

create or replace view sakila.user_activity as
select customer_id, convert(rental_date, date) as Activity_date,
date_format(convert(rental_date,date), '%m') as Activity_Month,
date_format(convert(rental_date,date), '%Y') as Activity_year
from sakila.rental;

select * from sakila.user_activity;

create or replace view sakila.monthly_active_users as
select Activity_year, Activity_Month, count(customer_id) as Active_users
from sakila.user_activity
group by Activity_year, Activity_Month
order by Activity_year asc, Activity_Month asc;

select * from monthly_active_users;

-- 2. Active users in the previous month.
select 
   Activity_year, 
   Activity_month,
   Active_users, 
   lag(Active_users) over () as Last_month 
from monthly_active_users;

-- 3. Percentage change in the number of active customers.
 with cte_activity as
(
  select
    Activity_year, Activity_month, Active_users,
    lag(Active_users,1) over (partition by Activity_year) as last_month
  from monthly_active_users
)
select
  activity_year, activity_month,
  (Active_users-last_month)/Active_users*100 as percentage_change
from cte_activity
where last_month is not null;

-- 4. Retained customers every month.
with cte as
(
	select *,
    lag(Active_users) over () as Previous_month_users
    from sakila.monthly_active_users
)
select *, Active_users - Previous_month_users
from cte;