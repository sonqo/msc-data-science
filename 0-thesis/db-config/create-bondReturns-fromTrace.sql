DROP TABLE IF EXISTS [dbo].[BondReturns_fromTrace]

SELECT
	*,
	CASE 
		WHEN PrevRptdPr IS NULL OR PrevRptdPr = 0 THEN NULL
		ELSE
			CASE
				WHEN InterestFrequency = 0 THEN (RptdPr - PrevRptdPr) / PrevRptdPr
				ELSE ( ( RptdPr + AccruedInterest + Coupon * CouponsPaid * 1.0 / InterestFrequency ) - ( PrevRptdPr + PrevAccruedInterest ) ) / ( PrevRptdPr + PrevAccruedInterest ) 
			END 
	END AS R
INTO
	[dbo].[BondReturns_fromTrace]
FROM (
	-- CALCULATE GAP
	SELECT
		*,
		LAG(AccruedInterest) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) AS PrevAccruedInterest,
		DATEDIFF(
			DAY,
			PrevTrdExctnDt,
			TrdExctnDt
		) - 2 * DATEDIFF(
			WEEK,
			PrevTrdExctnDt,
			TrdExctnDt
		) AS GapDays
	FROM (
		-- CALCULATE ACCRUED INTEREST
		SELECT
			CusipId,
			TrdExctnDt,
			Rated,
			LAG(TrdExctnDt) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) AS PrevTrdExctnDt,
			RptdPr,
			LAG(RptdPr) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) AS PrevRptdPr,
			EntrdVolQt,
			Coupon,
			PrincipalAmt,
			InterestFrequency,
			FirstInterestDate,
			NextInterestDate,
			LatestInterestDate,
			T,
			D,
			CouponsPaid,
			CASE
				WHEN InterestFrequency = 0 THEN NULL
				ELSE CouponsPaid * ( Coupon * D / InterestFrequency / 360 ) 
			END AS AccruedInterest
		FROM (
			-- CALCULATE T, D, COUPONS PAID FROM PREVIOUS TRADE
			SELECT
				CusipId,
				TrdExctnDt,
				Rated,
				RptdPr,
				EntrdVolQt,
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
					Rated,
					RptdPr,
					EntrdVolQt,
					Coupon,
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
					-- GET WEIGHTED AVERAGE PRICE IN DAY
					SELECT
						CusipId,
						TrdExctnDt,
						MAX(Rated) AS Rated,
						CASE
							WHEN SUM(EntrdVolQt) = 0 THEN NULL
							ELSE SUM(WeightedRptdPr) / SUM(EntrdVolQt) 
						END AS RptdPr,
						MAX(EntrdVolQt) AS EntrdVolQt,
						AVG(Coupon) AS Coupon,
						MAX(PrincipalAmt) AS PrincipalAmt,
						CASE
							WHEN AVG(InterestFrequency) IS NOT NULL THEN AVG(InterestFrequency)
							ELSE 2
						END AS InterestFrequency,
						CASE
							WHEN MAX(FirstInterestDate) IS NOT NULL THEN MAX(FirstInterestDate)
							ELSE MAX(OfferingDate)
						END AS FirstInterestDate
					FROM (
						-- GET BOND PARTICULARS
						SELECT
							CusipId,
							TrdExctnDt,
							CASE
								WHEN RatingNum = 0 THEN 0
								ELSE 1
							END AS Rated,
							(RptdPr * 10.0) * EntrdVolQt AS WeightedRptdPr,
							EntrdVolQt,
							(Coupon * 1.0 / 100) * PrincipalAmt AS Coupon,
							PrincipalAmt,
							CASE
								WHEN InterestFrequency IS NOT NULL THEN InterestFrequency
								ELSE 2
							END AS InterestFrequency,
							OfferingDate,
							CASE
								WHEN FirstInterestDate IS NOT NULL THEN FirstInterestDate
								ELSE OfferingDate
							END AS FirstInterestDate
						FROM
							Trace_filtered_withRatings
					) A
					GROUP BY
						CusipId,
						TrdExctnDt
				) B
			) C
		) D
	) E
) F
WHERE
	GapDays = 1
ORDER BY
	CusipId,
	TrdExctnDt
