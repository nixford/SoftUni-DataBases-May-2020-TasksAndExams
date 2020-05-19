CREATE DATABASE Minions

USE Minions

CREATE TABLE Minions (
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	Age INT
)

CREATE TABLE Towns (
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,	
)

ALTER TABLE Minions
ADD TownId INT CONSTRAINT FK_TownId_Towns FOREIGN KEY REFERENCES Towns(Id)

INSERT INTO Towns(Id, [Name])
VALUES (1, 'Sofia'),
	   (2, 'Plovdiv'),
	   (3, 'Varna')

INSERT INTO Minions(Id,Name,Age,TownId)
VALUES (1, 'Kevin', 22, 1),
	   (2, 'Bob', 15, 3),
	   (3, 'Steward', NULL, 2)

SET IDENTITY_INSERT Minions ON

DELETE FROM Minions

DROP TABLE Minions

DROP TABLE Towns

CREATE TABLE People
(
 [Id] INT PRIMARY KEY IDENTITY,
 [Name] NVARCHAR(200) NOT NULL,
 [Picture] VARBINARY(MAX),
 [Height] DECIMAL(5,2),
 [Weight] DECIMAL(5,2),
 [Gender] CHAR(1) Not null CHECK(Gender='m' OR Gender='f'),
 Birthdate DATE Not Null,
 Biography NVARCHAR(MAX)
)

INSERT INTO People(Name,Picture,Height,Weight,Gender,Birthdate,Biography) 
VALUES('Anton',Null,1.65,44.55,'m','2000-01-01',Null),
	  ('Ani',Null,2.15,95.55,'f','2001-02-02',Null),
	  ('Bobi',Null,1.55,33.00,'m','2002-03-03',Null),
	  ('Buba',Null,2.15,55.55,'f','2003-04-04',Null),
      ('Ceco',Null,1.85,90.00,'m','2004-05-05',Null)

CREATE TABLE Users(
	Id BIGINT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL UNIQUE,
	[Password] VARCHAR(26) NOT NULL,
	ProfilePicture VARBINARY(MAX),
	LastLoginTime DATETIME,
	IsDeleted BIT
)

INSERT INTO Users(Username, [Password], ProfilePicture, LastLoginTime, IsDeleted)
VALUES
('Stamat', '123', NULL, '05-22-2018', 0),
('Gosho', '125425', NULL, '12-06-2018', 0),
('Pesho', '168531', NULL, '01-01-2018', 0),
('Vankata', '1918653', NULL, '12-02-2018', 0),
('Kicata', '1891653', NULL, '12-05-2018', 0)

SELECT * FROM Users 

CREATE TABLE UsersHiddenPass(
	Id BIGINT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL UNIQUE,
	[Password] BINARY(96) NOT NULL,
	ProfilePicture VARBINARY(MAX),
	LastLoginTime DATETIME,
	IsDeleted BIT
)

INSERT INTO UsersHiddenPass(Username, [Password], ProfilePicture, LastLoginTime, IsDeleted)
VALUES
('Stamat', HASHBYTES('SHA1', '123'), NULL, '05-22-2018', 0)

SELECT * FROM UsersHiddenPass 

