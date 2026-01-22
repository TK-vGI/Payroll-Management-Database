/*
START STAGE 4
*/
DELIMITER $$

CREATE FUNCTION TaxOwed(income FLOAT)
RETURNS FLOAT(10,2)
DETERMINISTIC
BEGIN
    DECLARE tax FLOAT;

    IF income >= 578126 THEN
        SET tax = 174238.25 + (income - 578125) * 0.37;

    ELSEIF income >= 231251 THEN
        SET tax = 52832 + (income - 231250) * 0.35;

    ELSEIF income >= 182101 THEN
        SET tax = 37104 + (income - 182100) * 0.32;

    ELSEIF income >= 95376 THEN
        SET tax = 16290 + (income - 95375) * 0.24;

    ELSEIF income >= 44726 THEN
        SET tax = 5147 + (income - 44725) * 0.22;

    ELSEIF income >= 11001 THEN
        SET tax = 1100 + (income - 11000) * 0.12;

    ELSE
        SET tax = income * 0.10;
    END IF;

    RETURN tax;
END $$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION GetTotalHours(f_name VARCHAR(45), l_name VARCHAR(45))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE hours_worked INT;

    SELECT t.hours_worked
    INTO hours_worked
    FROM time_logs t
    WHERE t.first_name = f_name
      AND t.last_name = l_name
    LIMIT 1;

    RETURN hours_worked;
END $$

DELIMITER ;

SELECT
    e.first_name,
    e.last_name,
    GetTotalHours(e.first_name, e.last_name)
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE d.name = 'City Ethics Commission';

SELECT GetTotalHours('Philip', 'Wilson');


DELIMITER $$

CREATE PROCEDURE PayrollReport(IN dept_name VARCHAR(45))
BEGIN
    SELECT
        CONCAT(e.first_name, ' ', e.last_name) AS full_names,

        /* Base pay */
        CAST((2080 * j.hourly_rate) AS FLOAT) AS base_pay,

        /* Overtime pay */
        CAST(
            GREATEST(
                LEAST(
                    (GetTotalHours(e.first_name, e.last_name) - 2080)
                        * (j.hourly_rate * 1.5),
                    6000
                ),
                0
            )
        AS FLOAT) AS overtime_pay,

        /* Total pay */
        CAST(
            (
                (2080 * j.hourly_rate) +
                GREATEST(
                    LEAST(
                        (GetTotalHours(e.first_name, e.last_name) - 2080)
                            * (j.hourly_rate * 1.5),
                        6000
                    ),
                    0
                )
            )
        AS FLOAT) AS total_pay,

        /* Tax owed */
        CAST(
            TaxOwed(
                (
                    (2080 * j.hourly_rate) +
                    GREATEST(
                        LEAST(
                            (GetTotalHours(e.first_name, e.last_name) - 2080)
                                * (j.hourly_rate * 1.5),
                            6000
                        ),
                        0
                    )
                )
            )
        AS FLOAT) AS tax_owed,

        /* Net income */
        CAST(
            (
                (
                    (2080 * j.hourly_rate) +
                    GREATEST(
                        LEAST(
                            (GetTotalHours(e.first_name, e.last_name) - 2080)
                                * (j.hourly_rate * 1.5),
                            6000
                        ),
                        0
                    )
                )
                -
                TaxOwed(
                    (
                        (2080 * j.hourly_rate) +
                        GREATEST(
                            LEAST(
                                (GetTotalHours(e.first_name, e.last_name) - 2080)
                                    * (j.hourly_rate * 1.5),
                                6000
                            ),
                            0
                        )
                    )
                )
            )
        AS FLOAT) AS net_income

    FROM employees e
    JOIN departments d ON e.department_id = d.id
    JOIN jobs j ON e.job_id = j.id
    WHERE d.name = dept_name
    ORDER BY net_income DESC;
END $$

DELIMITER ;

CALL PayrollReport('City Ethics Commission');

/*
END STAGE 4
*/

/*
Other Solution
--

 */

/*
Other Solution
--

 */

/*
Other Solution
--

 */

