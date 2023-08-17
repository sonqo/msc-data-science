DROP TABLE IF EXISTS [dbo].[Trace_withRatings_filtered];

SELECT
	A.CusipId,
	A.TrdExctnDt,
	A.TrdExctnMn,
	A.TrdExctnYr,
	A.EntrdVolQt,
	A.RptdPr,
	A.RptSideCd,
	A.BuyCmsnRt,
	A.SellCmsnRt,
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
	#Trace_withoutRatings_filtered
FROM 
	Trace A
INNER JOIN
	BondIssues B ON A.CusipId = B.CompleteCusip
INNER JOIN 
	BondIssuers C ON B.IssuerId = C.IssuerId
WHERE
	A.CntraMpId = 'C' -- customer
	AND A.TrdExctnDtInd <> 0 -- last trade of the month (if in last 5-days)
	AND C.IndustryGroup <> 4 -- governemt
	AND C.CountryDomicile = 'USA' 
	AND A.TrdExctnDt <= B.Maturity
	AND B.OfferingDate < B.Maturity
	AND C.IndustryCode NOT IN (40, 41, 42, 43, 44, 45)

SELECT
	A.*,
	B.RatingNum
INTO
	[dbo].[Trace_withRatings_filtered]
FROM
	#Trace_withoutRatings_filtered A
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
			#Trace_withoutRatings_filtered A
		LEFT JOIN
			BondRatings B ON A.CusipId = B.CompleteCusip AND A.TrdExctnDt >= B.RatingDate
		GROUP BY
			A.CusipId,
			A.TrdExctnDt
	) B ON A.CompleteCusip = B.CusipId AND (A.RatingDate = B.LatestRatingDate OR B.LatestRatingDate IS NULL)
	GROUP BY
		B.TrdExctnDt,
		A.CompleteCusip
) B ON A.CusipId = B.CompleteCusip AND A.TrdExctnDt = B.TrdExctnDt

DROP TABLE IF EXISTS #Trace_withoutRatings_filtered;
