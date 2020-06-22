CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000
AS
SELECT FirstName,
	   LastName
	FROM Employees
	WHERE Salary > 35000
GO
EXEC usp_GetEmployeesSalaryAbove35000
GO


CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber
(@Number DECIMAL(18,4))
AS
SELECT FirstName,
	   LastName
	FROM Employees
	WHERE Salary >= @Number
GO
EXEC usp_GetEmployeesSalaryAboveNumber 48100
GO

CREATE PROCEDURE usp_GetTownsStartingWith
(@Text VARCHAR(MAX))
AS

	SELECT t.[Name] 
		FROM Towns AS t
		WHERE t.[Name] LIKE @Text + '%' 
GO
EXEC usp_GetTownsStartingWith 'S'
GO


CREATE PROCEDURE usp_GetEmployeesFromTown
(@InputTown VARCHAR(MAX))
AS
	SELECT e.FirstName,
		   e.LastName		   
	FROM Employees AS e
	JOIN Addresses AS a ON e.AddressID = a.AddressID
	JOIN Towns AS t ON a.TownID = t.TownID
	WHERE t.[Name] = @InputTown
GO
EXEC usp_GetEmployeesFromTown 'Berlin'
GO


CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @level NVARCHAR(MAX)
	IF(@salary < 30000)
		SET @level = 'Low';
	ELSE IF(@salary BETWEEN 30000 AND 50000)
		SET @level = 'Average';
	ELSE IF(@salary > 50000)
		SET @level = 'High';
	RETURN @level
END
GO
SELECT dbo.ufn_GetSalaryLevel (55000.50) AS SalaryLevel 
GO


CREATE PROCEDURE usp_EmployeesBySalaryLevel 
(@level VARCHAR(20))
AS
SELECT e.FirstName,
	   e.LastName
	FROM Employees AS e
	WHERE @level = dbo.ufn_GetSalaryLevel(Salary)
GO
EXEC usp_EmployeesBySalaryLevel 'High'
GO


CREATE FUNCTION ufn_IsWordComprised(@setOfLetters NVARCHAR(MAX), @word NVARCHAR(MAX))
  RETURNS BIT
AS
  BEGIN
    DECLARE @isComprised BIT = 0;
    DECLARE @currentIndex INT = 1;
    DECLARE @currentChar CHAR;

    WHILE (@currentIndex <= LEN(@word))
      BEGIN
        SET @currentChar = SUBSTRING(@word, @currentIndex, 1);
        IF (CHARINDEX(@currentChar, @setOfLetters) = 0)
          BEGIN
            RETURN @isComprised;
          END
        SET @currentIndex+= 1;
      END

    RETURN @isComprised + 1;
  END
GO
SELECT dbo.ufn_IsWordComprised('oistmiahf', 'Sofia')
GO


CREATE PROC usp_DeleteEmployeesFromDepartment(@departmentId INT)
AS
  ALTER TABLE Departments
    ALTER COLUMN ManagerID INT NULL

  DELETE FROM EmployeesProjects
  WHERE EmployeeID IN
        (
          SELECT EmployeeID
          FROM Employees
          WHERE DepartmentID = @departmentId
        )

  UPDATE Employees
  SET ManagerID = NULL
  WHERE ManagerID IN
        (
          SELECT EmployeeID
          FROM Employees
          WHERE DepartmentID = @departmentId
        )

  UPDATE Departments
  SET ManagerID = NULL
  WHERE ManagerID IN
        (
          SELECT EmployeeID
          FROM Employees
          WHERE DepartmentID = @departmentId
        )

  DELETE FROM Employees
  WHERE EmployeeID IN
        (
          SELECT EmployeeID
          FROM Employees
          WHERE DepartmentID = @departmentId
        )

  DELETE FROM Departments
  WHERE DepartmentID = @departmentId

  SELECT COUNT(*) AS [Employees Count]
  FROM Employees AS E
    JOIN Departments AS D
      ON D.DepartmentID = E.DepartmentID
  WHERE E.DepartmentID = @departmentId
GO


CREATE PROCEDURE usp_GetHoldersFullName
AS
	SELECT ah.FirstName + ' ' + ah.LastName AS [Full Name]
		   FROM AccountHolders AS ah
GO
EXEC dbo.usp_GetHoldersFullName
GO


