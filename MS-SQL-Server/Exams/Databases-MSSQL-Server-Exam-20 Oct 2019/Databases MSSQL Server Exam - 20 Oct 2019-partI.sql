CREATE DATABASE [Service]

USE [Service]
GO

CREATE TABLE Users(
	Id INT PRIMARY KEY IDENTITY NOT NULL, 
	Username NVARCHAR(30) NOT NULL UNIQUE,	
	[Password] NVARCHAR(50) NOT NULL, 
	[Name] NVARCHAR(50), 	
	Birthdate DATETIME,
	Age INT CHECK (Age > 14 AND Age <= 110),
	Email NVARCHAR(50) NOT NULL 
) 
GO

CREATE TABLE Departments(
	Id INT PRIMARY KEY IDENTITY(0,1), 	
	[Name] NVARCHAR(50) NOT NULL	
)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY(0,1), 
	FirstName NVARCHAR(25), 
	LastName NVARCHAR(25),
	Birthdate DATETIME,	
	Age INT CHECK (Age > 18 AND Age <= 110),
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) 
) 

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY(0,1), 	
	[Name] NVARCHAR(50) NOT NULL,	
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL
)

CREATE TABLE [Status](
	Id INT PRIMARY KEY IDENTITY(0,1), 	
	[Label] NVARCHAR(30) NOT NULL	
)

CREATE TABLE Reports(
	Id INT PRIMARY KEY IDENTITY(0,1), 
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	StatusId INT FOREIGN KEY REFERENCES [Status](Id) NOT NULL,
	OpenDate DATETIME NOT NULL,
	CloseDate DATETIME,
	[Description] NVARCHAR(200) NOT NULL,
	UserId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
) 


INSERT INTO Employees(FirstName,LastName, Birthdate)
VALUES
('Marlo', 'O''''Malley', '1958-9-21'),
('Niki', 'Stanaghan', '1969-11-26'),
('Ayrton', 'Senna', '1960-03-21'),
('Ronnie', 'Peterson', '1944-02-14'),
('Giovanna', 'Amati', '1959-07-20')


INSERT INTO Reports([CategoryId],[StatusId],[OpenDate],[CloseDate],[Description],[UserId],[EmployeeId])
VALUES
(1,1,'2017-04-13',NULL,'Stuck Road on Str.133',6,2),
(6,3,'2015-09-05','2015-12-06','Charity trail running',3,5),
(14,2,'2015-09-07',NULL,'Falling bricks on Str.58',5,2),
(4,3,'2017-07-03','2017-07-06','Cut off streetlight on Str.11',1,1)


UPDATE Reports
SET [CloseDate] = GETDATE() WHERE CloseDate IS NULL

DELETE FROM Reports WHERE [StatusId] = 4


