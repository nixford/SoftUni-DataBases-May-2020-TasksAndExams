SELECT CountryName AS [Country Name], IsoCode AS [ISO Code]
	FROM Countries
	WHERE CountryName LIKE '%a%a%a%'
	ORDER BY IsoCode

SELECT p.PeakName, r.RiverName, 
	LOWER (CONCAT(p.PeakName, SUBSTRING(r.RiverName, 2, LEN(r.RiverName) - 1))) AS [Mix]
	FROM Peaks AS p, Rivers AS r	
	WHERE RIGHT(p.PeakName, 1) = LEFT(r.RiverName, 1)
	ORDER BY [Mix]
