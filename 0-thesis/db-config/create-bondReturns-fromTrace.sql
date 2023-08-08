DROP TABLE IF EXISTS [dbo].[BondReturns];

SELECT
	*,
	 ( 
	 	( RptdPr + AccruedInterest + Coupon * CouponsPaid * 1.0 / InterestFrequency ) -
	 	( LAG(RptdPr) OVER (PARTITION BY CusipId ORDER BY LtTrdExctnDt) + LAG(AccruedInterest) OVER (PARTITION BY CusipId ORDER BY LtTrdExctnDt) )
	 ) / ( 
		LAG(RptdPr) OVER (PARTITION BY CusipId ORDER BY LtTrdExctnDt) + LAG(AccruedInterest) OVER (PARTITION BY CusipId ORDER BY LtTrdExctnDt)
	 ) AS R
INTO
	[dbo].[BondReturns]
FROM (
	-- CALCULATE ACCRUED INTEREST
	SELECT
		CusipId,
		LtTrdExctnDt,
		RptdPr,
		RptSideCd,
		BuyCmsnRt,
		SellCmsnRt,
		Coupon,
		InterestFrequency,
		FirstInterestDate,
		NextInterestDate,
		LatestInterestDate,
		T,
		D,
		CouponsPaid,
		Coupon * 1.0 * D / InterestFrequency / 360 AS AccruedInterest
	FROM (
		-- CALCULATE T, D, COUPONS PAID FROM LAG TRADE
		SELECT
			CusipId,
			LtTrdExctnDt,
			RptdPr,
			RptSideCd,
			BuyCmsnRt,
			SellCmsnRt,
			Coupon,
			InterestFrequency,
			FirstInterestDate,
			NextInterestDate,
			LatestInterestDate,
			360 / InterestFrequency AS T,
			CASE
				WHEN LatestInterestDate IS NULL THEN 0
				ELSE
					ABS ( 
						dbo.YearFact ( 
							LtTrdExctnDt,
							DATEADD( 
								MONTH,
								( ABS ( dbo.YearFact(LtTrdExctnDt, FirstInterestDate, 0 ) ) ) / ( 360 / InterestFrequency ) * (360 / InterestFrequency / 30),
								FirstInterestDate
							), 
							0
						)
					) 
			END AS D,
			CASE
				WHEN LAG(NextInterestDate) OVER (PARTITION BY CusipId ORDER BY LtTrdExctnDt) IS NULL THEN 0
				ELSE (
					DATEDIFF(
						MONTH, 
						LAG(NextInterestDate) OVER (PARTITION BY CusipId ORDER BY LtTrdExctnDt), 
						LtTrdExctnDt
					) + 12/InterestFrequency 
				) / (12/InterestFrequency) 
			END AS CouponsPaid
		FROM (
			-- CALCULATE NEXT INTEREST DATE, LATEST INTEREST DATE
			SELECT
				CusipId,
				LtTrdExctnDt,
				RptdPr,
				RptSideCd,
				BuyCmsnRt,
				SellCmsnRt,
				Coupon,
				InterestFrequency,
				FirstInterestDate,
				CASE
					WHEN LtTrdExctnDt < FirstInterestDate THEN FirstInterestDate
					ELSE 
						DATEADD( 
							MONTH,
							360 / InterestFrequency / 30,
							DATEADD( 
								MONTH,
								( ABS ( dbo.YearFact(LtTrdExctnDt, FirstInterestDate, 0 ) ) ) / ( 360 / InterestFrequency ) * (360 / InterestFrequency / 30),
								FirstInterestDate
							)
						)
				END AS NextInterestDate,
				CASE
					WHEN LtTrdExctnDt < FirstInterestDate THEN NULL
					ELSE
						DATEADD( 
							MONTH,
							( ABS ( dbo.YearFact(LtTrdExctnDt, FirstInterestDate, 0 ) ) ) / ( 360 / InterestFrequency ) * (360 / InterestFrequency / 30),
							FirstInterestDate
						) 
				END AS LatestInterestDate
			FROM (
				-- JOIN ON LATEST TRADING DATE AND CUSIP, GET TRADING PARTICULARS
				SELECT
					A.CusipId,
					A.LtTrdExctnDt,
					AVG(B.RptdPr) AS RptdPr,
					MAX(B.RptSideCd) AS RptSideCd,
					MAX(B.BuyCmsnRt) AS BuyCmsnRt,
					MAX(B.SellCmsnRt) AS SellCmsnRt,
					MAX(B.Coupon) AS Coupon,
					CASE
						WHEN MAX(B.InterestFrequency) IS NOT NULL AND MAX(B.InterestFrequency) <> 0 THEN MAX(B.InterestFrequency)
						ELSE 2
					END AS InterestFrequency,
					CASE
						WHEN MAX(B.FirstInterestDate) IS NOT NULL THEN MAX(B.FirstInterestDate)
						ELSE MAX(B.OfferingDate)
					END AS FirstInterestDate
				FROM (
					-- GET LATEST TRADING DATE FOR EVERY CUSIP
					SELECT
						CusipId,
						MAX(TrdExctnDt) AS LtTrdExctnDt
					FROM 
						TraceBond_filtered
					GROUP BY
						CusipId,
						TrdExctnMn,
						TrdExctnYr 
				) A
				INNER JOIN 
					TraceBond_filtered B ON A.CusipId = B.CusipId AND A.LtTrdExctnDt = B.TrdExctnDt
				GROUP BY
					A.LtTrdExctnDt,
					A.CusipId
			) B
		) C
	) D
) E
ORDER BY
	LtTrdExctnDt
