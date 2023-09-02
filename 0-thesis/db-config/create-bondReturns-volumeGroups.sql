DROP TABLE IF EXISTS #TEMP_TABLE

DECLARE @VolumeRangeStart int = 500000
DECLARE @VolumeRangeEnd int = 1000000

SELECT
	A.CusipId,
	A.TrdExctnDt AS StartDate,
	B.TrdExctnDt AS EndDate,
	A.WeightPrice AS StartPrice,
	B.WeightPrice AS EndPrice,
	A.Coupon,
	A.PrincipalAmt,
	A.InterestFrequency,
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
			FirstInterestDate,
			OfferingDate
		FROM (
			SELECT
				CusipId,
				MAX(TrdExctnDt) AS TrdExctnDt
			FROM
				Trace_filtered_withRatings
			WHERE
				RatingNum <> 0
				AND EntrdVolQt BETWEEN @VolumeRangeStart AND @VolumeRangeEnd
				AND TrdExctnDt >= DATEFROMPARTS(YEAR(TrdExctnDt), MONTH(TrdExctnDt), 1) AND TrdExctnDt <= DATEFROMPARTS(YEAR(TrdExctnDt), MONTH(TrdExctnDt), 5)
			GROUP BY
				CusipId,
				YEAR(TrdExctnDt),
				MONTH(TrdExctnDt)
		) A
		INNER JOIN 
			Trace_filtered_withRatings B ON A.CusipId = B.CusipId AND A.TrdExctnDt = B.TrdExctnDt
		WHERE
			B.RatingNum <> 0
			AND B.EntrdVolQt BETWEEN @VolumeRangeStart AND @VolumeRangeEnd
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
				FROM
					Trace_filtered_withRatings
				WHERE
					RatingNum <> 0
					AND EntrdVolQt BETWEEN @VolumeRangeStart AND @VolumeRangeEnd
					AND TrdExctnDt <= EOMONTH(TrdExctnDt) AND TrdExctnDt > DATEADD(DAY, -5, EOMONTH(TrdExctnDt))
				GROUP BY
					CusipId,
					YEAR(TrdExctnDt),
					MONTH(TrdExctnDt)
			) A
			INNER JOIN 
				Trace_filtered_withRatings B ON A.CusipId = B.CusipId AND A.TrdExctnDt = B.TrdExctnDt
			WHERE
				B.RatingNum <> 0
				AND B.EntrdVolQt BETWEEN @VolumeRangeStart AND @VolumeRangeEnd
		) A
		GROUP BY
			CusipId,
			TrdExctnDt
	) A
) B ON A.CusipId = B.CusipId AND A.MontYearId = B.MontYearId

SELECT
	*,
	ABS(
		DATEDIFF(
			MONTH,
			StartDate,
			LAG(EndDate) OVER (PARTITION BY CusipId ORDER BY StartDate)
		)
	) AS MonthGap,
	( 
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
		Coupon * PrincipalAmt / 100 * StartD / InterestFrequency / 360 ) ) AS R
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
) A
ORDER BY
	CusipId,
	StartDate

DROP TABLE #TEMP_TABLE
