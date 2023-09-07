------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

INSERT INTO dwh.Dim_Product (Product_ID, Product_Name, Category)
WITH product_values AS (
    SELECT DISTINCT
        product AS product
    FROM staging.ventas
    WHERE order_id IS NOT NULL
),
product_values_id AS (
    SELECT 
        product,
        ROW_NUMBER() OVER () AS product_id
    FROM product_values 
) 
SELECT DISTINCT  
	pv.product_id, 
	v.product, 	
	CASE
           WHEN LOWER(v.product) LIKE '%cable%' THEN 'Cable'
           WHEN LOWER(v.product) LIKE '%batteries%' THEN 'Batteries'
           WHEN LOWER(v.product) LIKE '%monitor%' THEN 'Monitor'
           WHEN LOWER(v.product) LIKE '%headphones%' THEN 'Headphones'
           WHEN LOWER(v.product) LIKE '%tv%' THEN 'TV'
           WHEN LOWER(v.product) LIKE '%phone%' THEN 'Phone'
           ELSE 'Otro'
       END AS Category
FROM staging.ventas v	
LEFT JOIN product_values_id pv ON v.product = pv.product 
WHERE order_id IS NOT NULL;

------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

INSERT INTO dwh.Dim_Location (Location_ID, Purchase_Address, street_number, street_name, city, state, postal_code)
-- PURCHASE_ADDRESS
WITH purchase_address_values AS (
    SELECT DISTINCT
       purchase_address AS purchase_address
    FROM staging.ventas
    WHERE order_id IS NOT NULL
),
purchase_address_id AS (
    SELECT 
        purchase_address,
        ROW_NUMBER() OVER () AS purchase_address_id
    FROM purchase_address_values 
)

SELECT DISTINCT
	pav.purchase_address_id,
    v.purchase_address,
    v.street_number,
    v.street_name,
    v.city,
    v.state,
    v.postal_code
FROM staging.ventas v	
LEFT JOIN purchase_address_id pav ON pav.purchase_address = v.purchase_address 
WHERE v.order_id IS NOT NULL;

------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

INSERT INTO dwh.Fact_Sales (Order_ID, Product_ID, Date_ID, Location_ID, Quantity_Ordered, Price_Each, Total_Sales)
-- PRODUCT
WITH product_values AS (
    SELECT DISTINCT
        product AS product
    FROM staging.ventas
    WHERE order_id IS NOT NULL
),
product_values_id AS (
    SELECT 
        product,
        ROW_NUMBER() OVER () AS product_id
    FROM product_values 
),
-- PURCHASE_ADDRESS
purchase_address_values AS (
    SELECT DISTINCT
       purchase_address AS purchase_address
    FROM staging.ventas
    WHERE order_id IS NOT NULL
),
purchase_address_id AS (
    SELECT 
        purchase_address,
        ROW_NUMBER() OVER () AS purchase_address_id
    FROM purchase_address_values 
),
--LOCATION
order_date_values AS (
    SELECT DISTINCT
        order_date
    FROM staging.ventas
    WHERE order_id IS NOT NULL
),
order_date_id AS (
    SELECT 
        order_date,
        ROW_NUMBER() OVER () AS order_date_id
    FROM order_date_values 
)

SELECT 
	v.order_id::integer, 
	pv.product_id,
	od.order_date_id, 
	pa.purchase_address_id,
	v.quantity_ordered::float, 
	v.price_each::float,
	(v.quantity_ordered::float * v.price_each::float)::float
FROM public.ventas v
LEFT JOIN product_values_id pv  ON pv.product = v.product 
LEFT JOIN purchase_address_id pa ON pa.purchase_address = v.purchase_address 
LEFT JOIN order_date_id od ON od.order_date::timestamp = v.order_date::timestamp
WHERE v.order_id IS NOT NULL;
 
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

INSERT INTO dwh.Dim_Date (Date_ID, Order_Date, Year, Quarter, Month, Day)
--ORDER_DATE
WITH order_date_values AS (
    SELECT DISTINCT
        order_date
    FROM staging.ventas
    WHERE order_id IS NOT NULL
),
order_date_id AS (
    SELECT 
        order_date,
        ROW_NUMBER() OVER () AS order_date_id
    FROM order_date_values 
)

SELECT DISTINCT 
	od.order_date_id,
	v.order_date,
	EXTRACT(YEAR FROM v.order_date), 
    CASE 
        WHEN EXTRACT(QUARTER FROM v.order_date) = 1 THEN 'Q1'
        WHEN EXTRACT(QUARTER FROM v.order_date) = 2 THEN 'Q2'
        WHEN EXTRACT(QUARTER FROM v.order_date) = 3 THEN 'Q3'
        WHEN EXTRACT(QUARTER FROM v.order_date) = 4 THEN 'Q4'
    END,
    TO_CHAR(v.order_date, 'Month'),
	EXTRACT(DAY FROM v.order_date)
FROM staging.ventas v
LEFT JOIN order_date_id od ON od.order_date::timestamp = v.order_date::timestamp
WHERE v.order_id IS NOT NULL;
