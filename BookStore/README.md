# Assignment III: SQL Table Manipulation — Online Bookstore Management System

## Section 1: Project Overview

- **Project title:** Online Bookstore Management System
- **Student name / ID:** twin / 202513604
- **Business idea:** An online bookstore that keeps track of its customers, its catalogue of books, and the orders customers place.
- **DBMS:** PostgreSQL (pgAdmin 4)

## Section 2: Database and Table Design

**Database name:** `twin_202513604_bookstore_system`

| Table | Role | Purpose |
|---|---|---|
| `customers` | Parent | People who buy books |
| `books` | Parent | Catalogue of books for sale |
| `orders` | Child | Which customer bought which book, how many, when, and the order status |

**Columns**

`customers`: `customer_id` (INTEGER, PK, identity), `full_name` VARCHAR(100), `email` VARCHAR(120) UNIQUE, `phone` VARCHAR(20), `city` VARCHAR(60), `registered_on` DATE

`books`: `book_id` (INTEGER, PK, identity), `title` VARCHAR(150), `author` VARCHAR(100), `category` VARCHAR(50), `price` NUMERIC(10,2) (RWF), `stock_quantity` INTEGER, `published_year` INTEGER

`orders`: `order_id` (INTEGER, PK, identity), `customer_id` (FK), `book_id` (FK), `quantity` INTEGER, `order_date` DATE, `status` VARCHAR(20)

**Keys**

- **Primary keys** (`customer_id`, `book_id`, `order_id`) uniquely identify each row. They are generated automatically with `GENERATED ALWAYS AS IDENTITY`, so I never type them in.
- **Foreign keys:** `orders.customer_id → customers.customer_id` and `orders.book_id → books.book_id`. They guarantee that every order points to a real customer and a real book.

**Relationships**

- One customer can place many orders (1 : N).
- One book can appear in many orders (1 : N).
- Together, `orders` links customers and books (a many-to-many relationship resolved by the child table).
- Customer and book details are stored once and referenced by ID, which avoids duplication and keeps the data consistent.

**Other constraints:** `NOT NULL`, `UNIQUE (email)`, `CHECK (price > 0)`, `CHECK (stock_quantity >= 0)`, `CHECK (quantity > 0)`, `CHECK (status IN ('Pending','Shipped','Delivered','Cancelled'))`, `DEFAULT CURRENT_DATE`.

### ERD

![ERD](erd.png)

*(Generated in pgAdmin 4: right-click database → ERD For Database → Download image. Generate it before the ALTER TABLE tasks.)*

## Section 3: Database and Table Creation

See `assignment_iii.sql`, Sections 1 and 2 (`CREATE DATABASE`, then `CREATE TABLE` for `customers`, `books`, and finally `orders`).

## Section 4: Initial Data Insertion

See `assignment_iii.sql`, Section 3. Parents are inserted first (6 customers, 6 books), then the child (8 orders).

Evidence of counts:

| table_name | total_rows |
|---|---|
| customers | 6 |
| books | 6 |
| orders | 8 |

`customer_id`, `book_id`, and `order_id` were generated automatically (1, 2, 3, …), and every order's foreign keys reference existing parent rows.

> 📸 *Screenshot: initial data in pgAdmin*

## Section 5: SQL Practical Tasks

### SELECT

**Q1.1 Basic retrieval** — list title, author, and price of every book.
```sql
SELECT title, author, price FROM books;
```
Returns all 6 books with just those three columns. *(Explanation: selecting specific columns gives a clean catalogue view.)*

**Q1.2 Conditional retrieval** — books in the Technology category.
```sql
SELECT book_id, title, author, price FROM books WHERE category = 'Technology';
```
Result: Clean Code (35000.00) and Database System Concepts (55000.00). *(The WHERE clause filters rows.)*

**Q1.3 Sorted retrieval** — most to least expensive.
```sql
SELECT title, category, price FROM books ORDER BY price DESC;
```
Result starts with Database System Concepts (55000.00) and ends with The Alchemist (10000.00).

### JOIN

**Q2.1 INNER JOIN** — customers who have placed orders.
```sql
SELECT c.customer_id, c.full_name, o.order_id, o.order_date, o.status
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
ORDER BY o.order_id;
```
Returns 8 rows, one per order. Eric Mugisha does not appear because he has no orders; INNER JOIN keeps only matching rows.

