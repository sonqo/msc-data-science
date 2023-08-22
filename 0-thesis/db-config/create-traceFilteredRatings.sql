DROP TABLE IF EXISTS [dbo].[Trace_filtered_withRatings];

SELECT
	A.*,
	CASE
        WHEN B.RatingNum IS NOT NULL THEN B.RatingNum
        WHEN C.RatingNum <> 0 THEN C.RatingNum
        ELSE 0
    END AS RatingNum
INTO
	[dbo].[Trace_filtered_withRatings]
FROM
	Trace_filtered_withoutRatings A
INNER JOIN (
	-- get minimum rating for current TradeExecutionDate and latest RatingDate
	SELECT
		A.Cusip,
		B.TrdExctnDt,
		A.RatingNum
	FROM (
		-- get latest RatingDate according to current TradeExecutionDate
		SELECT
			A.CusipId,
			A.TrdExctnDt,
			MAX(Date) AS LatestRatingDate
		FROM
			Trace_filtered_withoutRatings A
		LEFT JOIN
			BondReturns B ON A.CusipId = B.Cusip AND A.TrdExctnDt >= B.Date
		GROUP BY
			A.CusipId,
			A.TrdExctnDt
	) B
	LEFT JOIN 
		BondReturns a ON A.Cusip = B.CusipId AND A.Date = B.LatestRatingDate
) B ON A.CusipId = B.Cusip AND A.TrdExctnDt = B.TrdExctnDt
INNER JOIN (
    -- get minimum rating for current TradeExecutionDate and latest RatingDate
	SELECT
		B.TrdExctnDt,
		A.CompleteCusip,
		MIN(
			CASE
				WHEN A.RatingCategory IS NULL THEN 0
				ELSE A.RatingCategory
			END
		) AS RatingNum
	FROM
		BondRatings A
	INNER JOIN (
		-- get latest RatingDate according to current TradeExecutionDate
		SELECT
			A.CusipId,
			A.TrdExctnDt,
			CASE
				WHEN MAX(
					CASE
						WHEN B.RatingDate IS NULL THEN '2542-01-01'
						ELSE B.RatingDate
					END
				) = '2542-01-01' THEN NULL
				ELSE MAX(B.RatingDate)
			END AS LatestRatingDate
		FROM
			Trace_filtered_withoutRatings A
		LEFT JOIN
			BondRatings B ON A.CusipId = B.CompleteCusip AND A.TrdExctnDt >= B.RatingDate
		GROUP BY
			A.CusipId,
			A.TrdExctnDt
	) B ON A.CompleteCusip = B.CusipId AND (A.RatingDate = B.LatestRatingDate OR B.LatestRatingDate IS NULL)
	GROUP BY
		B.TrdExctnDt,
		A.CompleteCusip
) C ON A.CusipId = C.CompleteCusip AND A.TrdExctnDt = C.TrdExctnDt
