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

SELECT FirstName + ' ' + ISNULL(MiddleName, '') + ' ' + LastName AS FullName, 
	Address FROM Students
	WHERE Address LIKE '%Road%'
	ORDER BY FirstName, LastName, Address

SELECT FirstName, Address, Phone 
	FROM Students
	WHERE Phone LIKE '42%' AND MiddleName IS NOT NULL
	ORDER BY FirstName

SELECT  s.FirstName,
	    s.LastName,
	    COUNT(t.Id) AS TeachersCount
		FROM Students AS s
		JOIN StudentsTeachers AS st ON s.Id = st.StudentId
		JOIN Teachers AS t ON st.TeacherId = t.Id
		GROUP BY s.FirstName, s.LastName

SELECT t.FirstName + ' ' + t.LastName AS [Name], s.[Name] + '-' + CAST(s.Lessons AS NVARCHAR(5)) AS Subjects,
	COUNT(ss.StudentId) AS Students
	FROM Teachers AS t
	JOIN Subjects AS s ON s.Id = t.SubjectId
	JOIN StudentsTeachers AS ss ON ss.TeacherId = t.Id
	GROUP BY t.FirstName, t.LastName, s.Name,s.Lessons
	ORDER BY COUNT(ss.StudentId) DESC, Name, Subjects
	   	 
SELECT s.FirstName + ' ' + s.LastName AS [Full Name]
	FROM Students AS s
	LEFT JOIN StudentsExams AS se ON s.Id = se.StudentId	
	WHERE ExamId IS NULL
	ORDER BY [Full Name]

SELECT TOP(10) t.FirstName, t.LastName, COUNT(*) AS StudentsCount
     FROM Students AS s
	 JOIN StudentsTeachers AS st ON st.StudentId = s.Id
	 JOIN Teachers AS t ON t.Id = st.TeacherId 
	 GROUP BY t.FirstName, t.LastName
	 ORDER BY StudentsCount DESC, FirstName, LastName
	 	 
SELECT TOP(10)  s.FirstName AS [First Name],
		s.LastName AS [Last Name],
		CAST(AVG(se.Grade) AS DECIMAL(15,2)) AS Grade
		FROM Students AS s
		JOIN StudentsExams AS se ON s.Id = se.StudentId
		GROUP BY s.FirstName, s.LastName
		ORDER BY Grade DESC, s.FirstName ASC, s.LastName ASC

SELECT k.FirstName, k.LastName, k.Grade
  FROM (
   SELECT FirstName, LastName, Grade, 
          ROW_NUMBER() OVER (PARTITION BY FirstName, LastName ORDER BY Grade DESC) AS RowNumber
		  FROM Students AS s
		  JOIN StudentsSubjects AS ss ON ss.StudentId = s.Id
		) AS k
 WHERE k.RowNumber = 2
 ORDER BY FirstName, LastName
 
SELECT 
	CONCAT(s.FirstName, ISNULL(' ' + s.MiddleName, ''), ' ', s.LastName) AS [Full Name]
	FROM Students AS s
	LEFT JOIN StudentsSubjects AS ss ON s.Id = ss.StudentId
	LEFT JOIN Subjects AS sb ON ss.SubjectId = sb.Id
	WHERE sb.[Name] IS NULL
	ORDER BY [Full Name]


SELECT j.[Teacher Full Name], j.SubjectName ,j.[Student Full Name], FORMAT(j.TopGrade, 'N2') AS Grade
  FROM (
SELECT k.[Teacher Full Name],k.SubjectName, k.[Student Full Name], k.AverageGrade  AS TopGrade,
	   ROW_NUMBER() OVER (PARTITION BY k.[Teacher Full Name] ORDER BY k.AverageGrade DESC) AS RowNumber
  FROM (
  SELECT t.FirstName + ' ' + t.LastName AS [Teacher Full Name],
  	   s.FirstName + ' ' + s.LastName AS [Student Full Name],
  	   AVG(ss.Grade) AS AverageGrade,
  	   su.Name AS SubjectName
    FROM Teachers AS t 
    JOIN StudentsTeachers AS st ON st.TeacherId = t.Id
    JOIN Students AS s ON s.Id = st.StudentId
    JOIN StudentsSubjects AS ss ON ss.StudentId = s.Id
    JOIN Subjects AS su ON su.Id = ss.SubjectId AND su.Id = t.SubjectId
GROUP BY t.FirstName, t.LastName, s.FirstName, s.LastName, su.Name
) AS k
) AS j
   WHERE j.RowNumber = 1 
ORDER BY j.SubjectName,j.[Teacher Full Name], TopGrade DESC

SELECT	
		s.[Name],
		AVG(ss.Grade) AS AverageGrade
		FROM Subjects AS s
		JOIN StudentsSubjects AS ss ON s.Id = ss.SubjectId	
		GROUP BY s.[Name], s.Id
		ORDER BY s.Id
		
SELECT  k.Quarter, k.SubjectName, COUNT(k.StudentId) AS StudentsCount
  FROM (
  SELECT s.Name AS SubjectName,
		 se.StudentId,
		 CASE
		 WHEN DATEPART(MONTH, Date) BETWEEN 1 AND 3 THEN 'Q1'
		 WHEN DATEPART(MONTH, Date) BETWEEN 4 AND 6 THEN 'Q2'
		 WHEN DATEPART(MONTH, Date) BETWEEN 7 AND 9 THEN 'Q3'
		 WHEN DATEPART(MONTH, Date) BETWEEN 10 AND 12 THEN 'Q4'
		 WHEN Date IS NULL THEN 'TBA'
		 END AS [Quarter]
    FROM Exams AS e
	JOIN Subjects AS s ON s.Id = e.SubjectId 
	JOIN StudentsExams AS se ON se.ExamId = e.Id
	WHERE se.Grade >= 4
) AS k
GROUP BY k.Quarter, k.SubjectName
ORDER BY k.Quarter


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
