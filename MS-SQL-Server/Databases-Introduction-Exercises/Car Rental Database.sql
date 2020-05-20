CREATE DATABASE CarRental

USE CarRental

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	CategoryName NVARCHAR(50) NOT NULL,
	DailyRate DECIMAL(15,2) NOT NULL,
	WeeklyRate DECIMAL(15,2) NOT NULL,
	MonthlyRate DECIMAL(15,2) NOT NULL,
	WeekendRate DECIMAL(15,2) NOT NULL
)

INSERT INTO Categories(CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate)
VALUES
('Car', 100.50, 500.50, 2500.50, 300.50),
('Bus', 200.50, 1000.50, 5000.50, 600.50),
('Bike', 50.50, 50.50, 250.50, 30.50)

CREATE TABLE Cars(
	Id INT PRIMARY KEY IDENTITY, 
	PlateNumber NVARCHAR(8) NOT NULL, 
	Manufacturer NVARCHAR(30) NOT NULL, 
	Model NVARCHAR(30) NOT NULL, 
	CarYear DATE NOT NULL, 
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id), 
	Doors INT NOT NULL CHECK(Doors=2 OR Doors=4),
	Picture VARBINARY(MAX), 
	Condition NVARCHAR(50), 
	Available CHAR(1) NOT NULL CHECK(Available='N' OR Available='Y')
)

INSERT INTO Cars (PlateNumber, Manufacturer, 
Model, CarYear, Doors, Picture, Condition, Available)
VALUES
('AA1111AA', 'BMW', 'X5', '2010', 4, NULL, 'Good', 'Y'),
('BB2222BB', 'Audi', 'S6', '2011', 4, NULL, 'Good', 'Y'),
('CC3333CC', 'Mercedes-Benz', 'E280', '2012', 4, NULL, 'Good', 'N')

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL, 
	LastName NVARCHAR(30) NOT NULL, 
	Title NVARCHAR(30) NOT NULL, 
	Notes NVARCHAR(MAX)
)

INSERT INTO Employees(FirstName, LastName, Title, Notes)
VALUES
('Tom', 'Davidson', 'Seller', NULL),
('Ben', 'Jhones', 'Junior Seller', NULL),
('Anton', 'Miller', 'Seior Seller', NULL)

CREATE TABLE Customers(
	Id INT PRIMARY KEY IDENTITY, 
	DriverLicenceNumber NVARCHAR(6) NOT NULL, 
	FullName NVARCHAR(50) NOT NULL, 
	[Address] NVARCHAR(50), 
	City NVARCHAR(30) NOT NULL, 
	ZIPCode INT, 
	Notes NVARCHAR(MAX)
)

INSERT INTO Customers (DriverLicenceNumber, FullName, [Address], City, ZIPCode, Notes)
VALUES
('AA1111', 'FirstName1 SecondName1 ThirdName1', NULL,'Sofia', 1784, NULL),
('BB2222', 'FirstName2 SecondName2 ThirdName2', NULL,'Sofia', 1784, NULL),
('CC3333', 'FirstName3 SecondName3 ThirdName3', NULL,'Sofia', 1784, NULL)

CREATE TABLE RentalOrders(
	Id INT PRIMARY KEY IDENTITY, 
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id), 
	CustomerId INT FOREIGN KEY REFERENCES Customers(Id), 
	CarId INT FOREIGN KEY REFERENCES Cars(Id), 
	TankLevel INT NOT NULL, 
	KilometrageStart DECIMAL(10,2) NOT NULL, 
	KilometrageEnd DECIMAL(10,2) NOT NULL, 
	TotalKilometrage DECIMAL(10,2) NOT NULL, 
	StartDate DATE NOT NULL, 
	EndDate DATE NOT NULL, 
	TotalDays INT NOT NULL, 
	RateApplied DECIMAL(10,2) NOT NULL, 
	TaxRate INT NOT NULL, 
	OrderStatus NVARCHAR(30), 
	Notes NVARCHAR(MAX)
)

INSERT INTO RentalOrders(TankLevel, KilometrageStart, 
KilometrageEnd, TotalKilometrage, StartDate, EndDate, TotalDays, RateApplied, TaxRate, 
OrderStatus, Notes)
VALUES
(60, 70200.50, 70800.50, 600, '2020-05-18', '2020-05-20', 2, 100.50, 20, 'Pending', NULL),
(80, 70200.50, 70800.50, 600, '2020-05-18', '2020-05-20', 2, 100.50, 20, 'Closed', NULL),
(100, 70200.50, 70800.50, 600, '2020-05-18', '2020-05-20', 2, 100.50, 20, 'Pending', NULL)