 CREATE TABLE staging.ventas (
    order_id INTEGER,
    product TEXT,
    quantity_ordered INTEGER,
    price_each NUMERIC,
    order_date TIMESTAMP,
    purchase_address TEXT,
    street_number TEXT,
    street_name TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT
);


INSERT INTO staging.ventas (
    order_id,
    product,
    quantity_ordered,
    price_each,
    order_date,
    purchase_address,
    street_number,
    street_name,
    city,
    state,
    postal_code
)
SELECT 
    v.order_id::int, -- No se necesita casting
    v.product,
    v.quantity_ordered::int,
    v.price_each::float,
    v.order_date::TIMESTAMP,
    v.purchase_address,
    SPLIT_PART(v.purchase_address, ' ', 1) AS street_number,
    SUBSTRING(SPLIT_PART(v.purchase_address, ',', 1), 5) AS street_name,
    SPLIT_PART(v.purchase_address, ',', 2) AS city,
    SPLIT_PART(SPLIT_PART(v.purchase_address, ',', 3), ' ', 2) AS state,
    SPLIT_PART(SPLIT_PART(v.purchase_address, ',', 3), ' ', 3) AS postal_code
FROM public.ventas v
WHERE v.order_id IS NOT NULL;
