/*
START STAGE 3
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

CALL EmployeeTotalPay('Philip', 'Wilson', 2160, 2080, 1.5, 6000, @p1);
CALL EmployeeTotalPay('Daisy', 'Diamond', 2100, 2080, 1.5, 6000, @p2);

SELECT ROUND(TaxOwed(@p1), 1) AS 'Philip Wilson',
       ROUND(TaxOwed(@p2), 1) AS 'Daisy Diamond';

/*
END STAGE 3
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
CREATE FUNCTION TaxOwed(total_income FLOAT)
    RETURNS FLOAT
BEGIN
    DECLARE result_double FLOAT;
    SET result_double =
        CASE
            WHEN total_income > 0 AND total_income <= 11000
            THEN total_income * 0.1
            WHEN total_income > 11000 AND total_income <= 44725
            THEN 1100 + ((total_income - 11000) * 0.12)
            WHEN total_income > 44726 AND total_income <= 95375
            THEN 5147 + ((total_income - 44725) * 0.22)
            WHEN total_income > 95376  AND total_income <= 182100
            THEN 16290 + ((total_income - 95375) * 0.24)
            WHEN total_income > 182101 AND total_income <= 231250
            THEN 37104  + ((total_income - 182100) * 0.32)
            WHEN total_income > 231251 AND total_income <= 578125
            THEN 52832 + ((total_income - 231250) * 0.35)
            WHEN total_income > 578126
            THEN 174238.25 + ((total_income - 578125) * 0.37)
        END;
    RETURN ROUND(result_double, 1);
END;

SELECT
    TaxOwed(137164.796875) AS 'Philip Wilson',
    TaxOwed(89231.8984375) AS 'Daisy Diamond';
 */

/*
Other Solution
--
CREATE FUNCTION TaxOwed(total_pay FLOAT)
RETURNS FLOAT
DETERMINISTIC
BEGIN
    DECLARE tax_rate FLOAT;
    DECLARE tax_start FLOAT;
    DECLARE taxable FLOAT;
    DECLARE total_tax FLOAT;

    IF total_pay <= 11000.00 THEN
        SET tax_rate = 0.10;
        SET tax_start = 0;
        SET taxable = total_pay;
    ELSEIF total_pay <= 44725.00 THEN
        SET tax_rate = 0.12;
        SET tax_start = 1100.00;
        SET taxable = total_pay - 11000.00;
    ELSEIF total_pay <= 95375.00 THEN
        SET tax_rate = 0.22;
        SET tax_start = 5147.00;
        SET taxable = total_pay - 44725.00;
    ELSEIF total_pay <= 182100.00 THEN
        SET tax_rate = 0.24;
        SET tax_start = 16290.00;
        SET taxable = total_pay - 95375.00;
    ELSEIF total_pay <= 231250.00 THEN
        SET tax_rate = 0.32;
        SET tax_start = 37104.00;
        SET taxable = total_pay - 182100.00;
    ELSEIF total_pay <= 578125.00 THEN
        SET tax_rate = 0.35;
        SET tax_start = 52832.00;
        SET taxable = total_pay - 231250.00;
    ELSE
        SET tax_rate = 0.37;
        SET tax_start = 174238.25;
        SET taxable = total_pay - 578125.00;
    END IF;

    SET total_tax = tax_start + taxable * tax_rate;

    RETURN total_tax;
END;

CREATE PROCEDURE EmployeeTotalPay(
    IN first_name VARCHAR(45),
    IN last_name VARCHAR(45),
    IN total_hours INT,
    IN normal_hours INT,
    IN overtime_rate FLOAT(5,2),
    IN max_overtime_pay FLOAT(6,2),
    OUT total_pay FLOAT
)
BEGIN
    DECLARE hourly_rate FLOAT(10,2);
    DECLARE over_time_hours INT;
    DECLARE normal_pay FLOAT(10,2);
    DECLARE overtime_pay FLOAT(10,2);
    DECLARE v_total_pay FLOAT(10,2);

    SET hourly_rate = (
        SELECT job.hourly_rate
        FROM employees emp
        JOIN jobs job ON job.id = emp.job_id
        WHERE emp.first_name = first_name AND emp.last_name = last_name
        LIMIT 1
    );

    SET over_time_hours = total_hours - normal_hours;
    IF over_time_hours < 0 THEN
        SET over_time_hours = 0;
    END IF;

    SET normal_pay = LEAST(total_hours, normal_hours) * hourly_rate;

    SET overtime_pay = over_time_hours * hourly_rate * overtime_rate;
    IF overtime_pay > max_overtime_pay THEN
        SET overtime_pay = max_overtime_pay;
    END IF;

    SET v_total_pay = normal_pay + overtime_pay;

    SET total_pay = ROUND(v_total_pay, 0);
END;

CALL EmployeeTotalPay("Philip", "Wilson", 2160, 2080, 1.5, 6000, @result1);
CALL EmployeeTotalPay("Daisy", "Diamond", 2100, 2080, 1.5, 6000, @result2);
SELECT TaxOwed(@result1) as "Philip Wilson", TaxOwed(@result2) as "Daisy Diamond";
 */

/*
Other Solution
--
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

CALL EmployeeTotalPay('Philip', 'Wilson', 2160, (250+10)*8, 1.5, 6000.0, @philip_wilson_pay);
CALL EmployeeTotalPay('Daisy', 'Diamond', 2100, (250+10)*8, 1.5, 6000.0, @daisy_diamond_pay);

SELECT
    ROUND(taxOwed(@philip_wilson_pay), 1) AS 'Philip Wilson',
    ROUND(taxOwed(@daisy_diamond_pay), 1) AS 'Daisy Diamond'
 */