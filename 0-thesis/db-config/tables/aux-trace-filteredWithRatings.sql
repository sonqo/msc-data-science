DROP TABLE IF EXISTS [dbo].[TraceFilteredWithRatings];

SELECT
	A.*,
	CASE
        WHEN B.RatingNum <> 0 THEN B.RatingNum
        ELSE C.RatingNum
    END AS RatingNum
INTO
	[dbo].[TraceFilteredWithRatings]
FROM
	TraceFiltered A
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
			TraceFiltered A
		LEFT JOIN
			BondReturnsWrds B ON A.CusipId = B.Cusip AND A.TrdExctnDt >= B.Date
		GROUP BY
			A.CusipId,
			A.TrdExctnDt
	) B
	LEFT JOIN 
		BondReturnsWrds A ON A.Cusip = B.CusipId AND A.Date = B.LatestRatingDate
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
			TraceFiltered A
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
	[dbo].[TraceFilteredWithRatings]
ADD
	PrincipalAmt INT

UPDATE
	[dbo].[TraceFilteredWithRatings]
SET
	PrincipalAmt = B.PrincipalAmt
FROM
	[dbo].[TraceFilteredWithRatings] A
INNER JOIN (
	SELECT 
		Cusip,
		MAX(PrincipalAmt) AS PrincipalAmt
	FROM
		BondReturnsWrds
	GROUP BY
		Cusip
) B ON A.CusipId = B.Cusip
