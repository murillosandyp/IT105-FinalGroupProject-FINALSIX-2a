-- =============================================
-- ONLINE SHOP SYSTEM - 100,000+ ROW DATASET
-- IT 105 Final Project - Group 6
-- Generated: April 10, 2026
-- =============================================

USE online_shop;

-- =============================================
-- STORED PROCEDURE: Generate 50,000 Customers
-- =============================================
DELIMITER $$
DROP PROCEDURE IF EXISTS generate_customers$$
CREATE PROCEDURE generate_customers()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE first_names VARCHAR(500) DEFAULT 'James,Mary,John,Patricia,Robert,Jennifer,Michael,Linda,William,Elizabeth,David,Susan,Joseph,Jessica,Thomas,Sarah,Charles,Karen,Christopher,Nancy,Daniel,Lisa,Matthew,Betty,Anthony,Margaret,Donald,Sandra,Mark,Ashley,Paul,Kimberly,Steven,Emily,Andrew,Donna,Kenneth,Michelle,George,Dorothy,Joshua,Carol,Kevin,Amanda,Brian,Melissa,Edward,Deborah,Ronald,Stephanie';
    DECLARE last_names VARCHAR(500) DEFAULT 'Smith,Johnson,Williams,Brown,Jones,Garcia,Miller,Davis,Rodriguez,Martinez,Wilson,Anderson,Taylor,Thomas,Moore,Jackson,Martin,Lee,White,Harris,Clark,Lewis,Walker,Hall,Allen,Young,Hernandez,King,Wright,Lopez,Hill,Scott,Green,Adams,Baker,Gonzalez,Nelson,Carter,Mitchell,Perez,Roberts,Turner,Phillips,Campbell,Parker,Evans,Edwards,Collins,Stewart,Sanchez';
    
    WHILE i <= 50000 DO
        INSERT INTO Customer (first_name, last_name, email, password, phone, address, created_at)
        VALUES (
            ELT(1 + FLOOR(RAND() * 50), 'James','Mary','John','Patricia','Robert','Jennifer','Michael','Linda','William','Elizabeth','David','Susan','Joseph','Jessica','Thomas','Sarah','Charles','Karen','Christopher','Nancy','Daniel','Lisa','Matthew','Betty','Anthony','Margaret','Donald','Sandra','Mark','Ashley','Paul','Kimberly','Steven','Emily','Andrew','Donna','Kenneth','Michelle','George','Dorothy','Joshua','Carol','Kevin','Amanda','Brian','Melissa','Edward','Deborah','Ronald','Stephanie'),
            ELT(1 + FLOOR(RAND() * 50), 'Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis','Rodriguez','Martinez','Wilson','Anderson','Taylor','Thomas','Moore','Jackson','Martin','Lee','White','Harris','Clark','Lewis','Walker','Hall','Allen','Young','Hernandez','King','Wright','Lopez','Hill','Scott','Green','Adams','Baker','Gonzalez','Nelson','Carter','Mitchell','Perez','Roberts','Turner','Phillips','Campbell','Parker','Evans','Edwards','Collins','Stewart','Sanchez'),
            CONCAT('customer', i, '@mail.com'),
            MD5(CONCAT('pass', i)),
            CONCAT('09', LPAD(FLOOR(RAND() * 1000000000), 9, '0')),
            CONCAT(FLOOR(RAND() * 9999), ' ', ELT(1 + FLOOR(RAND() * 10), 'Main St','Oak Ave','Maple Rd','Pine Ln','Cedar Dr','Elm Blvd','Washington St','Lake Ave','Hill Rd','Park Blvd')),
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 730) DAY)
        );
        SET i = i + 1;
        IF i % 10000 = 0 THEN
            SELECT CONCAT('Inserted ', i, ' customers') AS Progress;
        END IF;
    END WHILE;
END$$
DELIMITER ;

-- =============================================
-- STORED PROCEDURE: Generate 10,000 Products
-- =============================================
DELIMITER $$
DROP PROCEDURE IF EXISTS generate_products$$
CREATE PROCEDURE generate_products()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE categories VARCHAR(500) DEFAULT 'Electronics,Clothing,Books,Home,Toys,Sports,Beauty,Garden,Automotive,Pet Supplies,Office,Jewelry,Music,Grocery,Health,Tools,Baby,Food,Drinks,Furniture';
    
    WHILE i <= 10000 DO
        INSERT INTO Product (name, description, price, stock_quantity, category, created_at)
        VALUES (
            CONCAT(ELT(1 + FLOOR(RAND() * 20), 'Deluxe','Premium','Basic','Pro','Max','Lite','Plus','Ultra','Standard','Advanced','Essential','Complete','Smart','Digital','Classic','Modern','Eco','Sport','Travel','Home'), ' Product ', i),
            CONCAT('High-quality ', ELT(1 + FLOOR(RAND() * 10), 'electronic','clothing','book','home item','toy','sports equipment','beauty product','garden tool','automotive part','office supply'), ' with excellent features and warranty. Perfect for your needs.'),
            ROUND(5 + RAND() * 995, 2),
            FLOOR(RAND() * 500),
            ELT(1 + FLOOR(RAND() * 20), 'Electronics','Clothing','Books','Home','Toys','Sports','Beauty','Garden','Automotive','Pet Supplies','Office','Jewelry','Music','Grocery','Health','Tools','Baby','Food','Drinks','Furniture'),
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365) DAY)
        );
        SET i = i + 1;
        IF i % 2000 = 0 THEN
            SELECT CONCAT('Inserted ', i, ' products') AS Progress;
        END IF;
    END WHILE;
