SELECT
	A.TrdExctnDt,
	C.IssuerId,
	COUNT(DISTINCT A.CusipId) AS DistinctCusips,
	SUM(A.EntrdVolQt) AS TotalVolume
FROM 
	Trace A
INNER JOIN
	BondIssues B ON A.CusipId = B.CompleteCusip
INNER JOIN 
	BondIssuers C ON B.IssuerId = C.IssuerId
WHERE
	A.CntraMpId = 'C'
	AND C.IndustryGroup <> 4
	AND C.CountryDomicile = 'USA'
	AND C.IndustryCode NOT IN (40, 41, 42, 43, 44, 45)
	AND A.TrdExctnDt >= '2002-01-1' AND A.TrdExctnDt < '2023-01-01'
GROUP BY
	A.TrdExctnDt, 
	C.IssuerId
ORDER BY
	A.TrdExctnDt, 
	C.IssuerId