--creating schema
CREATE SCHEMA amazon_brazil;

--customer table
CREATE TABLE amazon_brazil.customers(
customer_id VARCHAR(50) PRIMARY KEY,
customer_unique_id VARCHAR(50) NOT NULL,
customer_zip_code_prefix INT NOT NULL
);
SELECT * FROM amazon_brazil.customers;

--orders table
CREATE TABLE amazon_brazil.orders(
order_id VARCHAR(50) PRIMARY KEY,
customer_id VARCHAR(50) NOT NULL,
order_status VARCHAR(50) NOT NULL,
order_purchase_timestamp TIMESTAMP,
order_approved_at TIMESTAMP,
order_delivered_carrier_date TIMESTAMP,
order_delivered_customer_date TIMESTAMP,
order_estimated_delivery_date TIMESTAMP,
FOREIGN KEY (customer_id) REFERENCES amazon_brazil.customers(customer_id)
);
SELECT * FROM amazon_brazil.orders

--order items table

CREATE TABLE amazon_brazil.order_items(
order_id VARCHAR(50),
order_item_id INT NOT NULL,
product_id VARCHAR(50)NOT NULL,
seller_id VARCHAR(50) NOT NULL,
shipping_limit_date	TIMESTAMP,
price DECIMAL(10,2),
freight_value DECIMAL(10,2),
PRIMARY KEY (order_id, order_item_id)
);
SELECT*FROM amazon_brazil.order_items

--product table

CREATE TABLE amazon_brazil.product(
product_id VARCHAR(50) PRIMARY KEY,
product_category_name VARCHAR(50),
product_name_lenght INT,
product_description_lenght INT,
product_photos_qty INT,
product_weight_g INT,
product_length_cm INT,
product_height_cm INT,
product_width_cm INT 
);
SELECT*FROM amazon_brazil.product;

--seller table

CREATE TABLE amazon_brazil.seller(
seller_id VARCHAR(50) PRIMARY KEY, 
seller_zip_code_prefix INT NOT NULL
);
SELECT*FROM amazon_brazil.seller;

--payments table

CREATE TABLE amazon_brazil.payments(
order_id VARCHAR(50),
payment_sequential INT NOT NULL,
payment_type VARCHAR(50),
payment_installments INT,
payment_value DECIMAL(10,2),
PRIMARY KEY(order_id,payment_sequential)
);
SELECT* FROM amazon_brazil.payments;

--ANALYSIS 1

-- standardaise payment values

SELECT payment_type,
ROUND(AVG(payment_value)) AS rounded_avg_payment_value
FROM amazon_brazil.payments
GROUP BY payment_type
ORDER BY rounded_avg_payment_value;

--distribution of order by payment type

SELECT  payment_type,
ROUND(COUNT(order_id) * 100.0 / SUM(COUNT(order_id)) OVER(), 1) AS percentage
FROM amazon_brazil.payments
GROUP BY payment_type
ORDER BY percentage DESC;

--Identify all products priced between 100 and 500 BRL that contain the word 'Smart' 

SELECT 
oi.product_id,
oi.price
FROM amazon_brazil.order_items oi
JOIN amazon_brazil.product p 
ON oi.product_id = p.product_id
WHERE oi.price BETWEEN 100 AND 500
AND p.product_category_name ILIKE '%Smart%'
ORDER BY oi.price DESC;

--top 3 months with the highest total sales value, rounded to the nearest integer

SELECT 
EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
ROUND(SUM(oi.price)) AS total_sales
FROM amazon_brazil.orders o
JOIN amazon_brazil.order_items oi 
ON o.order_id = oi.order_id
GROUP BY month
ORDER BY total_sales DESC
LIMIT 3;

--categories where the difference between the maximum and minimum product prices >500

SELECT 
p.product_category_name,
ROUND(MAX(oi.price) - MIN(oi.price)) AS price_difference
FROM amazon_brazil.product p
JOIN amazon_brazil.order_items oi 
ON p.product_id = oi.product_id
GROUP BY p.product_category_name
HAVING (MAX(oi.price) - MIN(oi.price)) > 500
ORDER BY price_difference DESC;

-- payment types with the least variance in transaction amounts

SELECT 
payment_type,
ROUND(STDDEV(payment_value)) AS std_deviation
FROM amazon_brazil.payments
GROUP BY payment_type
ORDER BY std_deviation;

--products where the product category name is missing or contains only a single character.

SELECT 
product_id,
product_category_name
FROM amazon_brazil.product
WHERE product_category_name IS NULL
OR LENGTH(product_category_name) <= 1;


--ANALYSIS 2

--Segment order values into three ranges

SELECT CASE 
WHEN payment_value < 200 THEN 'Low'
WHEN payment_value BETWEEN 200 AND 1000 THEN 'Medium'
ELSE 'High'
END AS order_value_segment,
payment_type,
COUNT(*) AS count
FROM amazon_brazil.payments
GROUP BY order_value_segment, payment_type
ORDER BY count DESC;

-- minimum, maximum, and average price for each category

SELECT 
p.product_category_name,
ROUND(MIN(oi.price), 2) AS min_price,
ROUND(MAX(oi.price), 2) AS max_price,
ROUND(AVG(oi.price), 2) AS avg_price
FROM amazon_brazil.product p
JOIN amazon_brazil.order_items oi 
ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY avg_price DESC;

--customers with more than one order

SELECT 
c.customer_unique_id,
COUNT(o.order_id) AS total_orders
FROM amazon_brazil.customers c
JOIN amazon_brazil.orders o 
ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(o.order_id) > 1
ORDER BY total_orders DESC;

