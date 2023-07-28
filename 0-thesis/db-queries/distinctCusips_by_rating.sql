SELECT
	TrdExctnDt,
	MinimumRating,
	COUNT(DISTINCT CusipId) AS DistinctCusips
FROM (	
	SELECT
		CusipId,
		TrdExctnDt, 
		MIN(RatingCategory) AS MinimumRating
	FROM (
		SELECT
			A.CusipId, 
			A.TrdExctnDt, 
			MAX(D.RatingDate) AS MaxRatingDate,
			D.RatingCategory
		FROM 
			Trace A
		INNER JOIN
			BondIssues B ON A.CusipId = B.CompleteCusip
		INNER JOIN 
			BondIssuers C ON B.IssuerId = C.IssuerId
		LEFT JOIN 
			BondRatings D ON A.CusipId = D.CompleteCusip AND D.RatingDate <= A.TrdExctnDt
		WHERE
			A.CntraMpId = 'C'
			AND C.IndustryGroup <> 4
			AND C.CountryDomicile = 'USA'
			AND C.IndustryCode NOT IN (40, 41, 42, 43, 44, 45)
			AND A.TrdExctnDt >= '2002-01-1' AND A.TrdExctnDt < '2023-01-01'
		GROUP BY
			A.CusipId,
			A.TrdExctnDt,
			D.RatingCategory
	) A
	GROUP BY 
		CusipId, 
		TrdExctnDt, 
		MaxRatingDate
) B
GROUP BY
	TrdExctnDt,
	MinimumRating