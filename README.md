# 🛒 Online Shop System – IT 105 Final Project

## Project Overview
This project is a fully functional relational database for an **Online Shop System** with 8 integrated tables: Category, Customer, Product, User, Order, OrderItem, Payment, and AuditLog. The system manages customers, products, orders, payments, and includes an audit trail for data changes.

## Group Members and Roles
| Name                   | Role                  |
|------------------------|-----------------------|
| Sandy Murillo          | Project Manager       |
| Annaliza Juarez        | Documentation Lead    |
| Donalen Grace Rico     | SQL Developer         |
| Eunice Lozano          | Security Officer      |
| Gabriel Angelo Arcenal | QA/Tester             |
| Abby Llaguno           | Database Administrator|
 
## Database Schema Overview

| Table     | Description                                                      |
|-----------|------------------------------------------------------------------|
| Category  | Product categories (Electronics, Clothing, Books)                |
| Customer  | Customer information and login credentials                       |
| Product   | Product catalog with category, price, and stock                  |
| User      | Admin/staff accounts with role-based access                      |
| Order     | Customer orders with status tracking                             |
| OrderItem | Individual items within an order (with auto-calculated subtotal) |
| Payment   | Payment transactions with method and status                      |
| AuditLog  | Tracks all data modifications for security                       |

## How to Restore and Run the System

### 1. Clone the GitHub Repository
git clone https://github.com/murillosandyp/IT105-FinalGroupProject-FINALSIX-2a.git

### 2. Import the Database Schema
mysql -u your_username -p < sql/schema.sql

### 3. Verify the Installation
mysql -u your_username -p -e "USE OnlineShop; SHOW TABLES;"

### 4. Test the Admin Login
mysql -u your_username -p OnlineShop -e "SELECT * FROM User;"

### 5. Run Sample Queries
|Type              | File                            |
|------------------|---------------------------------|
| Basic queries	   | sql/sample_queries_basic.sql    |
| BI queries       | sql/sample_queries_bi.sql       |
| Optimized queries| sql/sample_queries_optimized.sql|

### 6.  Apply Indexing & Performance Improvements
mysql -u your_username -p OnlineShop < sql/indexing_performance.sql

## Key Features and Functionalities

### Customer & Account Management
- Customer registration with unique email validation
- Complete customer profile (name, email, phone, address)
- Automatic account creation timestamp
- Indexed email field for fast login

### Product & Category Catalog
- Product catalog with category association (Electronics, Clothing, Books)
- Price validation (no negative prices)
- Stock quantity tracking with minimum zero validation
- Indexed product name for quick search
- Category management with unique names

### Order Management
- Create orders linked to customers
- Order status workflow: pending → processing → shipped → delivered/cancelled
- Store shipping address per order
- Automatic order date tracking
- Indexes on customer_id and order_date for fast order history

### Order Items (Line Items)
- Support multiple products per order
- Prevent duplicate products in same order
- Auto-calculated subtotal using generated column (`quantity × unit_price`)
- Preserve historical unit prices (not affected by current product price changes)
- Cascade delete – remove order items automatically when order is deleted

### Payment Processing
- Multiple payment methods: Credit Card, GCash, PayMaya, Cash on Delivery (COD)
- Payment status tracking: Pending, Completed, Failed, Refunded
- Unique transaction reference for each payment
- Amount validation (must be greater than zero)

### Admin & Staff Authentication
- Separate user table for system administrators and staff
- Role-based access control: admin, staff, viewer
- Pre-loaded admin account (username: admin, password: admin123)

### Security & Audit Trail
- Complete audit logging of all data modifications
- Tracks: who changed what, when, old value vs new value
- Covers all tables for full compliance and debugging

### Data Integrity Features
- Foreign key constraints prevent orphaned records
- Check constraints ensure valid prices, stock levels, and quantities
- Unique constraints prevent duplicate emails, usernames, and transaction references
- Default values for order status and timestamps
- Not null constraints on critical fields

### Built-in Performance Indexes
- Customer email index
- Product name index  
- Order customer_id and order_date indexes
- Payment order_id index

## License
This project is for educational purposes only as part of IT 105.  
© 2025 FINALSIX Group – All rights reserved for academic submission.
