USE sakila;

-- 1. Get number of monthly active customers.

-- I decided to use the rental table as an active customer is someone who rents films

SELECT YEAR(rental_date) AS active_year,
        MONTH(rental_date) AS active_month,
        COUNT(DISTINCT(customer_id)) AS active_customers
FROM rental
GROUP BY active_year, active_month;

-- 2. Active users in the previous month.
WITH cte1 AS(
SELECT YEAR(rental_date) AS active_year,
        MONTH(rental_date) AS active_month,
        COUNT(DISTINCT(customer_id)) AS active_customers
FROM rental
GROUP BY active_year, active_month)
SELECT active_year,
        active_month,
        active_customers,
        LAG(active_customers) OVER(ORDER BY active_year, active_month) AS previous_month
FROM cte1;

-- 3. Percentage change in the number of active customers.

WITH cte1 AS
			(SELECT YEAR(rental_date) AS active_year,
					MONTH(rental_date) AS active_month,
					COUNT(DISTINCT(customer_id)) AS active_customers
			FROM rental
			GROUP BY active_year, active_month),
cte2 AS
		(SELECT active_year,
				active_month,
				active_customers,
				LAG(active_customers) OVER(ORDER BY active_year, active_month) AS previous_month
		FROM cte1)
SELECT active_year,
		active_month,
		active_customers,
		previous_month,
        (active_customers - previous_month) AS difference,
        round(((active_customers - previous_month)/previous_month)*100, 2) AS growth_percentage
FROM cte2;

-- 4. Retained customers every month.
-- I am not sure how to do this..this is the same query as the one before.
-- how can we find out how many customers there were at the beginning of the period?


WITH cte1 AS
			(SELECT YEAR(rental_date) AS active_year,
					MONTH(rental_date) AS active_month,
					COUNT(DISTINCT(customer_id)) AS active_customers
			FROM rental
			GROUP BY active_year, active_month),
cte2 AS
		(SELECT active_year,
				active_month,
				active_customers,
				LAG(active_customers) OVER(ORDER BY active_year, active_month) AS previous_month
		FROM cte1)
SELECT active_year,
		active_month,
		active_customers,
		previous_month,
        (active_customers - previous_month) AS difference,
        round(((active_customers - previous_month)/previous_month)*100, 2) AS growth_percentage
FROM cte2;