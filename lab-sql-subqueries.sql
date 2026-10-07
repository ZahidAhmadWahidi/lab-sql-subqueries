USE sakila ;
-- determine the total number of physical copies of 
-- the movie "Hunchback Impossible" stored across the entire inventory system
SELECT 
    f.title, 
    COUNT(i.inventory_id) AS total_copies
FROM film f
JOIN inventory i ON f.film_id = i.film_id
WHERE f.title = 'HUNCHBACK IMPOSSIBLE'
GROUP BY f.film_id, f.title;
-- List all films whose length is longer than the global average length
-- we use subquery here 
SELECT title, length 
FROM film 
WHERE length > (
    SELECT AVG(length) 
    FROM film
)
ORDER BY length ASC;

-- Use a subquery to display all actors who appear in the film "Alone Trip"
SELECT first_name, last_name 
FROM actor 
WHERE actor_id IN (
    SELECT actor_id 
    FROM film_actor 
    WHERE film_id = (
        SELECT film_id 
        FROM film 
        WHERE title = 'ALONE TRIP'
    )
);

--
SELECT f.title AS family_film_title, c.name AS category_name
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Family'
ORDER BY f.title ASC;

--  Customer Retrieval: Canadian Customers (Subqueries vs. Joins)
-- using joins 
SELECT cu.first_name, cu.last_name, cu.email, co.country
FROM customer cu
JOIN address a ON cu.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

-- using subquery 

SELECT first_name, last_name, email 
FROM customer 
WHERE address_id IN (
    SELECT address_id FROM address WHERE city_id IN (
        SELECT city_id FROM city WHERE country_id = (
            SELECT country_id FROM country WHERE country = 'Canada'
        )
    )
);

--  Star Power: Films starring the most prolific actor
SELECT title AS films_starring_top_actor 
FROM film 
WHERE film_id IN (
    SELECT film_id 
    FROM film_actor 
    WHERE actor_id = (
        SELECT actor_id 
        FROM film_actor 
        GROUP BY actor_id 
        ORDER BY COUNT(film_id) DESC 
        LIMIT 1
    )
)
ORDER BY title ASC;

-- 4. VIP Rentals: Films rented by the most profitable customer

SELECT DISTINCT f.title AS films_rented_by_vip
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.customer_id = (
    SELECT customer_id 
    FROM payment 
    GROUP BY customer_id 
    ORDER BY SUM(amount) DESC 
    LIMIT 1
)
ORDER BY f.title ASC;


-- 5. High-Rollers: Clients spending more than the global client average

SELECT customer_id, SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING total_amount_spent > (
    SELECT AVG(sub.total_spent)
    FROM (
        SELECT SUM(amount) AS total_spent
        FROM payment
        GROUP BY customer_id
    ) AS sub
)
ORDER BY total_amount_spent DESC;






