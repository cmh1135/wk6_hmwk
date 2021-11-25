--Carla H. WK 6 Homework

--1. Show all customers whose last names start with T. Order them by first name from A-Z.
SELECT last_name FROM customer --filtering customer table to creating a table of the customers names
WHERE(last_name) LIKE ('T%') --customers nameswhose last name starts with T
ORDER BY first_name; --sorted the list in ASC by first name  

--2. Show all rentals returned from 5/28/2005 to 6/1/2005
-- viewing the table 
SELECT * from rental;

--filtering table to rental date.
SELECT return_date FROM rental 
WHERE return_date >= '2005-05-28' --starting point
AND return_date <= '2006-06-01';--creating range end pt
-- Used WHERE to isolate data/ rentals by selected date range

--3.How would you determine which movies are rented the most?
SELECT r.inventory_id, f.title, i.film_id, --columns to select
COUNT(r.rental_id)AS times_rented --counting the times ea rental id appears gave alias  
FROM film AS f --pulled from film table first
INNER JOIN inventory AS i --joined film and inventory 
ON f.film_id = i.film_id --using film id as common column
INNER JOIN rental AS r --joined inventory and rental tables
ON i.inventory_id = r.inventory_idusing -- use inventory id as common column
GROUP BY r.inventory_id, f.title, i.film_id -- grouping table
ORDER BY times_rented DESC; --order by most to least rentals 
/*Joined the film, inventory and rental tables to get film title, id and count of times rented
Could have started with FROM rental or inventory or ordered join differently 
Kept film id in group as movie titles may not be unique */  

--4. Show how much each customer spent on movies (for all time) . Order them from least to most.
SELECT customer_id, SUM(amount) as amt_spent  FROM payment
GROUP BY customer_id ORDER BY amt_spent;
/* selected customer_id and amount. amount created w/ agg function and alias to 
add all amounts spent by each cus id and rename then sorted by the summed amount */

--5. Which actor was in the most movies in 2006 (based on this dataset)? Be sure to alias the actor name and count as a more descriptive name. Order the results from most to least.
SELECT concat(first_name, ' ', last_name) AS actor_full_name, --combines first and last name w/ space   
fa.actor_id, COUNT(fa.actor_id) AS num_movies_acted_2006
FROM actor AS ac
INNER JOIN film_actor AS fa
ON ac.actor_id = fa.actor_id
INNER JOIN film AS f
ON fa.film_id = f.film_id
WHERE f.release_year =2006
GROUP BY actor_full_name, fa.actor_id
ORDER BY num_movies_acted_2006 DESC;    
-- Gina Degeneres was in the most movies (42)
/* Joined actor, film amd film actor table to access release year, actor names
through film id and actor id columns. Used where clause to limit to movies
released in 2006. Sorted by count, most to least*/ 


--6. Write an explain plan for 4 and 5. Show the queries and explain what is happening in each one. Use the following link to understand how this works http://postgresguide.com/performance/explain.html 

EXPLAIN ANALYZE SELECT customer_id, SUM(amount) 
as amt_spent FROM payment GROUP BY customer_id ORDER BY amt_spent;  
--Explains details how effeciently a query processes 
/*explanation for 4: This query processes quickly as it processes 
one table and one row, Agg function and sorts  run slower */

EXPLAIN ANALYZE SELECT concat(first_name, ' ', last_name) AS actor_full_name, --combines first and last name w/ space   
fa.actor_id, COUNT(fa.actor_id) AS num_movies_acted_2006
FROM actor AS ac
INNER JOIN film_actor AS fa
ON ac.actor_id = fa.actor_id
INNER JOIN film AS f
ON fa.film_id = f.film_id
WHERE f.release_year =2006
GROUP BY actor_full_name, fa.actor_id
ORDER BY num_movies_acted_2006 DESC;  
/* explanation for 5: There are 3 seq scans, 1 for each table in the query. Group By clauses 
req more memory to process than other operations. The time to run each step 
of the query for each of these seq scans fast (low cost). Bucketing where created to partion data 
and reduce shuffling the multiple joins taking place */

