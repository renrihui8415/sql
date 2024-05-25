-- AGGREGATE
/* 1. Write a query that determines how many times each vendor has rented a booth 
at the farmer’s market by counting the vendor booth assignments per vendor_id. */
SELECT 
	vendor_id, 
	count(*) as booth_count 
FROM vendor_booth_assignments
GROUP BY vendor_id;

/* 2. The Farmer’s Market Customer Appreciation Committee wants to give a bumper 
sticker to everyone who has ever spent more than $2000 at the market. Write a query that generates a list 
of customers for them to give stickers to, sorted by last name, then first name. 

HINT: This query requires you to join two tables, use an aggregate function, and use the HAVING keyword. */

SELECT
	c.customer_last_name,
	c.customer_first_name,
	SUM(cp.quantity *cp.cost_to_customer_per_qty) AS total_cost
FROM customer_purchases AS cp
LEFT JOIN customer as c    -- use LEFT JOIN, because that the 'customer' table may not contain all customers' info
ON cp.customer_id=c.customer_id
GROUP BY cp.customer_id
HAVING total_cost >2000
ORDER BY c.customer_last_name, c.customer_first_name;

/* Thought on Data Cleansing
Although the Farmer's Market database has been cleaned, 
it's essential to account for potential issues with data types. 
While SQLite doesn't enforce data types, ensuring that values in the 'quantity' and 'cost_to_customer_per_qty' columns are valid 
is crucial for accurate calculations. Any invalid values, such as strings, or nulls,
should be excluded from calculations to maintain data integrity.
*/
SELECT
	c.customer_last_name,
	c.customer_first_name,
	SUM(COALESCE(CAST(cp.quantity AS REAL), 0)*COALESCE(CAST(cp.cost_to_customer_per_qty AS REAL), 0)) AS total_cost
FROM customer_purchases AS cp
LEFT JOIN customer as c    -- use LEFT JOIN, because that the 'customer' table may not contain all customers' info
ON cp.customer_id=c.customer_id
GROUP BY cp.customer_id
HAVING total_cost >2000
ORDER BY c.customer_last_name, c.customer_first_name;

--Temp Table
/* 1. Insert the original vendor table into a temp.new_vendor and then add a 10th vendor: 
Thomass Superfood Store, a Fresh Focused store, owned by Thomas Rosenthal

HINT: This is two total queries -- first create the table from the original, then insert the new 10th vendor. 
When inserting the new vendor, you need to appropriately align the columns to be inserted 
(there are five columns to be inserted, I've given you the details, but not the syntax) 

-> To insert the new row use VALUES, specifying the value you want for each column:
VALUES(col1,col2,col3,col4,col5) 
*/
DROP TABLE IF EXISTS new_vendor;

CREATE TEMP TABLE new_vendor AS

SELECT * FROM vendor;

INSERT INTO new_vendor (vendor_id, vendor_name,vendor_type,vendor_owner_first_name,vendor_owner_last_name)
	VALUES(10, 'Thomass Superfood Store', 'Fresh Focused', 'Thomas', 'Rosenthal');

SELECT * FROM new_vendor;


-- Date
/*1. Get the customer_id, month, and year (in separate columns) of every purchase in the customer_purchases table.

HINT: you might need to search for strfrtime modifers sqlite on the web to know what the modifers for month 
and year are! */

SELECT 
	customer_id,
	strftime('%m', market_date) as month,
	strftime('%Y', market_date) as year
	
FROM customer_purchases;


/* 2. Using the previous query as a base, determine how much money each customer spent in April 2019. 
Remember that money spent is quantity*cost_to_customer_per_qty. 

HINTS: you will need to AGGREGATE, GROUP BY, and filter...
but remember, STRFTIME returns a STRING for your WHERE statement!! */

SELECT 
	customer_id,
	strftime('%m', market_date) as month,
	strftime('%Y', market_date) as year,
	sum(quantity * cost_to_customer_per_qty) as total_cost
	
FROM customer_purchases
WHERE month ='04' AND year = '2019'
GROUP BY customer_id, month, year;

/* Thought on data cleansing
If we take data validation into consideration, the QUERY would be like:
*/
SELECT 
	customer_id,
	strftime('%m', market_date) as month,
	strftime('%Y', market_date) as year,
	SUM(COALESCE(CAST(quantity AS REAL), 0)*COALESCE(CAST(cost_to_customer_per_qty AS REAL), 0)) AS total_cost
	
FROM customer_purchases
WHERE month ='04' AND year = '2019'
GROUP BY customer_id, month, year;
