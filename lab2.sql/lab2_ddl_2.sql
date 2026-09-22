select table_name
from information_schema.tables
where table_schema = 'public';
drop table if exists students;
create database university_main;
create database universuty_archive;
create database university_test;
drop database university_main;
create database university_main
with
owner = postgres
template = template0
encoding = 'UTF8';
create database university_archive
with
template = template0
connection limit = 50;
create database university_test
with
connection limit = 10
is_template = true ;
drop database university_archive;
drop database university_test;

SELECT current_user;
SHOW data_directory;
SHOW port;
CREATE TABLESPACE student_data
    LOCATION '/Users/Shared/data/students';

CREATE TABLESPACE course_data
    OWNER postgres
    LOCATION '/Users/Shared/data/courses';
CREATE DATABASE university_distributed
    WITH
    TEMPLATE = template0
    ENCODING = 'LATIN9'
    TABLESPACE = student_data;
DROP DATABASE IF EXISTS universuty_archive;
DROP DATABASE IF EXISTS universiyy_archive;
CREATE DATABASE university_test
    WITH
    CONNECTION LIMIT = 10
    IS_TEMPLATE = true;
CREATE TABLE students (
                          student_id SERIAL PRIMARY KEY,
                          first_name VARCHAR(50),
                          last_name VARCHAR(50),
                          email VARCHAR(100),
                          phone CHAR(15),
                          date_of_birth DATE,
                          enrollment_date DATE,
                          gpa NUMERIC(4,2),
                          is_active BOOLEAN,
                          graduation_year SMALLINT
);
SELECT datname
FROM pg_database
ORDER BY datname;
select table_name
from information_schema.tables
where table_schema = 'public';
drop table students;