--7. What is the average rental rate per genre?
SELECT cat.name AS genre, AVG(f.rental_rate) 
AS avg_rental_rate FROM category AS cat
INNER JOIN film_category AS fc
ON cat.category_id = fc.category_id
INNER JOIN film AS f
ON fc.film_id = f.film_id
GROUP BY cat.name
ORDER BY avg_rental_rate DESC;
/* Used join funcion for cat, film, cat and film to get rental rates and 
cat / genres. Agg fun to calc average rate then srted by avg rates descending */

--8. How many films were returned late? Early? On time?
SELECT CASE 
WHEN rental_duration >DATE_PART('day', return_date - rental_date) THEN 'returned early'
WHEN rental_duration =DATE_PART('day', return_date - rental_date) THEN 'returned on time'
ELSE 'returned late'
END AS return_status,
COUNT(*) AS num_films FROM film
INNER JOIN inventory AS i
ON film.film_id = i.film_id
INNER JOIN rental AS r
ON i.inventory_id = r.inventory_id
GROUP BY 1 ORDER BY 2 DESC;

--Early 7738,Late 6586, On Time 1720
/* Use case to create conditional clause that defines 
return status. Then loop returns, set agg fun to get a count of the films,  join film, rental and inventory 
to get rental and return date, sort by */ 

--9. What categories are the most rented and what are their total sales?

SELECT cat.name, COUNT(r.rental_id) 
AS times_rented, SUM(amount) as total_sales
FROM category AS cat
INNER JOIN film_category AS fc
ON cat.category_id = fc.category_id
INNER JOIN film AS f
ON fc.film_id = f.film_id
INNER JOIN inventory AS i
ON fc.film_id = i.film_id
INNER JOIN rental AS r
ON i.inventory_id = r.inventory_id
INNER JOIN payment AS pa
ON r.rental_id= pa.rental_id
GROUP BY cat.name
ORDER BY times_rented DESC, total_sales DESC;

/* Joined cat, filmm at, film, inventory, retal, 
and payment to get columns rental id, amount and name. 
Agg fun to add sales and num of rentals. grouped cat name 
in most -least order buy sales and rentals*/

--10. Create a view for 8 and a view for 9. Be sure to name them appropriately. 
CREATE VIEW return_status AS
SELECT CASE 
WHEN rental_duration >DATE_PART('day', return_date - rental_date) THEN 'returned early'
WHEN rental_duration =DATE_PART('day', return_date - rental_date) THEN 'returned on time'
ELSE 'returned late'
END AS return_status,
COUNT(*) AS num_films FROM film
INNER JOIN inventory AS i
ON film.film_id = i.film_id
INNER JOIN rental AS r
ON i.inventory_id = r.inventory_id
GROUP BY 1 ORDER BY 2 DESC;

CREATE VIEW most_rented_sales AS
SELECT cat.name, COUNT(r.rental_id) 
AS times_rented, SUM(amount) as total_sales
FROM category AS cat
INNER JOIN film_category AS fc
ON cat.category_id = fc.category_id
INNER JOIN film AS f
ON fc.film_id = f.film_id
INNER JOIN inventory AS i
ON fc.film_id = i.film_id
INNER JOIN rental AS r
ON i.inventory_id = r.inventory_id
INNER JOIN payment AS pa
ON r.rental_id= pa.rental_id
GROUP BY cat.name
ORDER BY times_rented DESC, total_sales DESC;
--create view forms a vitual from a result set that can be called later 

--Bonus: Write a query that shows how many films were rented each month. Group them by category and month. 

SELECT cat.name, COUNT(r.rental_id)AS times_rented,
Extract (MONTH FROM rental_date) AS rental_month
FROM category AS cat
INNER JOIN film_category AS fc
ON cat.category_id = fc.category_id
INNER JOIN film AS f
ON fc.film_id = f.film_id
INNER JOIN inventory AS i
ON fc.film_id = i.film_id
INNER JOIN rental AS r
ON i.inventory_id = r.inventory_id
INNER JOIN payment AS pa
ON r.rental_id= pa.rental_id
GROUP BY cat.name, rental_month
ORDER BY rental_month, times_rented;

/* used query from 9 without payment join, 
reformated date pulling month sorted in month order 
and rentals ASC*/ 
