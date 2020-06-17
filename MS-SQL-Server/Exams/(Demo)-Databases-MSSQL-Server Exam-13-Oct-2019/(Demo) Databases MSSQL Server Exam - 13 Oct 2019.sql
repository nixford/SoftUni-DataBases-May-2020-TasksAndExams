CREATE TABLE Users (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Username NVARCHAR(30) NOT NULL,
	[Password] NVARCHAR(30) NOT NULL,
	Email NVARCHAR(50) NOT NULL
)

CREATE TABLE Repositories (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL	
)

CREATE TABLE RepositoriesContributors (
	RepositoryId INT NOT NULL, 
	ContributorId INT NOT NULL,
	CONSTRAINT PK_RepositoriesContributors PRIMARY KEY(RepositoryId, ContributorId),
	CONSTRAINT FK_RepositoriesContributors_Repositories 
		FOREIGN KEY(RepositoryId) 
		REFERENCES Repositories(Id), 
	CONSTRAINT FK_RepositoriesContributors_Users 
		FOREIGN KEY(ContributorId) 
		REFERENCES Users(Id)	
)

CREATE TABLE Issues (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Title NVARCHAR(255) NOT NULL,
	IssueStatus NVARCHAR(6) NOT NULL,	
	RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
	AssigneeId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
)

CREATE TABLE Commits (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Message] NVARCHAR(255) NOT NULL,
	IssueId INT FOREIGN KEY REFERENCES Issues(Id),
	RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
	ContributorId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
)

CREATE TABLE Files (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(100) NOT NULL,
	[Size] DECIMAL(18,2) NOT NULL,
	ParentId INT FOREIGN KEY REFERENCES Files(Id),
	CommitId INT FOREIGN KEY REFERENCES Commits(Id) NOT NULL
)


INSERT INTO Files([Name], Size, ParentId, CommitId)
VALUES
('Trade.idk', 2598.0, 1, 1),
('menu.net', 9238.31, 2, 2),
('Administrate.soshy', 1246.93, 3, 3),
('Controller.php', 7353.15, 4, 4),
('Find.java', 9957.86, 5, 5),
('Controller.json', 14034.87, 3, 6),
('Operate.xix', 7662.92, 7, 7)


INSERT INTO Issues(Title, IssueStatus, RepositoryId, AssigneeId)
VALUES
('Critical Problem with HomeController.cs file', 'open', 1, 4),
('Typo fix in Judge.html', 'open', 4, 3),
('Implement documentation for UsersService.cs', 'closed', 8, 2),
('Unreachable code in Index.cs', 'open', 9, 8)


UPDATE Issues
   SET IssueStatus = 'closed'
 WHERE AssigneeId = 6


DELETE
  FROM [dbo].[RepositoriesContributors]
 WHERE [dbo].[RepositoriesContributors].[RepositoryId] IN (SELECT [r].[Id]
  FROM [dbo].[Repositories] AS r
 WHERE [r].[Name] = 'Softuni-Teamwork');

DELETE
  FROM [dbo].[Issues]
 WHERE [dbo].[Issues].[RepositoryId] IN (SELECT [r].[Id]
  FROM [dbo].[Repositories] AS r
 WHERE [r].[Name] = 'Softuni-Teamwork');


 SELECT Id AS Id,
		[Message] AS [Message],
		RepositoryId AS [RepositoryId],
		ContributorId AS [ContributorId]
	FROM Commits
	ORDER BY Id, [Message], RepositoryId, ContributorId

SELECT Id AS Id,
	   [Name] AS [Name],
	   Size AS Size
	FROM Files
	WHERE Size > 1000 AND [Name] LIKE '%html'
	ORDER BY Size DESC, Id ASC, [Name] ASC

SELECT i.Id AS Id,
	   u.Username + ' : ' +  i.Title AS IssueAssignee
	FROM Issues AS i
	JOIN Users AS u ON i.AssigneeId = u.Id
	ORDER BY i.Id DESC, u.Username + ' : ' +  i.Title


SELECT f.Id AS Id,
	   f.[Name] AS [Name],
	   CONCAT(f.Size, 'KB') AS Size
	FROM Files AS f
	LEFT JOIN Files AS r ON f.Id = r.ParentId
	WHERE r.ParentId IS NULL
	ORDER BY f.Id, f.[Name], f.Size DESC

SELECT TOP(5) 
		r.Id,
		r.[Name],
	    COUNT(c.Id) AS Commits
	    FROM Repositories AS r
	    JOIN Commits AS c ON r.Id = c.RepositoryId
		JOIN RepositoriesContributors AS rc ON r.Id = rc.RepositoryId
	GROUP BY r.Id, r.[Name]
	ORDER BY Commits DESC, r.Id, r.[Name]


SELECT u.Username,	   
	   AVG(f.Size) AS Size
	FROM Users AS u
	JOIN Commits AS c ON u.Id = c.ContributorId
	JOIN Files AS f ON c.Id = f.CommitId
	WHERE u.Id IS NOT NULL
	GROUP BY u.Username	
	ORDER BY AVG(f.Size) DESC, u.Username

GO
CREATE FUNCTION udf_UserTotalCommits
(@username VARCHAR(50))
RETURNS INT
AS
BEGIN
	RETURN
	(
	SELECT 
		COUNT(*)		   
		FROM Users AS u
		JOIN Commits AS c ON u.Id = c.ContributorId
		WHERE u.Username = @username		
	)		
END
GO
SELECT dbo.udf_UserTotalCommits('UnderSinduxrein')


CREATE PROCEDURE usp_FindByExtension
(@extension VARCHAR(20))
AS
	SELECT f.Id AS Id,
		   f.[Name] AS [Name],
		   CONCAT(f.Size, 'KB') AS Size
		FROM Files AS f	
		WHERE CHARINDEX(@extension, [f].[Name]) > 0
		ORDER BY f.Id ASC, f.[Name] ASC, f.Size DESC
GO