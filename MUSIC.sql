SELECT * FROM album
SELECT * FROM artist
SELECT * FROM employee
SELECT * FROM invoice
SELECT * FROM genre
SELECT * FROM media_type
SELECT * FROM playlist_track
SELECT * FROM track
SELECT * FROM invoice_line
SELECT * FROM customer
SELECT * FROM album


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

WITH damn AS (
SELECT SUM(total) as total, customer_id
FROM invoice
GROUP BY customer_id
ORDER BY total DESC
)
SELECT d.total, d.customer_id, c.first_name, c.last_name
FROM damn AS d
LEFT JOIN customer AS c
ON d.customer_id = c.customer_id
ORDER BY d.total DESC
LIMIT 1


/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT(g.name), c.first_name, c.last_name, c.email  FROM genre AS g
JOIN track AS t ON g.genre_id=t.genre_id
JOIN invoice_line as i ON t.track_id = i.track_id	
JOIN invoice as inv ON i.invoice_id=inv.invoice_id
JOIN customer as c ON inv.customer_id=c.customer_id
WHERE g.name='Rock'
ORDER BY c.email


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT COUNT(t.name) as total_track_count, a.name as artist_name, a.artist_id from artist as a
JOIN album as al ON a.artist_id = al.artist_id
JOIN track as t ON t.album_id=al.album_id
JOIN genre as g ON g.genre_id=t.genre_id
WHERE g.name='Rock'
GROUP BY a.artist_id
ORDER BY total_track_count DESC
LIMIT 10


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name, milliseconds FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) from track)
ORDER BY milliseconds DESC

/* Q1: Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent */

SELECT c.first_name as customer, art.name as artist, SUM(i.total) as total_spent FROM customer as c
JOIN invoice as i ON c.customer_id=i.customer_id
JOIN invoice_line as il ON il.invoice_id=i.invoice_id
JOIN track as t ON t.track_id=il.track_id
JOIN album AS a ON a.album_id=t.album_id
JOIN artist AS art ON art.artist_id=a.artist_id
GROUP BY first_name, art.name 
ORDER BY total_spent DESC


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */
WITH damn as (
SELECT c.country, g.name as genre, SUM(il.quantity) as quantity, ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY SUM(il.quantity) DESC) AS car
FROM genre as g
JOIN track as t ON t.genre_id=g.genre_id
JOIN invoice_line as il ON il.track_id=t.track_id
JOIN invoice as i ON i.invoice_id=il.invoice_id
JOIN customer as c ON c.customer_id=i.customer_id
GROUP BY g.name, c.country
ORDER by c.country DESC
)
SELECT country, genre, quantity, car FROM damn
WHERE car=1

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
WITH damn AS(
SELECT c.country, c.first_name, SUM(i.total) as total, ROW_NUMBER() OVER(PARTITION BY country ORDER BY SUM(i.total) DESC) as car
FROM genre as g
JOIN track as t ON t.genre_id=g.genre_id
JOIN invoice_line as il ON il.track_id=t.track_id
JOIN invoice as i ON i.invoice_id=il.invoice_id
JOIN customer as c ON c.customer_id=i.customer_id
GROUP BY first_name, c.country
ORDER BY c.country ASC, total DESC
)
SELECT country, first_name, total, car FROM damn
WHERE car=1

damn1 as(
SELECT country, first_name, total, ROW_NUMBER() OVER(PARTITION BY country ORDER BY total DESC) as car 
FROM damn)

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1




