CREATE TABLE Students(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(30) NOT NULL,
	MiddleName NVARCHAR(25),
	LastName NVARCHAR(30) NOT NULL,
	Age INT NOT NULL CHECK(Age BETWEEN 5 AND 100),
	[Address] NVARCHAR(50),
	Phone NVARCHAR(10) CHECK(LEN(Phone) = 10)
)

CREATE TABLE Subjects(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(20) NOT NULL,
	Lessons INT NOT NULL CHECK(Lessons > 0)
)

CREATE TABLE StudentsSubjects(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
	SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL, 
	Grade DECIMAL(15,2) NOT NULL CHECK(Grade BETWEEN 2 AND 6)
)

CREATE TABLE Exams(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Date] DATETIME,
	SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL
)

CREATE TABLE StudentsExams (
	StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
	ExamId INT FOREIGN KEY REFERENCES Exams(Id) NOT NULL,
	Grade DECIMAL(15,2) NOT NULL CHECK(Grade BETWEEN 2 AND 6),
	CONSTRAINT PK_StudentsExams PRIMARY KEY(StudentId, ExamId)
)

CREATE TABLE Teachers(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(20) NOT NULL,
	LastName NVARCHAR(20) NOT NULL,
	[Address] NVARCHAR(20)NOT NULL,
	Phone NVARCHAR(10) CHECK(LEN(Phone) = 10),
	SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL
)

CREATE TABLE StudentsTeachers(
	StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
	TeacherId INT FOREIGN KEY REFERENCES Teachers(Id) NOT NULL,
	CONSTRAINT PK_StudentsTeachers PRIMARY KEY(StudentId, TeacherId)
)


INSERT INTO Teachers (FirstName, LastName, [Address], Phone, SubjectId) 
VALUES
('Ruthanne', 'Bamb', '84948 Mesta Junction', '3105500146', 6),
('Gerrard', 'Lowin', '370 Talisman Plaza', '3324874824', 2),
('Merrile', 'Lambdin', '81 Dahle Plaza', '4373065154', 5),
('Bert', 'Ivie', '2 Gateway Circle', '4409584510', 4)

INSERT INTO Subjects ([Name], Lessons) 
VALUES 
('Geometry', 12),
('Health', 10),
('Drama', 7),
('Sports', 9)

SELECT * 
		FROM StudentsSubjects
		WHERE SubjectId IN (1,2) AND Grade >= 5.50

UPDATE StudentsSubjects
	SET Grade = 6.00
WHERE SubjectId IN(1,2) AND Grade >= 5.50 


DELETE
  FROM StudentsTeachers
  WHERE TeacherId IN (
					  SELECT Id FROM Teachers
					  WHERE Phone LIKE '%72%'
					);
DELETE FROM Teachers
	WHERE Phone LIKE '%72%'


SELECT FirstName,
	   LastName,
	   Age
	FROM Students
	WHERE Age >= 12 
	ORDER BY FirstName, LastName, Age

SELECT  s.FirstName,
	    s.LastName,
	    COUNT(t.Id) AS TeachersCount
		FROM Students AS s
		JOIN StudentsTeachers AS st ON s.Id = st.StudentId
		JOIN Teachers AS t ON st.TeacherId = t.Id
		GROUP BY s.FirstName, s.LastName


SELECT s.FirstName + ' ' + s.LastName AS [Full Name]
		FROM Students AS s
		LEFT JOIN StudentsExams AS se ON s.Id = se.StudentId	
		WHERE ExamId IS NULL
		ORDER BY [Full Name]


SELECT TOP(10)  s.FirstName AS [First Name],
		s.LastName AS [Last Name],
		CAST(AVG(se.Grade) AS DECIMAL(15,2)) AS Grade
		FROM Students AS s
		JOIN StudentsExams AS se ON s.Id = se.StudentId
		GROUP BY s.FirstName, s.LastName
		ORDER BY Grade DESC, s.FirstName ASC, s.LastName ASC


SELECT 
	CONCAT(s.FirstName, ISNULL(' ' + s.MiddleName, ''), ' ', s.LastName) AS [Full Name]
	FROM Students AS s
	LEFT JOIN StudentsSubjects AS ss ON s.Id = ss.StudentId
	LEFT JOIN Subjects AS sb ON ss.SubjectId = sb.Id
	WHERE sb.[Name] IS NULL
	ORDER BY [Full Name]


SELECT	
		s.[Name],
		AVG(ss.Grade) AS AverageGrade
		FROM Subjects AS s
		JOIN StudentsSubjects AS ss ON s.Id = ss.SubjectId	
		GROUP BY s.[Name], s.Id
		ORDER BY s.Id

GO
CREATE FUNCTION udf_ExamGradesToUpdate
(@studentId INT, @grade DECIMAL(15,2))
RETURNS VARCHAR(MAX)
AS
BEGIN
DECLARE @currName VARCHAR(50) = (SELECT [s].[FirstName]
	                                     FROM [dbo].[Students] AS s
										WHERE [s].[Id] = @studentId)

	IF(@currName IS NULL)
		RETURN 'The student with provided id does not exist in the school!'

	IF(@grade > 6.00)
		RETURN 'Grade cannot be above 6.00!'

	DECLARE @count INT = (SELECT COUNT(*)
	                        FROM [dbo].[Students] AS s
							JOIN [dbo].[StudentsExams] AS [se] ON [s].[Id] = [se].[StudentId]
	                       WHERE [s].[Id] = @studentId AND [se].[Grade] BETWEEN @grade AND @grade + 0.50)

	RETURN CONCAT('You have to update ', @count, ' grades for the student ', @currName)
END


GO
CREATE PROCEDURE usp_ExcludeFromSchool
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
GO
