/*
START STAGE 1
*/
DELIMITER $$

CREATE PROCEDURE GetEmployeesByDept (IN dept_name VARCHAR(45))
BEGIN
    SELECT e.first_name,
           e.last_name,
           j.title AS job_title
    FROM employees e
    JOIN jobs j
        ON e.job_id = j.id
    JOIN departments d
        ON e.department_id = d.id
    WHERE d.name = dept_name
    ORDER BY e.first_name;
END $$

DELIMITER ;

CALL GetEmployeesByDept('Office of Finance');

/*
END STAGE 1
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