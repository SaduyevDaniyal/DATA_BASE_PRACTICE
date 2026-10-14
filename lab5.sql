--task 1.1
CREATE TABLE employees(
                          employee_id integer,
                          first_name varchar(50),
                          last_name varchar(50),
                          age integer check(age between 18 and 65),
                          salary NUMERIC check( salary>0)
);
--task1.2
CREATE TABLE products_catalog(
    product_id integer,
    product_name varchar(50),
    regular_price numeric,
    discount_price numeric

);
ALTER TABLE products_catalog
add constraint valid_discount
check(regular_price > 0 and discount_price > 0 and discount_price<regular_price);
--task1.3
CREATE TABLE booking(
    booking_id integer,
    check_in_date date,
    check_out_date date,
    num_guests integer

);
ALTER TABLE booking
add constraint check_table
check(num_guests between 1 and 10
    and check_out_date>check_in_date);
--task1.4
INSERT INTO employees (employee_id, first_name, last_name, age, salary)
VALUES (1, 'Alex', 'Smith', 25, 300000);
-- INVALID: age = 17, but CHECK requires age BETWEEN 18 AND 65.
-- PostgreSQL rejects this row because the employee is under 18.
-- INSERT INTO employees VALUES (3, 'John', 'White', 17, 200000);


-- 2. PRODUCTS_CATALOG
INSERT INTO products_catalog VALUES (1, 'Laptop', 500000, 400000);
INSERT INTO products_catalog VALUES (2, 'Mouse', 10000, 8000);

-- INVALID: discount_price = 250000 > regular_price = 200000.
-- Violates valid_discount because discount must be lower.
-- INSERT INTO products_catalog VALUES (3, 'Phone', 200000, 250000);


-- 3. BOOKINGS
INSERT INTO booking VALUES (1, '2026-10-14', '2026-10-20', 3);
INSERT INTO booking VALUES (2, '2026-11-01', '2026-11-05', 5);

-- INVALID: check_out_date is earlier than check_in_date.
-- Violates the CHECK requiring check_out_date > check_in_date.
-- INSERT INTO bookings VALUES (3, '2026-10-20', '2026-10-14', 3);


-- Task 2.1: NOT NULL Implementation
CREATE TABLE customers (
                           customer_id INTEGER NOT NULL,
                           email TEXT NOT NULL,
                           phone TEXT,
                           registration_date DATE NOT NULL
);

-- Task 2.2: Combining Constraints
CREATE TABLE inventory (
                           item_id INTEGER NOT NULL,
                           item_name TEXT NOT NULL,
                           quantity INTEGER NOT NULL CHECK (quantity >= 0),
                           unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
                           last_updated TIMESTAMP NOT NULL
);

-- Task 2.3: Testing NOT NULL

-- VALID: complete customer record
INSERT INTO customers
VALUES (1, 'alex@gmail.com', '87001234567', '2026-10-14');

-- VALID: phone is nullable
INSERT INTO customers
VALUES (2, 'bob@gmail.com', NULL, '2026-10-14');

-- INVALID: email cannot be NULL
-- Violates NOT NULL on customers.email
-- INSERT INTO customers
-- VALUES (3, NULL, '87007778899', '2026-10-14');

-- VALID: complete inventory record
INSERT INTO inventory
VALUES (1, 'Mouse', 10, 5000, CURRENT_TIMESTAMP);

INSERT INTO inventory
VALUES (2, 'Keyboard', 5, 12000, CURRENT_TIMESTAMP);

-- INVALID: item_name cannot be NULL
-- Violates NOT NULL on inventory.item_name
-- INSERT INTO inventory
-- VALUES (3, NULL, 10, 5000, CURRENT_TIMESTAMP);

-- INVALID: quantity cannot be NULL
-- Violates NOT NULL on inventory.quantity
-- INSERT INTO inventory
-- VALUES (4, 'Monitor', NULL, 50000, CURRENT_TIMESTAMP);

-- Check inserted data
SELECT * FROM customers;
SELECT * FROM inventory;

-- Task 3.1: Single Column UNIQUE
CREATE TABLE users (
                       user_id INTEGER,
                       username TEXT UNIQUE,
                       email TEXT UNIQUE,
                       created_at TIMESTAMP
);

-- Task 3.2: Multi-Column UNIQUE
CREATE TABLE course_enrollments (
                                    enrollment_id INTEGER,
                                    student_id INTEGER,
                                    course_code TEXT,
                                    semester TEXT,
                                    UNIQUE (student_id, course_code, semester)
);

