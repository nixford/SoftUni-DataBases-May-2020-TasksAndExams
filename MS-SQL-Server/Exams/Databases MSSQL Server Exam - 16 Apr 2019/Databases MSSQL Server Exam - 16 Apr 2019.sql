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
	Origin NVARCHAR(50) NOT NULL,
	Destination NVARCHAR(50) NOT NULL,
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
	LuggageTypeId INT FOREIGN KEY REFERENCES LuggageTypes(Id) NOT NULL,
	PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL
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


 SELECT Origin,
		Destination
		FROM Flights
		ORDER BY Origin, Destination


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


SELECT TOP(10)
		p.FirstName,
		p.LastName,
		t.Price
		FROM Passengers AS p
		JOIN Tickets AS t ON p.Id = t.PassengerId
		ORDER BY t.Price DESC, p.FirstName, p.LastName


SELECT  lt.[Type] AS [Type],
		COUNT(l.LuggageTypeId) AS MostUsedLuggage
		FROM Luggages AS l
		JOIN LuggageTypes AS lt ON l.LuggageTypeId = lt.Id
		GROUP BY l.LuggageTypeId, lt.[Type]
		ORDER BY MostUsedLuggage DESC, [Type]


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


SELECT p.PassportId AS [Passport Id],
	   p.[Address] AS [Address]
		FROM Passengers AS p
		LEFT JOIN Luggages AS l ON p.Id = l.PassengerId
		WHERE l.PassengerId IS NULL
		ORDER BY [Passport Id], [Address]


SELECT  p.FirstName AS [First Name],
		p.LastName AS [Last Name],
		COUNT(t.PassengerId) AS [Total Trips]
		FROM Passengers AS p
		LEFT JOIN Tickets AS t ON p.Id = t.PassengerId
		GROUP BY t.PassengerId, p.FirstName, p.LastName
		ORDER BY [Total Trips] DESC, [First Name], [Last Name]


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


SELECT k.FirstName, k.LastName, k.Destination, k.Price
  FROM (
	SELECT p.FirstName, p.LastName, f.Destination, t.Price,
		   DENSE_RANK() OVER(PARTITION BY p.FirstName, p.LastName ORDER BY t.Price DESC) As PriceRank
	  FROM Passengers AS p
	  JOIN Tickets AS t ON t.PassengerId = p.Id
	  JOIN Flights AS f ON f.Id = t.FlightId
  ) AS k 
  WHERE k.PriceRank = 1
  ORDER BY k.Price DESC, k.FirstName, k.LastName, k.Destination
  

SELECT	f.Destination,
		COUNT(t.Id) AS FilesCount
		FROM Flights AS f
		LEFT JOIN Tickets AS t ON f.Id = t.FlightId
		GROUP BY f.Destination
		ORDER BY FilesCount DESC, f.Destination


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
CREATE FUNCTION udf_CalculateTickets
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


CREATE PROCEDURE usp_DeletedPlanes
(@StudentId INT)
AS
	DECLARE @currName INT = (SELECT [s].[Id]
	                               FROM [dbo].[Students] AS s
								   WHERE [s].[Id] = @studentId)
	IF(@currName IS NULL)
	BEGIN
		RAISERROR('This school has no student with the provided id!', 16, 1)
		RETURN
	END

	ELSE
		BEGIN
				DELETE FROM StudentsSubjects
					   WHERE StudentId = @StudentId
										  
				DELETE FROM StudentsExams
					   WHERE StudentId = @StudentId
										
				DELETE FROM StudentsTeachers
					   WHERE StudentId = @StudentId										

				DELETE FROM Students
					  WHERE Id = @StudentId
		END


CREATE TABLE DeletedPlanes
(
	Id INT,
	Name VARCHAR(30),
	Seats INT,
	Range INT
)

CREATE TRIGGER tr_DeletedPlanes ON Planes 
AFTER DELETE AS
  INSERT INTO DeletedPlanes (Id, Name, Seats, Range) 
      (SELECT Id, Name, Seats, Range FROM deleted)