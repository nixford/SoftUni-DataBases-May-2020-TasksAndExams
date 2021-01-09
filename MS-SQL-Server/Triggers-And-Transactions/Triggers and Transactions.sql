--Triggers and Transactions


--01. Create Table Logs
CREATE TABLE LOGS(
LogId INT IDENTITY,
AccountId INT NOT NULL,
OldSum MONEY,
NewSum MONEY,
CONSTRAINT PK_Logs
PRIMARY KEY (LogId),
CONSTRAINT FK_Logs_Accounts
FOREIGN KEY(AccountId)
REFERENCES Accounts(Id)
)
GO

CREATE TRIGGER tr_ChangedAccount_After_Updates
ON Accounts
AFTER UPDATE
AS
BEGIN
	INSERT INTO Logs(AccountId, OldSum, NewSum)
	SELECT deleted.Id AS AccountId,
		   deleted.Balance AS OldSum,
		   inserted.Balance AS NewSum 
	FROM inserted
	INNER JOIN deleted
	ON deleted.Id = inserted.Id
END

UPDATE Accounts
SET Balance += 10
WHERE Id = 1

SELECT * FROM Accounts
SELECT * FROM Ëîãñ


--02. Create Table Emails
CREATE TABLE NotificationEmails(
Id INT IDENTITY,
Recipient INT NOT NULL,
Subject VARCHAR(255),
Body VARCHAR(MAX),
CONSTRAINT PK_NotificationEmails
PRIMARY KEY(Id),
CONSTRAINT FK_NotificationEmails_Logs
FOREIGN KEY(Recipient)
REFERENCES Logs(LogId)
)
GO

CREATE  TRIGGER tr_EmailWriter_Afret_Update
ON Logs
AFTER INSERT
AS
BEGIN
	DECLARE @recipient INT = (SELECT AccountId FROM inserted)
	DECLARE @oldSum MONEY = (SELECT OldSum FROM inserted)
	DECLARE @newSum MONEY = (SELECT NewSum FROM inserted)

	INSERT INTO NotificationEmails(Recipient, Subject, Body) 
	VALUES (@recipient 
			,'Balance change for account: '+CAST(@recipient AS VARCHAR)
			,'On '+CAST(GETDATE() AS VARCHAR)
			+' your balance was changed from '+CAST(@OldSum AS VARCHAR)
			+' to '+CAST(@NewSum AS VARCHAR))
END

SELECT * FROM NotificationEmails


--03. Deposit Money 
CREATE PROC usp_DepositMoney (@accountId INT, @moneyAmount DECIMAL(15,4)) 
AS
BEGIN
	IF(@moneyAmmount > 0)
	BEGIN
		UPDATE Accounts SET Balance += @moneyAmount	
		WHERE Id = @AccountId
	END
END

EXECUTE usp_DepositMoney 1, 10 


--04. Withdraw Money Procedure
CREATE PROC usp_WithdrawMoney (@accountId INT, @moneyAmount DECIMAL(15, 4))  
AS
	IF(@moneyAmount >0)
	BEGIN
		UPDATE Accounts SET Balance -= @moneyAmount
		WHERE Id = @accountId
	END

	EXEC usp_WithdrawMoney 1, 10

	SELECT * FROM Accounts


--05. Money Transfer
CREATE OR ALTER PROC usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount DECIMAL(15, 4)) 
AS
BEGIN TRANSACTION
		EXEC usp_WithdrawMoney @SenderId, @Amount     
		EXEC usp_DepositMoney @ReceiverId, @Amount				

		DECLARE @senderBalance DECIMAL(15,4) = (SELECT Balance FROM Accounts
							 WHERE Id = @SenderId)
		IF(@senderBalance < 0)
		BEGIN
			ROLLBACK
			RETURN
		END
COMMIT

EXEC usp_TransferMoney 1, 2, 10

SELECT * FROM Accounts


--07. *Massive Shopping
DECLARE @userId INT = (SELECT Id FROM Users WHERE Username = 'Stamat')
DECLARE @gameId INT = (SELECT Id FROM Games WHERE Name = 'Safflower')
DECLARE @userGameId INT = (SELECT Id FROM UsersGames WHERE UserID = @userId AND
							GameID = @gameId)
BEGIN TRY
BEGIN TRANSACTION
	UPDATE UsersGames
	SET Cash -= (SELECT SUM(Price) FROM Items WHERE MinLevel IN (11, 12))
	WHERE Id = @userGameId
		
	DECLARE @userBalance DECIMAL(15,4) = (SELECT Cash FROM UsersGames WHERE Id = @userGameId )
	If(@userBalance < 0)
	BEGIN
		ROLLBACK
		RETURN
	END

	INSERT INTO UserGameItems
	SELECT Id, @userGameId FROM Items WHERE MinLevel IN (11, 12)
COMMIT
END TRY
BEGIN CATcH
	ROLLBACK
END CATCH

BEGIN TRY
BEGIN TRANSACTION
	UPDATE UsersGames
	SET Cash -= (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 19 AND 21)
	WHERE Id = @userGameId
		
	SET @userBalance = (SELECT Cash FROM UsersGames WHERE Id = @userGameId )
	If(@userBalance < 0)
	BEGIN
		ROLLBACK
		RETURN
	END

	INSERT INTO UserGameItems
	SELECT Id, @userGameId FROM Items WHERE MinLevel BETWEEN 19 AND 21
COMMIT
END TRY
BEGIN CATcH
	ROLLBACK
END CATCH

SELECT i.Name  AS 'Item Name'
FROM Items AS i
JOIN UserGameItems AS u
ON u.ItemId = i.Id
WHERE u.UserGameId = @userGameId
ORDER BY 'Item Name'


--08. Employees with Three Projects
CREATE  PROC usp_AssignProject(@emloyeeId INT, @projectID INT) 
AS
BEGIN TRANSACTION

	INSERT INTO EmployeesProjects 
	VALUES (@emloyeeId, @projectID) 

DECLARE @projectsCount INT = (SELECT COUNT(ProjectId) FROM EmployeesProjects
							WHERE EmployeeID = @emloyeeId)
	IF(@projectsCount > 3)
	BEGIN
		RAISERROR('The employee has too many projects!',16, 1)
		ROLLBACK
		RETURN
	END	
COMMIT


EXEC usp_AssignProject 2, 2

SELECT * FROM EmployeesProjects


--09. Delete Employees
Create table Deleted_Employees(
EmployeeId INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(40) NOT NULL,
LastName VARCHAR(40) NOT NULL,
MiddleName VARCHAR(40), 
JobTitle VARCHAR(40) NOT NULL, 
DeparmentId INT NOT NULL FOREIGN KEY 
REFERENCES Departments(DepartmentID), 
Salary MONEY) 
GO

CREATE  TRIGGER tr_DeletedEmploees
ON Employees
AFTER DELETE
AS
BEGIN
	INSERT INTO Deleted_Employees
	SELECT FirstName, LastName, MiddleName, JobTitle, DepartmentID, Salary 
	FROM deleted
END


DELETE FROM Employees
WHERE EmployeeID = 1

SELECT * FROM Deleted_Employees