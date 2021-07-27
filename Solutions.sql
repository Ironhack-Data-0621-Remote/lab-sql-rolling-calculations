-- 1. Get number of monthly active customers.
create or replace view bank.user_activity as
SELECT account_id,
		convert(date,date) as activity_date,
        date_format(convert(date,date),'%m') as activity_month,
        date_format(convert(date,date),'%Y') as activity_year
FROM bank.trans;

SELECT * 
FROM bank.user_activity;

CREATE OR REPLACE VIEW bank.monthly_active_users as
SELECT activity_year, activity_month, count(account_id) as active_users
FROM bank.user_activity
GROUP BY activity_year, activity_month
ORDER BY activity_year, activity_month;

SELECT * 
FROM bank.monthly_active_users;

-- 2. Active users in the previous month.
CREATE OR REPLACE VIEW bank.prev_monthly_active_users as
SELECT activity_year,
		activity_month,
        lag(active_users) over() as last_month
FROM bank.monthly_active_users;

SELECT * FROM bank.prev_monthly_active_users;

-- 3. Percentage change in the number of active customers.
CREATE OR REPLACE VIEW bank.diff_monthly_active_users as
WITH cte_view AS (
SELECT activity_year,
		activity_month,
        active_users,
        lag(active_users) over() as last_month
FROM bank.monthly_active_users
)
SELECT activity_year
		activity_month,
        active_users,
        last_month,
        (active_users - last_month) as difference,
        round(((active_users - last_month)/last_month)*100,2) as per_change
FROM cte_view;

SELECT * FROM bank.diff_monthly_active_users;

-- 4. Retained customers every month.

SELECT *, round(((last_month - difference)/active_users)*100, 2) AS retained_cust
FROM bank.diff_monthly_active_users;