SELECT
	MaturityBand,
	COUNT(DISTINCT CusipId) AS DistinctCusips
FROM (
	SELECT
		CASE 
			WHEN ABS(DATEDIFF(DAY, B.Maturity, B.OfferingDate)) * 1.0 / 360 < 5 THEN 1
			WHEN ABS(DATEDIFF(DAY, B.Maturity, B.OfferingDate)) * 1.0 / 360 < 15 THEN 2
			ELSE 3
		END AS MaturityBand,
		A.CusipId
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
		AND B.Maturity >= A.TrdExctnDt
		AND B.Maturity > B.OfferingDate
		AND C.IndustryCode NOT IN (40, 41, 42, 43, 44, 45)
		AND A.TrdExctnDt >= '2002-01-1' AND A.TrdExctnDt < '2023-01-01'
) A
GROUP BY
	MaturityBand
ORDER BY
	MaturityBand
