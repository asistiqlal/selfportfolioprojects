################################################################################

-- 10 Final Query Questions --

################################################################################

-- PREPARATION
USE employees;

-- TAKE A LOOK AT EACH TABLES IN THE DATABASE
SELECT * FROM departments LIMIT 10;
SELECT * FROM dept_emp LIMIT 10;
SELECT * FROM dept_manager LIMIT 10;
SELECT * FROM employees LIMIT 10;
SELECT * FROM emp_manager LIMIT 10;
SELECT * FROM salaries LIMIT 10;
SELECT * FROM titles LIMIT 10;

################################################################################

-- QUESTION 1
-- Find the average salary of the male and female employees in each department.

-- ANSWER 1
SELECT 
    YEAR(s.from_date) AS calendar_year,
    d.dept_name,
    e.gender,
    ROUND(AVG(s.salary), 2) AS salary
FROM
    salaries s
        JOIN
    employees e ON s.emp_no = e.emp_no
        JOIN
    dept_emp de ON de.emp_no = e.emp_no
        JOIN
    departments d ON de.dept_no = d.dept_no
GROUP BY calendar_year , d.dept_name , e.gender
ORDER BY d.dept_name;

################################################################################

-- QUESTION 2
-- Find the lowest department number encountered in the 'dept_emp' table.
-- Then, find the highest department number.

-- ANSWER 2
SELECT 
    MIN(dept_no) AS lowest_dept_no,
    MAX(dept_no) AS highest_dept_no
FROM
    dept_emp;

################################################################################

-- QUESTION 3
-- Obtain a table containing the following three fields for all individuals whose employee number is not greater than 10040:
-- a) employee number
-- b) the lowest department number among the departments where the employee has worked in
-- (Hint: use a subquery to retrieve this value from the 'dept_emp' table)
-- c) assign '110022' as 'manager' to all individuals whose employee number is lower than or equal to 10020, and '110039' to those whose number is between 10021 and 10040 inclusive.
-- Use a CASE statement to create the third field.
-- If you've worked correctly, you should obtain an output containing 40 rows.
  
-- ANSWER 3
-- Step 1: Give row number to each departement number for each employee number.
SELECT
	e.emp_no AS emp_no,
	de.dept_no AS dept_no,
	ROW_NUMBER() OVER (PARTITION BY e.emp_no ORDER BY de.dept_no) AS dept_rank
FROM
	employees e
JOIN dept_emp de ON e.emp_no = de.emp_no;

-- Step 2: Only show the lowest departement number for each employee.
SELECT
	a.emp_no AS emp_no,
    a.dept_no AS dept_no
FROM (
	SELECT
		e.emp_no AS emp_no,
		de.dept_no AS dept_no,
		ROW_NUMBER() OVER (PARTITION BY e.emp_no ORDER BY de.dept_no) AS dept_rank
    FROM
		employees e
	JOIN dept_emp de ON e.emp_no = de.emp_no
	) a
WHERE a.dept_rank = 1;

-- Step 3: Assign the correct manager to certain employees based on the criteria mentioned above
SELECT
	a.emp_no AS emp_no,
    a.dept_no AS dept_no,
    CASE
		WHEN a.emp_no BETWEEN 10001 AND 10020 THEN 110022
        WHEN a.emp_no BETWEEN 10021 AND 10040 THEN 110039
		ELSE NULL
	END AS manager
FROM (
	SELECT
		e.emp_no AS emp_no,
		de.dept_no AS dept_no,
		ROW_NUMBER() OVER (PARTITION BY e.emp_no ORDER BY de.dept_no) AS dept_rank
    FROM
		employees e
	JOIN dept_emp de ON e.emp_no = de.emp_no
	) a
WHERE
	a.dept_rank = 1
	AND a.emp_no <= 10040;
    
################################################################################

-- QUESTION 4
-- Retrieve a list of all employees that have been hired in 2000.