/*
Other Solution
--
CREATE FUNCTION getHourlyRate(first_name VARCHAR(45), last_name VARCHAR(45))
RETURNS FLOAT
BEGIN
    DECLARE hourly_rate FLOAT;
    SET hourly_rate = (
        SELECT j.hourly_rate
        FROM employees e
        JOIN jobs j ON e.job_id = j.id
        WHERE
            e.first_name = first_name
            AND e.last_name = last_name
    );
    RETURN hourly_rate;
END;

CREATE FUNCTION calculateBasePay(first_name VARCHAR(45), last_name VARCHAR(45), normal_hours INT)
RETURNS FLOAT
BEGIN
    DECLARE base_pay FLOAT;
    SET base_pay = normal_hours * getHourlyRate(first_name, last_name);
    RETURN base_pay;
END;

CREATE FUNCTION calculateOvertimePay(first_name VARCHAR(45), last_name VARCHAR(45), total_hours INT, normal_hours INT, overtime_rate FLOAT, max_overtime_pay FLOAT)
RETURNS FLOAT
BEGIN
    DECLARE overtime_pay FLOAT;
    DECLARE overtime_hours INT;
    SET overtime_hours = GREATEST(total_hours - normal_hours, 0);
    SET overtime_pay = LEAST(overtime_hours * getHourlyRate(first_name, last_name) * overtime_rate, max_overtime_pay);
    RETURN overtime_pay;
END;

CREATE FUNCTION taxOwed(totalPay FLOAT)
RETURNS FLOAT
BEGIN
    DECLARE taxAmount FLOAT DEFAULT 0;

    SET taxAmount = CASE
        WHEN totalPay <= 11000 THEN
            totalPay * 0.10

        WHEN totalPay <= 44725 THEN
            1100 + ((totalPay - 11000) * 0.12)

        WHEN totalPay <= 95375 THEN
            5147 + ((totalPay - 44725) * 0.22)

        WHEN totalPay <= 182100 THEN
            16290 + ((totalPay - 95375) * 0.24)

        WHEN totalPay <= 231250 THEN
            37104 + ((totalPay - 182100) * 0.32)

        WHEN totalPay <= 578125 THEN
            52832 + ((totalPay - 231250) * 0.35)

        ELSE
            174238.25 + ((totalPay - 578126) * 0.37)
    END;

    RETURN taxAmount;
END;

CREATE FUNCTION getHoursLogged(first_name VARCHAR(45), last_name VARCHAR(45))
RETURNS INT
BEGIN
    DECLARE hoursWorked INT DEFAULT 0;

    SET hoursWorked = CASE
        WHEN concat(first_name, ' ', last_name) = 'Dixie Herda' THEN 2095
        WHEN concat(first_name, ' ', last_name) = 'Stephen West' THEN 2091
        WHEN concat(first_name, ' ', last_name) = 'Philip Wilson' THEN 2160
        WHEN concat(first_name, ' ', last_name) = 'Robin Walker' THEN 2083
        WHEN concat(first_name, ' ', last_name) = 'Antoinette Matava' THEN 2115
        WHEN concat(first_name, ' ', last_name) = 'Courtney Walker' THEN 2206
        WHEN concat(first_name, ' ', last_name) = 'Gladys Bosch' THEN 900
        ELSE 0
    END;

    RETURN hoursWorked;
END;

CREATE PROCEDURE PayrollReport(IN deptName VARCHAR(45))
BEGIN
    DECLARE WORKING_DAYS_PER_YEAR INT DEFAULT 250;
    DECLARE WORKING_HOURS_PER_DAY INT DEFAULT 8;
    DECLARE PAID_VACATION_DAYS_PER_YEAR INT DEFAULT 10;
    DECLARE PAID_HOURS_PER_YEAR INT;
    DECLARE OVERTIME_RATE FLOAT DEFAULT 1.5;
    DECLARE MAX_OVERTIME_PAY FLOAT DEFAULT 6000.0;

    SET PAID_HOURS_PER_YEAR = (WORKING_DAYS_PER_YEAR + PAID_VACATION_DAYS_PER_YEAR) * WORKING_HOURS_PER_DAY;

    WITH pay_calc AS (
        SELECT
            CONCAT(e.first_name, ' ', e.last_name) AS full_name,
            calculateBasePay(e.first_name, e.last_name, PAID_HOURS_PER_YEAR) AS base_pay,
            calculateOvertimePay(e.first_name, e.last_name, getHoursLogged(e.first_name, e.last_name), PAID_HOURS_PER_YEAR, OVERTIME_RATE, MAX_OVERTIME_PAY) AS overtime_pay
        FROM employees e
        JOIN departments d ON e.department_id = d.id
        WHERE d.name = deptName
    ),
    totals AS (
        SELECT
            full_name,
            base_pay,
            overtime_pay,
            base_pay + overtime_pay AS total_pay
        FROM pay_calc
    )
    SELECT
        full_name AS full_names,
        ROUND(base_pay, 2) AS base_pay,
        ROUND(overtime_pay, 2) AS overtime_pay,
        ROUND(total_pay, 2) AS total_pay,
        ROUND(taxOwed(total_pay), 2) AS tax_owed,
        ROUND(total_pay - taxOwed(total_pay), 2) AS net_income
    FROM totals
    ORDER BY net_income DESC;
END;

CALL PayrollReport('City Ethics Commission');
 */

