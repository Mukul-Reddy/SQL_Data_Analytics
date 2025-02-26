-- CHANGES OVER TIME

SELECT YEAR(order_date)as Year, SUM(sales_amount) as Revenue, sum(quantity) as Quantity
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

SELECT MONTH(order_date) as Month, SUM(sales_amount) as Revenue, sum(quantity) as Quantity
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date);

SELECT YEAR(order_date) as Year, MONTH(order_date) as Month, 
SUM(sales_amount) as Revenue, sum(quantity) as Quantity
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);


-- CUMULATIVE ANALYSIS

SELECT Year, Revenue, 
SUM(Revenue) OVER(Order By Year) as Cumulative_Revenue
FROM(
SELECT DISTINCT YEAR(order_date) as Year, 
SUM(sales_amount) OVER(PARTITION BY YEAR(order_date)) as Revenue
FROM fact_sales
WHERE order_date IS NOT NULL
)t;

SELECT Year, Month, Revenue, 
SUM(Revenue) OVER(PARTITION BY Year Order By Year, Month) as Cumulative_Revenue
FROM(
SELECT DISTINCT YEAR(order_date) as Year, MONTH(order_date) as Month, 
SUM(sales_amount) OVER(PARTITION BY YEAR(order_date), MONTH(order_date)) as Revenue
FROM fact_sales
WHERE order_date IS NOT NULL
)t;

SELECT Year, Month, Avg_Revenue, 
AVG(Avg_Revenue) OVER(PARTITION BY Year Order By Year, Month) as Moving_Avg_Revenue
FROM(
SELECT DISTINCT YEAR(order_date) as Year, MONTH(order_date) as Month, 
AVG(sales_amount) OVER(PARTITION BY YEAR(order_date), MONTH(order_date)) as Avg_Revenue
FROM fact_sales
WHERE order_date IS NOT NULL
)t;


-- PERFORMANCE ANALYSIS

WITH sales AS(
SELECT DISTINCT YEAR(f.order_date) as year, p.product_name as name,
SUM(f.sales_amount) OVER(PARTITION BY YEAR(f.order_date), p.product_name) as sales
FROM fact_sales as f
LEFT JOIN dim_products as p
ON f.product_key = p.product_key
)
SELECT year, name, sales,
AVG(sales) OVER(PARTITION BY name) as Avg_Sales,
LAG(sales) OVER(PARTITION BY name ORDER BY year) as Prev_Yr_Sales,
sales - LAG(sales) OVER(PARTITION BY name ORDER BY year) as Diff_Amount,
    CASE WHEN sales - LAG(sales) OVER(PARTITION BY name ORDER BY year) > 0 THEN  'Increase'
        WHEN sales - LAG(sales) OVER(PARTITION BY name ORDER BY year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END as sales_change
FROM sales;


-- PART TO WHOLE ANALYSIS

SELECT category, sales, 
CONCAT(ROUND((sales * 100)/Total_Sales,2), '%') as sales_pct
FROM(
SELECT DISTINCT category, SUM(sales_amount) OVER() as Total_Sales,
SUM(sales_amount) OVER(PARTITION BY category) as sales
FROM fact_sales AS f
LEFT JOIN dim_products AS p
ON f.product_key = p.product_key
ORDER BY sales DESC
)t


-- SEGMENTATION ANALYSIS

SELECT price_range, COUNT(product_name) as Count
FROM (
SELECT product_name, cost,
    CASE WHEN cost > 1000 THEN 'Above 1000'
        WHEN cost > 500 THEN '500-1000'
        WHEN cost > 100 THEN '100-500'
        ELSE 'Below 100'
    END AS price_range
FROM dim_products
)t
GROUP BY price_range


SELECT Customer_Type, count(*)
FROM(
SELECT DISTINCT c.customer_key as ckey,
MIN(f.order_date) as first_order,
MAX(f.order_date) as last_order,
TIMESTAMPDIFF(MONTH, MIN(f.order_date),MAX(f.order_date)) as lifespan,
SUM(sales_amount)  as sales,
CASE WHEN TIMESTAMPDIFF(MONTH, MIN(f.order_date),MAX(f.order_date)) >= 12 AND SUM(sales_amount) > 5000 THEN "VIP"
    WHEN TIMESTAMPDIFF(MONTH, MIN(f.order_date),MAX(f.order_date)) >= 12 AND SUM(sales_amount) < 5000 THEN "Regular"
    ELSE "NEW"
END AS Customer_Type
FROM fact_sales as f
LEFT JOIN dim_customers as c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)t
GROUP BY Customer_Type