--categorize customers into different types

--create temporary table with order counts
CREATE TEMP TABLE customer_order_counts AS
SELECT 
c.customer_unique_id,
COUNT(o.order_id) AS total_orders
FROM amazon_brazil.customers c
JOIN amazon_brazil.orders o 
ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id;

--query with case when to categorize customers
SELECT 
customer_unique_id,
CASE 
WHEN total_orders = 1 THEN 'New'
WHEN total_orders BETWEEN 2 AND 4 THEN 'Returning'
WHEN total_orders > 4 THEN 'Loyal'
END AS customer_type
FROM customer_order_counts
ORDER BY total_orders DESC;

--total revenue for each product category

SELECT 
p.product_category_name,
ROUND(SUM(oi.price), 2) AS total_revenue
FROM amazon_brazil.product p
JOIN amazon_brazil.order_items oi 
ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 5;

--ANALYSIS 3

-- calculate total sales for each season

SELECT 
season,
ROUND(SUM(total_price), 2) AS total_sales
FROM(
SELECT 
oi.price AS total_price,
CASE 
WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) 
IN (3, 4, 5)  THEN 'Spring'
WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) 
IN (6, 7, 8)  THEN 'Summer'
WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) 
IN (9, 10, 11) THEN 'Autumn'
ELSE 'Winter'
END AS season
FROM amazon_brazil.orders o
JOIN amazon_brazil.order_items oi 
ON o.order_id = oi.order_id
) AS seasonal_sales
GROUP BY season
ORDER BY total_sales DESC;

--filter products with a total quantity sold above the average quantity.

SELECT
product_id,
COUNT(*) AS total_quantity_sold
FROM amazon_brazil.order_items
GROUP BY product_id
HAVING COUNT(*) > (
SELECT AVG(product_count)
FROM (
SELECT COUNT(*) AS product_count
FROM amazon_brazil.order_items
GROUP BY product_id
) AS avg_sales
)
ORDER BY total_quantity_sold DESC;

--total revenue generated each month and identifying periods of peak and low sales

SELECT 
EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
ROUND(SUM(oi.price), 2) AS total_revenue
FROM amazon_brazil.orders o
JOIN amazon_brazil.order_items oi 
ON o.order_id = oi.order_id
WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
GROUP BY month
ORDER BY month ;

--segmentation based on purchase frequency

WITH customer_order_counts AS(
SELECT 
c.customer_unique_id,
COUNT(o.order_id) AS total_orders
FROM amazon_brazil.customers c
JOIN amazon_brazil.orders o 
ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
),
customer_segments AS(
SELECT 
customer_unique_id,
CASE 
WHEN total_orders BETWEEN 1 AND 2 THEN 'Occasional'
WHEN total_orders BETWEEN 3 AND 5 THEN 'Regular'
WHEN total_orders > 5 THEN 'Loyal'
END AS customer_type
FROM customer_order_counts
)
SELECT 
customer_type,
COUNT(*) AS count
FROM customer_segments
GROUP BY customer_type
ORDER BY count DESC;

--rank customers based on their average order value

SELECT 
c.customer_unique_id,
ROUND(AVG(oi.price), 2) AS avg_order_value,
RANK() OVER (ORDER BY AVG(oi.price) DESC) AS customer_rank
FROM amazon_brazil.customers c
JOIN amazon_brazil.orders o 
ON c.customer_id = o.customer_id
JOIN amazon_brazil.order_items oi 
ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY customer_rank ASC
LIMIT 20;

--cumulative sales for each product from the date of its first sale

WITH monthly_sales AS(
SELECT 
oi.product_id,
DATE_TRUNC('month', o.order_purchase_timestamp) AS sale_month,
SUM(oi.price) AS monthly_revenue
FROM amazon_brazil.order_items oi
JOIN amazon_brazil.orders o 
ON oi.order_id = o.order_id
GROUP BY oi.product_id, DATE_TRUNC('month', o.order_purchase_timestamp)
),
cumulative_sales AS(
SELECT 
product_id,
sale_month,
monthly_revenue,
SUM(monthly_revenue) OVER (
PARTITION BY product_id 
ORDER BY sale_month
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS total_sales
FROM monthly_sales
)
SELECT 
product_id,
TO_CHAR(sale_month, 'YYYY-MM') AS sale_month,
ROUND(total_sales, 2) AS total_sales
FROM cumulative_sales
ORDER BY product_id, sale_month;

--total monthly sales for each payment method, then compute the percentage change from the previous month.

WITH monthly_payment_sales AS(
SELECT 
p.payment_type,
DATE_TRUNC('month', o.order_purchase_timestamp) AS sale_month,
SUM(p.payment_value) AS monthly_total
FROM amazon_brazil.payments p
JOIN amazon_brazil.orders o 
ON p.order_id = o.order_id
WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
GROUP BY p.payment_type, DATE_TRUNC('month', o.order_purchase_timestamp)
),
monthly_growth AS (
SELECT 
payment_type,
sale_month,
monthly_total,
LAG(monthly_total) OVER (
PARTITION BY payment_type 
ORDER BY sale_month
)AS prev_month_total
FROM monthly_payment_sales
)
SELECT 
payment_type,
TO_CHAR(sale_month, 'YYYY-MM') AS sale_month,
ROUND(monthly_total::NUMERIC, 2) AS monthly_total,
ROUND(
((monthly_total - prev_month_total) / NULLIF(prev_month_total, 0) * 100)::NUMERIC, 2
) AS monthly_change
FROM monthly_growth
ORDER BY payment_type, sale_month;
