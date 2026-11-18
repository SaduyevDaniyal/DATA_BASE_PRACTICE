-- Lab 8 - indexes
-- postgres

DROP SCHEMA IF EXISTS lab8 CASCADE;
CREATE SCHEMA lab8;
SET search_path TO lab8, public;

-- Part 1. database setup
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT,
    salary DECIMAL(10,2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

CREATE TABLE projects (
    proj_id INT PRIMARY KEY,
    proj_name VARCHAR(100),
    budget DECIMAL(12,2),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C');

INSERT INTO employees VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 101, 55000),
(3, 'Mike Johnson', 102, 48000),
(4, 'Sarah Williams', 102, 52000),
(5, 'Tom Brown', 103, 60000);

INSERT INTO projects VALUES
(201, 'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),
(203, 'HR System Upgrade', 50000, 102);

-- Part 2. creating basic indexes

-- Exercise 2.1: Simple B-tree index
CREATE INDEX emp_salary_idx ON employees(salary);

SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'lab8' AND tablename = 'employees';
-- 2.1: 2 indexes: primary key and salary index.

-- Exercise 2.2: Index on a foreign key
CREATE INDEX emp_dept_idx ON employees(dept_id);
SELECT * FROM employees WHERE dept_id = 101;
-- 2.2: index on dept_id helps search and joins.

-- Exercise 2.3: List indexes
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'lab8'
ORDER BY tablename, indexname;
-- 2.3: pkey indexes are automatic, other ones made by us.

-- Part 3. multicolumn indexes

-- Exercise 3.1
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);
SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;
-- 3.1: not really good for only salary, because dept_id goes first.

-- Exercise 3.2
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);
SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;
-- 3.2: yes, index column order matters. WHERE condition order does not.

-- Part 4. unique indexes

-- Exercise 4.1
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

DO $$
BEGIN
    BEGIN
        INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
        VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'Exercise 4.1: expected error: duplicate key value violates unique constraint emp_email_unique_idx';
    END;
END;
$$;
-- 4.1: duplicate email error (unique constraint).

-- Exercise 4.2
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'lab8'
  AND tablename = 'employees'
  AND indexname LIKE '%phone%';
-- 4.2: yes, unique automatically makes a btree index.

-- Part 5. indexes and sorting

-- Exercise 5.1
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);
SELECT emp_name, salary FROM employees ORDER BY salary DESC;
-- 5.1: can help with ORDER BY salary DESC.

-- Exercise 5.2
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);
SELECT proj_name, budget FROM projects ORDER BY budget NULLS FIRST;

-- Part 6. indexes on expressions

-- Exercise 6.1
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));
SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';
-- 6.1: without index it checks LOWER(name) on rows.

-- Exercise 6.2
ALTER TABLE employees ADD COLUMN hire_date DATE;
UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));
SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;

-- Part 7. managing indexes

-- Exercise 7.1
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;
SELECT indexname FROM pg_indexes
WHERE schemaname = 'lab8' AND tablename = 'employees';

-- Exercise 7.2
DROP INDEX emp_salary_dept_idx;
-- 7.2: remove unused indexes to save space and reduce write cost.

-- Exercise 7.3
REINDEX INDEX employees_salary_index;
-- 7.3: reindex rebuilds the index, for example if bloated.

-- Part 8. practical scenarios

-- Exercise 8.1
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

CREATE INDEX emp_salary_filter_idx ON employees(salary)
WHERE salary > 50000;

-- Exercise 8.2
CREATE INDEX proj_high_budget_idx ON projects(budget)
WHERE budget > 80000;
SELECT proj_name, budget FROM projects WHERE budget > 80000;
-- 8.2: partial index only stores rows matching WHERE.

-- Exercise 8.3
EXPLAIN SELECT * FROM employees WHERE salary > 52000;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM employees WHERE salary > 52000;
-- 8.3: Seq Scan means scanning table, Index Scan uses index. Small table may use Seq Scan.

-- Part 9. index types comparison

-- Exercise 9.1
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);
SELECT * FROM departments WHERE dept_name = 'IT';
-- 9.1: hash is for = only. Btree also supports ranges.

-- Exercise 9.2
CREATE INDEX proj_name_btree_idx ON projects(proj_name);
CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name);
SELECT * FROM projects WHERE proj_name = 'Website Redesign';
SELECT * FROM projects WHERE proj_name > 'Database';
-- 9.2: both for =, but only btree works with > and <.

-- Part 10. cleanup and best practices

-- Exercise 10.1
SELECT schemaname, tablename, indexname,
       pg_size_pretty(pg_relation_size(
           format('%I.%I', schemaname, indexname)::regclass
       )) AS index_size
FROM pg_indexes
WHERE schemaname = 'lab8'
ORDER BY tablename, indexname;
-- 10.1: check the size query result, it depends on data.

-- Exercise 10.2
DROP INDEX IF EXISTS proj_name_hash_idx;
-- 10.2: removed hash because btree already covers this search.

-- Exercise 10.3
CREATE VIEW index_documentation AS
SELECT tablename, indexname, indexdef,
       'Improves salary-based queries' AS purpose
FROM pg_indexes
WHERE schemaname = 'lab8'
  AND indexname LIKE '%salary%';
SELECT * FROM index_documentation;

-- questions
-- 1. btree
-- 2. WHERE, JOIN, ORDER BY
-- 3. small tables, rarely used columns
-- 4. indexes update too, so writing can be slower
-- 5. EXPLAIN

-- extra

-- Challenge 1: Index for finding hires in a specific month
CREATE INDEX emp_hire_month_idx
ON employees (EXTRACT(MONTH FROM hire_date));
SELECT emp_name, hire_date FROM employees
WHERE EXTRACT(MONTH FROM hire_date) = 1;

-- Challenge 2: Composite unique index on department and email
CREATE UNIQUE INDEX emp_dept_email_unique_idx
ON employees(dept_id, email);

-- Challenge 3: Compare actual query plans with and without index.
EXPLAIN (ANALYZE, BUFFERS)
SELECT emp_name, salary FROM employees WHERE salary > 52000;
BEGIN;
DROP INDEX employees_salary_index;
EXPLAIN (ANALYZE, BUFFERS)
SELECT emp_name, salary FROM employees WHERE salary > 52000;
ROLLBACK;

-- Challenge 4: Covering index for a specific query
CREATE INDEX emp_dept_cover_idx
ON employees(dept_id) INCLUDE (emp_name, salary);
EXPLAIN SELECT emp_name, salary FROM employees WHERE dept_id = 101;

-- conclusion
-- Indexes help search faster but take extra space.
-- It is better to add them for columns used often in queries.
-- EXPLAIN shows if the index was chosen.

-- check indexes
SELECT schemaname, tablename, indexname
FROM pg_indexes
WHERE schemaname = 'lab8'
ORDER BY tablename, indexname;