CREATE PROCEDURE usp_GetHoldersWithBalanceHigherThan
(@number DECIMAL(18,4))
AS
	SELECT ah.FirstName AS [First Name],
		   ah.LastName AS [Last Name]		   
		FROM AccountHolders AS ah
		JOIN Accounts AS a ON ah.Id = a.AccountHolderId 		
		GROUP BY ah.FirstName, ah.LastName
		HAVING SUM(a.Balance) >= @number
		ORDER BY ah.FirstName, ah.LastName
GO
EXEC usp_GetHoldersWithBalanceHigherThan 550000
GO


CREATE FUNCTION ufn_CalculateFutureValue
(@initialSum DECIMAL(18,4), @intersetRate FLOAT, @yearsNumber INT)
RETURNS DECIMAL(18,4)
AS
BEGIN	
		RETURN @initialSum * (POWER(1 + @intersetRate, @yearsNumber))	 
END
GO
SELECT dbo.ufn_CalculateFutureValue (1000, 0.1, 5)
GO


CREATE PROCEDURE usp_CalculateFutureValueForAccount
(@AccountId INT, @InterestRate FLOAT)
AS
BEGIN
	DECLARE @Years INT = 5;

	SELECT a.Id AS [Account Id],
		   ah.FirstName AS [First Name],
		   ah.LastName AS [Last Name],
		   a.Balance AS [Current Balance],
		   dbo.ufn_CalculateFutureValue(a.Balance, @InterestRate, @Years) AS [Balance in 5 years]
		FROM AccountHolders AS ah
		JOIN Accounts AS a ON ah.Id = a.AccountHolderId
		WHERE a.Id = @AccountId
END
GO
EXEC usp_CalculateFutureValueForAccount 1, 0.10
GO


CREATE FUNCTION ufn_CashInUsersGames(@gameName NVARCHAR(MAX))
  RETURNS TABLE
AS
  RETURN  SELECT SUM(Cash) AS SumCash
    FROM (
           SELECT
             ug.Cash,
             ROW_NUMBER()
             OVER (
               ORDER BY ug.Cash DESC ) AS RowNum
           FROM UsersGames AS ug
             INNER JOIN Games AS g
               ON ug.GameId = g.Id
           WHERE g.Name = @gameName
         ) AS CashList
    WHERE RowNum % 2 = 1
GO


CREATE TABLE Logs (
  LogId INT PRIMARY KEY IDENTITY,
  AccountId INT,
  OldSum MONEY,
  NewSum MONEY
)

CREATE TRIGGER InsertNewEntryIntoLogs
  ON Accounts
  AFTER UPDATE
AS
  INSERT INTO Logs
  VALUES (
    (SELECT Id
     FROM inserted),
    (SELECT Balance
     FROM deleted),
    (SELECT Balance
     FROM inserted)
  )


CREATE TABLE NotificationEmails (
  Id INT PRIMARY KEY IDENTITY,
  Recipient INT,
  Subject NVARCHAR(MAX),
  Body NVARCHAR(MAX)
)

CREATE TRIGGER CreateNewNotificationEmail
  ON Logs
  AFTER INSERT
AS
  BEGIN
    INSERT INTO NotificationEmails
    VALUES (
      (SELECT AccountId
       FROM inserted),
      (CONCAT('Balance change for account: ', (SELECT AccountId
                                               FROM inserted))),
      (CONCAT('On ', (SELECT GETDATE()
                      FROM inserted), 'your balance was changed from ', (SELECT OldSum
                                                                         FROM inserted), 'to ', (SELECT NewSum
                                                                                                 FROM inserted), '.'))
    )
  END
GO


CREATE PROCEDURE usp_DepositMoney(@AccountId INT, @MoneyAmount MONEY)
AS
  BEGIN TRANSACTION
  UPDATE Accounts
  SET Balance += @MoneyAmount
  WHERE Id = @AccountId
  COMMIT
GO


CREATE PROCEDURE usp_WithdrawMoney(@AccountId INT, @MoneyAmount MONEY)
AS
  BEGIN TRANSACTION
  UPDATE Accounts
  SET Balance -= @MoneyAmount
  WHERE Id = @AccountId
  COMMIT