**Q2.2 LEFT JOIN** — all customers, with orders where they exist.
```sql
SELECT c.customer_id, c.full_name, o.order_id, o.status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.order_id;
```
Returns 9 rows. Eric Mugisha now appears with `NULL` order fields, so LEFT JOIN keeps every customer even without a match.

**Q2.3 Multi-table JOIN** — sales report across all three tables.
```sql
SELECT o.order_id, c.full_name, b.title, o.quantity, b.price,
       (o.quantity * b.price) AS total_amount, o.status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN books b     ON o.book_id     = b.book_id
ORDER BY o.order_id;
```
Returns 8 rows showing who bought which book and the order total (for example, order 1: Aline Uwase, Things Fall Apart, 2 × 12000 = 24000).

### UPDATE

**Q3.1 Update one record** — Eric Mugisha moved to Kigali.
```sql
UPDATE customers SET city = 'Kigali' WHERE email = 'eric.mugisha@example.com';
```
`UPDATE 1`. Verified with a SELECT: city changed from Nyagatare to Kigali. The unique email targets exactly one row.

**Q3.2 Update multiple records** — raise Fiction book prices by 10%.
```sql
UPDATE books SET price = ROUND(price * 1.10, 2) WHERE category = 'Fiction';
```
Before: I selected the Fiction rows (2 books). `UPDATE 2`. Verified: Things Fall Apart 12000.00 → 13200.00, The Alchemist 10000.00 → 11000.00.

**Q3.3 Conditional update (business rule)** — Pending orders placed on or before 2026-10-20 become Shipped.
```sql
UPDATE orders SET status = 'Shipped'
WHERE status = 'Pending' AND order_date <= DATE '2026-10-20';
```
Before: only order 7 matched. `UPDATE 1`. Verified: order 7 is now Shipped; order 8 (2026-10-23) stays Pending.

### ALTER TABLE

**Q4.1 Rename a column** — `customers.phone` → `phone_number`.
```sql
ALTER TABLE customers RENAME COLUMN phone TO phone_number;
```
Verified through `information_schema.columns` (new name appears) and a SELECT showing the phone numbers are intact.

**Q4.2 Change a data type** — `books.published_year` INTEGER → SMALLINT.
```sql
ALTER TABLE books
ALTER COLUMN published_year TYPE SMALLINT USING published_year::SMALLINT;
```
All years (1958–2019) fit in SMALLINT (max 32767), so the conversion is safe. Verified: data_type is now `smallint` and all six years are unchanged.

**Q4.3 Add a column** — `books.isbn`.
```sql
ALTER TABLE books ADD COLUMN isbn VARCHAR(17);
```
I chose to add rather than remove because an ISBN is a standard identifier for books. Verified: `isbn` (varchar, 17) appears in the structure; existing rows have `NULL`.

### INSERT

**Q5.1 Single record** — new customer.
```sql
INSERT INTO customers (full_name, email, phone_number, city)
VALUES ('Sandrine Uwimana', 'sandrine.uwimana@example.com', '0788246810', 'Rusizi');
```
`INSERT 0 1`. Verified: she was assigned `customer_id` 7 automatically, with `registered_on` defaulting to today.

**Q5.2 Multiple records** — three new books (Educated, The Pragmatic Programmer, Half of a Yellow Sun).
```sql
INSERT INTO books (title, author, category, price, stock_quantity, published_year, isbn) VALUES (...), (...), (...);
```
`INSERT 0 3`. Verified: book_ids 7, 8, 9 were generated.

**Q5.3 Related record** — Sandrine orders Atomic Habits.
```sql
INSERT INTO orders (customer_id, book_id, quantity, order_date, status)
VALUES ((SELECT customer_id FROM customers WHERE email = 'sandrine.uwimana@example.com'),
        2, 1, '2026-10-24', 'Pending');
```
`INSERT 0 1`. Verified by a JOIN: order 9 links Sandrine Uwimana to Atomic Habits. The foreign keys accepted it because both parents exist.

> 📸 *Add a screenshot of each task's result from pgAdmin under its section.*

## Section 6: Conclusion

*(Write this in your own words. Points to cover:)* creating a database and tables with proper data types; how primary keys identify rows and foreign keys connect tables and protect integrity; inserting parents before children; the difference between INNER JOIN (matches only) and LEFT JOIN (keeps all rows from the left table); why every UPDATE needs a precise WHERE clause and a verification SELECT; and how ALTER TABLE changes structure rather than data.
