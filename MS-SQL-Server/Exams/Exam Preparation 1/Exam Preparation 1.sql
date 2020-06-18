CREATE TABLE Planes (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(30) NOT NULL,
	Seats INT NOT NULL,
	[Range] INT NOT NULL
)

CREATE TABLE Flights (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	DepartureTime DATETIME,
	ArrivalTime DATETIME,
	Origin NVARCHAR(50),
	Destination NVARCHAR(50),
	PlaneId INT FOREIGN KEY REFERENCES Planes(Id) NOT NULL
)

CREATE TABLE Passengers (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Age INT NOT NULL,
	[Address] NVARCHAR(30) NOT NULL,
	PassportId NVARCHAR(11) NOT NULL
)

CREATE TABLE LuggageTypes (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Type] NVARCHAR(30) NOT NULL	
)

CREATE TABLE Luggages (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	LuggageTypeId INT FOREIGN KEY REFERENCES LuggageTypes(Id),
	PassengerId INT FOREIGN KEY REFERENCES Passengers(Id)
)

CREATE TABLE Tickets (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	PassengerId INT FOREIGN KEY REFERENCES [dbo].[Passengers]([Id]) NOT NULL,
	FlightId INT FOREIGN KEY REFERENCES [dbo].[Flights]([Id]) NOT NULL,
	LuggageId INT FOREIGN KEY REFERENCES [dbo].[Luggages]([Id]) NOT NULL,
	Price DECIMAL(15, 2) NOT NULL
)


INSERT INTO Planes ([Name], Seats, [Range]) 
VALUES
('Airbus 336', 112, 5132),
('Airbus 330', 432, 5325),
('Boeing 369', 231, 2355),
('Stelt 297', 254, 2143),
('Boeing 338', 165, 5111),
('Airbus 558', 387, 1342),
('Boeing 128', 345, 5541)

INSERT INTO LuggageTypes ([Type]) 
VALUES
('Crossbody Bag'),
('School Backpack'),
('Shoulder Bag')


UPDATE Tickets
	SET Price = Price * 1.13
WHERE FlightId = 41


DELETE
  FROM Tickets
  WHERE FlightId IN (
					  SELECT Id FROM Flights
					  WHERE Destination = 'Ayn Halagim'
					);

DELETE
  FROM Flights
 WHERE Destination = 'Ayn Halagim'


 SELECT [Id],
		[Name],
		[Seats],
		[Range]
		FROM Planes 
		WHERE [Name] LIKE '%tr%'
		ORDER BY [Id],[Name],[Seats],[Range] 


SELECT f.Id AS FlightId,
	   SUM(t.Price) AS Price
	FROM Flights AS f
	JOIN Tickets AS t ON f.Id = t.FlightId
	GROUP BY f.Id
	ORDER BY Price DESC, FlightId


SELECT p.FirstName + ' ' + p.LastName AS [Full Name],
	   f.Origin AS Origin,
	   f.Destination AS Destination
	FROM Passengers as p
	JOIN Tickets AS t ON p.Id = t.PassengerId
	JOIN Flights AS f ON t.FlightId = f.Id
	ORDER BY p.FirstName + ' ' + p.LastName, f.Origin, f.Destination


SELECT  p.FirstName AS [First Name],
		p.LastName AS [Last Name],
		p.Age AS [Age]
	FROM Passengers AS p
	LEFT JOIN Tickets AS t ON p.Id = t.PassengerId
	WHERE t.Id IS NULL
	ORDER BY p.Age DESC, p.FirstName, p.LastName

SELECT p.FirstName + ' ' + p.LastName AS [Full Name],
	   pl.[Name] AS [Plane Name],
	   CONCAT(f.Origin, ' - ', f.Destination) AS [Trip],
	   lt.[Type] AS [Luggage Type]
	FROM Passengers AS p
	LEFT JOIN Tickets AS t ON p.Id = t.PassengerId
	LEFT JOIN Flights AS f ON t.FlightId = f.Id
	JOIN Planes AS pl ON f.PlaneId = pl.Id
	JOIN Luggages AS l ON t.LuggageId = l.Id
	JOIN LuggageTypes AS lt ON l.LuggageTypeId = lt.Id
	WHERE t.Id IS NOT NULL
	ORDER BY [Full Name], [Plane Name], f.Origin, f.Destination, [Luggage Type]


SELECT p.[Name],
	   p.Seats,
	   COUNT(ps.Id) AS [Passengers Count]
		FROM Planes AS p
		LEFT JOIN Flights AS f ON p.Id = PlaneId
		LEFT JOIN Tickets AS t ON f.Id = t.FlightId
		LEFT JOIN Passengers AS ps ON t.PassengerId = ps.Id
		GROUP BY p.[Name], p.Seats
		ORDER BY COUNT(ps.Id) DESC, p.[Name], p.Seats


GO
CREATE OR ALTER FUNCTION udf_CalculateTickets
(@origin NVARCHAR(50), @destination NVARCHAR(50), @peopleCount INT) 
RETURNS NVARCHAR(50)
AS
BEGIN
	IF(@peopleCount <= 0)	
		RETURN 'Invalid people count!';

	ELSE IF((SELECT f.Origin 
				FROM Flights AS f 
				WHERE f.Origin = @origin AND f.Destination = @destination) IS NULL)
		RETURN 'Invalid flight!';

	ELSE
	DECLARE @result DECIMAL(15,2) =	(SELECT  
				t.Price	* @peopleCount	
				FROM Flights AS f
				JOIN Tickets AS t ON f.Id = t.FlightId		
				WHERE f.Origin = @origin AND f.Destination = @destination)
	RETURN CONCAT('Total price ', @result);	
END

SELECT dbo.udf_CalculateTickets ('Kolyshley','Rancabolang', -1)

GO
CREATE PROCEDURE usp_CancelFlights
AS
  BEGIN
		UPDATE Flights
			SET
				ArrivalTime = NULL,
				DepartureTime = NULL
		WHERE ArrivalTime > DepartureTime

  END
GO