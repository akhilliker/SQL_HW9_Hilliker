USE sakila;
-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
-- CONCAT_WS connects data in two fields; the first parameter is the spacer between the field data
DESCRIBE actor;
SELECT actor_id, CONCAT_WS(' ', first_name, last_name) AS "Actor Name" FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
-- or use WHERE first_name LIKE  "JO%" to pick up names like JOSEPH, but not needed here
SELECT actor_id, first_name, last_name FROM actor WHERE first_name  = "JOE";

-- 2b. Find all actors whose last name contain the letters GEN:
-- Returns 4 names
SELECT * FROM actor WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
-- %LI% finds names with LI anywhere in the name. LI% finds names that start with LI
SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name ASC;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
-- IN (A,B,C) functions like A or B or C
SELECT country_id, country FROM country WHERE country IN ("Afghanistan", "Bangladesh",  "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor 
ADD description LONGBLOB;
SELECT * FROM actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS 'number of actors w/this name'
FROM actor
GROUP BY last_name; 

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
-- HAVING is a way to subselect a portion of data from the group by
SELECT last_name, COUNT(last_name) AS 'number of actors sharing name'
FROM actor 
GROUP BY last_name HAVING COUNT(last_name) >= 2; 

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
SELECT actor_ID, first_name FROM actor WHERE last_name = "WILLIAMS"; -- GROUCHO ID is 172
UPDATE actor
SET first_name = "HARPO" 
WHERE actor_ID = 172;
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
-- NOTE: I'm not sure what I should have done that is more succicant, as I think this counts as one query.
-- I could say WHERE first_name = "HARPO" here, but that risks changing more records if there is another HARPO in the dataset
UPDATE actor
SET first_name = "GROUCHO" 
WHERE actor_ID = 172;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT * FROM address;
SELECT * FROM staff; -- only 2 staff members shown
SHOW CREATE TABLE staff; -- address_id in staff table is a foreign key for address_id in address table
-- choosing LEFT JOIN on staff so that all staff are included, even if there is no address on file
SELECT address, staff.first_name, staff.last_name
FROM staff
LEFT JOIN address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
-- choosing LEFT JOIN on staff so that all staff are included, even if they never rang a transaction
SELECT staff.last_name, staff.first_name,  SUM(payment.amount)
FROM staff
LEFT JOIN payment ON staff.staff_id = payment.payment_id
GROUP BY staff.last_name, staff.first_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title, COUNT(film_actor.film_id)
FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, COUNT(inventory.film_id) AS "Total Inventory"
FROM film
LEFT JOIN inventory ON film.film_id = inventory.film_id
GROUP BY title HAVING title = "Hunchback Impossible"; 

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT last_name, first_name, SUM(amount) AS "Total Paid"
FROM customer
LEFT JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY last_name, first_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
-- Use WHERE once and use OR and AND to connect the different conditions of the WHERE clause
-- Code will first find the english language id and then find all titles starting with K or Q, but only keep those that have the english language code
SELECT title
FROM film
WHERE title LIKE "K%"  OR title LIKE "Q%"
and film.language_id  IN
(
SELECT language_id
FROM language
WHERE name = "English"
);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN 
(
SELECT actor_id
FROM film_actor
WHERE film_id IN
(
SELECT film_id
FROM film
WHERE title = "Alone Trip"
));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT d.customer_id, d.first_name, d.last_name, d.email
FROM customer d
JOIN address c
ON c.address_id = d.address_id
JOIN city b
ON b.city_id = c.city_id
JOIN country a
ON a.country_id = b.country_id AND a.country = "Canada";

/* Opps, this uses subqueries...
SELECT first_name, last_name, email -- select this customer info from customers with address that are from Canadian cities
FROM customer
WHERE address_id IN
(SELECT address_id -- select all address_id from address in the city_id s found in Canada
FROM address
WHERE city_id IN
(SELECT city_id -- selects any cit_id for cities in Canada
FROM city
WHERE country_id IN
(SELECT country_id -- selects only the country id for Canada, 20)
FROM country
WHERE country = "Canada"
)))
; */

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT * FROM category;
SELECT a.title
FROM film a
JOIN film_category b
ON a.film_id = b.film_id
JOIN category c
ON b.category_id = c.category_id AND c.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT * FROM rental;

SELECT a.title, COUNT(c.inventory_id) AS 'Number of rentals'
FROM film a 
JOIN inventory b
ON a.film_id = b.film_id
JOIN rental c
ON b.inventory_id = c.inventory_id
GROUP BY a.title
ORDER BY COUNT(c.inventory_id) DESC; 

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT a.store_id, sum(d.amount) AS "Sales in dollars"
FROM store a
JOIN staff b
ON a.store_id = b.store_id
JOIN rental c
ON b.staff_id = c.staff_id
JOIN payment d
ON c.rental_id = d.rental_id
GROUP BY a.store_id
ORDER BY a.store_id ASC;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT a.store_id, c.country_id, d.country
FROM store a
JOIN address b
ON a.address_id = b.address_id
JOIN city c
ON b.city_id = c.city_id
JOIN country d
ON c.country_id = d.country_id
ORDER BY a.store_id ASC;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT a.name, sum(e.amount) AS gross_revenue
FROM category a
JOIN film_category b
ON a.category_id = b.category_id
JOIN inventory c 
ON b.film_id = c.film_id
JOIN rental d
ON c.inventory_id = d.inventory_id
JOIN payment e
ON d.rental_id = e.rental_id
GROUP BY a.name
ORDER BY gross_revenue DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres_gross_rev AS
	SELECT a.name, sum(e.amount) AS gross_revenue
	FROM category a
	JOIN film_category b
	ON a.category_id = b.category_id
	JOIN inventory c 
	ON b.film_id = c.film_id
	JOIN rental d
	ON c.inventory_id = d.inventory_id
	JOIN payment e
	ON d.rental_id = e.rental_id
	GROUP BY a.name
	ORDER BY gross_revenue DESC LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres_gross_rev;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres_gross_rev;
SELECT * FROM top_five_genres_gross_rev;
-- After DROP, SELECT statement above gives error: Error Code: 1146. Table 'sakila.top_five_genres_gross_rev' doesn't exist
