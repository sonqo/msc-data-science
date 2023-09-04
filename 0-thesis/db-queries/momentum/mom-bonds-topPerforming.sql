CREATE PROCEDURE

	[dbo].[Momentum_TopPerformers] @TopPerformers INT, @HoldingPeriod INT

AS

BEGIN
	
	SET NOCOUNT ON

	-- CREATE TEMP TABLE
	SELECT
		A.CusipId,
		EOMONTH(B.TrdExctnDt) AS Date,
		A.TrdExctnDt AS StartDate,
		B.TrdExctnDt AS EndDate,
		A.WeightPrice AS StartPrice,
		B.WeightPrice AS EndPrice,
		A.Coupon,
		A.PrincipalAmt,
		A.InterestFrequency,
		A.RatingNum,
		A.Maturity,
		A.FirstInterestDate,
		CASE 
			WHEN A.InterestFrequency = 0 THEN NULL
			ELSE
				CASE
					WHEN A.TrdExctnDt < A.FirstInterestDate THEN A.FirstInterestDate
					ELSE 
						DATEADD( 
							MONTH,
							360 / A.InterestFrequency / 30,
							DATEADD( 
								MONTH,
								( ABS ( dbo.YearFact(A.TrdExctnDt, A.FirstInterestDate, 0 ) ) ) / ( 360 / A.InterestFrequency ) * (360 / A.InterestFrequency / 30 ),
								A.FirstInterestDate
							)
						)
				END 
		END AS NextInterestDate,
		CASE
			WHEN InterestFrequency = 0 THEN NULL
			ELSE
				CASE
					WHEN A.TrdExctnDt < FirstInterestDate THEN NULL
					ELSE
						DATEADD( 
							MONTH,
							( ABS ( dbo.YearFact(A.TrdExctnDt, FirstInterestDate, 0 ) ) ) / ( 360 / InterestFrequency ) * (360 / InterestFrequency / 30 ),
							FirstInterestDate
						) 
				END 
		END AS LatestInterestDate
	INTO
		#TEMP_TABLE
	FROM (
		-- FIRST 5 DAYS OF MONTH TRADE
		SELECT
			CusipId,
			TrdExctnDt,
			EOMONTH(TrdExctnDt) AS TrdExctnDtEOM,
			CONCAT(MONTH(TrdExctnDt), '-', YEAR(TrdExctnDt)) AS MontYearId,
			SUM(PriceVolumeProduct) / SUM(EntrdVolQt) AS WeightPrice,
			MAX(Coupon) AS Coupon,
			MAX(PrincipalAmt) AS PrincipalAmt,
			CASE
				WHEN MAX(InterestFrequency) IS NOT NULL THEN MAX(InterestFrequency)
				ELSE 2
			END AS InterestFrequency,
			MAX(RatingNum) AS RatingNum,
			MAX(Maturity) AS Maturity,
			CASE
				WHEN MAX(FirstInterestDate) IS NOT NULL THEN MAX(FirstInterestDate)
				ELSE MAX(OfferingDate)
			END AS FirstInterestDate
		FROM (
			SELECT
				B.CusipId,
				B.TrdExctnDt,
				EntrdVolQt,
				RptdPr * EntrdVolQt AS PriceVolumeProduct,
				Coupon,
				PrincipalAmt,
				InterestFrequency,
				RatingNum,
				Maturity,
				FirstInterestDate,
				OfferingDate
			FROM (
				SELECT
					CusipId,
					MAX(TrdExctnDt) AS TrdExctnDt
				FROM (
					SELECT
						B.CusipId,
						B.TrdExctnDt
					FROM (
						SELECT
							*,
							DENSE_RANK() OVER (PARTITION BY IssuerId, MonthYearId ORDER BY SumVolume DESC) AS Ranking
						FROM (
							SELECT
								IssuerId,
								CusipId,
								CONCAT(MONTH(TrdExctnDt), '-', YEAR(TrdExctnDt)) AS MonthYearId,
								SUM(EntrdVolQt) AS SumVolume
							FROM
								Trace_filtered_withRatings
							GROUP BY
								IssuerId,
								CusipId,
								MONTH(TrdExctnDt),
								YEAR(TrdExctnDt)
						) A
					) A
					INNER JOIN (
						SELECT
							CusipId,
							TrdExctnDt,
							CONCAT(MONTH(TrdExctnDt), '-', YEAR(TrdExctnDt)) AS MonthYearId
						FROM
							Trace_filtered_withRatings
						WHERE
							RatingNum <> 0
					) B ON A.CusipId = B.CusipId AND A.MonthYearId = B.MonthYearId
					WHERE
						A.Ranking <= @TopPerformers
				) A
				WHERE
					TrdExctnDt >= DATEFROMPARTS(YEAR(TrdExctnDt), MONTH(TrdExctnDt), 1) AND TrdExctnDt <= DATEFROMPARTS(YEAR(TrdExctnDt), MONTH(TrdExctnDt), 5)
				GROUP BY
					CusipId,
					YEAR(TrdExctnDt),
					MONTH(TrdExctnDt)
			) A
			INNER JOIN 
				Trace_filtered_withRatings B ON A.CusipId = B.CusipId AND A.TrdExctnDt = B.TrdExctnDt
			WHERE
				B.RatingNum <> 0
		) A
		GROUP BY
			CusipId,
			TrdExctnDt
	) A
	INNER JOIN (
		-- LAST 5 DAYS OF MONTH TRADE
		SELECT
			*
		FROM (
			SELECT
				CusipId,
				TrdExctnDt,
				EOMONTH(TrdExctnDt) AS TrdExctnDtEOM,
				CONCAT(MONTH(TrdExctnDt), '-', YEAR(TrdExctnDt)) AS MontYearId,
				SUM(PriceVolumeProduct) / SUM(EntrdVolQt) AS WeightPrice
			FROM (
				SELECT
					B.CusipId,
					B.TrdExctnDt,
					EntrdVolQt,
					RptdPr * EntrdVolQt AS PriceVolumeProduct
				FROM (
					SELECT
						CusipId,
						MAX(TrdExctnDt) AS TrdExctnDt
					FROM (
						SELECT
							B.CusipId,
							B.TrdExctnDt
						FROM (
							SELECT
								*,
								DENSE_RANK() OVER (PARTITION BY IssuerId, MonthYearId ORDER BY SumVolume DESC) AS Ranking
							FROM (
								SELECT
									IssuerId,
									CusipId,
									CONCAT(MONTH(TrdExctnDt), '-', YEAR(TrdExctnDt)) AS MonthYearId,
									SUM(EntrdVolQt) AS SumVolume
								FROM
									Trace_filtered_withRatings
								GROUP BY
									IssuerId,
									CusipId,
									MONTH(TrdExctnDt),
									YEAR(TrdExctnDt)
							) A
						) A
						INNER JOIN (
							SELECT
								CusipId,
								TrdExctnDt,
								CONCAT(MONTH(TrdExctnDt), '-', YEAR(TrdExctnDt)) AS MonthYearId
							FROM
								Trace_filtered_withRatings
							WHERE
								RatingNum <> 0
						) B ON A.CusipId = B.CusipId AND A.MonthYearId = B.MonthYearId
						WHERE
							A.Ranking <= @TopPerformers
					) A
					WHERE
						TrdExctnDt <= EOMONTH(TrdExctnDt) AND TrdExctnDt > DATEADD(DAY, -5, EOMONTH(TrdExctnDt))
					GROUP BY
						CusipId,
						YEAR(TrdExctnDt),
						MONTH(TrdExctnDt)
				) A
				INNER JOIN 
					Trace_filtered_withRatings B ON A.CusipId = B.CusipId AND A.TrdExctnDt = B.TrdExctnDt
				WHERE
					B.RatingNum <> 0
			) A
			GROUP BY
				CusipId,
				TrdExctnDt
		) A
	) B ON A.CusipId = B.CusipId AND A.MontYearId = B.MontYearId
	WHERE
		DATEADD(MONTH, @HoldingPeriod, A.TrdExctnDt) <= A.Maturity

	-- SELECT STATEMENT
	SELECT
		*,
		ABS(
			DATEDIFF(
				MONTH,
				StartDate,
				LAG(EndDate) OVER (PARTITION BY CusipId ORDER BY StartDate)
			)
		) AS MonthGap,
		CASE
			WHEN InterestFrequency = 0 THEN 0
			ELSE ( 
				-- PRICE @ T
				EndPrice * PrincipalAmt / 100 +
				-- COUPONS PAID DURING T-1, T
				CouponsPaid * Coupon * PrincipalAmt / 100 / InterestFrequency / 360 + ( 
				-- ACCRUED INTEREST @ T
				Coupon * PrincipalAmt / 100 * EndD / InterestFrequency / 360 ) -
				-- PRICE @ T-1
				StartPrice * PrincipalAmt / 100 - (
				-- ACCRUED INTEREST @ T-1
				Coupon * PrincipalAmt / 100 * StartD / InterestFrequency / 360 ) ) / ( 
				-- PRICE @ T-1
				StartPrice * PrincipalAmt / 100 + ( 
				-- ACCRUED INTEREST @ T-1
				Coupon * PrincipalAmt / 100 * StartD / InterestFrequency / 360 ) 
			)
		END AS R
	FROM (
		SELECT
			*,
			CASE
				WHEN NextInterestDate >= StartDate AND NextInterestDate <= EndDate THEN 1
				ELSE 0
			END AS CouponsPaid,
			CASE
				WHEN InterestFrequency = 0 OR LatestInterestDate IS NULL THEN 0
				ELSE dbo.YearFact(LatestInterestDate, StartDate, 0 )
			END AS StartD,
			CASE
				WHEN InterestFrequency = 0 THEN 0
				ELSE
					CASE
						WHEN NextInterestDate >= StartDate AND NextInterestDate <= EndDate THEN dbo.YearFact(NextInterestDate, EndDate, 0 )
						ELSE dbo.YearFact(LatestInterestDate, EndDate, 0)
					END 
			END AS EndD
		FROM
			#TEMP_TABLE
		WHERE
			PrincipalAmt IS NOT NULL
	) A
	ORDER BY
		CusipId,
		StartDate

	-- DROP TEMP TABLE
	DROP TABLE #TEMP_TABLE

END
