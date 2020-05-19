CREATE DATABASE Movies

USE Movies

CREATE TABLE Directors(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	DirectorName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Directors(DirectorName,Notes)
VALUES
('director1', NULL),
('director2', NULL),
('director3', NULL),
('director4', NULL),
('director5', NULL)

CREATE TABLE Genres(
	Id INT PRIMARY KEY IDENTITY,
	GenreName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Genres(GenreName, Notes)
VALUES
('Genres1', NULL),
('Genres2', NULL),
('Genres3', NULL),
('Genres4', NULL),
('Genres5', NULL)

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	CategoryName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO Categories(CategoryName, Notes)
VALUES
('Categories1', NULL),
('Categories2', NULL),
('Categories3', NULL),
('Categories4', NULL),
('Categories5', NULL)

CREATE TABLE Movies(
	Id INT PRIMARY KEY IDENTITY,
	Title NVARCHAR(50) NOT NULL,
	DirectorId INT FOREIGN KEY REFERENCES Directors(Id),
	CopyrightYear INT,
	[Length] TIME,
	GenreId INT FOREIGN KEY REFERENCES Genres(Id),
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id),
	Rating INT,
	Notes NVARCHAR(MAX)
)

INSERT INTO Movies(Title, CopyrightYear, [Length], Rating, Notes)
VALUES
('Film1', 2000, '01:50:25', 10, 'asdasdasdasdad'),
('Film2', 2001, '01:50:25', 5, 'xvcxvcxcvxcvxcv'),
('Film3', 2002, '01:50:25', 3, 'hjkhjkhjkhjkhjk'),
('Film4', 2003, '01:50:25', 4, 'rtyrtyrtyrtyrty'),
('Film5', 2004, '01:50:25', 10, 'jkljkljkljkljk')