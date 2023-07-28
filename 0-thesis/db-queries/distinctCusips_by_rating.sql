SELECT
	TrdExctnDt,
	MinimumRating,
	COUNT(DISTINCT CusipId) AS DistinctCusips
FROM (
	SELECT 
		A.CusipId, 
		A.TrdExctnDt, 
		MAX(D.RatingDate) AS RatingDate, 
		D.RatingType, 
		MIN(D.RatingCategory) AS MinimumRating
	FROM 
		Trace A
	INNER JOIN
		BondIssues B ON A.CusipId = B.CompleteCusip
	INNER JOIN 
		BondIssuers C ON B.IssuerId = C.IssuerId
	LEFT JOIN 
		BondRatings D ON A.CusipId = D.CompleteCusip AND D.RatingDate BETWEEN DATEADD(MONTH, -12, A.TrdExctnDt) AND A.TrdExctnDt
	WHERE
		A.CntraMpId = 'C'
		AND C.IndustryGroup <> 4
		AND C.CountryDomicile = 'USA'
		AND C.IndustryCode NOT IN (40, 41, 42, 43, 44, 45)
		AND A.TrdExctnDt >= '2002-01-1' AND A.TrdExctnDt < '2023-01-01'
	GROUP BY
		A.CusipId,
		A.TrdExctnDt,
		D.RatingType
) A
GROUP BY 
	TrdExctnDt,
	MinimumRating
ORDER BY
	TrdExctnDt,
	MinimumRating
