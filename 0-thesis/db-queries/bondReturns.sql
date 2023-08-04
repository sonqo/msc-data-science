-- DROP TABLE IF EXISTS BondReturns;

SELECT
	LtTrdExctnDt,
	CusipId,
	RptdPr,
	LAG(RptdPr) OVER (PARTITION BY CusipId ORDER BY LtTrdExctnDt) AS LagRptdPr,
	Coupon,
	InterestFrequency,
	LatestInterestDate,
	NextInterestDate,
	LAG(NextInterestDate) OVER (PARTITION BY CusipId ORDER BY LtTrdExctnDt) AS LagInterestDate,
	(
		DATEDIFF(
		MONTH,
		LAG(NextInterestDate) OVER (PARTITION BY CusipId ORDER BY LtTrdExctnDt),
		LtTrdExctnDt
	) + 12/InterestFrequency ) / (12/InterestFrequency) AS CouponsPaid,
	T,
	D,
	AccruedInterest

	-- LAG(AccruedInterest) OVER (PARTITION BY CusipId ORDER BY LtTrdExctnDt) AS LagAccruedInterest,
	-- ( 
	-- 	(RptdPr + AccruedInterest + Coupon * 1.0 / InterestFrequency ) - -- Price + AccInt + Coupon
	-- 	(LAG(RptdPr) OVER (PARTITION BY CusipId ORDER BY LtTrdExctnDt) + LAG(AccruedInterest) OVER (PARTITION BY CusipId ORDER BY LtTrdExctnDt)) -- -(LagPrice + LagAccInt)
	-- ) / ( 
	-- 	LAG(RptdPr) OVER (PARTITION BY CusipId ORDER BY LtTrdExctnDt) + LAG(AccruedInterest) OVER (PARTITION BY CusipId ORDER BY LtTrdExctnDt) -- / (LagPrice + LagAccInt)
	-- ) AS R
-- INTO
	-- BondReturns
FROM (
	SELECT
		LtTrdExctnDt,
		CusipId,
		RptdPr,
		Coupon,
		InterestFrequency,
		360 / InterestFrequency AS T,
		FirstInterestDate,
		DATEADD( 
			MONTH,
			-- CouponsPaid * MonthsInPeriod
			( ABS ( dbo.YearFact(LtTrdExctnDt, FirstInterestDate, 0 ) ) ) / ( 360 / InterestFrequency ) * (360 / InterestFrequency / 30),
			FirstInterestDate
		) AS LatestInterestDate,
		DATEADD( 
			MONTH,
			-- CouponsPaid * MonthsInPeriod
			360 / InterestFrequency / 30,
			DATEADD( 
				MONTH,
				-- CouponsPaid * MonthsInPeriod
				( ABS ( dbo.YearFact(LtTrdExctnDt, FirstInterestDate, 0 ) ) ) / ( 360 / InterestFrequency ) * (360 / InterestFrequency / 30),
				FirstInterestDate
			)
		) AS NextInterestDate,
		ABS ( 
			dbo.YearFact ( 
				LtTrdExctnDt,
				-- LatestInterestDate
				DATEADD( 
					MONTH,
					-- CouponsPaid * MonthsInPeriod
					( ABS ( dbo.YearFact(LtTrdExctnDt, FirstInterestDate, 0 ) ) ) / ( 360 / InterestFrequency ) * (360 / InterestFrequency / 30),
					FirstInterestDate
				), 
				0
			)
		) AS D,
		Coupon * 1.0 / InterestFrequency * ABS ( 
			dbo.YearFact ( 
				LtTrdExctnDt,
				-- LatestInterestDate
				DATEADD( 
					MONTH,
					-- CouponsPaid * MonthsInPeriod
					( ABS ( dbo.YearFact(LtTrdExctnDt, FirstInterestDate, 0 ) ) ) / ( 360 / InterestFrequency ) * (360 / InterestFrequency / 30),
					FirstInterestDate
				), 
				0
			)
		) / 360 AS AccruedInterest
	FROM (
		SELECT
			A.LtTrdExctnDt,
			A.CusipId,
			AVG(B.RptdPr) AS RptdPr,
			MAX(C.Coupon) AS Coupon,
			CASE
				WHEN MAX(C.InterestFrequency) IS NOT NULL AND MAX(C.InterestFrequency) <> 0 THEN MAX(C.InterestFrequency)
				ELSE 2
			END AS InterestFrequency,
			CASE
				WHEN MAX(C.FirstInterestDate) IS NOT NULL THEN MAX(C.FirstInterestDate)
				ELSE MAX(C.OfferingDate)
			END AS FirstInterestDate
		FROM (
			SELECT top 100
				CusipId,
				MAX(TrdExctnDt) AS LtTrdExctnDt
			FROM 
				Trace A
			INNER JOIN
				BondIssues B ON A.CusipId = B.CompleteCusip
			INNER JOIN 
				BondIssuers C ON B.IssuerId = C.IssuerId
			WHERE
				A.CntraMpId = 'C' 
				AND TrdExctnDtInd <> 0
				AND C.IndustryGroup <> 4
				AND C.CountryDomicile = 'USA'
				AND B.Maturity >= A.TrdExctnDt
				AND B.Maturity > B.OfferingDate
				AND C.IndustryCode NOT IN (40, 41, 42, 43, 44, 45)
				AND A.TrdExctnDt >= '2002-01-1' AND A.TrdExctnDt < '2006-01-01'
			GROUP BY
				CusipId,
				TrdExctnMn,
				TrdExctnYr,
				TrdExctnDtInd order by CusipId, LtTrdExctnDt
		) A
		INNER JOIN 
			Trace B ON A.CusipId = B.CusipId AND A.LtTrdExctnDt = B.TrdExctnDt
		INNER JOIN
			BondIssues C ON A.CusipId = C.CompleteCusip
		GROUP BY
			A.LtTrdExctnDt,
			A.CusipId
	) B
) C
