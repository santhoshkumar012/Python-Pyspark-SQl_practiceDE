-- ShopSphere -> MySQL / MySQL Workbench setup (MySQL 8.0+ needed for window functions)
--
-- BEFORE RUNNING:
--   1. Find & Replace  C:/de_practice/data/   with the folder where you unzipped the CSVs
--      (use forward slashes, even on Windows, and keep the trailing slash).
--   2. LOAD DATA LOCAL needs two switches:
--        a) server:  SET GLOBAL local_infile = 1;      (run once; needs an admin user)
--        b) Workbench connection: Manage Server Connections > your connection > Advanced
--           > "Others" box, add:  OPT_LOCAL_INFILE=1     then reconnect.
--   3. Run the whole script (lightning-bolt icon). Loading takes a few seconds.
--
-- If LOAD DATA gives you trouble: right-click each table > "Table Data Import Wizard" and pick the CSV.

CREATE DATABASE IF NOT EXISTS shopsphere;
USE shopsphere;

DROP TABLE IF EXISTS returns;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    email         VARCHAR(120),
    phone         VARCHAR(20),
    gender        VARCHAR(10),
    date_of_birth DATE,
    city          VARCHAR(50),
    state         VARCHAR(50),
    signup_date   DATE,
    loyalty_tier  VARCHAR(20)
);
CREATE TABLE products (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR(120) NOT NULL,
    category     VARCHAR(50),
    sub_category VARCHAR(50),
    brand        VARCHAR(50),
    unit_price   DECIMAL(12,2),
    cost_price   DECIMAL(12,2),
    launch_date  DATE,
    is_active    TINYINT
);
CREATE TABLE orders (
    order_id      INT PRIMARY KEY,
    customer_id   INT NOT NULL,
    order_date    DATE NOT NULL,
    order_status  VARCHAR(20),
    channel       VARCHAR(20),
    shipping_city VARCHAR(50),
    shipping_fee  DECIMAL(8,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    INDEX ix_orders_customer (customer_id),
    INDEX ix_orders_date (order_date)
);
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id      INT NOT NULL,
    product_id    INT NOT NULL,
    quantity      INT,
    unit_price    DECIMAL(12,2),
    discount_pct  INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE payments (
    payment_id     INT PRIMARY KEY,
    order_id       INT NOT NULL,
    payment_method VARCHAR(20),
    payment_status VARCHAR(20),
    amount         DECIMAL(12,2),
    paid_at        DATETIME,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    INDEX ix_payments_order (order_id)
);
CREATE TABLE returns (
    return_id     INT PRIMARY KEY,
    order_item_id INT NOT NULL,
    return_date   DATE,
    reason        VARCHAR(30),
    refund_amount DECIMAL(12,2),
    FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id)
);

-- ---------------------------------------------------------------- load (parents first)
LOAD DATA LOCAL INFILE 'C:/de_practice/data/customers.csv' INTO TABLE customers
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
  (customer_id, first_name, last_name, @email, @phone, gender, date_of_birth, city, state, signup_date, loyalty_tier)
  SET email = NULLIF(@email, ''), phone = NULLIF(@phone, '');

LOAD DATA LOCAL INFILE 'C:/de_practice/data/products.csv' INTO TABLE products
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/de_practice/data/orders.csv' INTO TABLE orders
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/de_practice/data/order_items.csv' INTO TABLE order_items
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/de_practice/data/payments.csv' INTO TABLE payments
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/de_practice/data/returns.csv' INTO TABLE returns
  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

-- ---------------------------------------------------------------- verify: expect 3000 / 196 / 30000 / 55760 / 30000 / 2983
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'products',    COUNT(*) FROM products
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'payments',    COUNT(*) FROM payments
UNION ALL SELECT 'returns',     COUNT(*) FROM returns;