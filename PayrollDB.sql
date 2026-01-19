CREATE DATABASE IF NOT EXISTS Payroll;
USE Payroll;

CREATE TABLE departments (
    id INT NOT NULL,
    name VARCHAR(45) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE jobs (
    id INT NOT NULL,
    title VARCHAR(45) NOT NULL,
    type VARCHAR(45) NOT NULL,
    hourly_rate FLOAT(5,2) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE insurance_benefits (
    id INT NOT NULL,
    job_id INT NOT NULL,
    annual_insurance FLOAT(7,2),
    PRIMARY KEY (id),
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE
);

CREATE TABLE employees (
    id INT NOT NULL,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    department_id INT,
    job_id INT,
    date_employee DATE,
    PRIMARY KEY (id),
    FOREIGN KEY (department_id) REFERENCES departments(id)  ON DELETE CASCADE,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE
);