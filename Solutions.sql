USE sakila;

-- 1. Get number of monthly active customers.
CREATE OR REPLACE VIEW sakila.user_activity AS
SELECT customer_id,
DATE_FORMAT(CONVERT(rental_date, DATE), '%m') AS activity_month,
DATE_FORMAT(CONVERT(rental_date, DATE), '%Y') AS activity_year
FROM rental;

SELECT * 
FROM sakila.user_activity;

CREATE OR REPLACE VIEW sakila.monthly_active_users AS
SELECT activity_year, activity_month, COUNT(DISTINCT(customer_id)) AS user_count
FROM user_activity
GROUP BY activity_year, activity_month
ORDER BY activity_year, activity_month;

SELECT * 
FROM monthly_active_users;

-- 2. Active users in the previous month.
SELECT activity_year, activity_month, user_count, 
	LAG(user_count) OVER (PARTITION BY activity_year ORDER BY activity_year, activity_month) AS user_count_prevm 
FROM monthly_active_users;

-- 3. Percentage change in the number of active customers.
CREATE OR REPLACE VIEW sakila.diff_monthly_active_users AS
WITH cte_view AS (
	SELECT activity_year, activity_month, user_count, 
		LAG(user_count) OVER (PARTITION BY activity_year ORDER BY activity_year, activity_month) AS user_count_prevm
	FROM monthly_active_users
	)
SELECT activity_year, activity_month, user_count, user_count_prevm, 
	(user_count - user_count_prevm) AS difference,
	((user_count - user_count_prevm)/user_count_prevm)*100 AS percent_change
FROM cte_view;

SELECT * 
FROM diff_monthly_active_users;

-- 4. Retained customers every month.

