CREATE DATABASE Hotel 

USE Hotel 

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL, 
	LastName NVARCHAR(50) NOT NULL, 
	Title NVARCHAR(50) NOT NULL, 
	Notes NVARCHAR(MAX)	
)

INSERT INTO Employees(FirstName, LastName, Title, Notes)
VALUES
('Tom', 'Davidson', 'Accounter', NULL),
('Ben', 'Jhones', 'Junior Accounter', NULL),
('Anton', 'Miller', 'Seior Accounter', NULL)

CREATE TABLE Customers(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	AccountNumber BIGINT,
	FirstName VARCHAR(50),
	LastName VARCHAR(50),
	PhoneNumber VARCHAR(15),
	EmergencyName VARCHAR(150),
	EmergencyNumber VARCHAR(15),
	Notes VARCHAR(MAX)
)

INSERT INTO Customers(AccountNumber, FirstName, LastName, PhoneNumber, 
EmergencyName, EmergencyNumber, Notes)
VALUES
(1234, 'Tom', 'Davidson', '1234567891', 'EmergencyName1', '1134567891', NULL),
(2345, 'Ben', 'Jhones', '2234567891', 'EmergencyName2', '2134567891', NULL),
(3456, 'Anton', 'Miller', '3234567891', 'EmergencyName3', '3134567891', NULL)

CREATE TABLE RoomStatus(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	RoomStatus CHAR(1) NOT NULL CHECK(RoomStatus='F' OR RoomStatus='N'), 
	Notes NVARCHAR(MAX)
)

INSERT INTO RoomStatus(RoomStatus, Notes)
VALUES
('F', NULL),
('N', NULL),
('F', NULL)

CREATE TABLE RoomTypes(
	RoomType VARCHAR(50) PRIMARY KEY,
	Notes VARCHAR(MAX)
)
 
INSERT INTO RoomTypes (RoomType, Notes)
VALUES
('Suite', 'Two beds'),
('Wedding suite', 'One king size bed'),
('Apartment', 'Up to 3 adults and 2 children')

CREATE TABLE BedTypes(
	BedType VARCHAR(50) PRIMARY KEY,
	Notes VARCHAR(MAX)
)
 
INSERT INTO BedTypes
VALUES
('Double', 'One adult and one child'),
('King size', 'Two adults'),
('Couch', 'One child')

CREATE TABLE Rooms(
	RoomNumber INT PRIMARY KEY IDENTITY NOT NULL,	
	RoomType VARCHAR(50) FOREIGN KEY REFERENCES RoomTypes(RoomType),
	BedType VARCHAR(50) FOREIGN KEY REFERENCES BedTypes(BedType),
	Rate DECIMAL(6,2),
	RoomStatus CHAR(1),
	Notes NVARCHAR(MAX)
)

INSERT INTO Rooms (Rate, Notes)
VALUES
(1,'F'),
(2, 'N'),
(3, 'F')

CREATE TABLE Payments(
	Id INT PRIMARY KEY IDENTITY, 
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id), 
	PaymentDate DATE, 
	AccountNumber INT, 
	FirstDateOccupied DATE, 
	LastDateOccupied DATE, 
	TotalDays AS DATEDIFF(DAY, FirstDateOccupied, LastDateOccupied), 
	AmountCharged DECIMAL(15,2), 
	TaxRate DECIMAL(15,2), 
	TaxAmount DECIMAL(15,2), 
	PaymentTotal DECIMAL(15,2), 
	Notes VARCHAR(MAX)
)

INSERT INTO Payments (EmployeeId, PaymentDate, AmountCharged)
VALUES
(1, '01/01/2020', 3000.50),
(2, '01/01/2020', 3500.50),
(3, '01/01/2020', 4500.50)

CREATE TABLE Occupancies(
	Id  INT PRIMARY KEY IDENTITY NOT NULL,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id), 
	DateOccupied DATE, 
	AccountNumber BIGINT, 
	RoomNumber INT FOREIGN KEY REFERENCES Rooms(RoomNumber), 
	RateApplied DECIMAL(15,2), 
	PhoneCharge DECIMAL(15,2), 
	Notes NVARCHAR(MAX)
)

INSERT INTO Occupancies (EmployeeId, RateApplied, Notes) 
VALUES
(1, 55.55, NULL),
(2, 15.55, NULL),
(3, 35.55, NULL)

UPDATE Payments
SET TaxRate *= 0.97

SELECT TaxRate FROM Payments


TRUNCATE TABLE Occupancies
