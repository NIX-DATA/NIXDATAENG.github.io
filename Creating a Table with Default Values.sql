CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    hire_date DATE DEFAULT CURRENT_DATE,
    job_title VARCHAR(100) DEFAULT 'New Hire',
    salary DECIMAL(10, 2) DEFAULT 50000.00
);