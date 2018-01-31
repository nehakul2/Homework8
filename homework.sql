Use sakila;
#1a. Display the first and last names of all actors from the table actor.
select  first_name , last_name 
from sakila.actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select CONCAT(first_name, ', ' , last_name)  as Name from  actor;


#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
#What is one query would you use to obtain this information?#
select actor_id, first_name , last_name  from sakila.actor
where first_name  =  'JOE';

#2b. Find all actors whose last name contain the letters GEN:
select actor_id, first_name , last_name  from sakila.actor
where first_name  like   '%GEN%';

#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select actor_id, first_name , last_name  from sakila.actor
where last_name  like   '%LI%';

#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China
select country_id, country from country
where country in ('Afghanistan', 'Bangladesh', 'China');

#3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE `sakila`.`actor` 
ADD COLUMN `middle_name` VARCHAR(45) NULL DEFAULT '45' AFTER `first_name`;

#3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor
MODIFY COLUMN middle_name Blob;

#3c. Now delete the middle_name column.
ALTER TABLE `sakila`.`actor` 
DROP COLUMN `middle_name`;

#4a. List the last names of actors, as well as how many actors have that last name.
select a.first_name , a.last_name 
from actor a
join customer c
using (last_name);

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name from actor group by last_name having count(*) > 1;

#4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. 
#Write a query to fix the record.
#query to find the exact record
#select * from actor where first_name = "GROUCHO" and last_name = "WILLIAMS";

UPDATE actor 
SET first_name = "HARPO",
    last_name = "WILLIAMS"
WHERE (first_name = "GROUCHO" and last_name = "WILLIAMS");

#query to confirm the change is done as expected
#select * from actor where first_name = "HARPO" and last_name = "WILLIAMS";

/*
4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query,
 if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, 
 as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
*/
select * from actor where actor_id = 172;

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?%#
SHOW CREATE TABLE address;

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select s.first_name , s.last_name, a.address   from staff s
join address a
using(address_id);

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select staff_id, s.first_name ,s.last_name,sum(p.amount) from staff s
join payment p
using(staff_id)
where Year(p.payment_date) = 2005 and Month(p.payment_date) = 8
group by staff_id;
    
#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select f.title, fa.actor_id ,count( fa.actor_id) from film f
inner join film_actor fa
using(film_id);

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(*) from inventory where 
film_id  in 
	(select  film_id 
	from film 
	where title = 'Hunchback Impossible');
    

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select last_name ,first_name,sum(p.amount)  from customer
join payment p
using(customer_id)
group by(customer_id)
order by last_name;

/*7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.*/

select  title from 
film where title like  ( 'K%') or title like  'Q%'
and  language_id  in
(	
	select name
    from language l);
    
#7b. Use subqueries to display all actors who appear in the film Alone Trip.
select a.first_name,a.last_name from actor a
where a.actor_id in 
(
	select fa.actor_id from film_actor fa
join film m
	on fa.film_id = m.film_id
where m.title = 'Alone Trip');

#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
#where country_id in;
select c.first_name , c.last_name , c.customer_id , ci.city from customer c , address a, city ci
where c.address_id = a.address_id
and a.city_id = ci.city_id
and ci.country_id = 20;

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
select title,description from film where film_id in
(select film_id from film_category
		where category_id in
			(select category_id from category where name = 'Family'
            )
);

#7e. Display the most frequently rented movies in descending order.
#not sure if rental_rate is the right attribute
select * from film order by rental_rate desc ;

#this is also a solution to the same question.
SELECT f.film_id, f.title, COUNT(r.customer_id) AS rent_count
FROM rental r
JOIN inventory i USING (inventory_id) 
JOIN film f USING (film_id)
GROUP BY f.film_id
ORDER BY rent_count DESC;


#7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, concat('$',format(sum(amount),2)) as total_business
from store s 
	join  customer c
		using(store_id)
			join payment p
				on (c.customer_id = p.customer_id)
group by c.store_id;

#7g. Write a query to display for each store its store ID, city, and country.
select store_id, c.city , ct.country from store s
	join address a
		using (address_id)
			join city c
				using (city_id)
					join country ct
						using(country_id);
 


#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select c.name, sum(p.amount)  as gross_rev
 from category as c
	inner join film_category as f  	
		on c.category_id = f.category_id
	inner join inventory as i
		on f.film_id = i.film_id
	inner join rental as r
		on i.inventory_id = r.inventory_id
	inner join payment as p
		on r.rental_id= p.rental_id
group by c.name
order by 2 desc
limit 5;

/*
8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
If you haven't solved 7h, you can substitute another query to create a view.*/
create or replace view top_5_genres As
select c.name, sum(p.amount)  as gross_rev
 from category as c
	inner join film_category as f  	
		on c.category_id = f.category_id
	inner join inventory as i
		on f.film_id = i.film_id
	inner join rental as r
		on i.inventory_id = r.inventory_id
	inner join payment as p
		on r.rental_id= p.rental_id
group by c.name
order by 2 desc
limit 5;
 
#8b. How would you display the view that you created in 8a?
select * from top_5_genres;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_5_genres;
#confirm if the view is dropped
select * from top_5_genres;
