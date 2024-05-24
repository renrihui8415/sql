-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */

SELECT 
	vendor_name,
	product_name,
	original_price* 5 * customer_number as earning_per_product
FROM (

				SELECT DISTINCT
					vendor_id,
					product_id,
					original_price,
					c.customer_number
				FROM
					vendor_inventory as vi
				CROSS JOIN (
					SELECT 
						count(DISTINCT (customer_id)) AS customer_number
					FROM
						customer 
				)as c 
				
) as m
INNER JOIN product as p
ON m.product_id=p.product_id
INNER JOIN vendor as v
ON v.vendor_id=m.vendor_id;


-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */

DROP TABLE IF EXISTS product_units;

CREATE TABLE product_units AS
SELECT 
	*,
	CURRENT_TIMESTAMP as snapshot_timestamp
FROM	
	product
WHERE
	product_qty_type='unit';
	
-- add Primary Key to a table is not directly supported in SQLite;
-- we can firstly create the table listing the columns and its datatypes and add PK at the same time
-- and insert the data later
	
-- SELECT * from product_units ORDER BY product_id;


/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */

INSERT INTO product_units (product_id, product_name,product_size,product_category_id, product_qty_type, snapshot_timestamp)
VALUES(
	(SELECT max(product_id) +1 FROM product_units),  -- take ''max(product_id) +1'' to be the product_id for the new entry
	'Cherry Pie',
	'large',
	(SELECT product_category_id FROM product_units WHERE product_name='Cherry Pie' LIMIT 1), -- get the cherry pie's category_id for the new entry: 'Cherry Pie'
	'unit',
	CURRENT_TIMESTAMP
);

-- SELECT * from product_units ORDER BY product_id;

-- DELETE
/* 1. Delete the older record for the whatever product you added. 

HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/

DELETE FROM product_units
WHERE
	product_name='Cherry Pie' 
	and snapshot_timestamp= (SELECT min(snapshot_timestamp) FROM product_units WHERE product_name="Cherry Pie")
	
-- SELECT * from product_units ORDER BY product_id;

-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;

Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 
Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
When you have all of these components, you can run the update statement. */

-- 0. Check the column EXISTS or not
-- as SQLite does not support procedural language to check a column EXISTS or not,
-- Either manually check the column: PRAGMA table_info(product_units)
-- or, use python to automate this process

-- METHOD A
-- 1) ADD current_quantity column to the 'product_units' table
ALTER TABLE 	product_units
ADD current_quantity INT;
-- 2) Get the 'last_quantity' according to the lastest market_date, from the 'vendor_inventory' table 
-- 3) Update the 'product_units' table with the result returned from Step 2

UPDATE product_units AS pu
SET current_quantity = (

    SELECT lq.quantity
    FROM (
				SELECT 
					product_id,
					quantity 
				FROM
					vendor_inventory AS vi_1
				WHERE 
					market_date = (
						SELECT 
							MAX(market_date) 
						FROM 
							vendor_inventory AS vi_2
						WHERE 
							vi_1.product_id = vi_2.product_id
					) 

)AS lq
WHERE pu.product_id = lq.product_id
);

-- 4) Update the 'product_units' table and ensure that 'current_quantity' is set to 0 where it is NULL
UPDATE 	product_units
SET current_quantity=0
WHERE current_quantity IS NULL;
-- 5) Check the result
-- SELECT * from product_units ORDER BY product_id;


-- METHOD B
-- 1) ADD current_quantity column to the 'product_units' table
ALTER TABLE 	product_units
ADD current_quantity INT;
-- 2) Update the 'product_units' table by searching the latest quantity in the 'vendor_inventory' table, 
-- if the product is not found in the 'vendor_inventory' table, update the column with a value of '0'

UPDATE product_units as pu
SET current_quantity = coalesce(
														(SELECT vi.quantity
														FROM vendor_inventory as vi
														WHERE vi.product_id=pu.product_id
														ORDER BY vi.market_date DESC
														LIMIT 1),
														0)
-- WHERE product_id IN (SELECT product_id from vendor_inventory);		
-- Either a) use COALESCE to replace null with '0' as the above QUERY; 
-- or, b) use WHERE condition to only update rows in the 'product_units' table 
-- 		that have a corresponding 'product_id' in the 'vendor_inventory' table.  Then,
--      use a UPDATE statement to update those null values to be '0'.

					
-- 3) Check the result
-- SELECT * from product_units ORDER BY product_id;
