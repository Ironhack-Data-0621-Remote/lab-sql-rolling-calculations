-- 1. Get number of monthly active customers.
use sakila;
create or replace view monthly_active_users as
select date_format(convert(payment_date, date), '%m') as activity_month, date_format(convert(payment_date, date), '%Y') as activity_year,
count(distinct(customer_id)) as monthly_act_cust
from payment
group by activity_month, activity_year
order by activity_year asc, activity_month asc;
select * from monthly_active_users;
-- 2. Active users in the previous month.
select activity_month, activity_year, monthly_act_cust, lag(monthly_act_cust) over() as last_period
from monthly_active_users;

-- 3. Percentage change in the number of active customers.
select activity_month, activity_year, monthly_act_cust, lag(monthly_act_cust) over() as last_period, round(((monthly_act_cust/lag(monthly_act_cust) over())-1)*100,2) as perc_growth
from monthly_active_users;

-- 4. Retained customers every month.
select activity_month, activity_year, monthly_act_cust, lag(monthly_act_cust) over() as last_period, (monthly_act_cust - (lag(monthly_act_cust) over())) as cust_change
from monthly_active_users;
-- I had no idea on how to get number of new customers from one month to another, so this is not retained customer ratio but variation of customers...