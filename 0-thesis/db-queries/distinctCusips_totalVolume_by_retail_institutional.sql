SELECT 
	TrdExctnDt,
	RetailThreshold,
	COUNT(DISTINCT CusipId) AS DistinctCusips,
	SUM(EntrdVolQt) AS TotalVolume
FROM (
	SELECT
		A.TrdExctnDt,
		CASE WHEN A.EntrdVolQt < 100000 THEN 'R' ELSE 'IN' END AS RetailThreshold,
		A.CusipId,
		A.EntrdVolQt
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
		AND A.TrdExctnDt >= '2002-01-1' AND A.TrdExctnDt < '2004-01-01'
) A
GROUP BY
	TrdExctnDt,
	RetailThreshold
ORDER BY
	TrdExctnDt, 
	RetailThreshold
