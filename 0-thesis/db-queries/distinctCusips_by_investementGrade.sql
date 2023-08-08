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
			MIN(B.RatingCategory) AS RatingCategory
		FROM (
			SELECT
				CusipId,
				MIN(TrdExctnDt) AS FirstTradeExecutionDate
			FROM 
				TraceBond_filtered
			WHERE
				TrdExctnDt >= '2002-01-1' AND TrdExctnDt < '2023-01-01'
			GROUP BY
				CusipId
		) A
		LEFT JOIN 
			BondRatings B ON A.CusipId = B.CompleteCusip 
			AND B.RatingDate <= A.FirstTradeExecutionDate 
			AND B.RatingCategory IS NOT NULL
		GROUP BY
			A.CusipId
	) B
) C
GROUP BY
	InvestmentGrade
ORDER BY
	InvestmentGrade
