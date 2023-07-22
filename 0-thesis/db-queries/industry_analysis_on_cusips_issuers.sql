SELECT
	IndustryGroup,
	IndustryCode,
	DistinctCusips,
	DistinctCusips * 1.0 / SUM(DistinctCusips) OVER (PARTITION BY IndustryGroup) AS PercentageCusip,
	DistinctIssuers,
	DistinctIssuers * 1.0 / SUM(DistinctIssuers) OVER (PARTITION BY IndustryGroup) AS PercentageIssuer
FROM (
	SELECT 
		C.IndustryGroup,
		C.IndustryCode,
		COUNT(DISTINCT A.CusipId) AS DistinctCusips,
		COUNT(DISTINCT C.IssuerID) AS DistinctIssuers
	FROM
		Trace A
	INNER JOIN
		BondIssues B ON A.CusipId = B.CompleteCusip
	INNER JOIN 
		BondIssuers C ON B.IssuerId = C.IssuerId
	WHERE
		C.IndustryGroup <> 4
		AND C.CountryDomicile = 'USA'
		AND C.IndustryCode NOT IN (40, 41, 42, 43, 44, 45)
		AND A.TrdExctnDt >= '2002-01-1' AND A.TrdExctnDt < '2004-01-01'
	GROUP BY
		C.IndustryGroup, 
		C.Industrycode 
) A
