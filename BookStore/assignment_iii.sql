-- =====================================================================
-- ASSIGNMENT III: SQL TABLE MANIPULATION
-- Project   : Online Bookstore Management System
-- Student   : twin  (ID: 202513604)
-- DBMS      : PostgreSQL (pgAdmin 4)
-- Database  : twin_202513604_bookstore_system
-- =====================================================================


-- =====================================================================
-- SECTION 1: DATABASE CREATION
-- =====================================================================
-- Run this statement while connected to the default "postgres" database.
-- CREATE DATABASE cannot run inside a transaction block, so run it alone.
-- Then, in pgAdmin 4, right-click the new database -> Query Tool and run
-- everything below this section.

CREATE DATABASE twin_202513604_bookstore_system;


-- =====================================================================
-- SECTION 2: TABLE CREATION AND CONSTRAINTS
-- (parent tables first, child table last)
-- =====================================================================

-- Parent table 1: customers
CREATE TABLE customers (
    customer_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(120) NOT NULL UNIQUE,
    phone         VARCHAR(20),
    city          VARCHAR(60)  NOT NULL,
    registered_on DATE         NOT NULL DEFAULT CURRENT_DATE
);

-- Parent table 2: books
CREATE TABLE books (
    book_id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title          VARCHAR(150)  NOT NULL,
    author         VARCHAR(100)  NOT NULL,
    category       VARCHAR(50)   NOT NULL,
    price          NUMERIC(10,2) NOT NULL CHECK (price > 0),       -- price in RWF
    stock_quantity INTEGER       NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    published_year INTEGER       CHECK (published_year BETWEEN 1450 AND 2100)
);

-- Child table: orders (references both parents)
CREATE TABLE orders (
    order_id    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INTEGER     NOT NULL,
    book_id     INTEGER     NOT NULL,
    quantity    INTEGER     NOT NULL CHECK (quantity > 0),
    order_date  DATE        NOT NULL DEFAULT CURRENT_DATE,
    status      VARCHAR(20) NOT NULL DEFAULT 'Pending'
                CHECK (status IN ('Pending', 'Shipped', 'Delivered', 'Cancelled')),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id),
    CONSTRAINT fk_orders_book FOREIGN KEY (book_id)
        REFERENCES books (book_id)
);


-- =====================================================================
-- SECTION 3: INITIAL DATA INSERTION
-- (primary keys are generated automatically; parents before child)
-- =====================================================================

INSERT INTO customers (full_name, email, phone, city, registered_on) VALUES
    ('Aline Uwase',      'aline.uwase@example.com',   '0788111222', 'Kigali',   '2026-01-15'),
    ('Jean Claude Habimana', 'jc.habimana@example.com','0788333444', 'Huye',     '2026-02-03'),
    ('Grace Mukamana',   'grace.mukamana@example.com','0788555666', 'Musanze',  '2026-03-21'),
    ('Patrick Niyonzima','patrick.n@example.com',     '0788777888', 'Rubavu',   '2026-05-10'),
    ('Diane Ingabire',   'diane.ingabire@example.com','0788999000', 'Kigali',   '2026-07-28'),
    ('Eric Mugisha',     'eric.mugisha@example.com',  '0788123456', 'Nyagatare','2026-09-12');

INSERT INTO books (title, author, category, price, stock_quantity, published_year) VALUES
    ('Things Fall Apart',        'Chinua Achebe',     'Fiction',    12000.00, 40, 1958),
    ('Atomic Habits',            'James Clear',       'Self-Help',  18000.00, 25, 2018),
    ('Clean Code',               'Robert C. Martin',  'Technology', 35000.00, 15, 2008),
    ('The Alchemist',            'Paulo Coelho',      'Fiction',    10000.00, 50, 1988),
    ('Database System Concepts', 'Abraham Silberschatz','Technology',55000.00,  8, 2019),
    ('Long Walk to Freedom',     'Nelson Mandela',    'Biography',  20000.00, 20, 1994);

INSERT INTO orders (customer_id, book_id, quantity, order_date, status) VALUES
    (1, 1, 2, '2026-10-01', 'Delivered'),
    (1, 3, 1, '2026-10-05', 'Shipped'),
    (2, 2, 1, '2026-10-08', 'Delivered'),
    (3, 3, 1, '2026-10-10', 'Shipped'),
    (4, 4, 3, '2026-10-12', 'Delivered'),
    (5, 5, 1, '2026-10-14', 'Cancelled'),
    (2, 6, 1, '2026-10-15', 'Pending'),
    (3, 1, 2, '2026-10-23', 'Pending');

-- Verification: every table has at least 5 records
SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'books',     COUNT(*) FROM books
UNION ALL
SELECT 'orders',    COUNT(*) FROM orders;

-- Verification: identity keys and foreign keys work
SELECT * FROM customers ORDER BY customer_id;
SELECT * FROM books     ORDER BY book_id;
SELECT * FROM orders    ORDER BY order_id;


-- =====================================================================
-- >>> GENERATE THE ERD NOW (before the ALTER TABLE tasks) <<<
-- pgAdmin 4: right-click the database -> "ERD For Database"
--            -> Download image -> save as erd.png
-- =====================================================================


-- =====================================================================
-- SECTION 4: SELECT TASKS
-- =====================================================================

-- Q1.1 Basic Data Retrieval
-- Objective: list the title, author and price of every book.
SELECT title, author, price
FROM books;

-- Q1.2 Conditional Data Retrieval
-- Objective: list only books in the 'Technology' category.
SELECT book_id, title, author, price
FROM books
WHERE category = 'Technology';

-- Q1.3 Sorted Data Retrieval
-- Objective: list books from the most to the least expensive.
SELECT title, category, price
FROM books
ORDER BY price DESC;


