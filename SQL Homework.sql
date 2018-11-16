USE sakila ;

-- 1a. Display the first and last names of all actors from the table `actor`.

SELECT first_name, last_name
FROM actor ;

-- 1b. Display the first and last name of each actor in a single column in 
-- upper case letters. Name the column `Actor Name`.

SELECT actor_id
     , CONCAT_WS(' ', UPPER(first_name), UPPER(last_name)) AS 'Actor Name'
FROM  actor ;

-- 2a. You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." What is one query would you use 
-- to obtain this information?

SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe" ;

-- 2b. Find all actors whose last name contain the letters `GEN`:

SELECT last_name
FROM actor
WHERE last_name LIKE '%GEN%' ;

-- 2c. Find all actors whose last names contain the letters `LI`. This time, 
-- order the rows by last name and first name, in that order:

SELECT last_name, first_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name ;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the 
-- following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China") ;

-- 3a. You want to keep a description of each actor. You don't think you will 
-- be performing queries on a description, so create a column in the table
-- `actor` named `description` and use the data type `BLOB` 

ALTER TABLE actor
ADD COLUMN description BLOB ;

-- 3b. Very quickly you realize that entering descriptions for each actor is 
-- too much effort. Delete the `description` column.

ALTER TABLE actor
DROP COLUMN description ;

-- 4a. List the last names of actors, as well as how many actors have 
-- that last name.

SELECT last_name, COUNT(last_name) AS shared_count
FROM actor
GROUP BY last_name ;

-- 4b. List last names of actors and the number of actors who have that 
-- last name, but only for names that are shared by at least two actors

SELECT last_name, COUNT(last_name) AS shared_count
FROM actor
GROUP BY last_name
HAVING shared_count >= 2 ;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` 
-- table as `GROUCHO WILLIAMS`. Write a query to fix the record.

UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns 
-- out that `GROUCHO` was the correct name after all! In a single query, if 
-- the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO" ;

-- 5a. You cannot locate the schema of the `address` table. Which query would 
-- you use to re-create it?

CREATE TABLE address
(
	address_id SMALLINT(5) UNSIGNED UNIQUE AUTO_INCREMENT,
    address VARCHAR(50) DEFAULT NULL,
    address2 VARCHAR(50) DEFAULT NULL,
    district VARCHAR(20) DEFAULT NULL,
    city_id SMALLINT(5) UNIQUE DEFAULT NULL,
    postal_code VARCHAR(10) DEFAULT NULL,
    phone VARCHAR(20) DEFAULT NULL,
    location GEOMETRY DEFAULT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY(address_id)
);

-- 6a. Use `JOIN` to display the first and last names, as well as the address, 
-- of each staff member. Use the tables `staff` and `address`:

SELECT a.first_name, a.last_name, b.address
FROM staff AS a
JOIN address AS b
ON a.address_id = b.address_id ;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in 
-- August of 2005. Use tables `staff` and `payment`.

SELECT a.staff_id, SUM(b.amount) AS 'Total Amount'
FROM staff AS a
JOIN payment AS b
ON a.staff_id = b.staff_id
GROUP BY staff_id ;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables `film_actor` and `film`. Use inner join.

SELECT a.title, COUNT(b.actor_id)
FROM film AS a
JOIN film_actor b
ON a.film_id = b.film_id
GROUP BY title ;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the 
-- inventory system?

SELECT a.title, COUNT(b.inventory_id) AS 'Copies Count'
FROM film AS a
JOIN inventory AS b
ON a.film_id = b.film_id
WHERE a.title = "Hunchback Impossible"
GROUP BY a.title ;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, 
-- list the total paid by each customer. List the customers alphabetically by last name:

SELECT a.last_name, a.first_name, SUM(b.amount) AS 'Total Paid'
FROM customer AS a
LEFT JOIN payment AS b
ON a.customer_id = b.customer_id
GROUP BY a.customer_id
ORDER BY last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters `K` and `Q` have 
-- also soared in popularity. Use subqueries to display the titles of movies 
-- starting with the letters `K` and `Q` whose language is English.

SELECT title
FROM film
WHERE language_id IN
	(SELECT language_id
	 FROM language
	 WHERE name = "English")
AND title LIKE 'K%'
OR title LIKE 'Q%' ;

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name
FROM actor
WHERE actor_id IN
	(SELECT actor_id
     FROM film_actor
     WHERE film_id IN
		(SELECT film_id
		 FROM film
         WHERE title = "Alone Trip"
		)
	) ;
    
-- 7c. You want to run an email marketing campaign in Canada, for which you will 
-- need the names and email addresses of all Canadian customers. Use joins to 
-- retrieve this information.

SELECT a.first_name, a.last_name, a.email
FROM customer as a
INNER JOIN address as b ON b.address_id = a.address_id
INNER JOIN city as c ON c.city_id = b.city_id
INNER JOIN country as d ON d.country_id = c.country_id
WHERE country = "Canada" ;

-- 7d. Sales have been lagging among young families, and you wish to target all 
-- family movies for a promotion. Identify all movies categorized as _family_ films.

SELECT a.title as Film_Title, c.name as Category
FROM film as a
INNER JOIN film_category as b ON b.film_id = a.film_id
INNER JOIN category as c ON c.category_id = b.category_id
WHERE c.name = "Family" ;

-- 7e. Display the most frequently rented movies in descending order.

SELECT a.title as Film_Title, COUNT(c.rental_id) as Total_Rentals
FROM film as a
INNER JOIN inventory as b ON b.film_id = a.film_id
INNER JOIN rental as c ON c.inventory_id = b.inventory_id
GROUP BY a.title
ORDER BY Total_Rentals DESC ;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT c.store_id as Store, SUM(a.amount) as Total_Sales
FROM payment as a
INNER JOIN staff as b ON b.staff_id = a.staff_id
INNER JOIN store as c ON c.store_id = b.store_id
GROUP BY c.store_id ;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT a.store_id as Store, c.city as City, d.country as Country
FROM store as a
INNER JOIN address as b ON b.address_id = a.address_id
INNER JOIN city as c ON c.city_id = b.city_id
INNER JOIN country as d ON d.country_id = c.country_id ;

-- 7h. List the top five genres in gross revenue in descending order.

SELECT a.name as Category, SUM(e.amount) as Total_Sales
FROM category as a
INNER JOIN film_category as b ON b.category_id = a.category_id
INNER JOIN inventory as c ON c.film_id = b.film_id
INNER JOIN rental as d ON d.inventory_id = c.inventory_id
INNER JOIN payment as e ON e.rental_id = d.rental_id
GROUP BY Category
ORDER BY Total_Sales DESC
LIMIT 5 ;

-- 8a. In your new role as an executive, you would like to have an easy way 
-- of viewing the Top five genres by gross revenue.

CREATE VIEW Top_5_Genres_By_Gross_Revenue AS
SELECT a.name as Category, SUM(e.amount) as Total_Sales
FROM category as a
INNER JOIN film_category as b ON b.category_id = a.category_id
INNER JOIN inventory as c ON c.film_id = b.film_id
INNER JOIN rental as d ON d.inventory_id = c.inventory_id
INNER JOIN payment as e ON e.rental_id = d.rental_id
GROUP BY Category
ORDER BY Total_Sales DESC
LIMIT 5 ;

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM Top_5_Genres_By_Gross_Revenue ;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a 
-- query to delete it.

DROP VIEW Top_5_Genres_By_Gross_Revenue ;