-- Task 3.3: Named UNIQUE Constraints

-- Remove automatically named constraints
ALTER TABLE users
    DROP CONSTRAINT users_username_key;

ALTER TABLE users
    DROP CONSTRAINT users_email_key;

-- Add named UNIQUE constraints
ALTER TABLE users
    ADD CONSTRAINT unique_username UNIQUE (username);

ALTER TABLE users
    ADD CONSTRAINT unique_email UNIQUE (email);

-- VALID: different usernames and emails
INSERT INTO users
VALUES (1, 'alex', 'alex@gmail.com', CURRENT_TIMESTAMP);

INSERT INTO users
VALUES (2, 'bob', 'bob@gmail.com', CURRENT_TIMESTAMP);

-- INVALID: duplicate username 'alex'
-- Violates unique_username
-- INSERT INTO users
-- VALUES (3, 'alex', 'john@gmail.com', CURRENT_TIMESTAMP);

-- INVALID: duplicate email 'bob@gmail.com'
-- Violates unique_email
-- INSERT INTO users
-- VALUES (4, 'john', 'bob@gmail.com', CURRENT_TIMESTAMP);

-- Check inserted records
SELECT * FROM users;

-- PART 4: PRIMARY KEY CONSTRAINTS


-- Task 4.1: Single-column Primary Key

CREATE TABLE departments (
                             dept_id INTEGER PRIMARY KEY,
                             dept_name TEXT NOT NULL,
                             location TEXT
);

INSERT INTO departments VALUES
                            (1, 'Engineering', 'Almaty'),
                            (2, 'Finance', 'Astana'),
                            (3, 'HR', 'Shymkent');

-- INVALID: dept_id = 1 already exists.
-- Violates PRIMARY KEY (duplicate ID).
-- INSERT INTO departments VALUES (1, 'Marketing', 'Almaty');

-- INVALID: PRIMARY KEY cannot be NULL.
-- INSERT INTO departments VALUES (NULL, 'Legal', 'Almaty');


-- Task 4.2: Composite Primary Key

