SELECT r.[Description],
		FORMAT(r.[OpenDate], 'dd-MM-yyyy') AS [OpenDate]		
  FROM Reports AS r
  LEFT JOIN Employees AS e ON r.EmployeeId = e.Id
  WHERE e.Id IS NULL
  ORDER BY r.[OpenDate], r.[Description]


SELECT r.[Description], c.[Name] AS [CategoryName]		
  FROM Reports AS r
  JOIN Categories AS c ON r.CategoryId = c.Id  
  ORDER BY r.[Description], r.CategoryId


SELECT TOP(5) [c].[Name] AS [CategoryName],
         COUNT([r].[CategoryId]) AS [ReportsNumber]
    FROM [Reports] AS r
    JOIN [Categories] AS [c] ON [r].[CategoryId] = [c].[Id]
	GROUP BY [c].[Name]
	ORDER BY [ReportsNumber] DESC, [c].[Name]


SELECT Username, 
		c.[Name] AS [CategoryName]	
	FROM [Users] AS u
	JOIN [Reports] AS r ON u.Id = r.UserId
	JOIN [Categories] AS c ON c.Id = r.[CategoryId]
	WHERE DATEPART(DAY, r.[OpenDate]) = DATEPART(DAY, u.[Birthdate])
		  AND DATEPART(MONTH, r.[OpenDate]) = DATEPART(MONTH, u.[Birthdate])
	ORDER BY Username, [CategoryName]


SELECT e.FirstName + ' ' + e.LastName AS FullName,	
	   COUNT(r.UserId) AS UsersCount
	   FROM [Employees] AS e
	   LEFT JOIN Reports AS r ON e.Id = r.EmployeeId
	   GROUP BY e.FirstName, e.LastName
	   ORDER BY UsersCount DESC, FullName


SELECT  ISNULL([e].[FirstName] + ' ' + [e].[LastName], 'None') AS [Employee],
          ISNULL([d].[Name], 'None') AS [Department],
		  ISNULL([c].[Name], 'None') AS [Category],
		  ISNULL([r].[Description], 'None') AS [Description],
		  ISNULL(FORMAT([r].[OpenDate], 'dd.MM.yyyy'), 'None') AS [OpenDate],
		  ISNULL([s].[Label], 'None') AS [Status],
		  ISNULL([u].[Name], 'None') AS [User]
		FROM [Reports] AS r
		LEFT JOIN [Employees] AS e ON r.EmployeeId = e.Id
		LEFT JOIN [Departments] AS d ON e.DepartmentId = d.Id
		LEFT JOIN [Categories] AS c ON r.CategoryId = c.Id
		LEFT JOIN [Status] AS s ON r.StatusId = s.Id
		LEFT JOIN [Users] AS u ON r.UserId = u.Id		
		ORDER BY [e].[FirstName] DESC, [e].[LastName] DESC, [d].[Name] ASC, [c].[Name] ASC, 
				 [r].[Description] ASC, [r].[OpenDate] ASC, [s].[Label] ASC, [u].[Name] ASC
GO


CREATE FUNCTION udf_HoursToComplete(@StartDate DATETIME, @EndDate DATETIME)  
RETURNS int   
AS 
BEGIN  
	DECLARE @ret int;      
    SELECT @ret = DATEDIFF(HOUR, @StartDate, @EndDate)    
     IF (@StartDate IS NULL OR @StartDate IS NULL)   
        SET @ret = 0; 	 
    RETURN @ret;  
END; 

GO
SELECT dbo.udf_HoursToComplete(OpenDate, CloseDate) AS TotalHours
   FROM [Service].[dbo].[Reports]
GO


CREATE PROCEDURE usp_AssignEmployeeToReport(@EmployeeId INT, @ReportId INT)
AS
BEGIN
	DECLARE @employeeDepartment INT = (SELECT [e].[DepartmentId]
                                         FROM [Service].[dbo].[Employees] AS e
                                        WHERE [e].[Id] = @EmployeeId)

	DECLARE @reportDepartment INT = (SELECT [c].[DepartmentId]
                                       FROM [Service].[dbo].[Reports] AS r
                                       JOIN [dbo].[Categories] AS [c] ON [r].[CategoryId] = [c].[Id]
                                      WHERE [r].[Id] = @ReportId)

	IF(@employeeDepartment <> @reportDepartment)
	BEGIN
		RAISERROR('Employee doesn''t belong to the appropriate department!', 16, 1)
		RETURN
	END

	UPDATE [dbo].[Reports]
	SET
	    [Reports].[EmployeeId] = @EmployeeId
	WHERE [Reports].[Id] = @ReportId
END
GO;

EXEC usp_AssignEmployeeToReport 30, 1
EXEC usp_AssignEmployeeToReport 17, 2


	