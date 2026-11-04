DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS projects;


-- Create table: employees
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

-- Insert data into employees
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
    (1, 'John Smith', 101, 50000),
    (2, 'Jane Doe', 102, 60000),
    (3, 'Mike Johnson', 101, 55000),
    (4, 'Sarah Williams', 103, 65000),
    (5, 'Tom Brown', NULL, 45000);
-- Insert data into departments
INSERT INTO departments (dept_id, dept_name, location) VALUES
                                                           (101, 'IT', 'Building A'),
                                                           (102, 'HR', 'Building B'),
                                                           (103, 'Finance', 'Building C'),
                                                           (104, 'Marketing', 'Building D');
-- Insert data into projects
INSERT INTO projects (project_id, project_name, dept_id,
                      budget) VALUES
                                  (1, 'Website Redesign', 101, 100000),
                                  (2, 'Employee Training', 102, 50000),
                                  (3, 'Budget Analysis', 103, 75000),
                                  (4, 'Cloud Migration', 101, 150000),
                                  (5, 'AI Research', NULL, 200000);

select * from departments;
select * from employees;
select * from projects;
--TASK 2.1
--Answer : 5*4=20
select e.emp_name, d.dept_name
from employees e cross join departments d;
--TASK 2.2
select e.emp_name , d.dept_name
from employees e, departments d;

select e.emp_name , d.dept_name
from employees e inner join departments d on true;
--TASK 2.3
select e.emp_name , p.project_name
from employees e inner join projects p on true;
--Part 3: INNER JOIN Exercise
--Exercise 3.1:
select e.emp_name,d.dept_name
from employees e inner join departments d using(dept_id);
-- Your query here
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
         INNER JOIN departments d ON e.dept_id = d.dept_id;
--Answer: return 4 rows, Tom Brown does not have dept_id
--Exercise 3.2: INNER JOIN with USING
select e.emp_name,d.dept_name, d.location
from employees e inner join departments d using(dept_id);-- In the previous query, we manually specified
-- which columns should match using ON.
-- Here, both tables have a column named dept_id,
-- so we can use USING (dept_id) instead.
-- SQL automatically matches rows based on this column.

--Exercise 3.3: NATURAL INNER JOIN
select emp_name , dept_name, location
from employees natural inner join departments;
--Exercise 3.4: Multi-table INNER JOIN
--Join all three tables to show: employee name, department name, and project name.
select e.emp_name,d.dept_name,p.project_name
from departments d
inner join projects p on d.dept_id = p.dept_id
inner join employees e on d.dept_id=e.dept_id;

--Exercise 4.1: Basic LEFT JOIN
--Write a query to show all employees with their department information, including employees
--without a department.
select * from employees
left join departments on employees.dept_id=departments.dept_id;
--answer:because we use left join which represent all rows from left table, even if we do not find matching from right.

--TASK 4.2
select * from employees
left join departments using(dept_id);

--Exercise 4.3: Find Unmatched Records
--Write a query to find employees who are NOT assigned to any department.
select e.emp_name
from employees e
left join departments d using(dept_id)
where d.dept_name is null;
--Exercise 4.4: LEFT JOIN with Aggregation
--Show all departments with the count of employees in each department (include departments with 0
--employees)
select d.dept_name , count(e.emp_id) as emp_count
from departments d
left join employees e using(dept_id)
group by dept_name
order by emp_count desc;
--Exercise 5.1: Basic RIGHT JOIN
--Write a query to show all departments with their employees, including departments without
--employees.
select e.emp_name,d.dept_name
from employees e
right join departments d using (dept_id);

--5.2 TASK
select e.emp_name,d.dept_name
from departments d
         left join employees e using (dept_id);
--Exercise 5.3: Find Departments Without Employees
--Write a query to identify departments that have no employees assigned
select d.dept_name , e.emp_id
from employees e
natural right join departments d
where e.emp_id is null;
--Part 6: FULL JOIN Exercises
--Exercise 6.1: Basic FULL JOIN
--Write a query to show all employees and all departments, with NULL values where there's no
--match.
select e.emp_name , d.dept_name
from employees e
full join departments d  using(dept_id);
--Answer: from left side not have employee for Marketing, from right side no have department for Tom Brown.

--Exercise 6.2: FULL JOIN with Projects
--Show all departments and all projects, including those without matches
select d.dept_name , p.project_name
from departments d natural full join projects p;

--6.3 TASK
select e.emp_name, d.dept_name
from departments d natural full join employees e
where d.dept_id is null or e.emp_id is null;

--Part 7: ON vs WHERE Clause
--Exercise 7.1: Filtering in ON Clause (Outer Join)
--Write a query using LEFT JOIN with an additional condition in the ON clause.

SELECT e.emp_name, d.dept_name
FROM employees e
         LEFT JOIN departments d
                   ON e.dept_id = d.dept_id
                       AND d.location = 'Building A';
--Exercise 7.2: Filtering in WHERE Clause (Outer Join)
--Write the same query but move the location filter to the WHERE clause.
SELECT e.emp_name, d.dept_name
FROM employees e
         LEFT JOIN departments d
                   ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
--Answer:
--Query 1 (ON clause): Applies the filter BEFORE the join, so all employees are included, bu
--only departments in Building A are matched.

--Query 2 (WHERE clause): Applies the filter AFTER the join, so employees are excluded i
--their department is not in Building A.

--7.3 TASK
SELECT e.emp_name, d.dept_name
FROM employees e
         INNER JOIN departments d
                    ON e.dept_id = d.dept_id
                        AND d.location = 'Building A';

SELECT e.emp_name, d.dept_name
FROM employees e
         INNER JOIN departments d
                    ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
--Answer:No, there is no difference in the results.
--Both queries return only employees whose departments are located in Building A.
--This is because INNER JOIN returns only matching rows.
--The condition in the ON clause restricts which rows can be joined, while the condition in the WHERE clause filters the joined rows.
--In this case, both approaches produce the same result.
-- Part 8: Complex JOIN Scenarios

-- Exercise 8.1: Multiple Joins with Different Types

SELECT
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
FROM departments d
         LEFT JOIN employees e ON d.dept_id = e.dept_id
         LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;


-- Exercise 8.2: Self Join

ALTER TABLE employees ADD COLUMN manager_id INT;

UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

SELECT
    e.emp_name AS employee,
    m.emp_name AS manager
FROM employees e
         LEFT JOIN employees m ON e.manager_id = m.emp_id;


-- Exercise 8.3: Join with Subquery

SELECT
    d.dept_name,
    AVG(e.salary) AS avg_salary
FROM departments d
         INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;
--Answer
--INNER JOIN vs LEFT JOIN: INNER returns only matching rows. LEFT returns all left-table rows, even without matches.

--CROSS JOIN: Used to generate all possible combinations of rows.

--ON vs WHERE: ON controls matching; WHERE filters results. In OUTER JOIN, WHERE may remove unmatched rows.

--CROSS JOIN COUNT: 5 × 10 = 50 rows.

--NATURAL JOIN: Automatically joins columns with identical names.

--NATURAL JOIN risks: May join unintended columns and produce unexpected results.

--LEFT to RIGHT JOIN:

--SELECT * FROM B RIGHT JOIN A ON A.id = B.id;

--FULL OUTER JOIN: Used to return all rows from both tables, including unmatched rows.