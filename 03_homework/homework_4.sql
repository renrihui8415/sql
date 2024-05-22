-- COALESCE
/* 1. Our favourite manager wants a detailed long list of products, but is afraid of tables! 
We tell them, no problem! We can produce a list with all of the appropriate details. 

Using the following syntax you create our super cool and not at all needy manager a list:

SELECT 
product_name || ', ' || product_size|| ' (' || product_qty_type || ')'
FROM product

But wait! The product table has some bad data (a few NULL values). 
Find the NULLs and then using COALESCE, replace the NULL with a 
blank for the first problem, and 'unit' for the second problem. 

HINT: keep the syntax the same, but edited the correct components with the string. 
The `||` values concatenate the columns into strings. 
Edit the appropriate columns -- you're making two edits -- and the NULL rows will be fixed. 
All the other rows will remain the same.) */

SELECT 
    COALESCE(product_name, '') || ', ' || COALESCE(product_size,'') || ' (' || COALESCE(product_qty_type, 'unit') || ')' as Product_List
FROM product;

--Windowed Functions
/* 1. Write a query that selects from the customer_purchases table and numbers each customer’s  
visits to the farmer’s market (labeling each market date with a different number). 
Each customer’s first visit is labeled 1, second visit is labeled 2, etc. 

You can either display all rows in the customer_purchases table, with the counter changing on
each new market date for each customer, or select only the unique market dates per customer 
(without purchase details) and number those visits. 
HINT: One of these approaches uses ROW_NUMBER() and one uses DENSE_RANK(). */

-- Approach 1, row_number 
-- Select only the unique market dates per customer
SELECT 
	customer_id,
    market_date,
	row_number() OVER (PARTITION BY customer_id ORDER BY market_date) as visit_number
FROM (

	SELECT 
		DISTINCT customer_id, market_date 
	FROM customer_purchases
	
) as distinct_visits;
		
-- Approach 2, dense_rank 
-- Display all rows in the 'customer_purchases' table
SELECT
	*,
	dense_rank() OVER (PARTITION BY customer_id ORDER BY market_date) as visit_number

FROM customer_purchases;



/* 2. Reverse the numbering of the query from a part so each customer’s most recent visit is labeled 1, 
then write another query that uses this one as a subquery (or temp table) and filters the results to 
only the customer’s most recent visit. */

-- Reverse the rank in 'DESC' order
-- Select only the unique market dates per customer to ensure a single recent visit date per customer
-- Otherwise, one customer may have duplicate recent visit dates
SELECT
	customer_id,
    market_date,
	dense_rank() OVER (PARTITION BY customer_id ORDER BY market_date DESC) as visit_number
FROM(
	SELECT 
		DISTINCT customer_id, market_date 
	FROM customer_purchases
) as distinct_visits;

-- SELECT the most recent visit for each customer
SELECT 
	customer_id,
	market_date as recent_visit
FROM (

		SELECT
			customer_id,
			market_date,
			dense_rank() OVER (PARTITION BY customer_id ORDER BY market_date DESC) as visit_number
		FROM(
			SELECT 
				DISTINCT customer_id, market_date 
			FROM customer_purchases
		) as distinct_visits
	
) AS rank_visits
WHERE 
	rank_visits.visit_number=1;

/* 3. Using a COUNT() window function, include a value along with each row of the 
customer_purchases table that indicates how many different times that customer has purchased that product_id. */

-- Approach 1 
-- Display all rows in the 'customer_purchases' table 
-- with 'purchase_times' along with each row 
SELECT 
	*,
	count(*) OVER (PARTITION BY customer_id, product_id) as purchase_times
FROM 
	customer_purchases;

-- Approach 2
-- Select only the unique product_ids per customer without purchase details.
SELECT
	DISTINCT customer_id, product_id, purchase_times
FROM (
		SELECT 
			customer_id,
			product_id,
			count(*) OVER (PARTITION BY customer_id, product_id) as purchase_times
		FROM 
			customer_purchases
) AS x;


	