CREATE TABLE student_courses (
                                 student_id INTEGER,
                                 course_id INTEGER,
                                 enrollment_date DATE,
                                 grade TEXT,
                                 CONSTRAINT pk_student_courses PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_courses VALUES
                                (101, 10, '2026-09-01', 'A'),
                                (101, 20, '2026-09-01', 'B'),
                                (102, 10, '2026-09-02', 'A');

-- INVALID: pair (101, 10) already exists.
-- Violates pk_student_courses.
-- INSERT INTO student_courses
-- VALUES (101, 10, '2026-09-03', 'C');


-- Task 4.3: Comparison Exercise

-- 1. PRIMARY KEY uniquely identifies each row and
--    does not allow NULL.
--    UNIQUE prevents duplicates but normally allows
--    multiple NULL values in PostgreSQL.

-- 2. Single-column PRIMARY KEY uses one column
--    to identify a row, for example dept_id.
--    Composite PRIMARY KEY uses multiple columns,
--    for example (student_id, course_id).

-- 3. A table can have only one PRIMARY KEY because
--    it defines the primary identity of each row.
--    Multiple UNIQUE constraints can be used
--    to protect other columns from duplicates.


-- PART 5: FOREIGN KEY CONSTRAINTS


-- Task 5.1: Basic Foreign Key

CREATE TABLE employees_dept (
                                emp_id INTEGER PRIMARY KEY,
                                emp_name TEXT NOT NULL,
                                dept_id INTEGER REFERENCES departments(dept_id),
                                hire_date DATE
);

INSERT INTO employees_dept VALUES
                               (1, 'Aigerim', 1, '2026-02-10'),
                               (2, 'Daniyar', 2, '2026-03-15');

-- INVALID: department 999 does not exist.
-- Violates FOREIGN KEY.
-- INSERT INTO employees_dept
-- VALUES (3, 'John', 999, '2026-04-01');


-- Task 5.2: Multiple Foreign Keys

CREATE TABLE authors (
                         author_id INTEGER PRIMARY KEY,
                         author_name TEXT NOT NULL,
                         country TEXT
);

CREATE TABLE publishers (
                            publisher_id INTEGER PRIMARY KEY,
                            publisher_name TEXT NOT NULL,
                            city TEXT
);

CREATE TABLE books (
                       book_id INTEGER PRIMARY KEY,
                       title TEXT NOT NULL,
                       author_id INTEGER REFERENCES authors(author_id),
                       publisher_id INTEGER REFERENCES publishers(publisher_id),
                       publication_year INTEGER,
                       isbn TEXT UNIQUE
);

INSERT INTO authors VALUES
                        (1, 'George Orwell', 'United Kingdom'),
                        (2, 'Jane Austen', 'United Kingdom');

INSERT INTO publishers VALUES
                           (1, 'North Press', 'London'),
                           (2, 'East Books', 'Almaty');

INSERT INTO books VALUES
                      (1, 'Nineteen Eighty-Four', 1, 1, 1949, '9780000000001'),
                      (2, 'Pride and Prejudice', 2, 2, 1813, '9780000000002');

-- INVALID: author 999 does not exist.
-- Violates FOREIGN KEY.
-- INSERT INTO books
-- VALUES (3, 'Unknown Book', 999, 1, 2026, '9780000000003');


-- Task 5.3: ON DELETE Options
-- Separate schema avoids conflicting table names.

CREATE SCHEMA fk_demo;

CREATE TABLE fk_demo.categories (
                                    category_id INTEGER PRIMARY KEY,
                                    category_name TEXT NOT NULL
);

CREATE TABLE fk_demo.products_fk (
                                     product_id INTEGER PRIMARY KEY,
                                     product_name TEXT NOT NULL,
                                     category_id INTEGER REFERENCES fk_demo.categories(category_id)
                                         ON DELETE RESTRICT
);

CREATE TABLE fk_demo.orders (
                                order_id INTEGER PRIMARY KEY,
                                order_date DATE NOT NULL
);

CREATE TABLE fk_demo.order_items (
                                     item_id INTEGER PRIMARY KEY,
                                     order_id INTEGER REFERENCES fk_demo.orders(order_id)
                                         ON DELETE CASCADE,
                                     product_id INTEGER REFERENCES fk_demo.products_fk(product_id),
                                     quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO fk_demo.categories VALUES
                                   (1, 'Electronics'),
                                   (2, 'Stationery');

INSERT INTO fk_demo.products_fk VALUES
                                    (1, 'Mouse', 1),
                                    (2, 'Notebook', 2);

INSERT INTO fk_demo.orders VALUES
                               (1, '2026-10-14'),
                               (2, '2026-10-15');

INSERT INTO fk_demo.order_items VALUES
                                    (1, 1, 1, 2),
                                    (2, 1, 2, 1),
                                    (3, 2, 1, 1);

-- RESTRICT TEST:
-- Cannot delete category 1 because products reference it.
-- DELETE FROM fk_demo.categories WHERE category_id = 1;

-- CASCADE TEST:
-- Deleting order 1 automatically deletes its order_items.
SELECT * FROM fk_demo.order_items ORDER BY item_id;

DELETE FROM fk_demo.orders WHERE order_id = 1;

SELECT * FROM fk_demo.order_items ORDER BY item_id;

-- Expected: before DELETE = 3 rows.
-- After DELETE =


-- PART 6: E-COMMERCE DATABASE


-- Separate schema to avoid conflicts.
CREATE SCHEMA shop;

-- Task 6.1

CREATE TABLE shop.customers (
                                customer_id INTEGER PRIMARY KEY,
                                name TEXT NOT NULL,
                                email TEXT NOT NULL UNIQUE,
                                phone TEXT,
                                registration_date DATE NOT NULL
);

CREATE TABLE shop.products (
                               product_id INTEGER PRIMARY KEY,
                               name TEXT NOT NULL,
                               description TEXT,
                               price NUMERIC(12, 2) NOT NULL CHECK (price >= 0),
                               stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE shop.orders (
                             order_id INTEGER PRIMARY KEY,
                             customer_id INTEGER NOT NULL
                                 REFERENCES shop.customers(customer_id)
                                     ON DELETE RESTRICT,
                             order_date DATE NOT NULL,
                             total_amount NUMERIC(12, 2) NOT NULL CHECK (total_amount >= 0),
                             status TEXT NOT NULL CHECK (
                                 status IN (
                                            'pending',
                                            'processing',
                                            'shipped',
                                            'delivered',
                                            'cancelled'
                                     )
                                 )
);

CREATE TABLE shop.order_details (
                                    order_detail_id INTEGER PRIMARY KEY,
                                    order_id INTEGER NOT NULL
                                        REFERENCES shop.orders(order_id)
                                            ON DELETE CASCADE,
                                    product_id INTEGER NOT NULL
                                        REFERENCES shop.products(product_id)
                                            ON DELETE RESTRICT,
                                    quantity INTEGER NOT NULL CHECK (quantity > 0),
                                    unit_price NUMERIC(12, 2) NOT NULL CHECK (unit_price >= 0)
);


-- INSERT SAMPLE DATA

INSERT INTO shop.customers VALUES
                               (1, 'Alex', 'alex@example.com', '87001000001', '2026-09-01'),
                               (2, 'Bob', 'bob@example.com', NULL, '2026-09-02'),
                               (3, 'Aigerim', 'aigerim@example.com', '87001000003', '2026-09-03'),
                               (4, 'Dana', 'dana@example.com', NULL, '2026-09-04'),
                               (5, 'Timur', 'timur@example.com', '87001000005', '2026-09-05');

INSERT INTO shop.products VALUES
                              (1, 'Mouse', 'Wireless mouse', 5000, 25),
                              (2, 'Keyboard', 'Mechanical keyboard', 12000, 10),
                              (3, 'Monitor', '24 inch monitor', 75000, 8),
                              (4, 'USB cable', 'USB-C cable', 2000, 40),
                              (5, 'Laptop stand', 'Adjustable stand', 9000, 15);

INSERT INTO shop.orders VALUES
                            (1, 1, '2026-10-01', 10000, 'pending'),
                            (2, 2, '2026-10-02', 12000, 'processing'),
                            (3, 3, '2026-10-03', 75000, 'shipped'),
                            (4, 4, '2026-10-04', 6000, 'delivered'),
                            (5, 5, '2026-10-05', 9000, 'cancelled');

INSERT INTO shop.order_details VALUES
                                   (1, 1, 1, 2, 5000),
                                   (2, 2, 2, 1, 12000),
                                   (3, 3, 3, 1, 75000),
                                   (4, 4, 4, 3, 2000),
                                   (5, 5, 5, 1, 9000);


-- TEST QUERIES

SELECT * FROM shop.customers;
SELECT * FROM shop.products;
SELECT * FROM shop.orders;
SELECT * FROM shop.order_details;


-- INVALID: duplicate email violates UNIQUE.
-- INSERT INTO shop.customers
-- VALUES (6, 'Sam', 'alex@example.com', NULL, '2026-10-06');

-- INVALID: name cannot be NULL.
-- INSERT INTO shop.customers
-- VALUES (6, NULL, 'sam@example.com', NULL, '2026-10-06');

-- INVALID: price cannot be negative.
-- INSERT INTO shop.products
-- VALUES (6, 'Broken Price', NULL, -1, 1);

-- INVALID: stock_quantity cannot be negative.
-- INSERT INTO shop.products
-- VALUES (6, 'Negative Stock', NULL, 100, -2);

-- INVALID: 'returned' is not an allowed order status.
-- INSERT INTO shop.orders
-- VALUES (6, 1, '2026-10-06', 100, 'returned');

-- INVALID: customer 999 does not exist.
-- INSERT INTO shop.orders
-- VALUES (6, 999, '2026-10-06', 100, 'pending');

-- INVALID: quantity must be greater than 0.
-- INSERT INTO shop.order_details
-- VALUES (6, 1, 1, 0, 5000);

-- INVALID: order 999 does not exist.
-- INSERT INTO shop.order_details
-- VALUES (6, 999, 1, 1, 5000);

-- INVALID: duplicate PRIMARY KEY.
-- INSERT INTO shop.order_details
-- VALUES (1, 2, 2, 1, 12000);


-- ON DELETE RESTRICT:
-- Cannot delete a product referenced by order_details.
-- DELETE FROM shop.products WHERE product_id = 1;

-- Cannot delete a customer with existing orders.
-- DELETE FROM shop.customers WHERE customer_id = 1;


-- ON DELETE CASCADE:
-- Deleting an order deletes its order_details.
-- ROLLBACK restores the original data.

BEGIN;

DELETE FROM shop.orders WHERE order_id = 1;

SELECT COUNT(*) AS remaining_details_for_order_1
FROM shop.order_details
WHERE order_id = 1;

-- Expected result: 0

ROLLBACK;



