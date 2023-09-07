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

-- STREET_NUMBER
street_number_values AS (
    SELECT DISTINCT
       SPLIT_PART(purchase_address, ' ', 1) AS street_number
    FROM staging.ventas
    WHERE order_id IS NOT NULL
),
street_number_id AS (
    SELECT 
        street_number,
        ROW_NUMBER() OVER () AS street_number_values
    FROM street_number_values 
),

-- STREET_NAME
street_name_values AS (
    SELECT DISTINCT
       SUBSTRING(SPLIT_PART(purchase_address, ',', 1), 5) AS street_name
    FROM staging.ventas
    WHERE order_id IS NOT NULL
),
street_name_id AS (
    SELECT 
        street_name,
        ROW_NUMBER() OVER () AS street_name_id
    FROM street_name_values 
),

-- CITY
city_values AS (
    SELECT DISTINCT
        SPLIT_PART(purchase_address, ',', 2) AS city
    FROM staging.ventas
    WHERE order_id IS NOT NULL
),
city_id AS (
    SELECT 
        city,
        ROW_NUMBER() OVER () AS city_id
    FROM city_values 
),

-- STATE
state_values AS (
    SELECT DISTINCT
        SPLIT_PART(SPLIT_PART(purchase_address, ',', 3), ' ', 2) AS state
    FROM staging.ventas
    WHERE order_id IS NOT NULL
),
state_id AS (
    SELECT 
        state,
        ROW_NUMBER() OVER () AS state_id
    FROM state_values 
),

-- POSTAL_CODE
postal_code_values AS (
    SELECT DISTINCT
        SPLIT_PART(SPLIT_PART(purchase_address, ',', 3), ' ', 3) AS postal_code
    FROM staging.ventas
    WHERE order_id IS NOT NULL
),
postal_code_id AS (
    SELECT 
        postal_code,
        ROW_NUMBER() OVER () AS postal_code_id
    FROM postal_code_values 
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
    FROM postal_code_values 
),
	


SELECT 
    v.*, 
    pv.product_id,
    pav.purchase_address_id,
    snv.street_number_values AS street_number_id,
    snn.street_name_id,
    cv.city_id,
    sv.state_id,
    pcv.postal_code_id
FROM staging.ventas v	
LEFT JOIN product_values_id pv ON v.product = pv.product
LEFT JOIN purchase_address_id pav ON pav.purchase_address = v.purchase_address
LEFT JOIN street_number_id snv ON snv.street_number = v.street_number
LEFT JOIN street_name_id snn ON snn.street_name = v.street_name
LEFT JOIN city_id cv ON cv.city = v.city
LEFT JOIN state_id sv ON sv.state = v.state
LEFT JOIN postal_code_id pcv ON pcv.postal_code = v.postal_code;