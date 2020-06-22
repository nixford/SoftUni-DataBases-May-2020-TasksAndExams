CREATE TABLE Cities (
  Id INT PRIMARY KEY IDENTITY,
  [Name] NVARCHAR(20) NOT NULL,
  CountryCode NCHAR(2) NOT NULL
)

CREATE TABLE Hotels (
  Id INT PRIMARY KEY IDENTITY,
  [Name] NVARCHAR(30) NOT NULL,
  CityId INT FOREIGN KEY REFERENCES Cities (Id) NOT NULL,
  EmployeeCount INT NOT NULL,
  BaseRate DECIMAL(15, 2)
)

CREATE TABLE Rooms (
  Id INT PRIMARY KEY IDENTITY,
  Price DECIMAL(15, 2) NOT NULL,
  [Type] NVARCHAR(20) NOT NULL,
  Beds INT NOT NULL,
  HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL
)

CREATE TABLE Trips (
  Id INT PRIMARY KEY IDENTITY,
  RoomId INT NOT NULL,
  BookDate DATE NOT NULL,
  ArrivalDate DATE NOT NULL,
  ReturnDate DATE NOT NULL,
  CancelDate DATE,
  CONSTRAINT FK_Trips_Rooms FOREIGN KEY (RoomId) REFERENCES Rooms (Id),
  CONSTRAINT CK_BookDate_ArrivalDate CHECK (BookDate < ArrivalDate),
  CONSTRAINT CK_ArrivalDate_ReturnDate CHECK (ArrivalDate < ReturnDate),
)

CREATE TABLE Accounts (
  Id INT PRIMARY KEY IDENTITY,
  FirstName NVARCHAR(50) NOT NULL,
  MiddleName NVARCHAR(20),
  LastName NVARCHAR(50) NOT NULL,
  CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
  BirthDate DATE NOT NULL,
  Email VARCHAR(100) NOT NULL UNIQUE
)

CREATE TABLE AccountsTrips (
  AccountId INT FOREIGN KEY REFERENCES Accounts(Id) NOT NULL,
  TripId INT FOREIGN KEY REFERENCES Trips(Id) NOT NULL,
  Luggage INT NOT NULL CHECK (Luggage >= 0),
  CONSTRAINT PK_AccountsTrips PRIMARY KEY (AccountId, TripId)  
)

INSERT INTO Accounts (FirstName, MiddleName, LastName, CityId, BirthDate, Email) 
VALUES
  ('John', 'Smith', 'Smith', '34', '1975-07-21', 'j_smith@gmail.com'),
  ('Gosho', NULL, 'Petrov', '11', '1978-05-16', 'g_petrov@gmail.com'),
  ('Ivan', 'Petrovich', 'Pavlov', '59', '1849-09-26', 'i_pavlov@softuni.bg'),
  ('Friedrich', 'Wilhelm', 'Nietzsche', '2', '1844-10-15', 'f_nietzsche@softuni.bg')

