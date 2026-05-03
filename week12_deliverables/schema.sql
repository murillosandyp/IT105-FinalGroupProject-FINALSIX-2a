-- =====================================================
-- STAR SCHEMA FOR ONLINE SHOP SYSTEM
-- =====================================================

USE online_shop;

-- ---------------------------------------------------------------------
-- 1. DIMENSION TABLE: dim_date
-- Time dimension for all date-based analysis
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS dim_date;
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,  -- Format: YYYYMMDD
    full_date DATE NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20),
    week_of_year INT NOT NULL,
    day_of_month INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(20),
    is_weekend TINYINT(1) DEFAULT 0,  -- 1 = weekend, 0 = weekday
    is_weekday TINYINT(1) DEFAULT 1
);

-- Populate dim_date with dates from your orders
-- This creates date entries for all order dates in your system
INSERT INTO dim_date (date_key, full_date, year, quarter, month, month_name, 
                      week_of_year, day_of_month, day_of_week, day_name, 
                      is_weekend, is_weekday)
SELECT DISTINCT
    YEAR(order_date) * 10000 + MONTH(order_date) * 100 + DAY(order_date) AS date_key,
    DATE(order_date) AS full_date,
    YEAR(order_date) AS year,
    QUARTER(order_date) AS quarter,
    MONTH(order_date) AS month,
    MONTHNAME(order_date) AS month_name,
    WEEK(order_date) AS week_of_year,
    DAY(order_date) AS day_of_month,
    DAYOFWEEK(order_date) AS day_of_week,
    DAYNAME(order_date) AS day_name,
    CASE WHEN DAYOFWEEK(order_date) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend,
    CASE WHEN DAYOFWEEK(order_date) NOT IN (1, 7) THEN 1 ELSE 0 END AS is_weekday
FROM `Order`
WHERE order_date IS NOT NULL;

-- If you have no orders yet, insert some default dates (2024-2026)
-- This ensures the dimension has data even before orders exist
INSERT IGNORE INTO dim_date (date_key, full_date, year, quarter, month, month_name, 
                              week_of_year, day_of_month, day_of_week, day_name, 
                              is_weekend, is_weekday)
SELECT 
    YEAR(dates.date_value) * 10000 + MONTH(dates.date_value) * 100 + DAY(dates.date_value),
    dates.date_value,
    YEAR(dates.date_value),
    QUARTER(dates.date_value),
    MONTH(dates.date_value),
    MONTHNAME(dates.date_value),
    WEEK(dates.date_value),
    DAY(dates.date_value),
    DAYOFWEEK(dates.date_value),
    DAYNAME(dates.date_value),
    CASE WHEN DAYOFWEEK(dates.date_value) IN (1, 7) THEN 1 ELSE 0 END,
    CASE WHEN DAYOFWEEK(dates.date_value) NOT IN (1, 7) THEN 1 ELSE 0 END
FROM (
    SELECT DATE('2024-01-01') + INTERVAL (a.a + (10*b.a)) DAY AS date_value
    FROM (
        SELECT 0 AS a UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
        UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
    ) AS a
    CROSS JOIN (
        SELECT 0 AS a UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
        UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
    ) AS b
    WHERE DATE('2024-01-01') + INTERVAL (a.a + (10*b.a)) DAY <= '2026-12-31'
) AS dates
WHERE NOT EXISTS (
    SELECT 1 FROM dim_date d WHERE d.full_date = dates.date_value
);

-- ---------------------------------------------------------------------
-- 2. DIMENSION TABLE: dim_customer
-- Customer dimension with demographics and segments
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS dim_customer;
CREATE TABLE dim_customer (
    customer_key INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    full_name VARCHAR(101),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    customer_segment VARCHAR(20),
    registration_date DATE,
    days_as_customer INT,
    total_orders INT DEFAULT 0,
    lifetime_value DECIMAL(10,2) DEFAULT 0
);

-- Populate dim_customer from your Customer table
INSERT INTO dim_customer (customer_id, full_name, first_name, last_name, 
                          email, phone, address, registration_date)
SELECT 
    customer_id,
    CONCAT(first_name, ' ', last_name),
    first_name,
    last_name,
    email,
    phone,
    address,
    DATE(created_at) AS registration_date
FROM Customer;

-- Update calculated columns
UPDATE dim_customer dc
SET days_as_customer = DATEDIFF(CURDATE(), registration_date),
    customer_segment = CASE 
        WHEN days_as_customer < 30 THEN 'New'
        WHEN days_as_customer BETWEEN 30 AND 365 THEN 'Active'
        WHEN days_as_customer > 365 THEN 'Long-term'
        ELSE 'Unknown'
    END;

-- Update total orders and lifetime value from actual data
UPDATE dim_customer dc
SET total_orders = (
    SELECT COUNT(DISTINCT o.order_id)
    FROM `Order` o
    WHERE o.customer_id = dc.customer_id
      AND o.status != 'cancelled'
),
lifetime_value = (
    SELECT COALESCE(SUM(oi.subtotal), 0)
    FROM `Order` o
    JOIN OrderItem oi ON o.order_id = oi.order_id
    WHERE o.customer_id = dc.customer_id
      AND o.status != 'cancelled'
);

