DROP TABLE IF EXISTS [dbo].[BondReturns_volumeGroups_250k-500k]

DECLARE @VolumeRangeStart INT
DECLARE @VolumeRangeEnd INT

SET @VolumeRangeStart = 250000
SET @VolumeRangeEnd = 500000

-- TEMP TABLE : SAME CUSIP TRADE VOLUME INTRA MONTH
SELECT
	A.CusipId,
	EOMONTH(B.TrdExctnDt) AS TrdExctnDtEOM,
	A.TrdExctnDt AS StartDate,
	B.TrdExctnDt AS EndDate,
	A.WeightPrice AS StartPrice,
	B.WeightPrice AS EndPrice,
	A.Volume,
	A.Coupon,
	A.PrincipalAmt,
	A.InterestFrequency,
	A.RatingNum,
	A.RatingClass,
	A.Maturity,
	A.MaturityBand,
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
		SUM(PriceVolumeProduct) / SUM(EntrdVolQt) AS WeightPrice,
		SUM(EntrdVolQt) AS Volume,
		MAX(Coupon) AS Coupon,
		MAX(PrincipalAmt) AS PrincipalAmt,
		CASE
			WHEN MAX(InterestFrequency) IS NOT NULL THEN MAX(InterestFrequency)
			ELSE 2
		END AS InterestFrequency,
		MAX(RatingNum) AS RatingNum,
		CASE
			WHEN MAX(RatingNum) <= 10 THEN 'IG'
			WHEN MAX(RatingNum) >= 11 THEN 'HY'
			ELSE NULL
		END AS RatingClass,
		MAX(Maturity) AS Maturity,
		CASE 
			WHEN ABS(DATEDIFF(DAY, MAX(Maturity), MAX(OfferingDate))) * 1.0 / 360 <= 4 THEN 1
			WHEN ABS(DATEDIFF(DAY, MAX(Maturity), MAX(OfferingDate))) * 1.0 / 360 <= 14 THEN 2
			WHEN ABS(DATEDIFF(DAY, MAX(Maturity), MAX(OfferingDate))) * 1.0 / 360 >= 15 THEN 3
			ELSE NULL
		END AS MaturityBand,
		CASE
			WHEN MAX(FirstInterestDate) IS NOT NULL THEN MAX(FirstInterestDate)
			ELSE MAX(OfferingDate)
		END AS FirstInterestDate
	FROM (
		SELECT
			B.CusipId,
			B.TrdExctnDt,
			RptdPr * EntrdVolQt AS PriceVolumeProduct,
			EntrdVolQt,
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
				MIN(TrdExctnDt) AS TrdExctnDt
			FROM
				Trace_filtered_withRatings
			WHERE
				RatingNum <> 0
				AND EntrdVolQt >= @VolumeRangeStart AND EntrdVolQt < @VolumeRangeEnd
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
			AND EntrdVolQt >= @VolumeRangeStart AND EntrdVolQt < @VolumeRangeEnd
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
					AND EntrdVolQt >= @VolumeRangeStart AND EntrdVolQt < @VolumeRangeEnd
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
				AND EntrdVolQt >= @VolumeRangeStart AND EntrdVolQt < @VolumeRangeEnd
		) A
		GROUP BY
			CusipId,
			TrdExctnDt
	) A
) B ON A.CusipId = B.CusipId AND A.TrdExctnDtEOM = B.TrdExctnDtEOM

-- TEMP TABLE : RETURNS
SELECT
	*
INTO
	#TEMP_RETURNS
FROM (
	SELECT
		*,
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
				ELSE dbo.YearFact(LatestInterestDate, StartDate, 0)
			END AS StartD,
			CASE
				WHEN InterestFrequency = 0 THEN 0
				ELSE
					CASE
						WHEN NextInterestDate >= StartDate AND NextInterestDate <= EndDate THEN dbo.YearFact(NextInterestDate, EndDate, 0)
						ELSE
							CASE
								WHEN LatestInterestDate IS NULL THEN 0
								ELSE dbo.YearFact(LatestInterestDate, EndDate, 0)
							END
					END 
			END AS EndD
		FROM
			#TEMP_TABLE
		WHERE
			PrincipalAmt IS NOT NULL
	) A
) B

-- TEMP TABLE : ALL DATE RETURNS
SELECT
	B.CusipId,
	A.MonthDateEOM AS TrdExctnDtEOM,
	C.StartPrice,
	C.EndPrice,
	C.Volume,
	C.Coupon,
	C.PrincipalAmt,
	C.InterestFrequency,
	C.RatingNum,
	C.RatingClass,
	C.Maturity,
	C.MaturityBand,
	C.FirstInterestDate,
	C.NextInterestDate,
	C.LatestInterestDate,
	C.CouponsPaid,
	C.R
INTO	
	#TEMP_FINAL
FROM
	Date A
CROSS JOIN (
	SELECT
		DISTINCT CusipId
	FROM
		#TEMP_RETURNS
) B
LEFT JOIN 
	#TEMP_RETURNS C ON A.MonthDateEOM = C.TrdExctnDtEOM AND B.CusipId = C.CusipId

-- RETURNS
SELECT
	A.*
INTO
	[dbo].[BondReturns_volumeGroups_250k-500k]
FROM
	#TEMP_FINAL A
INNER JOIN (
	SELECT 
		CusipId,
		MIN(TrdExctnDtEOM) AS MinTrdExctnDtEOM,
		MAX(TrdExctnDtEOM) AS MaxTrdExctnDtEOM
	FROM
		#TEMP_FINAL
	WHERE
		StartPrice IS NOT NULL AND EndPrice IS NOT NULL
	GROUP BY
		CusipId
) B ON A.CusipId = B.CusipId AND A.TrdExctnDtEOM >= B.MinTrdExctnDtEOM AND A.TrdExctnDtEOM <= MaxTrdExctnDtEOM

DROP TABLE #TEMP_FINAL
DROP TABLE #TEMP_TABLE
DROP TABLE #TEMP_RETURNS
