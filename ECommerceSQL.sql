CREATE DATABASE olist_db;
USE olist_db;

CREATE TABLE olist_products (	
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(255),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);



CREATE TABLE olist_customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);


CREATE TABLE olist_order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

CREATE TABLE olist_orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);




CREATE TABLE olist_sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);

-- 1. Get all unique customer_unique_id and their zip codes
SELECT DISTINCT customer_unique_id, customer_zip_code_prefix
FROM olist_customers;

-- 2. Count the number of orders made by each customer
SELECT customer_id, COUNT(order_id) AS num_orders
FROM olist_orders
GROUP BY customer_id;

-- 3. Count the number of orders for each order status
SELECT order_status, COUNT(*) AS total_orders
FROM olist_orders
GROUP BY order_status;

-- 4. Get the average price per product category
SELECT p.product_category_name, AVG(oi.price) AS avg_price
FROM olist_products p
JOIN olist_order_items oi ON  p.product_id = oi.product_id
GROUP BY p.product_category_name;

-- 5. Find sellers who sold more than 50 products
SELECT seller_id, COUNT(product_id) AS total_products
FROM olist_order_items
GROUP BY seller_id
HAVING COUNT(product_id) > 50;

-- 6. Show customers who placed orders after 2018-01-01
SELECT DISTINCT customer_id, order_delivered_customer_date 
FROM olist_orders
WHERE order_purchase_timestamp > '2018-01-01';

-- 7. Sellers who handled more than 10 distinct orders
SELECT seller_id, COUNT(DISTINCT order_id) AS total_orders
FROM olist_order_items
GROUP BY seller_id
HAVING COUNT(DISTINCT order_id) > 10;

-- 8. Product category with the highest average price
SELECT product_category_name, avg_price
FROM (
    SELECT p.product_category_name, AVG(oi.price) AS avg_price
    FROM olist_products p
    JOIN olist_order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_category_name
) AS avg_prices
WHERE avg_price = (
    SELECT MAX(avg_price)
    FROM (
        SELECT AVG(oi.price) AS avg_price
        FROM olist_products p
        JOIN olist_order_items oi ON p.product_id = oi.product_id
        GROUP BY p.product_category_name
    ) AS inner_avg
);



-- 9. Top 5 most expensive products by price
SELECT product_id, price
FROM olist_order_items
ORDER BY price DESC
LIMIT 5;

-- 10. Customers who placed more than one order
SELECT c.customer_unique_id, COUNT(o.order_id) AS num_orders
FROM olist_customers c
JOIN olist_orders o  ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(o.order_id) > 1;