-- ANSWER 4
SELECT emp_no, first_name, last_name, YEAR(hire_date) as hire_date
FROM employees
WHERE YEAR(hire_date) = 2000
ORDER BY emp_no;

################################################################################

-- QUESTION 5
-- Retrieve a list of all employees from the ‘titles’ table who are engineers.
-- Repeat the exercise, this time retrieving a list of all employees from the ‘titles’ table who are senior engineers.
-- After LIKE, you could indicate what you are looking for with or without using parentheses.
-- Both options are correct and will deliver the same output.
-- We think using parentheses is better for legibility and that’s why it is the first option we’ve suggested.

-- ANSWER 5
-- a) Retrieve a list of all employees from the ‘titles’ table who are engineers
SELECT emp_no, title
FROM titles
WHERE title LIKE '%Engineer%';

-- b) Repeat the exercise, this time retrieving a list of all employees from the ‘titles’ table who are senior engineers.
SELECT emp_no, title
FROM titles
WHERE title = 'Senior Engineer';

################################################################################

-- QUESTION 6
-- Create a procedure that asks you to insert an employee number and that will obtain an output containing the same number,
-- as well as the number and name of the last department the employee has worked in.
-- Finally, call the procedure for employee number 10010.
-- If you've worked correctly, you should see that employee number 10010 has worked for department number 6 - "Quality Management".

-- ANSWER 6
-- STEP 1: Create the main query to be stored in the procedure
SELECT
	a.emp_no,
    a.dept_no,
    a.dept_name
FROM (
	SELECT
		s.emp_no,
        d.dept_no,
        d.dept_name,
        ROW_NUMBER() OVER (PARTITION BY s.emp_no ORDER BY d.dept_no DESC, s.from_date DESC) AS row_num
	FROM salaries s
	JOIN dept_emp de ON s.emp_no = de.emp_no
	JOIN departments d ON de.dept_no = d.dept_no
    ) a
WHERE a.row_num = 1;

-- STEP 2: Create the procedure contains the previous query
DROP PROCEDURE IF EXISTS emp_info;

DELIMITER $$
CREATE PROCEDURE emp_info (IN p_emp_no_in INT)
BEGIN
	SELECT
		a.emp_no,
		a.dept_no,				
		a.dept_name
	FROM (
		SELECT
			s.emp_no,
			d.dept_no,
			d.dept_name,
			ROW_NUMBER() OVER (PARTITION BY s.emp_no ORDER BY d.dept_no DESC, s.from_date DESC) AS row_num
		FROM salaries s
		JOIN dept_emp de ON s.emp_no = de.emp_no
		JOIN departments d ON de.dept_no = d.dept_no
		) a
	WHERE a.row_num = 1 AND a.emp_no = p_emp_no_in;
END$$
DELIMITER ;

CALL employees.emp_info(10010);

################################################################################

-- QUESTION 7
-- How many contracts have been registered in the ‘salaries’ table
-- with duration of more than one year and of value higher than or equal to $100,000?
-- Hint: You may wish to compare the difference between the start and end date of the salaries contracts.

-- ANSWER 7
SELECT 
    COUNT(emp_no) AS num_of_contracts_reg
FROM
    salaries
WHERE
    (YEAR(to_date) - YEAR(from_date)) > 1
        AND salary >= 100000;

################################################################################

-- QUESTION 8
-- Create a trigger that checks if new the hire date of an employee is higher than the current date.
-- If true, set the hire date to equal the current date. Format the output appropriately (YY-mm-dd).
-- Extra challenge: You can try to declare a new variable called 'today' which stores today's data, and then use it in your trigger!
-- After creating the trigger, execute the following code to see if it's working properly.

-- ANSWER 8
-- Create a checkpoint
COMMIT;

-- Create a variable which stores today's date
SET @today = SYSDATE();

-- Drop a trigger if turns out it's already exist in our database
DROP TRIGGER IF EXISTS trig_hire_date;

