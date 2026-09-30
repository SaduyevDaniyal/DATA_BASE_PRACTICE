-- TASK 1

CREATE DATABASE advanced_lab;

-- After creating the database, connect to advanced_lab.

CREATE TABLE employees (
                           emp_id SERIAL PRIMARY KEY,
                           first_name VARCHAR(50),
                           last_name VARCHAR(50),
                           department VARCHAR(100) DEFAULT 'Unassigned',
                           salary INTEGER DEFAULT 50000,
                           hire_date DATE,
                           status VARCHAR(50) DEFAULT 'Active'
);

CREATE TABLE departments (
                             dept_id SERIAL PRIMARY KEY,
                             dept_name VARCHAR(100),
                             budget INTEGER,
                             manager_id INTEGER
);

CREATE TABLE projects (
                          project_id SERIAL PRIMARY KEY,
                          project_name VARCHAR(100),
                          dept_id INTEGER,
                          start_date DATE,
                          end_date DATE,
                          budget INTEGER
);


-- TASK 2

INSERT INTO employees (
    emp_id,
    first_name,
    last_name,
    department
)
VALUES (
           1,
           'John',
           'Smith',
           'IT'
       );


-- TASK 3

INSERT INTO employees (
    first_name,
    last_name,
    salary,
    status
)
VALUES (
           'Anna',
           'Brown',
           DEFAULT,
           DEFAULT
       );


-- TASK 4

INSERT INTO departments (
    dept_name,
    budget,
    manager_id
)
VALUES
    ('IT', 150000, 1),
    ('Sales', 90000, 2),
    ('HR', 70000, 3);


-- TASK 5

INSERT INTO employees (
    first_name,
    last_name,
    department,
    salary,
    hire_date
)
VALUES (
           'David',
           'Wilson',
           'IT',
           50000 * 1.1,
           CURRENT_DATE
       );


-- TASK 6

CREATE TEMP TABLE temp_employees AS
SELECT *
FROM employees
WHERE department = 'IT';


-- TASK 7

UPDATE employees
SET salary = salary * 1.10;


-- TASK 8

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';


-- TASK 9
-- CASE checks conditions from top to bottom.

UPDATE employees
SET department =
        CASE
            WHEN salary > 80000 THEN 'Management'
            WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
            ELSE 'Junior'
            END;


-- TASK 10

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';


-- TASK 11
-- Each department receives a budget equal to
-- 120% of the average salary in that department.

UPDATE departments d
SET budget = (
    SELECT AVG(e.salary) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
)
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department = d.dept_name
);


-- TASK 12

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';


-- TASK 13

DELETE FROM employees
WHERE status = 'Terminated';


-- TASK 14

DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;


-- TASK 15
-- employees.department stores the department name,
-- while departments.dept_id is an integer.
-- Therefore dept_name must be compared with department.

DELETE FROM departments d
WHERE NOT EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department = d.dept_name
);


-- TASK 16

DELETE FROM projects
WHERE end_date < '2023-01-01'
    RETURNING *;


-- TASK 17

INSERT INTO employees (
    first_name,
    last_name,
    salary,
    department
)
VALUES (
           'Michael',
           'Green',
           NULL,
           NULL
       );


-- TASK 18

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;


-- TASK 19

DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;


-- TASK 20

INSERT INTO employees (
    first_name,
    last_name,
    department,
    salary,
    hire_date
)
VALUES (
           'Robert',
           'Taylor',
           'IT',
           65000,
           CURRENT_DATE
       )
    RETURNING
    emp_id,
    first_name || ' ' || last_name AS full_name;


-- TASK 21
-- Save the old salary first, then perform the update
-- so both old and new values can be returned.

WITH old_data AS (
    SELECT
        emp_id,
        salary AS old_salary
    FROM employees
    WHERE department = 'IT'
)
UPDATE employees e
SET salary = e.salary + 5000
    FROM old_data o
WHERE e.emp_id = o.emp_id
    RETURNING
    e.emp_id,
    o.old_salary,
    e.salary AS new_salary;


-- TASK 22

DELETE FROM employees
WHERE hire_date < '2020-01-01'
    RETURNING *;


-- TASK 23
-- Insert only if an employee with the same
-- first and last name does not already exist.

INSERT INTO employees (
    first_name,
    last_name,
    department,
    salary,
    hire_date
)
SELECT
    'James',
    'Anderson',
    'IT',
    60000,
    CURRENT_DATE
    WHERE NOT EXISTS (
    SELECT 1
    FROM employees
    WHERE first_name = 'James'
      AND last_name = 'Anderson'
);


-- TASK 24
-- Salary increase depends on the budget
-- of the employee's department.

UPDATE employees e
SET salary =
        CASE
            WHEN d.budget > 100000
                THEN e.salary * 1.10
            ELSE e.salary * 1.05
            END
    FROM departments d
WHERE e.department = d.dept_name;


-- TASK 25

INSERT INTO employees (
    first_name,
    last_name,
    department,
    salary,
    hire_date
)
VALUES
    ('Alice', 'White', 'IT', 50000, CURRENT_DATE),
    ('Bob', 'Black', 'IT', 52000, CURRENT_DATE),
    ('Charlie', 'Gray', 'Sales', 48000, CURRENT_DATE),
    ('Diana', 'Stone', 'HR', 55000, CURRENT_DATE),
    ('Edward', 'King', 'Sales', 60000, CURRENT_DATE);

UPDATE employees
SET salary = salary * 1.10
WHERE (first_name, last_name) IN (
                                  ('Alice', 'White'),
                                  ('Bob', 'Black'),
                                  ('Charlie', 'Gray'),
                                  ('Diana', 'Stone'),
                                  ('Edward', 'King')
    );


-- TASK 26
-- Copy inactive employees to the archive first,
-- then remove them from the original table.

CREATE TABLE employee_archive (
                                  LIKE employees INCLUDING ALL
);

INSERT INTO employee_archive
SELECT *
FROM employees
WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';


-- TASK 27
-- Extend only projects with budget > 50000
-- whose department has more than 3 employees.

UPDATE projects p
SET end_date = p.end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND (
    SELECT COUNT(*)
    FROM employees e
    JOIN departments d
    ON e.department = d.dept_name
    WHERE d.dept_id = p.dept_id
    ) > 3;