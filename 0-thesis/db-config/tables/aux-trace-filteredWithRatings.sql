DROP TABLE IF EXISTS [dbo].[TEMP_Trace-filtered];
DROP TABLE IF EXISTS [dbo].[Trace-filteredWithRatings];

-- create temp table of filtered trace for faster iterations
SELECT
	A.CusipId,
	A.TrdExctnDt,
	A.TrdExctnTm,
	A.TrdExctnMn,
	A.TrdExctnYr,
	A.EntrdVolQt,
	A.RptdPr,
	A.RptSideCd,
	A.BuyCmsnRt,
	A.SellCmsnRt,
	A.CntraMpId,
	B.InterestFrequency,
	B.Coupon,
	B.OfferingDate,
	B.DeliveryDate,
	B.FirstInterestDate,
	B.LastInterestDate,
	B.EffectiveDate,
	B.Maturity,
	C.IssuerId,
	C.IndustryCode,
	C.IndustryGroup
INTO
	[dbo].[TEMP_Trace-filtered]
FROM 
	Trace A
INNER JOIN
	BondIssues B ON A.CusipId = B.CompleteCusip
INNER JOIN 
	BondIssuers C ON B.IssuerId = C.IssuerId
WHERE
	C.IndustryGroup <> 4 -- government
	AND C.CountryDomicile = 'USA' 
	AND A.TrdExctnDt <= B.Maturity
	AND B.OfferingDate < B.Maturity
	AND RptdPr >= 10 AND RptdPr <= 500
	AND C.IndustryCode NOT IN (40, 41, 42, 43, 44, 45) -- government

-- populate filtered/enhanced table
SELECT
	A.*,
	B.PrincipalAmt,
	CASE
        WHEN B.RatingNum <> 0 THEN B.RatingNum
        ELSE C.RatingNum
    END AS RatingNum
INTO
	[dbo].[Trace-filteredWithRatings]
FROM
	[dbo].[TEMP_Trace-filtered] A
-- join with BondReturns-wrds
INNER JOIN (
	-- get minimum rating for current TradeExecutionDate and LatestRatingDate
	SELECT
		B.CusipId,
		B.TrdExctnDt,
		CASE
			WHEN A.RatingNum IS NULL THEN 0
			ELSE A.RatingNum
		END AS RatingNum,
		B.PrincipalAmt
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
			END AS LatestRatingDate,
			MAX(B.PrincipalAmt) AS PrincipalAmt
		FROM
			[dbo].[TEMP_Trace-filtered] A
		LEFT JOIN
			[dbo].[BondReturns-wrds] B ON A.CusipId = B.Cusip AND A.TrdExctnDt >= B.Date
		GROUP BY
			A.CusipId,
			A.TrdExctnDt
	) B
	LEFT JOIN 
		[dbo].[BondReturns-wrds] A ON A.Cusip = B.CusipId AND A.Date = B.LatestRatingDate
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
			[dbo].[TEMP_Trace-filtered] A
		LEFT JOIN
			[dbo].[BondRatings] B ON A.CusipId = B.CompleteCusip AND A.TrdExctnDt >= B.RatingDate
		GROUP BY
			A.CusipId,
			A.TrdExctnDt
	) B 
	LEFT JOIN 
		[dbo].[BondRatings] A ON A.CompleteCusip = B.CusipId AND (A.RatingDate = B.LatestRatingDate OR B.LatestRatingDate IS NULL)
	GROUP BY
		B.CusipId,
		B.TrdExctnDt
) C ON A.CusipId = C.CusipId AND A.TrdExctnDt = C.TrdExctnDt

DROP TABLE IF EXISTS [dbo].[TEMP_Trace-filtered]

CREATE CLUSTERED INDEX [IX_Trace-filteredWithRatings] ON 
	dbo.[Trace-filteredWithRatings] (
			[TrdExctnDt], [CusipId]
	);