/*
Other Solution
--
CREATE TABLE IF NoT exists EmployeesHRS (
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    hours_worked INT
);

INSERT INTO EmployeesHRS (first_name, last_name, hours_worked)
VALUES
('Dixie', 'Herda', 2095),
('Stephen', 'West', 2091),
('Philip', 'Wilson', 2160),
('Robin', 'Walker', 2083),
('Antoinette', 'Matava', 2115),
('Courtney', 'Walker', 2206),
('Gladys', 'Bosch', 900);

DELIMITER //
CREATE FUNCTION GetPay(
        first_name VARCHAR(45),
        last_name VARCHAR(45),
        hours_worked INT,
        param VARCHAR(20))
    RETURNS float(10,2)
BEGIN
    DECLARE normal_pay decimal(10,2);
    DECLARE overtime_pay decimal(10,2);
    DECLARE total_pay decimal(10,2);

    CALL EmployeeTotalPay(first_name, last_name, hours_worked, 2080, 1.5, 6000, normal_pay, overtime_pay, total_pay);

    CASE param
        WHEN 'normal_pay' THEN
            RETURN normal_pay;
        WHEN 'overtime_pay' THEN
            RETURN overtime_pay;
        WHEN 'total_pay' THEN
            RETURN total_pay;
        ELSE
            RETURN 0.0;
    END CASE;
END //
DELIMITER ;

CREATE FUNCTION TaxOwed(taxable_income FLOAT(10,1)) RETURNS FLOAT(10,1)
BEGIN
    DECLARE tax_owed FLOAT(10,1);

    IF taxable_income <= 11000 THEN
        SET tax_owed = taxable_income * 0.10;
    ELSEIF taxable_income <= 44725 THEN
        SET tax_owed = 1100 + (taxable_income - 11000) * 0.12;
    ELSEIF taxable_income <= 95375 THEN
        SET tax_owed = 5147 + (taxable_income - 44725) * 0.22;
    ELSEIF taxable_income <= 182100 THEN
        SET tax_owed = 16290 + (taxable_income - 95375) * 0.24;
    ELSEIF taxable_income <= 231250 THEN
        SET tax_owed = 37104 + (taxable_income - 182100) * 0.32;
    ELSEIF taxable_income <= 578125 THEN
        SET tax_owed = 52832 + (taxable_income - 231250) * 0.35;
    ELSE
        SET tax_owed = 174238.25 + (taxable_income - 578125) * 0.37;
    END IF;

    RETURN tax_owed;
END;


DELIMITER //
CREATE PROCEDURE EmployeeTotalPay(
    IN first_name VARCHAR(45),
    IN last_name VARCHAR(45),
    IN total_hours INT,
    IN normal_hours INT,
    IN overtime_rate decimal(5,2),
    IN max_overtime_pay decimal(10,2),
    OUT normal_pay decimal(10,2),
    OUT overtime_pay decimal(10,2),
    OUT total_pay decimal(10,2)
        )
BEGIN
    DECLARE hourly_rate decimal(10,2);
    DECLARE over_time_hours INT;

    SELECT j.hourly_rate INTO hourly_rate
    FROM employees e
    JOIN jobs j ON e.job_id = j.id
    WHERE e.first_name = first_name AND e.last_name = last_name;

    SET over_time_hours = GREATEST(total_hours - normal_hours,0);
    SET normal_pay = normal_hours * hourly_rate;
    SET overtime_pay = LEAST(over_time_hours * hourly_rate * overtime_rate, max_overtime_pay);
    SET total_pay = normal_pay + overtime_pay;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE PayrollReport(IN dept_name VARCHAR(45))
    BEGIN
    SELECT CONCAT(e.first_name, ' ', e.last_name) AS full_names,
        GetPay(e.first_name, e.last_name, h.hours_worked, 'normal_pay') AS base_pay,
        GetPay(e.first_name, e.last_name, h.hours_worked, 'overtime_pay') AS overtime_pay,
        GetPay(e.first_name, e.last_name, h.hours_worked, 'total_pay') AS total_pay,
        TaxOwed(GetPay(e.first_name, e.last_name, h.hours_worked, 'total_pay')) AS tax_owed,
        GetPay(e.first_name, e.last_name, h.hours_worked, 'total_pay') - TaxOwed(GetPay(e.first_name, e.last_name, h.hours_worked, 'total_pay')) AS net_income
     FROM employees e
        JOIN departments d ON e.department_id = d.id
        JOIN EmployeesHRS h ON e.first_name = h.first_name AND e.last_name = h.last_name
     WHERE d.name = dept_name
     ORDER BY net_income DESC;
    END //
DELIMITER ;

CALL PayrollReport("City Ethics Commission");
 */