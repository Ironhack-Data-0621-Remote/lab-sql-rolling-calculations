-- To do the questions separeted is necessary to create a view instead of a cte.
-- Because isolated cte cannot read the previous ones that were done.
-- This query has a problem when the months are not in a row. An improvement could be done on this regard.
-- For example: fixing months and inputing info from the database.
-- This could be done by:
-- 1. Creating the base table with months by year
-- 2. Filtering data from the cte/views created here
-- 3. Updating the new table with this info
-- OR with a JOIN between the new table and the cte/views
-- The problem would be how to create this table in sql without a for loop...

-- 1. Get number of monthly active customers.
-- -> column active_users
-- 2. Active users in the previous month.
-- -> column last_month
-- 3. Percentage change in the number of active customers.
-- -> column per_growth
-- 4. Retained customers every month.
-- -> It would be necessary to find the amount of clients at the beginning and at the end of the month.
-- Then subtract the number of new customers we’ve acquired over that time -> column difference.
-- Then divide by the number of customers you had at the beginning of that period.
-- If a percentage is also desired, then, multiply that by one hundred.
WITH cte_user_activity AS (
SELECT customer_id,
		convert(rental_date, date) AS activity_date
        , date_format(convert(rental_date, date), '%m') AS activity_month
        , date_format(convert(rental_date, date), '%y') AS activity_year
FROM sakila.rental
),
cte_monthly_active_users AS (
SELECT activity_year, activity_month, count(DISTINCT(customer_id)) AS active_users
FROM cte_user_activity
GROUP BY activity_year, activity_month
ORDER BY activity_year, activity_month
),
cte_view AS (
SELECT activity_year
		, activity_month
		, active_users
        , lag(active_users) OVER(ORDER BY activity_year, activity_month) AS last_month
FROM cte_monthly_active_users
),
cte_diff_monthly_active_users AS (
SELECT activity_year
		, activity_month
		, active_users
		, last_month
        , (active_users - last_month) AS difference
        , ((active_users - last_month)/last_month)*100 AS per_growth
FROM cte_view
)

SELECT * FROM cte_diff_monthly_active_users;