END$$
DELIMITER ;

-- =============================================
-- STORED PROCEDURE: Generate 30,000 Orders
-- =============================================
DELIMITER $$
DROP PROCEDURE IF EXISTS generate_orders$$
CREATE PROCEDURE generate_orders()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE max_customer INT;
    DECLARE rand_customer INT;
    
    SELECT MAX(customer_id) INTO max_customer FROM Customer;
    
    WHILE i <= 30000 DO
        SET rand_customer = 1 + FLOOR(RAND() * max_customer);
        
        INSERT INTO `Order` (customer_id, order_date, total_amount, status)
        VALUES (
            rand_customer,
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 180) DAY),
            0,
            ELT(1 + FLOOR(RAND() * 5), 'pending','processing','shipped','delivered','cancelled')
        );
        SET i = i + 1;
        IF i % 5000 = 0 THEN
            SELECT CONCAT('Inserted ', i, ' orders') AS Progress;
        END IF;
    END WHILE;
END$$
DELIMITER ;

-- =============================================
-- STORED PROCEDURE: Generate 65,000 OrderItems
-- =============================================
DELIMITER $$
DROP PROCEDURE IF EXISTS generate_order_items$$
CREATE PROCEDURE generate_order_items()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE max_order INT;
    DECLARE max_product INT;
    DECLARE rand_order INT;
    DECLARE rand_product INT;
    DECLARE rand_qty INT;
    DECLARE product_price DECIMAL(10,2);
    
    SELECT MAX(order_id) INTO max_order FROM `Order`;
    SELECT MAX(product_id) INTO max_product FROM Product;
    
    WHILE i <= 65000 DO
        SET rand_order = 1 + FLOOR(RAND() * max_order);
        SET rand_product = 1 + FLOOR(RAND() * max_product);
        SET rand_qty = 1 + FLOOR(RAND() * 5);
        
        SELECT price INTO product_price FROM Product WHERE product_id = rand_product;
        
        INSERT IGNORE INTO OrderItem (order_id, product_id, quantity, unit_price)
        VALUES (rand_order, rand_product, rand_qty, product_price);
        
        SET i = i + 1;
        IF i % 10000 = 0 THEN
            SELECT CONCAT('Inserted ', i, ' order items') AS Progress;
        END IF;
    END WHILE;
    
    -- Update order totals
    UPDATE `Order` o
    SET total_amount = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM OrderItem oi
        WHERE oi.order_id = o.order_id
    );
END$$
DELIMITER ;

-- =============================================
-- RUN ALL GENERATION PROCEDURES
-- =============================================
CALL generate_customers();
CALL generate_products();
CALL generate_orders();
CALL generate_order_items();

-- =============================================
-- VERIFY ROW COUNTS (PROOF OF 100,000+)
-- =============================================
SELECT 'Customer' AS table_name, COUNT(*) AS row_count FROM Customer
UNION ALL
SELECT 'Product', COUNT(*) FROM Product
UNION ALL
SELECT 'Order', COUNT(*) FROM `Order`
UNION ALL
SELECT 'OrderItem', COUNT(*) FROM OrderItem
UNION ALL
SELECT 'User', COUNT(*) FROM User;

-- =============================================
-- TOTAL ROW COUNT
-- =============================================
SELECT 
    (SELECT COUNT(*) FROM Customer) +
    (SELECT COUNT(*) FROM Product) +
    (SELECT COUNT(*) FROM `Order`) +
    (SELECT COUNT(*) FROM OrderItem) +
    (SELECT COUNT(*) FROM User) AS total_rows_in_database;

-- =============================================
-- SAMPLE QUERY 1: Recent Orders with Customer Names
-- =============================================
SELECT o.order_id, c.first_name, c.last_name, c.email, 
       o.order_date, o.total_amount, o.status
FROM `Order` o
JOIN Customer c ON o.customer_id = c.customer_id
ORDER BY o.order_date DESC
LIMIT 10;

-- =============================================
-- SAMPLE QUERY 2: Top Selling Products
-- =============================================
SELECT p.product_id, p.name, p.category, 
       SUM(oi.quantity) AS total_sold,
       SUM(oi.subtotal) AS total_revenue
FROM OrderItem oi
JOIN Product p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY total_sold DESC
LIMIT 10;

-- =============================================
-- SAMPLE QUERY 3: Customer Order Summary
-- =============================================
SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(o.order_id) AS order_count,
       SUM(o.total_amount) AS total_spent
FROM Customer c
LEFT JOIN `Order` o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 10;