SELECT COUNT(*) AS [Count] 
	FROM WizzardDeposits


SELECT MAX(MagicWandSize) AS LongestMagicWand
	FROM WizzardDeposits


SELECT DepositGroup, 
	MAX(MagicWandSize) AS LongestMagicWand 
	FROM WizzardDeposits
	GROUP BY DepositGroup


SELECT TOP(2) DepositGroup	
	FROM WizzardDeposits	
	GROUP BY DepositGroup
	ORDER BY AVG(MagicWandSize)


SELECT w.DepositGroup, 
	SUM(w.DepositAmount) AS TotalSum 
	FROM WizzardDeposits AS w
GROUP BY DepositGroup


SELECT w.DepositGroup, 
	SUM(w.DepositAmount) AS TotalSum 
	FROM WizzardDeposits AS w
	WHERE MagicWandCreator = 'Ollivander family'
	GROUP BY DepositGroup


SELECT w.DepositGroup, 
	SUM(w.DepositAmount) AS TotalSum 
	FROM WizzardDeposits AS w
	WHERE MagicWandCreator = 'Ollivander family'
	GROUP BY DepositGroup
	HAVING SUM(DepositAmount) < 150000
	ORDER BY TotalSum DESC


SELECT DepositGroup,
	   MagicWandCreator,  
	   MIN(DepositCharge) AS MinDepositCharge
	FROM WizzardDeposits
	GROUP BY DepositGroup, MagicWandCreator
	ORDER BY MagicWandCreator, DepositGroup


SELECT *, COUNT(*) AS WizardCount FROM 
(
SELECT 
  CASE
	WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
	WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
	WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
	WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
	WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
	WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
	ELSE '[61+]'
  END AS [AgeGroup]
  FROM WizzardDeposits
  ) AS Groups
GROUP BY AgeGroup
ORDER BY AgeGroup
	
	
SELECT LEFT(FirstName, 1) AS FirstLetter 
	FROM WizzardDeposits
	WHERE DepositGroup = 'Troll Chest'
	GROUP BY LEFT(FirstName, 1) 
	

SELECT DepositGroup, 
	   IsDepositExpired, 
	   AVG(DepositInterest) AS AverageInterest 
	FROM WizzardDeposits
	WHERE DATEPART(YEAR, DepositStartDate) >= 1985
	GROUP BY DepositGroup, IsDepositExpired
	ORDER BY DepositGroup DESC, IsDepositExpired


SELECT SUM([Difference]) AS [SumDifference]
FROM(
		SELECT FirstName AS [Host Wizard],
				DepositAmount AS [Host Wizard Deposit],
				LEAD(FirstName) OVER(ORDER BY Id ASC) AS [Guest Wizard],
				LEAD(DepositAmount) OVER (ORDER BY Id ASC) AS [Guest Wizard Deposit],
				DepositAmount - LEAD(DepositAmount) OVER (ORDER BY Id ASC) AS [Difference]
			FROM WizzardDeposits
	  ) AS [LeadQuery]
WHERE [Guest Wizard] IS NOT NULL


--USE SoftUni

SELECT DepartmentID, MIN(Salary) AS MinimumSalary 
	FROM Employees
	WHERE DATEPART(YEAR, HireDate) >= 2000
	GROUP BY DepartmentID
	HAVING DepartmentID IN (2, 5, 7)


SELECT * 
	INTO EmployeesWithHighSalary
	FROM Employees
	WHERE Salary > 30000

	DELETE FROM EmployeesWithHighSalary
	WHERE ManagerID = 42

	UPDATE EmployeesWithHighSalary
	SET Salary += 5000
	WHERE DepartmentID = 1
SELECT DepartmentID, 
	   AVG(Salary) AS AverageSalary 
	   FROM EmployeesWithHighSalary
	   GROUP BY DepartmentID


SELECT DepartmentID, 
	   MAX(Salary) AS [MaxSalary]
	   FROM Employees	   
	   GROUP BY DepartmentID
	   HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

SELECT COUNT(Salary)
	FROM Employees
	WHERE ManagerID IS NULL


SELECT a.DepartmentId,
(
	SELECT DISTINCT b.Salary FROM Employees AS b
	WHERE b.DepartmentID = a.DepartmentId
	ORDER BY Salary DESC
	OFFSET 2 ROWS
	FETCH NEXT 1 ROWS ONLY
) AS [ThirdHighestSalary]
FROM Employees AS a
WHERE (
	SELECT DISTINCT b.Salary FROM Employees AS b
	WHERE b.DepartmentID = a.DepartmentId
	ORDER BY Salary DESC
	OFFSET 2 ROWS
	FETCH NEXT 1 ROWS ONLY
) IS NOT NULL
GROUP BY a.DepartmentID
	

SELECT TOP(10) FirstName, 
			   LastName, 
			   DepartmentID 
		FROM Employees AS e
		WHERE Salary > (
			  SELECT AVG(Salary) 
			  FROM Employees AS empl
		      WHERE empl.DepartmentID = e.DepartmentID
	)
ORDER BY DepartmentID
