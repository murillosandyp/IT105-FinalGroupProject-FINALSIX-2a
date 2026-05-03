-- =============================================
-- PHASE 5: ORIGINAL QUERIES (BEFORE OPTIMIZATION)
-- =============================================

-- Query 1: Total sales per customer (BEFORE)
SELECT c.customer_id, c.first_name, c.last_name, SUM(o.total_amount) as total_spent
FROM Customer c
JOIN `Order` o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 20;

-- Query 2: Monthly sales report (BEFORE)
SELECT DATE_FORMAT(order_date, '%Y-%m') as month, COUNT(*) as total_orders, SUM(total_amount) as revenue
FROM `Order`
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month DESC;

-- Query 3: Top selling products (BEFORE)
SELECT p.product_id, p.name, SUM(oi.quantity) as total_sold, SUM(oi.subtotal) as total_revenue
FROM Product p
JOIN OrderItem oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name
ORDER BY total_sold DESC
LIMIT 10;

-- Query 4: Customer order history (BEFORE)
SELECT c.customer_id, c.first_name, c.last_name, COUNT(o.order_id) as order_count, SUM(o.total_amount) as total_spent
FROM Customer c
LEFT JOIN `Order` o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING order_count > 0
ORDER BY total_spent DESC;

-- Query 5: Pending orders (BEFORE)
SELECT o.order_id, o.order_date, o.total_amount, c.first_name, c.last_name, c.email
FROM `Order` o
JOIN Customer c ON o.customer_id = c.customer_id
WHERE o.status = 'pending'
ORDER BY o.order_date DESC;

-- =============================================
-- INDEXES ADDED
-- =============================================

CREATE INDEX idx_customer_id ON Customer(customer_id);
CREATE INDEX idx_order_customer ON `Order`(customer_id);
CREATE INDEX idx_product_id ON Product(product_id);
CREATE INDEX idx_orderitem_product ON OrderItem(product_id);
CREATE INDEX idx_order_status ON `Order`(status);

-- =============================================
-- OPTIMIZED QUERIES (AFTER OPTIMIZATION)
-- =============================================

-- Query 1: Total sales per customer (AFTER)
SELECT c.customer_id, c.first_name, c.last_name, SUM(o.total_amount) as total_spent
FROM Customer c
INNER JOIN `Order` o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 20;

-- Query 2: Monthly sales report (AFTER)
SELECT DATE_FORMAT(order_date, '%Y-%m') as month, COUNT(*) as total_orders, SUM(total_amount) as revenue
FROM `Order`
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month DESC;

-- Query 3: Top selling products (AFTER)
SELECT p.product_id, p.name, SUM(oi.quantity) as total_sold, SUM(oi.quantity * oi.unit_price) as total_revenue
FROM Product p
INNER JOIN OrderItem oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name
ORDER BY total_sold DESC
LIMIT 10;

-- Query 5: Pending orders (AFTER)
SELECT o.order_id, o.order_date, o.total_amount, c.first_name, c.last_name, c.email
FROM `Order` o
INNER JOIN Customer c ON o.customer_id = c.customer_id
WHERE o.status = 'pending'
ORDER BY o.order_date DESC;