CREATE PROCEDURE usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount DECIMAL(15, 4))
AS
  BEGIN
    BEGIN TRANSACTION
    EXEC dbo.usp_WithdrawMoney @SenderId, @Amount
    EXEC dbo.usp_DepositMoney @ReceiverId, @Amount
    IF ((SELECT Balance
         FROM Accounts
         WHERE Accounts.Id = @SenderId) < 0)
      BEGIN
        ROLLBACK
      END
    ELSE
      BEGIN
        COMMIT
      END
  END


DECLARE @gameName NVARCHAR(50) = 'Safflower'
DECLARE @username NVARCHAR(50) = 'Stamat'
DECLARE @userGameId INT = (
  SELECT ug.Id
  FROM UsersGames AS ug
    JOIN Users AS u
      ON ug.UserId = u.Id
    JOIN Games AS g
      ON ug.GameId = g.Id
  WHERE u.Username = @username AND g.Name = @gameName)

DECLARE @userGameLevel INT = (SELECT Level
                              FROM UsersGames
                              WHERE Id = @userGameId)
DECLARE @itemsCost MONEY, @availableCash MONEY, @minLevel INT, @maxLevel INT

SET @minLevel = 11
SET @maxLevel = 12
SET @availableCash = (SELECT Cash
                      FROM UsersGames
                      WHERE Id = @userGameId)
SET @itemsCost = (SELECT SUM(Price)
                  FROM Items
                  WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

IF (@availableCash >= @itemsCost AND @userGameLevel >= @maxLevel)

  BEGIN
    BEGIN TRANSACTION
    UPDATE UsersGames
    SET Cash -= @itemsCost
    WHERE Id = @userGameId
    IF (@@ROWCOUNT <> 1)
      BEGIN
        ROLLBACK
        RAISERROR ('Could not make payment', 16, 1)
      END
    ELSE
      BEGIN
        INSERT INTO UserGameItems (ItemId, UserGameId)
          (SELECT
             Id,
             @userGameId
           FROM Items
           WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

        IF ((SELECT COUNT(*)
             FROM Items
             WHERE MinLevel BETWEEN @minLevel AND @maxLevel) <> @@ROWCOUNT)
          BEGIN
            ROLLBACK;
            RAISERROR ('Could not buy items', 16, 1)
          END
        ELSE COMMIT;
      END
  END

SET @minLevel = 19
SET @maxLevel = 21
SET @availableCash = (SELECT Cash
                      FROM UsersGames
                      WHERE Id = @userGameId)
SET @itemsCost = (SELECT SUM(Price)
                  FROM Items
                  WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

IF (@availableCash >= @itemsCost AND @userGameLevel >= @maxLevel)

  BEGIN
    BEGIN TRANSACTION
    UPDATE UsersGames
    SET Cash -= @itemsCost
    WHERE Id = @userGameId

    IF (@@ROWCOUNT <> 1)
      BEGIN
        ROLLBACK
        RAISERROR ('Could not make payment', 16, 1)
      END
    ELSE
      BEGIN
        INSERT INTO UserGameItems (ItemId, UserGameId)
          (SELECT
             Id,
             @userGameId
           FROM Items
           WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

        IF ((SELECT COUNT(*)
             FROM Items
             WHERE MinLevel BETWEEN @minLevel AND @maxLevel) <> @@ROWCOUNT)
          BEGIN
            ROLLBACK
            RAISERROR ('Could not buy items', 16, 1)
          END
        ELSE COMMIT;
      END
  END

SELECT i.Name AS [Item Name]
FROM UserGameItems AS ugi
  JOIN Items AS i
    ON i.Id = ugi.ItemId
  JOIN UsersGames AS ug
    ON ug.Id = ugi.UserGameId
  JOIN Games AS g
    ON g.Id = ug.GameId
WHERE g.Name = @gameName
ORDER BY [Item Name]


CREATE TABLE Deleted_Employees
(
  EmployeeId INT PRIMARY KEY IDENTITY,
  FirstName VARCHAR(50) NOT NULL,
  LastName VARCHAR(50) NOT NULL,
  MiddleName VARCHAR(50),
  JobTitle VARCHAR(50),
  DepartmentId INT,
  Salary DECIMAL(15, 2)
)

CREATE TRIGGER tr_DeleteEmployees
  ON Employees
  AFTER DELETE
AS
  BEGIN
    INSERT INTO Deleted_Employees
      SELECT
        FirstName,
        LastName,
        MiddleName,
        JobTitle,
        DepartmentID,
        Salary
      FROM deleted
  END