INSERT INTO Trips (RoomId, BookDate, ArrivalDate, ReturnDate, CancelDate) 
VALUES
  (101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02'),
  (102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29'),
  (103, '2013-07-17', '2013-07-23', '2013-07-24', NULL),
  (104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10'),
  (109, '2017-08-07', '2017-08-28', '2017-08-29', NULL)


UPDATE Rooms
	SET Price = Price + Price * 0.14
WHERE HotelId IN (5, 7, 9)


DELETE FROM AccountsTrips
WHERE AccountId = 47


SELECT	a.FirstName,
		a.LastName,
		FORMAT(a.BirthDate, 'MM-dd-yyyy') AS BirthDate,
		c.[Name] AS Hometown,
		a.Email AS Email
		FROM Accounts AS a
		JOIN Cities AS c ON a.CityId = c.Id
		WHERE a.Email LIKE 'e%'
		ORDER BY c.[Name]


SELECT  c.[Name] AS City,
		COUNT(h.Id) AS Hotels
		FROM Cities AS c
		JOIN Hotels AS h ON c.Id = h.CityId	
		WHERE c.[Name] = 'Paris'
		GROUP BY c.Id, c.[Name]
		HAVING LEN(c.[Name]) > 3
		ORDER BY Hotels DESC, c.[Name]

		
SELECT	a.Id AS AccountId,
		a.FirstName + ' ' + a.LastName AS FullName,
		MAX(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS LongestTrip,
		MIN(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS ShortestTrip
		FROM Accounts AS a
		JOIN AccountsTrips AS act ON a.Id = act.AccountId
		JOIN Trips AS t ON act.TripId = t.Id
		WHERE a.MiddleName IS NULL AND t.CancelDate IS NULL
		GROUP BY a.Id, a.FirstName + ' ' + a.LastName
		ORDER BY LongestTrip DESC, ShortestTrip


SELECT TOP(10)
	   a.CityId AS Id,
	   c.[Name] AS City,
	   c.CountryCode AS Country,
	   COUNT(c.[Name]) AS Accounts
	FROM Cities AS c
	JOIN Accounts AS a ON c.Id = a.CityId
	GROUP BY c.[Name], a.CityId, c.CountryCode
	ORDER BY COUNT(c.[Name]) DESC


SELECT  a.Id,
		a.Email,
		c.[Name] AS City,
		COUNT(a.CityId) AS Trips
		FROM Accounts AS a
		JOIN AccountsTrips AS act ON a.Id = act.AccountId
		JOIN Trips AS t ON act.TripId = t.Id
		JOIN Rooms AS r ON r.Id = t.RoomId
		JOIN Hotels AS h ON r.HotelId = h.Id
		JOIN Cities AS c ON h.CityId = c.Id
		WHERE a.CityId = h.CityId
		GROUP BY a.Id, a.Email, a.CityId, c.[Name]		
		ORDER BY Trips DESC, a.Id


SELECT
  t.Id,
  CONCAT(a.FirstName, ' ' + a.MiddleName, ' ', a.LastName) AS [Full Name],
  ac.[Name] AS [From],
  hc.[Name] AS [To],
  CASE WHEN CancelDate IS NOT NULL
    THEN 'Canceled'
  ELSE CONCAT(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate), ' days')
  END AS Duration
FROM Trips AS t
  JOIN AccountsTrips AS act ON t.Id = act.TripId
  JOIN Accounts a ON act.AccountId = a.Id
  JOIN Rooms r ON t.RoomId = r.Id
  JOIN Hotels AS h ON r.HotelId = h.Id
  JOIN Cities AS hc ON H.CityId = hc.Id
  JOIN Cities AS ac on a.CityId = ac.Id
ORDER BY [Full Name], t.Id


CREATE FUNCTION udf_GetAvailableRoom
(@HotelId INT, @Date DATETIME, @People INT)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @resultTable TABLE
	(HotelId INT, RoomId INT, RoomType VARCHAR(50), RoomBeds INT, Price DECIMAL(15, 2))

	INSERT INTO @resultTable
	(HotelId, RoomId, RoomType, RoomBeds, Price)

	SELECT TOP(1) h.Id,
           r.Id,
 		   r.[Type],
 		   r.Beds,
 		   (h.BaseRate + r.Price) * @People AS Price
      FROM Hotels AS h
      JOIN Rooms AS r ON h.Id = r.HotelId
      JOIN Trips AS t ON r.Id = t.RoomId
     WHERE h.Id = @HotelId 
	 AND @Date NOT BETWEEN t.ArrivalDate AND t.ReturnDate 
	 AND r.Beds > @People
  ORDER BY Price DESC

	IF(@HotelId NOT IN (SELECT rt.HotelId FROM @resultTable AS rt))
	BEGIN
		RETURN 'No rooms available'
	END

	DECLARE @targetRoomId INT = (SELECT rt.RoomId FROM @resultTable AS rt WHERE rt.HotelId = @HotelId)
	DECLARE @targetRoomType VARCHAR(50) = (SELECT rt.RoomType FROM @resultTable AS rt WHERE rt.HotelId = @HotelId)
	DECLARE @targetRoomBeds INT = (SELECT rt.RoomBeds FROM @resultTable AS rt WHERE rt.HotelId = @HotelId)
	DECLARE @price DECIMAL(15, 2) = (SELECT rt.Price FROM @resultTable AS rt WHERE rt.HotelId = @HotelId)

	RETURN 'Room ' + CAST(@TargetRoomId AS VARCHAR(50)) + ': ' + @targetRoomType + 
		   ' (' + CAST(@targetRoomBeds AS VARCHAR(50)) + ' beds) - $' + CAST(@price AS VARCHAR(50))
END

SELECT dbo.udf_GetAvailableRoom(112, '2011-12-17', 2)
SELECT dbo.udf_GetAvailableRoom(94, '2015-07-26', 3)


CREATE PROC usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
AS
  BEGIN
    DECLARE @SourceHotelId INT = (SELECT H.Id
                                  FROM Hotels AS H
                                    JOIN Rooms AS R ON H.Id = R.HotelId
                                    JOIN Trips AS T ON R.Id = T.RoomId
                                  WHERE T.Id = @TripId)

    DECLARE @TargetHotelId INT = (SELECT H.Id
                                  FROM Hotels AS H
                                    JOIN Rooms AS R ON H.Id = R.HotelId
                                  WHERE R.Id = @TargetRoomId)

    IF (@SourceHotelId <> @TargetHotelId)
      THROW 50013, 'Target room is in another hotel!', 1

    DECLARE @PeopleCount INT = (SELECT COUNT(*)
                                FROM AccountsTrips
                                WHERE TripId = @TripId)

    DECLARE @TargetRoomBeds INT = (SELECT Beds
                                   FROM Rooms
                                   WHERE Id = @TargetRoomId)

    IF (@PeopleCount > @TargetRoomBeds)
      THROW 50013, 'Not enough beds in target room!', 1

    UPDATE Trips
    SET RoomId = @TargetRoomId
    WHERE Id = @TripId
  END

EXEC usp_SwitchRoom 10, 11
EXEC usp_SwitchRoom 10, 7
SELECT RoomId FROM Trips WHERE Id = 10


