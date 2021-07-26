use sakila;

-- 1. Get number of monthly active customers.

with cte as (
	select rental_id, customer_id, date_format(rental_date, '%m') as rental_month, date_format(rental_date, '%Y') as rental_year
	from rental
    ),
    cte1 as (
	select c.rental_year, c.rental_month, count(distinct(c.customer_id)) as active_customers
	from cte c
    join customer a
    ON c.customer_id = a.customer_id
    WHERE active = 1
	group by rental_year, rental_month
	order by rental_year, rental_month
    )
    Select * from cte1;
 
    

-- 2. Active users in the previous month.

with cte as (
	select rental_id, customer_id, date_format(rental_date, '%m') as rental_month, date_format(rental_date, '%Y') as rental_year
	from rental
    ),
    cte1 as (
	select c.rental_year, c.rental_month, count(distinct(c.customer_id)) as active_customers
	from cte c
    join customer a
    ON c.customer_id = a.customer_id
    WHERE active = 1
	group by rental_year, rental_month
	order by rental_year, rental_month
    ),
	cte2 as (
    select rental_year,
			rental_month,
			active_customers,
			lag(active_customers) over(order by rental_year, rental_month) as last_month
	from cte1
    )
    Select * from cte2;
    
-- 3. Percentage change in the number of active customers.

with cte as (
	select rental_id, customer_id, date_format(rental_date, '%m') as rental_month, date_format(rental_date, '%Y') as rental_year
	from rental
    ),
    cte1 as (
	select c.rental_year, c.rental_month, count(distinct(c.customer_id)) as active_customers
	from cte c
    join customer a
    ON c.customer_id = a.customer_id
    WHERE active = 1
	group by rental_year, rental_month
	order by rental_year, rental_month
    ),
	cte2 as (
    select rental_year,
			rental_month,
			active_customers,
			lag(active_customers) over(order by rental_year, rental_month) as last_month
	from cte1
    ),
     cte3 as (
	select rental_year,
			rental_month,
			active_customers,
			last_month,
			((active_customers - last_month)/last_month)*100 as per_growth
	from cte2
    )
    
    Select * from cte3;

-- 4. Retained customers every month.

with cte as (
	select rental_id, customer_id, date_format(rental_date, '%m') as rental_month, date_format(rental_date, '%Y') as rental_year
	from rental
    ),
    cte1 as (
	select c.rental_year, c.rental_month, count(distinct(c.customer_id)) as active_customers
	from cte c
    join customer a
    ON c.customer_id = a.customer_id
    WHERE active = 1
	group by rental_year, rental_month
	order by rental_year, rental_month
    ),
	cte2 as (
    select rental_year,
			rental_month,
			active_customers,
			lag(active_customers) over(order by rental_year, rental_month) as last_month
	from cte1
    ),
     cte3 as (
	select rental_year,
			rental_month,
			active_customers,
			last_month,
			((active_customers - last_month)/last_month)*100 as per_growth,
            (active_customers - last_month) as diff
	from cte2
    ),
	cte4 as (
		select rental_year,
			rental_month,
			active_customers,
			last_month,
			(active_customers + diff) as retained  -- calculated the retained customers by adding to the active customers the difference of customers every month
	from cte3
    )
    Select * from cte4;
