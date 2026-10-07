CREATE TABLE employees (
                           employee_id SERIAL PRIMARY KEY,
                           first_name VARCHAR(50),
                           last_name VARCHAR(50),
                           department VARCHAR(50),
                           salary NUMERIC(10,2),
                           hire_date DATE,
                           manager_id INTEGER,
                           email VARCHAR(100)
);

CREATE TABLE projects (
                          project_id SERIAL PRIMARY KEY,
                          project_name VARCHAR(100),
                          budget NUMERIC(12,2),
                          start_date DATE,
                          end_date DATE,
                          status VARCHAR(20)
);

CREATE TABLE assignments (
                             assignment_id SERIAL PRIMARY KEY,
                             employee_id INTEGER REFERENCES employees(employee_id),
                             project_id INTEGER REFERENCES projects(project_id),
                             hours_worked NUMERIC(5,1),
                             assignment_date DATE
);
INSERT INTO employees
(first_name, last_name, department, salary, hire_date, manager_id, email)
VALUES
    ('John', 'Smith', 'IT', 75000, '2020-01-15', NULL, 'john.smith@company.com'),
    ('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1, 'sarah.j@company.com'),
    ('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL, 'mbrown@company.com'),
    ('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL, 'emily.davis@company.com'),
    ('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
    ('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3, 'lisa.a@company.com');

INSERT INTO projects
(project_name, budget, start_date, end_date, status)
VALUES
    ('Website Redesign', 150000, '2024-01-01', '2024-06-30', 'Active'),
    ('CRM Implementation', 200000, '2024-02-15', '2024-12-31', 'Active'),
    ('Marketing Campaign', 80000, '2024-03-01', '2024-05-31', 'Completed'),
    ('Database Migration', 120000, '2024-01-10', NULL, 'Active');

INSERT INTO assignments
(employee_id, project_id, hours_worked, assignment_date)
VALUES
    (1, 1, 120.5, '2024-01-15'),
    (2, 1, 95.0, '2024-01-20'),
    (1, 4, 80.0, '2024-02-01'),
    (3, 3, 60.0, '2024-03-05'),
    (5, 2, 110.0, '2024-02-20'),
    (6, 3, 75.5, '2024-03-10');
--CHECK OF TABLE
SELECT * FROM employees;
SELECT * FROM projects;
SELECT * FROM assignments;
--TASK 1.1
SELECT
    first_name || ' ' || last_name as full_name,
    department,
    salary
from employees;
--TASK 1.2
select distinct department
from employees;
--TASK 1.3
select
    project_name,
    budget,
    case
        when budget>150000 then 'Large'
        when budget between 100000 and 150000 then'Medium'
        else 'Small'
        End as budget_category
from projects;
--task 1.4
select
    first_name || ' ' || last_name as full_name,
    coalesce(email,'No email provided') as email
from employees;
--task2.1
select * from employees
where hire_date>'2020-01-01';
--task2.2
select * from employees
where salary between 60000 and 70000;
--TASK2.3

select * from employees
where last_name like 'S%' or last_name like'J%';
0
--task2.4
select * from employees
where manager_id is not null and department = 'IT';
--task3.1
select
    upper(first_name),
    length(last_name),
    substring(email from 1 for 3)
FROM employees;
-- task3.2
select
    salary * 12 as Annual,
    salary as monthly,
    salary * 0.1 + salary as raisen
from employees;
--task3.3
select
    format(
            'Project: %s - Budget: $%s - Status: %s'
        ,
    project_name,
    budget,
    status

    )
from projects;
-- task3.4
select
    first_name ||' '||last_name,
    extract(years from age(current_date,hire_date))
from employees;
-- task4.1

select department,
       avg(salary)
from employees
group by department;
-- task4.2
select p.project_name,
       sum(a.hours_worked)
from projects p
join assignments a
on a.project_id=p.project_id
group by p.project_id;
--task4.3
select department,
       count(*)
from  employees
group by department
having count(*)>1;
--task4.4
SELECT
    MAX(salary) AS max_salary,
    MIN(salary) AS min_salary,
    SUM(salary) AS total_payroll
FROM employees;
-- Task 5.1
SELECT
    employee_id,
    first_name || ' ' || last_name AS full_name,
    salary
FROM employees
WHERE salary > 65000

UNION

SELECT
    employee_id,
    first_name || ' ' || last_name AS full_name,
    salary
FROM employees
WHERE hire_date > '2020-01-01';


-- Task 5.2
SELECT employee_id, first_name, last_name
FROM employees
WHERE department = 'IT'

INTERSECT

SELECT employee_id, first_name, last_name
FROM employees
WHERE salary > 65000;


-- Task 5.3
SELECT employee_id, first_name, last_name
FROM employees

EXCEPT

SELECT
    e.employee_id,
    e.first_name,
    e.last_name
FROM employees e
         JOIN assignments a
              ON e.employee_id = a.employee_id;


-- Task 6.1
SELECT *
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM assignments a
    WHERE a.employee_id = e.employee_id
);


-- Task 6.2
SELECT *
FROM employees
WHERE employee_id IN (
    SELECT a.employee_id
    FROM assignments a
             JOIN projects p
                  ON a.project_id = p.project_id
    WHERE p.status = 'Active'
);


-- Task 6.3
SELECT *
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department = 'Sales'
);


-- Task 7.1
SELECT
    e.first_name || ' ' || e.last_name AS employee_name,
    e.department,
    x.avg_hours,
    RANK() OVER (
        PARTITION BY e.department
        ORDER BY e.salary DESC
        ) AS salary_rank
FROM employees e
         LEFT JOIN (
    SELECT
        employee_id,
        AVG(hours_worked) AS avg_hours
    FROM assignments
    GROUP BY employee_id
) x
                   ON e.employee_id = x.employee_id;


-- Task 7.2
SELECT
    p.project_name,
    SUM(a.hours_worked) AS total_hours,
    COUNT(DISTINCT a.employee_id) AS employee_count
FROM projects p
         JOIN assignments a
              ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name
HAVING SUM(a.hours_worked) > 150;


-- Task 7.3
SELECT
    e.department,
    COUNT(*) AS total_employees,
    AVG(e.salary) AS average_salary,

    (
        SELECT e2.first_name || ' ' || e2.last_name
        FROM employees e2
        WHERE e2.department = e.department
        ORDER BY e2.salary DESC
        LIMIT 1
    ) AS highest_paid_employee,

    GREATEST(MIN(e.salary), MAX(e.salary)) AS highest_salary,
    LEAST(MIN(e.salary), MAX(e.salary)) AS lowest_salary

FROM employees e
GROUP BY e.department;