-- =====================================================================
-- SECTION 5: JOIN TASKS
-- =====================================================================

-- Q2.1 INNER JOIN
-- Objective: show only customers who have placed orders, with order details.
SELECT c.customer_id, c.full_name, o.order_id, o.order_date, o.status
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
ORDER BY o.order_id;

-- Q2.2 LEFT JOIN
-- Objective: show ALL customers, including those who have never ordered.
SELECT c.customer_id, c.full_name, o.order_id, o.status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.order_id;

-- Q2.3 Multi-Table JOIN (customers + orders + books)
-- Objective: produce a sales report with customer, book and order total.
SELECT o.order_id,
       c.full_name,
       b.title,
       o.quantity,
       b.price,
       (o.quantity * b.price) AS total_amount,
       o.status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN books b     ON o.book_id     = b.book_id
ORDER BY o.order_id;


-- =====================================================================
-- SECTION 6: UPDATE TASKS AND VERIFICATION
-- =====================================================================

-- Q3.1 Update One Record
-- Objective: customer Eric Mugisha moved from Nyagatare to Kigali.
SELECT customer_id, full_name, city FROM customers
WHERE email = 'eric.mugisha@example.com';            -- before

UPDATE customers
SET city = 'Kigali'
WHERE email = 'eric.mugisha@example.com';

SELECT customer_id, full_name, city FROM customers
WHERE email = 'eric.mugisha@example.com';            -- verification

-- Q3.2 Update Multiple Records
-- Objective: raise the price of all 'Fiction' books by 10%.
SELECT book_id, title, category, price FROM books
WHERE category = 'Fiction';                          -- before (affected rows)

UPDATE books
SET price = ROUND(price * 1.10, 2)
WHERE category = 'Fiction';

SELECT book_id, title, category, price FROM books
WHERE category = 'Fiction';                          -- verification

-- Q3.3 Conditional Update (business rule)
-- Rule: 'Pending' orders placed on or before 2026-10-20 are now 'Shipped'.
SELECT order_id, order_date, status FROM orders
WHERE status = 'Pending' AND order_date <= DATE '2026-10-20';   -- before

UPDATE orders
SET status = 'Shipped'
WHERE status = 'Pending'
  AND order_date <= DATE '2026-10-20';

SELECT order_id, order_date, status FROM orders
ORDER BY order_id;                                   -- verification


-- =====================================================================
-- SECTION 7: ALTER TABLE TASKS AND VERIFICATION
-- =====================================================================

-- Q4.1 Rename a Column
-- Objective: rename customers.phone to phone_number.
ALTER TABLE customers
RENAME COLUMN phone TO phone_number;

SELECT customer_id, full_name, phone_number FROM customers
ORDER BY customer_id;                                -- data still accessible

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'customers'
ORDER BY ordinal_position;                           -- new structure

-- Q4.2 Change a Column's Data Type
-- Objective: published_year (INTEGER) -> SMALLINT. All years (1958-2019)
-- fit safely inside SMALLINT's range (-32768 to 32767).
ALTER TABLE books
ALTER COLUMN published_year TYPE SMALLINT USING published_year::SMALLINT;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'books' AND column_name = 'published_year';   -- new type

SELECT book_id, title, published_year FROM books
ORDER BY book_id;                                    -- data still valid

-- Q4.3 Add a New Column
-- Objective: store each book's ISBN, a useful identifier for a bookstore.
ALTER TABLE books
ADD COLUMN isbn VARCHAR(17);

SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'books'
ORDER BY ordinal_position;                           -- verification

SELECT book_id, title, isbn FROM books
ORDER BY book_id;                                    -- existing rows get NULL


-- =====================================================================
-- SECTION 8: ADDITIONAL INSERT TASKS AND VERIFICATION
-- =====================================================================

-- Q5.1 Insert a Single Record
-- Objective: register a new customer.
INSERT INTO customers (full_name, email, phone_number, city)
VALUES ('Sandrine Uwimana', 'sandrine.uwimana@example.com', '0788246810', 'Rusizi');

SELECT * FROM customers
WHERE email = 'sandrine.uwimana@example.com';        -- verification

-- Q5.2 Insert Multiple Records
-- Objective: add three new books to the catalogue.
INSERT INTO books (title, author, category, price, stock_quantity, published_year, isbn) VALUES
    ('Educated',               'Tara Westover',  'Biography',  17000.00, 30, 2018, '978-0399590504'),
    ('The Pragmatic Programmer','Andrew Hunt',   'Technology', 40000.00, 12, 1999, '978-0201616224'),
    ('Half of a Yellow Sun',   'Chimamanda Ngozi Adichie','Fiction', 14000.00, 22, 2006, '978-0007200283');

SELECT book_id, title, author, isbn FROM books
WHERE book_id > 6
ORDER BY book_id;                                    -- verification

-- Q5.3 Insert a Related Record (child table with valid foreign keys)
-- Objective: the new customer Sandrine orders 'Atomic Habits' (book_id 2).
INSERT INTO orders (customer_id, book_id, quantity, order_date, status)
VALUES (
    (SELECT customer_id FROM customers WHERE email = 'sandrine.uwimana@example.com'),
    2, 1, '2026-10-24', 'Pending'
);

SELECT o.order_id, c.full_name, b.title, o.quantity, o.status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN books b     ON o.book_id     = b.book_id
WHERE c.email = 'sandrine.uwimana@example.com';      -- verification

-- Optional: prove the foreign key protects the data (this SHOULD fail).
-- INSERT INTO orders (customer_id, book_id, quantity) VALUES (999, 1, 1);

-- =====================================================================
-- END OF SCRIPT
-- =====================================================================
