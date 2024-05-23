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


-- String manipulations
/* 1. Some product names in the product table have descriptions like "Jar" or "Organic". 
These are separated from the product name with a hyphen. 
Create a column using SUBSTR (and a couple of other commands) that captures these, but is otherwise NULL. 
Remove any trailing or leading whitespaces. Don't just use a case statement for each product! 

| product_name               | description |
|----------------------------|-------------|
| Habanero Peppers - Organic | Organic     |

Hint: you might need to use INSTR(product_name,'-') to find the hyphens. INSTR will help split the column. */

SELECT 
	product_name,
	CASE
		WHEN instr(product_name,'-')=0
		THEN NULL
	ELSE
		trim(substr(product_name, instr(product_name,'-')+1) )
	END as captured_description
FROM
	product;


/* 2. Filter the query to show any product_size value that contain a number with REGEXP. */
SELECT 
	product_name,
	product_size,
	CASE
		WHEN instr(product_name,'-')=0
		THEN NULL
	ELSE
		trim(substr(product_name, instr(product_name,'-')+1) )
	END as captured_description
FROM
	product
WHERE 
	product_size REGEXP '[0-9]+' ;

-- UNION
/* 1. Using a UNION, write a query that displays the market dates with the highest and lowest total sales.

HINT: There are a possibly a few ways to do this query, but if you're struggling, try the following: 
1) Create a CTE/Temp Table to find sales values grouped dates; 
2) Create another CTE/Temp table with a rank windowed function on the previous query to create 
"best day" and "worst day"; 
3) Query the second temp table twice, once for the best day, once for the worst day, 
with a UNION binding them. */

DROP TABLE IF EXISTS daily_sales;
-- CREATE the temp daily_sales table and sort the sales in order
-- Convert any NULL values or non-numeric values to '0' when SUM, to ensure accuracy
CREATE TEMP TABLE daily_sales AS
SELECT
	market_date,
	SUM(COALESCE(CAST(quantity AS REAL), '0.00')*COALESCE(CAST(cost_to_customer_per_qty AS REAL), '0.00')) AS total_cost
FROM customer_purchases 
GROUP BY market_date
ORDER BY total_cost;

-- SELECT min and max total_cost from the temp table and UNION them
SELECT 
	market_date,
	min(total_cost) as total_sales,
	'min' as [max/min]
FROM 
	daily_sales

UNION	

SELECT 
	market_date,
	max(total_cost) as total_sales,
	'max' as [max/min]
FROM 
	daily_sales;
	

