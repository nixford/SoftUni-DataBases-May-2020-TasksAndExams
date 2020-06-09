SELECT TOP(5) e.EmployeeID, e.JobTitle, e.AddressID, a.AddressText 
	FROM Employees AS e
	JOIN Addresses AS a ON e.AddressID = a.AddressID
	ORDER BY e.AddressID ASC

SELECT TOP(50) e.FirstName, e.LastName, t.[Name], a.AddressText
	FROM Employees AS e
	JOIN Addresses AS a ON e.AddressID = a.AddressID
	JOIN Towns AS t ON a.TownID = t.TownID
	ORDER BY FirstName, LastName

SELECT e.EmployeeID, e.FirstName, e.LastName, d.[Name] 
	FROM Employees AS e
	JOIN Departments AS d ON e.DepartmentID = d.DepartmentID	
	WHERE d.[Name] = 'Sales'
	
SELECT TOP(5) e.EmployeeID, e.FirstName, e.Salary, d.[Name]
	FROM Employees AS e
	JOIN Departments AS d ON e.DepartmentID = d.DepartmentID	
	WHERE Salary > 15000
	ORDER BY d.DepartmentID ASC

SELECT TOP(3) e.EmployeeID, e.FirstName
	FROM Employees AS e
	LEFT JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID	
	WHERE ep.ProjectID IS NULL
	ORDER BY e.EmployeeID ASC

SELECT e.FirstName, e.LastName, e.HireDate, d.Name 
	FROM Employees AS e
	JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
	WHERE HireDate > '1.1.1999' 
		AND d.[Name] = 'Sales' OR d.[Name] = 'Finance'

SELECT e.EmployeeID, e.FirstName,
		CASE
			WHEN DATEPART(YEAR, p.StartDate) >= 2005 THEN NULL
			ELSE p.[Name]
		END AS [ProjectName]
	FROM Employees AS e
	JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID	
	JOIN Projects AS p ON ep.ProjectID = p.ProjectID
	WHERE e.EmployeeID = 24
	
