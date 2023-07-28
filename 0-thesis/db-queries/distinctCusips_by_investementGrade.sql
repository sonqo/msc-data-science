SELECT
	InvestmentGrade,
	COUNT(DISTINCT CusipId) AS DistinctCusips
FROM (
	SELECT
		CusipId,
		CASE
			WHEN RatingCategory < 11 THEN 'Y'
			WHEN RatingCategory < 25 THEN 'N'
			ELSE 'NR'
		END AS InvestmentGrade
	FROM (
		SELECT
			A.CusipId,
			MIN(D.RatingCategory) AS RatingCategory
		FROM (
			SELECT 
				A.CusipId,
				MIN(A.TrdExctnDt) AS FirstTradeExecutionDate
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
				A.CusipId
		) A
		LEFT JOIN 
			BondRatings D ON A.CusipId = D.CompleteCusip
		GROUP BY
			A.CusipId
	) B
) C
GROUP BY
	InvestmentGrade
