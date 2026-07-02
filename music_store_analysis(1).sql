/*Q1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1

/* Q2: Which countries have the most Invoices? */

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC

/* Q3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;

/* Q6: Find the top 5 cities based on total revenue generated. */

SELECT billing_city,
SUM(total) AS total_revenue
FROM invoice
GROUP BY billing_city
ORDER BY total_revenue DESC
LIMIT 5;

/* Q7: Which customer placed the highest number of orders (invoices)?*/

SELECT c.customer_id,
       c.first_name,
       c.last_name,
       COUNT(i.invoice_id) AS total_orders
FROM customer c
JOIN invoice i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_orders DESC
LIMIT 1;

/* Q8 : Which music genre has the highest number of tracks?*/

SELECT g.name,
       COUNT(t.track_id) AS total_tracks
FROM genre g
JOIN track t
ON g.genre_id = t.genre_id
GROUP BY g.name
ORDER BY total_tracks DESC
LIMIT 1;


/* Q9: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

/* 10: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

/* 11: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name,milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC;

/* 12 Which artist has released the highest number of albums? */

SELECT ar.name,
       COUNT(al.album_id) AS total_albums
FROM artist ar
JOIN album al
ON ar.artist_id = al.artist_id
GROUP BY ar.name
ORDER BY total_albums DESC
LIMIT 1;

/* Q13: Which albums contain the most tracks? */
SELECT a.title,
       COUNT(t.track_id) AS total_tracks
FROM album a
JOIN track t
ON a.album_id = t.album_id
GROUP BY a.album_id, a.title
ORDER BY total_tracks DESC
LIMIT 10;

/* Q14 Which customers have purchased the highest number of tracks? */
SELECT c.customer_id,
       c.first_name,
       c.last_name,
       COUNT(il.track_id) AS total_tracks
FROM customer c
JOIN invoice i
ON c.customer_id = i.customer_id
JOIN invoice_line il
ON i.invoice_id = il.invoice_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_tracks DESC
LIMIT 10;

/* Q15: Find tracks that have never been purchased.*/

SELECT name
FROM track
WHERE track_id NOT IN (
    SELECT DISTINCT track_id
    FROM invoice_line
);

/* Q16: Which media type contains the highest number of tracks? */

SELECT mt.name,
       COUNT(t.track_id) AS total_tracks
FROM media_type mt
JOIN track t
ON mt.media_type_id = t.media_type_id
GROUP BY mt.media_type_id, mt.name
ORDER BY total_tracks DESC;

/* Q17. Calculate the running total revenue.*/
SELECT invoice_date,
       total,
       SUM(total) OVER(
           ORDER BY invoice_date
       ) AS running_total
FROM invoice;

/* Q18. Find the average invoice amount for every customer.*/
SELECT customer_id,
       invoice_id,
       total,
       AVG(total) OVER(
           PARTITION BY customer_id
       ) AS avg_customer_spending
FROM invoice;

/* Q19. Find the Top 3 customers in every country.*/
SELECT *
FROM(
SELECT country,
       first_name,
       last_name,
       SUM(total) spending,
       DENSE_RANK() OVER(
       PARTITION BY country
       ORDER BY SUM(total) DESC
       ) rnk
FROM customer
JOIN invoice
ON customer.customer_id=invoice.customer_id
GROUP BY country,customer.customer_id,first_name,last_name
)t
WHERE rnk<=3;

/* Q20. Show the next invoice amount.*/
SELECT invoice_id,
       invoice_date,
       total,
       LEAD(total) OVER(
       ORDER BY invoice_date
       ) AS next_invoice
FROM invoice;

/* Q21. Find the first invoice made by each customer.*/
SELECT DISTINCT customer_id,
       FIRST_VALUE(invoice_date) OVER(
       PARTITION BY customer_id
       ORDER BY invoice_date
       ) first_purchase
FROM invoice;

/* Q22: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q23: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1






