-- ---------------------------------------------------------------------
-- 3. DIMENSION TABLE: dim_product
-- Product dimension with category and pricing
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS dim_product;
CREATE TABLE dim_product (
    product_key INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    product_name VARCHAR(100),
    description TEXT,
    category VARCHAR(50),
    current_price DECIMAL(10,2),
    price_range VARCHAR(20),
    stock_quantity INT DEFAULT 0,
    stock_status VARCHAR(20),
    is_active TINYINT(1) DEFAULT 1
);

-- Populate dim_product from your Product table
INSERT INTO dim_product (product_id, product_name, description, category, 
                         current_price, stock_quantity)
SELECT 
    product_id,
    name,
    description,
    category,
    price,
    stock_quantity
FROM Product;

-- Update calculated columns
UPDATE dim_product 
SET price_range = CASE 
        WHEN current_price < 20 THEN 'Budget'
        WHEN current_price BETWEEN 20 AND 100 THEN 'Mid-Range'
        WHEN current_price > 100 THEN 'Premium'
        ELSE 'Unpriced'
    END,
    stock_status = CASE 
        WHEN stock_quantity = 0 THEN 'Out of Stock'
        WHEN stock_quantity <= 10 THEN 'Low Stock'
        WHEN stock_quantity > 10 THEN 'In Stock'
        ELSE 'Unknown'
    END;

-- ---------------------------------------------------------------------
-- 4. FACT TABLE: fact_sales
-- The center of the star schema - contains measurable business metrics
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS fact_sales;
CREATE TABLE fact_sales (
    sales_key INT PRIMARY KEY AUTO_INCREMENT,
    date_key INT NOT NULL,
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    order_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2),
    subtotal DECIMAL(10,2),
    discount_amount DECIMAL(10,2) DEFAULT 0,
    order_status VARCHAR(20),
    INDEX idx_date_key (date_key),
    INDEX idx_customer_key (customer_key),
    INDEX idx_product_key (product_key),
    INDEX idx_order_id (order_id),
    INDEX idx_status (order_status)
);

-- Populate fact_sales from your existing Order and OrderItem tables
INSERT INTO fact_sales (date_key, customer_key, product_key, order_id, 
                        quantity, unit_price, subtotal, order_status)
SELECT 
    YEAR(o.order_date) * 10000 + MONTH(o.order_date) * 100 + DAY(o.order_date) AS date_key,
    dc.customer_key,
    dp.product_key,
    o.order_id,
    oi.quantity,
    oi.unit_price,
    oi.subtotal,
    o.status
FROM `Order` o
INNER JOIN OrderItem oi ON o.order_id = oi.order_id
INNER JOIN dim_customer dc ON o.customer_id = dc.customer_id
INNER JOIN dim_product dp ON oi.product_id = dp.product_id
WHERE o.status != 'cancelled';

-- ---------------------------------------------------------------------
-- 5. VERIFY YOUR STAR SCHEMA
-- Check row counts to ensure everything loaded correctly
-- ---------------------------------------------------------------------
SELECT 'dim_date' AS table_name, COUNT(*) AS row_count FROM dim_date
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL
SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM fact_sales;

-- ---------------------------------------------------------------------
-- 6. SAMPLE BI QUERY USING STAR SCHEMA
-- This shows how much faster/easier BI queries become
-- ---------------------------------------------------------------------
SELECT 
    d.year,
    d.month_name,
    dc.customer_segment,
    dp.category,
    COUNT(DISTINCT fs.order_id) AS total_orders,
    SUM(fs.quantity) AS total_units_sold,
    ROUND(SUM(fs.subtotal), 2) AS total_revenue,
    ROUND(AVG(fs.subtotal), 2) AS avg_order_value
FROM fact_sales fs
INNER JOIN dim_date d ON fs.date_key = d.date_key
INNER JOIN dim_customer dc ON fs.customer_key = dc.customer_key
INNER JOIN dim_product dp ON fs.product_key = dp.product_key
GROUP BY d.year, d.month_name, dc.customer_segment, dp.category
ORDER BY d.year DESC, d.month_name, total_revenue DESC;

-- ---------------------------------------------------------------------
-- 7. COMPARE PERFORMANCE: Star Schema vs Original Schema
-- Original way (more JOINs, slower on large data)
-- ---------------------------------------------------------------------
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    p.category,
    SUM(oi.subtotal) AS revenue
FROM `Order` o
INNER JOIN OrderItem oi ON o.order_id = oi.order_id
INNER JOIN Product p ON oi.product_id = p.product_id
INNER JOIN Customer c ON o.customer_id = c.customer_id
WHERE o.status != 'cancelled'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m'), p.category;

-- Star schema way (fewer JOINs, faster)
-- Same result but uses pre-joined fact table
SELECT 
    CONCAT(d.year, '-', LPAD(d.month, 2, '0')) AS month,
    dp.category,
    SUM(fs.subtotal) AS revenue
FROM fact_sales fs
INNER JOIN dim_date d ON fs.date_key = d.date_key
INNER JOIN dim_product dp ON fs.product_key = dp.product_key
GROUP BY d.year, d.month, dp.category
ORDER BY month DESC, revenue DESC;