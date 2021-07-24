-- 1. Get number of monthly active customers.
SELECT 	date_format(convert(last_update,date), '%m') AS months
		, COUNT(active) AS active_customers
FROM customer
GROUP BY 1
ORDER BY 1;

-- 2. Active users in the previous month.
SELECT 	date_format(convert(last_update,date), '%m') AS months
		, LAG(COUNT(active)) OVER() AS active_customers_last_month
FROM customer
GROUP BY 1
ORDER BY 1;

-- 3. Percentage change in the number of active customers.
WITH cte AS (
SELECT 	date_format(convert(last_update,date), '%m') AS months
		, COUNT(active) AS active_customers
        , LAG(COUNT(active)) OVER() AS active_customers_last_month
FROM customer
GROUP BY 1
ORDER BY 1
)
SELECT 	cte.*
		, (active_customers-active_customers_last_month)/active_customers*100 as percentage_change
FROM cte
;

-- 4. Retained customers every month.
with cte as
(
	SELECT date_format(convert(last_update,date), '%m') AS months
		, COUNT(active) AS active_customers
        , LAG(COUNT(active)) OVER() AS active_customers_last_month
    FROM customer
    GROUP BY 1
)
select active_customers - active_customers_last_month
from cte;