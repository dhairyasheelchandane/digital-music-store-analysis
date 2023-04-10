Use music_store;

-- Q.1 Who is the most senior employee based on the job title?

select * from employee
order by levels desc
limit 1;

-- Q.2 Which countries have the most invoices?

select count(*) as Invoices,  billing_country
from invoice
group by billing_country
order by Invoices desc;

-- Q.3 What are top 3 values of total invoice?

Select total from invoice
order by total desc
limit 3;

-- Q.4 Which city has the best customers?
-- We would like to throw a promotional music festival in the city we made the most money.
-- Write a query that returns one city that has the highest sum of invoice totals.
-- Return both city name & sum of all invoice totals.

select sum(total) as Invoice_total, billing_city
from invoice
group by billing_city
order by Invoice_total desc;

-- Q.5 Who is the best customer?
-- The customer who has spent most money will be declared the best customer.
-- Write a query that returns the person who has spent the most money.

select customer.customer_id,customer.first_name,customer.last_name, sum(invoice.total) as Total
from customer
join invoice on invoice.customer_id = customer.customer_id
group by customer.customer_id
order by Total desc
limit 1;

-- Q.6 Write a query to return email, firt_name and last_name of all rock music listeners.
-- Return your list ordered alphabetically by email strating with A.

select distinct email, first_name, last_name from
customer
join invoice on invoice.customer_id = customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
where track_id in(
					Select track_id from track
					join genre on genre.genre_id = track.genre_id
                    where genre.name = 'Rock'
)
order by email;

-- Q.7 Let's invite the artists who have written the most rock music in our dataset.
-- Write a query that returns the artist name and the total track count of the top 3 rock bands.

select artist.artist_id, artist.name, count(artist.artist_id) as Number_of_Songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name = 'Rock'
group by artist.artist_id
order by Number_of_Songs desc
limit 3;

-- Q.8 Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

select name, milliseconds
from track
where milliseconds > (
	select avg(milliseconds) as avg_track_length
	from track )
order by milliseconds desc;

-- Q.9 Find how much amount spent by each customer on best selling artist? Write a query to return customer name, artist name and total spent.

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

-- Q.10 We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
-- with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
-- the maximum number of purchases is shared return all Genres.

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
SELECT * FROM popular_genre WHERE RowNo <= 1;

-- Q.11 Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount.

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;






 




