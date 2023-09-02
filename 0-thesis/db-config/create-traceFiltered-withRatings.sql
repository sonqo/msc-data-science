DROP TABLE IF EXISTS [dbo].[Trace_filtered_withRatings];

SELECT
	A.*,
	CASE
        WHEN B.RatingNum <> 0 THEN B.RatingNum
        ELSE C.RatingNum
    END AS RatingNum
INTO
	[dbo].[Trace_filtered_withRatings]
FROM
	Trace_filtered_withoutRatings A
-- join with BondReturns
INNER JOIN (
	-- get minimum rating for current TradeExecutionDate and LatestRatingDate
	SELECT
		B.CusipId,
		B.TrdExctnDt,
		CASE
			WHEN A.RatingNum IS NULL THEN 0
			ELSE A.RatingNum
		END AS RatingNum
	FROM (
		-- get latest RatingDate according to current TradeExecutionDate
		SELECT
			A.CusipId,
			A.TrdExctnDt,
			CASE
				WHEN MAX(
					CASE
						WHEN B.Date IS NULL THEN '2542-01-01'
						ELSE B.Date
					END
				) = '2542-01-01' THEN NULL
				ELSE MAX(B.Date)
			END AS LatestRatingDate
		FROM
			Trace_filtered_withoutRatings A
		LEFT JOIN
			BondReturns B ON A.CusipId = B.Cusip AND A.TrdExctnDt >= B.Date
		GROUP BY
			A.CusipId,
			A.TrdExctnDt
	) B
	LEFT JOIN 
		BondReturns A ON A.Cusip = B.CusipId AND A.Date = B.LatestRatingDate
) B ON A.CusipId = B.CusipId AND A.TrdExctnDt = B.TrdExctnDt
-- join with BondRatings
INNER JOIN (
    -- get minimum rating for current TradeExecutionDate and LatestRatingDate
	SELECT
		B.CusipId,
		B.TrdExctnDt,
		MIN(
			CASE
				WHEN A.RatingCategory IS NULL THEN 0
				ELSE A.RatingCategory
			END
		) AS RatingNum
	FROM (
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
	) B 
	LEFT JOIN 
		BondRatings A ON A.CompleteCusip = B.CusipId AND (A.RatingDate = B.LatestRatingDate OR B.LatestRatingDate IS NULL)
	GROUP BY
		B.CusipId,
		B.TrdExctnDt
) C ON A.CusipId = C.CusipId AND A.TrdExctnDt = C.TrdExctnDt

-- ADD PRINCIPAL AMOUNT COLUMN

ALTER TABLE
	[dbo].[Trace_filtered_withRatings]
ADD
	PrincipalAmt INT

UPDATE
	[dbo].[Trace_filtered_withRatings]
SET
	PrincipalAmt = B.PrincipalAmt
FROM
	[dbo].[Trace_filtered_withRatings] A
INNER JOIN (
	SELECT 
		Cusip,
		MAX(PrincipalAmt) AS PrincipalAmt
	FROM
		BondReturns
	GROUP BY
		Cusip
) B ON A.CusipId = B.Cusip
