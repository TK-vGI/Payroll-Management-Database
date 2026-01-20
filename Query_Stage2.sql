/*
START STAGE 2
*/
DELIMITER $$

CREATE PROCEDURE EmployeeTotalPay(
    IN first_name VARCHAR(45),
    IN last_name VARCHAR(45),
    IN total_hours INT,
    IN normal_hours INT,
    IN overtime_rate FLOAT,
    IN max_overtime_pay FLOAT,
    OUT total_pay FLOAT
)
BEGIN
    DECLARE hourly_rate FLOAT;
    DECLARE base_pay FLOAT;
    DECLARE overtime_pay_rate FLOAT;
    DECLARE overtime_pay FLOAT;
    DECLARE overtime_hours INT;

    -- Pull hourly_rate automatically from jobs table
    SELECT j.hourly_rate
    INTO hourly_rate
    FROM employees e
    JOIN jobs j ON e.job_id = j.id
    WHERE e.first_name = first_name
      AND e.last_name = last_name
    LIMIT 1;

    -- Overtime hours = total - normal hours
    SET overtime_hours = total_hours - normal_hours;

    -- Overtime pay rate = 1.5 × hourly_rate
    SET overtime_pay_rate = hourly_rate * overtime_rate;

    -- Base pay = normal_hours × hourly_rate
    SET base_pay = normal_hours * hourly_rate;

    -- Overtime pay using the function
    IF overtime_hours <= 0 THEN
        SET overtime_pay = 0;
    ELSEIF (overtime_hours * overtime_pay_rate) > max_overtime_pay THEN
        SET overtime_pay = max_overtime_pay;
    ELSE
        SET overtime_pay = overtime_hours * overtime_pay_rate;
    END IF;

    -- Final total pay, rounded UP to whole number
    SET total_pay = base_pay + overtime_pay;
END $$

DELIMITER ;

SET @pay = 0;
CALL EmployeeTotalPay('Philip', 'Wilson', 2160, 2080, 1.5,6000, @pay1);
CALL EmployeeTotalPay('Daisy', 'Diamond', 2100, 2080,1.5, 6000, @pay2);
SELECT ROUND(@pay1,1) AS 'Philip Wilson',
       ROUND(@pay2,1) AS 'Daisy Diamond';

/*
END STAGE 2
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

 */

/*
Other Solution
--

 */