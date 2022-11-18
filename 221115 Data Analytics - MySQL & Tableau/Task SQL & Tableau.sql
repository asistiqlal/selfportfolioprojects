################################################################################

-- PREPARATION
USE employees_mod;

################################################################################

-- TASK 1
-- Create a visualization that provides a breakdown between the male and female employees working in the company each year,
-- starting from 1990 (included).
SELECT 
    emp_no, from_date, to_date
FROM
    t_dept_emp;

SELECT DISTINCT
    emp_no, from_date, to_date
FROM
    t_dept_emp;

SELECT 
    YEAR(tde.from_date) AS calendar_year,
    te.gender,
    COUNT(tde.emp_no) AS num_of_employees
FROM
    t_employees te
        JOIN
    t_dept_emp tde ON te.emp_no = tde.emp_no
WHERE
    YEAR(tde.from_date) >= 1990
GROUP BY YEAR(tde.from_date) , te.gender
ORDER BY YEAR(tde.from_date);

################################################################################

-- TASK 2
-- Compare the number of male managers to the number of female managers from different departments for each year,
-- starting from 1990.
SELECT 
    td.dept_name,
    te.gender,
    tdm.emp_no,
    tdm.from_date,
    tdm.to_date,
    e.calendar_year,
    CASE
        WHEN
            YEAR(tdm.to_date) >= e.calendar_year
                AND YEAR(tdm.from_date) <= e.calendar_year
        THEN
            1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY calendar_year) e
        CROSS JOIN
    t_dept_manager tdm
        JOIN
    t_departments td ON tdm.dept_no = td.dept_no
        JOIN
    t_employees te ON tdm.emp_no = te.emp_no
ORDER BY tdm.emp_no , calendar_year;

################################################################################

-- TASK 3
-- Compare the average salary of female versus male employees in the entire company until year 2002,
-- and add a filter allowing you to see that per each department.
SELECT 
    te.gender,
    td.dept_name,
    ROUND(AVG(ts.salary)) AS salary,
    YEAR(ts.from_date) AS calendar_year
FROM
    t_salaries ts
        JOIN
    t_employees te ON ts.emp_no = te.emp_no
        JOIN
    t_dept_emp tde ON tde.emp_no = te.emp_no
        JOIN
    t_departments td ON tde.dept_no = td.dept_no
GROUP BY td.dept_no , te.gender , calendar_year
HAVING calendar_year <= 2002
ORDER BY td.dept_no;

################################################################################

-- TASK 4
-- Create an SQL stored procedure that will allow you to obtain the average male and female salary per department
-- within a certain salary range. Let this range be defined by two values the user can insert when calling the procedure.
-- Finally, visualize the obtained result-set in Tableau as a double bar chart. 
DROP PROCEDURE IF EXISTS filter_salary;

DELIMITER $$
CREATE PROCEDURE filter_salary (IN p_min_salary FLOAT, IN p_max_salary FLOAT)
BEGIN
SELECT 
    te.gender, td.dept_name, AVG(ts.salary) as avg_salary
FROM
    t_salaries ts
        JOIN
    t_employees te ON ts.emp_no = te.emp_no
        JOIN
    t_dept_emp tde ON tde.emp_no = te.emp_no
        JOIN
    t_departments td ON td.dept_no = tde.dept_no
    WHERE ts.salary BETWEEN p_min_salary AND p_max_salary
GROUP BY td.dept_no, te.gender;
END$$
DELIMITER ;

CALL filter_salary(50000, 90000);