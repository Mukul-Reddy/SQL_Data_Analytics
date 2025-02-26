-- KEY METRICS

SELECT 'Total Sales' as measure, SUM(sales_amount) as value_ FROM fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_name) FROM dim_products
UNION ALL
SELECT 'Total Customers', COUNT(DISTINCT customer_key) FROM dim_customers


-- SALES TRENDS

-- SALES OVER THE YEARS
SELECT 
    DATE_FORMAT(order_date, '%Y') AS year, 
    SUM(sales_amount) AS Total_Sales
FROM fact_sales
GROUP BY year
ORDER BY year;

-- SALES BY MONTHS
SELECT 
    DATE_FORMAT(order_date, '%m') AS month, 
    SUM(sales_amount) AS Total_Sales
FROM fact_sales
GROUP BY month
ORDER BY month;


-- CUSTOMER ANALYSIS

-- Total Customers
SELECT COUNT(DISTINCT customer_key) as total_customers FROM dim_customers;

-- Customer Age
SELECT
    TIMESTAMPDIFF(YEAR, MIN(birthdate), CURDATE()) as oldest_age,
    AVG(TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) ) as avg_age,
    TIMESTAMPDIFF(YEAR, MAX(birthdate), CURDATE()) as youngest_age
FROM dim_customers;

-- Total Customer by Country
SELECT country, COUNT(customer_key) as customers FROM dim_customers
GROUP BY country
ORDER BY customers DESC;

-- Total Customer by Gender
SELECT gender, COUNT(DISTINCT customer_key) as customers FROM dim_customers
GROUP BY gender;

-- Date Exploration (Time-span)
SELECT MIN(order_date) as fisrt_order_date,
    MAX(order_date) as last_order_date
FROM fact_sales 

-- Revenue by Customer
SELECT c.first_name,
sum(f.sales_amount) as revenue
FROM fact_sales AS f
LEFT JOIN dim_customers as c
ON f.customer_key = c.customer_key
GROUP BY c.first_name
ORDER BY revenue DESC;

-- Orders by Customers
SELECT c.first_name,
count(*) as orders
FROM fact_sales AS f
LEFT JOIN dim_customers as c
ON f.customer_key = c.customer_key
GROUP BY c.first_name
ORDER BY orders DESC;

-- Top 10 Customer who generated highest revenue
SELECT c.first_name,
c.l,
sum(f.sales_amount) as revenue
FROM fact_sales AS f
LEFT JOIN dim_customers as c
ON f.customer_key = c.customer_key
GROUP BY c.first_name
ORDER BY revenue DESC
LIMIT 10;

-- Revenue and Quantity by Country
SELECT c.country,
sum(f.sales_amount) as revenue,
sum(f.quantity) as quantity
FROM fact_sales AS f
LEFT JOIN dim_customers as c
ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY revenue DESC;


-- PERFORMANCE ANALYSIS

-- AVG TIME BETWEEN ORDER AND SHIPPING DATE
SELECT AVG(TIMESTAMPDIFF(DAY, order_date, shipping_date)) as Days_
FROM fact_sales;

-- AVG TIME BETWEEN SHIPPING AND DUE DATE
SELECT AVG(TIMESTAMPDIFF(DAY, shipping_date, due_date)) as Days_
FROM fact_sales;


-- PRODUCT ANALYSIS

-- Total Products by Category
SELECT category, COUNT(DISTINCT product_name) as products FROM dim_products
GROUP BY category;

-- Avg Cost in Each Category
SELECT category, AVG(cost) as avg_cost FROM dim_products
GROUP BY category
ORDER BY avg_cost;

-- Total Revenue by Category and SubCategory
SELECT P.category,
P.subcategory,
SUM(F.sales_amount) AS revenue
FROM fact_sales as F
LEFT JOIN dim_products as P
ON F.product_key = P.product_key
GROUP BY P.category, P.subcategory
ORDER BY P.category, revenue;

-- Top 10 highest revenue generating products
SELECT P.product_name,
SUM(F.sales_amount) AS revenue
FROM fact_sales as F
LEFT JOIN dim_products as P
ON F.product_key = P.product_key
GROUP BY P.product_name
ORDER BY revenue DESC
LIMIT 10;

-- 5 worst performing products (revenue)
SELECT P.product_name,
SUM(F.sales_amount) AS revenue
FROM fact_sales as F
LEFT JOIN dim_products as P
ON F.product_key = P.product_key
GROUP BY P.product_name
ORDER BY revenue ASC
LIMIT 5;