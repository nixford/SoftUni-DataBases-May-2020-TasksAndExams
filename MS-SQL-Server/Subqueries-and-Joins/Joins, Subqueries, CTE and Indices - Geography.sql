SELECT c.CountryCode, m.MountainRange, p.PeakName, p.Elevation
	FROM Countries AS c
	JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
    JOIN Mountains AS m ON mc.MountainId = m.Id
    JOIN Peaks AS p ON p.MountainId = m.Id
WHERE c.CountryName = 'Bulgaria'
      AND p.Elevation > 2835
ORDER BY p.Elevation DESC; 

SELECT c.CountryCode, COUNT(mc.MountainId) AS MountainRanges
	   FROM Countries AS c
       LEFT OUTER JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
	   GROUP BY mc.CountryCode, c.CountryCode, CountryName
	   HAVING c.CountryName IN('United States', 'Russia', 'Bulgaria'); 

SELECT TOP(5) c.CountryName, r.RiverName
	FROM Countries AS c
	LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
	LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
	JOIN Continents AS cnt ON c.ContinentCode = cnt.ContinentCode
	WHERE cnt.ContinentName = 'Africa'
	ORDER BY c.CountryName

SELECT ContinentCode, CurrencyCode,CurrencyCount AS [CurrencyUsage]
FROM (
	SELECT ContinentCode, 
		   CurrencyCode, 
		   [CurrencyCount], 
		   DENSE_RANK() OVER
		   (PARTITION BY ContinentCode ORDER BY CurrencyCount DESC) AS [CurrencyRank]
		   FROM (
				SELECT ContinentCode, 
					CurrencyCode, 
					COUNT(*) AS [CurrencyCount]	   
				FROM Countries
				GROUP BY ContinentCode, CurrencyCode
				) AS [CurrencyCountQuery]
WHERE CurrencyCount > 1
) AS [CurrencyRankingQuery] 
WHERE CurrencyRank = 1
ORDER BY ContinentCode

SELECT COUNT(c.CountryCode) AS CountryCode
FROM Countries AS c
     LEFT OUTER JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
WHERE mc.CountryCode IS NULL; 

SELECT TOP(5) CountryName, 
		MAX(p.Elevation) AS [HighestPeakElevation],
		MAX(r.[Length]) AS [LongestRiverLength]
	FROM Countries AS c
	LEFT JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
	LEFT JOIN Rivers  AS r ON cr.RiverId = r.Id
	LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
	LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
	LEFT JOIN Peaks AS p ON p.MountainId =m.Id
	GROUP BY c.CountryName
	ORDER BY [HighestPeakElevation] DESC, [LongestRiverLength] DESC, CountryName


SELECT TOP (5)	Country,
		CASE 
			WHEN PeakName IS NULL THEN '(no highest peak)'
			ELSE PeakName
		END AS [Highest Peak Name],
		CASE
			WHEN Elevation IS NULL THEN '0'
			ELSE Elevation
		END AS [Highest Peak Elevation],
		CASE 
			WHEN MountainRange IS NULL THEN '(no mountain)'
			ELSE MountainRange
		END AS [Mountain]
					 FROM(SELECT *, 
					 DENSE_RANK() OVER
					 (PARTITION BY [Country] ORDER BY [Elevation] DESC) AS [PeakRank] 
					  FROM (			     
							SELECT CountryName AS [Country],
							p.PeakName,
							p.Elevation,
							m.MountainRange
							FROM Countries AS c
							LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
							LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
							LEFT JOIN Peaks AS p ON p.MountainId = m.Id
						  ) AS [FullInfoQuery]
					) AS [PeakRankingsQuery]
WHERE PeakRank = 1
ORDER BY Country ASC, [Highest Peak Name] ASC
