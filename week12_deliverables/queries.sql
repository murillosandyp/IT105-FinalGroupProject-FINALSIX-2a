-- =====================================================
-- BI QUERIES FOR ONLINE SHOP SYSTEM
-- =====================================================

USE online_shop;

-- ---------------------------------------------------------------------
-- QUERY 1: Monthly Sales Performance (Revenue KPI)
-- Shows total revenue, orders, and average order value per month
-- ---------------------------------------------------------------------
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.subtotal), 2) AS total_revenue,
    ROUND(AVG(oi.subtotal), 2) AS avg_order_value,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM `Order` o
INNER JOIN OrderItem oi ON o.order_id = oi.order_id
WHERE o.status != 'cancelled'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month DESC;

-- ---------------------------------------------------------------------
-- QUERY 2: Customer Retention – Repeat Purchase Rate
-- Identifies how many customers return to buy again
-- ---------------------------------------------------------------------
WITH customer_orders AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        COUNT(DISTINCT o.order_id) AS order_count,
        MIN(o.order_date) AS first_purchase,
        MAX(o.order_date) AS last_purchase,
        DATEDIFF(MAX(o.order_date), MIN(o.order_date)) AS customer_lifetime_days
    FROM Customer c
    INNER JOIN `Order` o ON c.customer_id = o.customer_id
    WHERE o.status != 'cancelled'
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT 
    CASE 
        WHEN order_count = 1 THEN 'One-time Buyer'
        WHEN order_count = 2 THEN 'Repeat Buyer (2x)'
        WHEN order_count BETWEEN 3 AND 4 THEN 'Frequent Buyer (3-4x)'
        WHEN order_count >= 5 THEN 'Loyal Customer (5+)'
        ELSE 'Unknown'
    END AS customer_segment,
    COUNT(customer_id) AS customer_count,
    ROUND(100 * COUNT(customer_id) / (SELECT COUNT(*) FROM customer_orders), 2) AS percentage,
    ROUND(AVG(customer_lifetime_days), 0) AS avg_lifetime_days
FROM customer_orders
GROUP BY customer_segment
ORDER BY 
    CASE customer_segment
        WHEN 'One-time Buyer' THEN 1
        WHEN 'Repeat Buyer (2x)' THEN 2
        WHEN 'Frequent Buyer (3-4x)' THEN 3
        WHEN 'Loyal Customer (5+)' THEN 4
        ELSE 5
    END;

-- ---------------------------------------------------------------------
-- QUERY 3: Top 5 Best-Selling Products by Revenue
-- Shows which products drive the most revenue
-- ---------------------------------------------------------------------
SELECT 
    p.product_id,
    p.name AS product_name,
    p.category,
    p.price AS current_price,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(SUM(oi.subtotal), 2) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS number_of_orders,
    ROUND(AVG(oi.unit_price), 2) AS avg_selling_price
FROM Product p
INNER JOIN OrderItem oi ON p.product_id = oi.product_id
INNER JOIN `Order` o ON oi.order_id = o.order_id
WHERE o.status != 'cancelled'
GROUP BY p.product_id, p.name, p.category, p.price
ORDER BY total_revenue DESC
LIMIT 5;

-- ---------------------------------------------------------------------
-- QUERY 4: High-Value Customers (Top 10 by Lifetime Spend)
-- Uses HAVING to filter customers above threshold
-- ---------------------------------------------------------------------
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.phone,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.subtotal), 2) AS lifetime_spend,
    ROUND(AVG(oi.subtotal), 2) AS avg_order_value,
    DATE(MIN(o.order_date)) AS first_order_date,
    DATE(MAX(o.order_date)) AS last_order_date
FROM Customer c
INNER JOIN `Order` o ON c.customer_id = o.customer_id
INNER JOIN OrderItem oi ON o.order_id = oi.order_id
WHERE o.status != 'cancelled'
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.phone
HAVING SUM(oi.subtotal) > 500
ORDER BY lifetime_spend DESC
LIMIT 10;

-- ---------------------------------------------------------------------
-- QUERY 5: Category Performance with Monthly Trends
-- Shows category revenue by month to identify growth/decline
-- ---------------------------------------------------------------------
SELECT 
    p.category,
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    ROUND(SUM(oi.subtotal), 2) AS monthly_revenue,
    SUM(oi.quantity) AS total_units_sold,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(DISTINCT c.customer_id) AS unique_customers
FROM Product p
INNER JOIN OrderItem oi ON p.product_id = oi.product_id
INNER JOIN `Order` o ON oi.order_id = o.order_id
INNER JOIN Customer c ON o.customer_id = c.customer_id
WHERE o.status != 'cancelled'
  AND p.category IS NOT NULL
  AND p.category != ''
GROUP BY p.category, DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY p.category, month DESC;