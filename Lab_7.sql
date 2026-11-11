-- Create table: employees
drop table if exists employees;
drop table if exists departments;
drop table if exists projects;
CREATE TABLE employees (
                           emp_id INT PRIMARY KEY,
                           emp_name VARCHAR(50),
                           dept_id INT,
                           salary DECIMAL(10, 2)
);
-- Create table: departments
CREATE TABLE departments (
                             dept_id INT PRIMARY KEY,
                             dept_name VARCHAR(50),
                             location VARCHAR(50)
);
-- Create table: projects
CREATE TABLE projects (
                          project_id INT PRIMARY KEY,
                          project_name VARCHAR(50),
                          dept_id INT,
                          budget DECIMAL(10, 2)
);
-- Task 1: Database setup (Lab 6 tables)
SELECT * FROM employees;
SELECT * FROM departments;
SELECT * FROM projects;


-- Task 2: Creating basic views

-- Task 2.1: Simple view creation
CREATE OR REPLACE VIEW employee_details AS
SELECT e.emp_name, e.salary, d.dept_name, d.location
FROM employees AS e
         INNER JOIN departments AS d ON d.dept_id = e.dept_id;
SELECT * FROM employee_details;


-- Task 2.2: Aggregation (including empty departments)
CREATE OR REPLACE VIEW dept_statistics AS
SELECT d.dept_name,
       COUNT(e.emp_id) AS employee_count,
       AVG(e.salary) AS average_salary,
       MAX(e.salary) AS maximum_salary,
       MIN(e.salary) AS minimum_salary
FROM departments AS d
         LEFT JOIN employees AS e ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name;
SELECT * FROM dept_statistics ORDER BY employee_count DESC;


-- Task 2.3: Multiple joins / department team size
CREATE OR REPLACE VIEW project_overview AS
SELECT p.project_name, p.budget, d.dept_name, d.location,
       COUNT(e.emp_id) AS team_size
FROM projects AS p
         JOIN departments AS d ON d.dept_id = p.dept_id
         LEFT JOIN employees AS e ON e.dept_id = d.dept_id
GROUP BY p.project_id, p.project_name, p.budget, d.dept_id, d.dept_name, d.location;
SELECT * FROM project_overview;


-- Task 2.4: Filtered view
CREATE OR REPLACE VIEW high_earners AS
SELECT e.emp_name, e.salary, d.dept_name
FROM employees AS e
         LEFT JOIN departments AS d ON d.dept_id = e.dept_id
WHERE e.salary > 55000;
SELECT * FROM high_earners;


-- Task 3: Modifying and managing views

-- Task 3.1: Add grade at the end, preserving existing view columns
CREATE OR REPLACE VIEW employee_details AS
SELECT e.emp_name, e.salary, d.dept_name, d.location,
       CASE
           WHEN e.salary > 60000 THEN 'High'
           WHEN e.salary > 50000 THEN 'Medium'
           ELSE 'Standard'
           END AS salary_grade
FROM employees AS e
         INNER JOIN departments AS d ON d.dept_id = e.dept_id;
SELECT * FROM employee_details;


-- Task 3.2: Rename a view
    ALTER VIEW high_earners RENAME TO top_performers;
SELECT * FROM top_performers;


-- Task 3.3: Create and drop temporary example view
CREATE VIEW temp_view AS
SELECT * FROM employees WHERE salary < 50000;
SELECT * FROM temp_view;
DROP VIEW temp_view;


-- Task 4: Updatable views

-- Task 4.1: Simple updatable view
CREATE OR REPLACE VIEW employee_salaries AS
SELECT emp_id, emp_name, dept_id, salary FROM employees;
SELECT * FROM employee_salaries;


-- Task 4.2: Update John Smith through view
UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';
SELECT * FROM employees WHERE emp_name = 'John Smith';


-- Task 4.3: Insert through view
INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000);
SELECT * FROM employees WHERE emp_id = 6;


-- Task 4.4: LOCAL CHECK OPTION
CREATE OR REPLACE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
        WITH LOCAL CHECK OPTION;
SELECT * FROM it_employees;
-- INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
-- VALUES (7, 'Bob Wilson', 103, 60000);


-- Task 5: Materialized views

-- Task 5.1: Materialized department summary, with no row multiplication
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT d.dept_id, d.dept_name,
       COALESCE(e.total_employees, 0) AS total_employees,
       COALESCE(e.total_salaries, 0) AS total_salaries,
       COALESCE(p.total_projects, 0) AS total_projects,
       COALESCE(p.total_project_budget, 0) AS total_project_budget
FROM departments AS d
         LEFT JOIN (
    SELECT dept_id, COUNT(*) AS total_employees, SUM(salary) AS total_salaries
    FROM employees GROUP BY dept_id
) AS e ON e.dept_id = d.dept_id
         LEFT JOIN (
    SELECT dept_id, COUNT(*) AS total_projects, SUM(budget) AS total_project_budget
    FROM projects GROUP BY dept_id
) AS p ON p.dept_id = d.dept_id
WITH DATA;
SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;