-- Create a trigger to adjust the new hire_date
DELIMITER $$
CREATE TRIGGER trig_hire_date  
BEFORE INSERT ON employees
FOR EACH ROW  
BEGIN  
	IF NEW.hire_date > date_format(@today, '%Y-%m-%d') THEN     
		SET NEW.hire_date = date_format(@today, '%Y-%m-%d');     
	END IF;  
END $$  
DELIMITER ;  

-- Insert new fictional data
INSERT employees VALUES ('999909', '1998-01-01', 'John', 'Doe', 'M', '2025-01-01');  

-- Check if the trigger works
SELECT 
    *
FROM
    employees
WHERE
    emp_no = 999909
ORDER BY emp_no DESC;

-- Return condition of the data to the previous state during the last commit
ROLLBACK;

################################################################################

-- QUESTION 9
-- Define a function that retrieves the largest contract salary value of an employee.
-- Apply it to employee number 11356.
-- In addition, what is the lowest contract salary value of the same employee?
-- You may want to create a new function that to obtain the result.

-- ANSWER 9
-- Step 1: Checking the highest & lowest contract salary value of employee number 11356
SELECT 
    emp_no, salary
FROM
    salaries
WHERE
    emp_no = 11356
ORDER BY salary DESC;

-- Step 2: Create Function 1 to obtain the highest salary value of a certain employee
DROP FUNCTION IF EXISTS f_highest_salary_val;

DELIMITER $$
CREATE FUNCTION f_highest_salary_val (p_emp_no INT) RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE v_highest_salary INT;
    
	SELECT
		MAX(salary) INTO v_highest_salary
    FROM
		salaries
    WHERE
		emp_no = p_emp_no;
    
    RETURN v_highest_salary;
END$$
DELIMITER ;

-- Step 3: Create Function 2 to obtain the lowest salary value of a certain employee
DROP FUNCTION IF EXISTS f_lowest_salary_val;

DELIMITER $$
CREATE FUNCTION f_lowest_salary_val (p_emp_no INT) RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE v_lowest_salary INT;
    
	SELECT 
		MIN(salary) INTO v_lowest_salary
	FROM
		salaries
	WHERE
		emp_no = p_emp_no;
    
    RETURN v_lowest_salary;
END$$
DELIMITER ;

-- Check if those two functions are working properly
SELECT
	f_highest_salary_val(11356) AS emp_highest_salary,
	f_lowest_salary_val(11356) AS emp_lowest_salary;

################################################################################

-- QUESTION 10
-- Based on the previous exercise, you can now try to create a third function that also accepts a second parameter.
-- Let this parameter be a character sequence.
-- Evaluate if its value is 'min' or 'max' and based on that retrieve either the lowest or the highest salary,
-- respectively (using the same logic and code structure from Exercise 9).
-- If the inserted value is any string value different from ‘min’ or ‘max’,
-- let the function return the difference between the highest and the lowest salary of that employee.

-- ANSWER 10
DROP FUNCTION IF EXISTS f_max_min_diff_salary;

DELIMITER $$
CREATE FUNCTION f_max_min_diff_salary (p_emp_no INT, p_max_min_diff CHAR(255)) RETURNS INT
DETERMINISTIC NO SQL READS SQL DATA
BEGIN
	DECLARE v_salary_info INT;

	SELECT
		CASE
			WHEN p_max_min_diff = 'max' THEN MAX(salary)
			WHEN p_max_min_diff = 'min' THEN MIN(salary)
			ELSE MAX(salary) - MIN(salary)
		END AS salary_info INTO v_salary_info
	FROM
		salaries
	WHERE
		emp_no = p_emp_no;

	RETURN v_salary_info;
END$$
DELIMITER ;

SELECT
	f_max_min_diff_salary(10020, 'max') AS emp_highest_salary,
    f_max_min_diff_salary(10020, 'min') AS emp_lowest_salary,
    f_max_min_diff_salary(10020, 'anything') AS emp_salary_diff;