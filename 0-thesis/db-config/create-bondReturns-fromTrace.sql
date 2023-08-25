--DROP TABLE IF EXISTS [dbo].[BondReturns_v2];

SELECT TOP 100
	*,
	 ( 
	 	( RptdPr * PrincipalAmt / 100 + AccruedInterest + Coupon * CouponsPaid * 1.0 / InterestFrequency ) -
	 	( LAG(RptdPr) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) * PrincipalAmt / 100 + LAG(AccruedInterest) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) )
	 ) / ( 
		LAG(RptdPr) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) * PrincipalAmt / 100 + LAG(AccruedInterest) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt)
	 ) AS R
--INTO
--	[dbo].[BondReturns_v2]
FROM (
	-- CALCULATE ACCRUED INTEREST
	SELECT
		CusipId,
		TrdExctnDt,
		RptdPr,
		Coupon,
		PrincipalAmt,
		InterestFrequency,
		FirstInterestDate,
		NextInterestDate,
		LatestInterestDate,
		T,
		D,
		CouponsPaid,
		CouponsPaid * ( Coupon * D / InterestFrequency / 360 ) AS AccruedInterest
	FROM (
		-- CALCULATE T, D, COUPONS PAID FROM LAG TRADE
		SELECT
			CusipId,
			TrdExctnDt,
			RptdPr,
			Coupon,
			PrincipalAmt,
			InterestFrequency,
			FirstInterestDate,
			NextInterestDate,
			LatestInterestDate,
			CASE
				WHEN InterestFrequency = 0 THEN NULL
				ELSE 360 / InterestFrequency 
			END AS T,
			CASE
				WHEN InterestFrequency = 0 THEN NULL
				ELSE
					CASE
						WHEN LatestInterestDate IS NULL THEN 0
						ELSE
							ABS ( 
								dbo.YearFact ( 
									TrdExctnDt,
									DATEADD( 
										MONTH,
										( ABS ( dbo.YearFact(TrdExctnDt, FirstInterestDate, 0 ) ) ) / ( 360 / InterestFrequency ) * (360 / InterestFrequency / 30),
										FirstInterestDate
									), 
									0
								)
							) 
					END 
			END AS D,
			CASE
				WHEN InterestFrequency = 0 THEN NULL
				ELSE
					CASE
						WHEN LAG(NextInterestDate) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) IS NULL THEN 0
						ELSE (
							DATEDIFF(
								MONTH, 
								LAG(NextInterestDate) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt), 
								TrdExctnDt
							) + 12/InterestFrequency 
						) / (12/InterestFrequency) 
					END 
			END AS CouponsPaid
		FROM (
			-- CALCULATE NEXT INTEREST DATE, LATEST INTEREST DATE
			SELECT
				CusipId,
				TrdExctnDt,
				RptdPr,
				(Coupon * 1.0 / 100) * PrincipalAmt AS Coupon,
				PrincipalAmt,
				InterestFrequency,
				FirstInterestDate,
				CASE 
					WHEN InterestFrequency = 0 THEN NULL
					ELSE
						CASE
							WHEN TrdExctnDt < FirstInterestDate THEN FirstInterestDate
							ELSE 
								DATEADD( 
									MONTH,
									360 / InterestFrequency / 30,
									DATEADD( 
										MONTH,
										( ABS ( dbo.YearFact(TrdExctnDt, FirstInterestDate, 0 ) ) ) / ( 360 / InterestFrequency ) * (360 / InterestFrequency / 30),
										FirstInterestDate
									)
								)
						END 
				END AS NextInterestDate,
				CASE
					WHEN InterestFrequency = 0 THEN NULL
					ELSE
						CASE
							WHEN TrdExctnDt < FirstInterestDate THEN NULL
							ELSE
								DATEADD( 
									MONTH,
									( ABS ( dbo.YearFact(TrdExctnDt, FirstInterestDate, 0 ) ) ) / ( 360 / InterestFrequency ) * (360 / InterestFrequency / 30),
									FirstInterestDate
								) 
						END 
				END AS LatestInterestDate
			FROM (
				-- JOIN ON LATEST TRADING DATE AND CUSIP, GET TRADING PARTICULARS
				SELECT
					A.CusipId,
					A.TrdExctnDt,
					AVG(A.RptdPr) AS RptdPr,
					AVG(A.Coupon) AS Coupon,
					MAX(A.PrincipalAmt) AS PrincipalAmt,
					CASE
						WHEN AVG(A.InterestFrequency) IS NOT NULL THEN AVG(A.InterestFrequency)
						ELSE 2
					END AS InterestFrequency,
					CASE
						WHEN MAX(A.FirstInterestDate) IS NOT NULL THEN MAX(A.FirstInterestDate)
						ELSE MAX(A.OfferingDate)
					END AS FirstInterestDate
				FROM 
					Trace_filtered_withRatings A
				GROUP BY
					CusipId,
					TrdExctnDt
			) B
		) C
	) D
) E
