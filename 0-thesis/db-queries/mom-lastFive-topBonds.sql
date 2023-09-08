DROP TABLE IF EXISTS [dbo].[BondReturns_lastFive_topBonds]

-- TEMP TABLE : TOP PERFORMERS ACCORDING TO THE LAST 5 DAYS OF THE MONTH
SELECT
    CusipId,
    TrdExctnDtEOM
INTO
    #TEMP_TopPerformers
FROM (
    SELECT
        *,
        DENSE_RANK() OVER (PARTITION BY IssuerId, TrdExctnDtEOM ORDER BY Volume DESC) AS VolumeRanking
    FROM (
        SELECT
            IssuerId,
            CusipId,
            EOMONTH(TrdExctnDt) AS TrdExctnDtEOM,
            SUM(EntrdVolQt) AS Volume
        FROM
            Trace_filtered_withRatings A
        WHERE
            RatingNum <> 0
            AND EntrdVolQt >= 500000 -- institunional
            AND PrincipalAmt IS NOT NULL
			AND TrdExctnDt <= EOMONTH(TrdExctnDt) AND TrdExctnDt > DATEADD(DAY, -5, EOMONTH(TrdExctnDt))
        GROUP BY
            IssuerId,
            CusipId,
            EOMONTH(TrdExctnDt)
    ) A
) B
WHERE
    VolumeRanking <= 3

-- TEMP TABLE : RETURN PARTICULARS
SELECT
	*,
	CASE
		WHEN InterestFrequency = 0 THEN NULL
		ELSE
			CASE
				WHEN NextInterestDate <= TrdExctnDtEOM AND NextInterestDate >= DATEFROMPARTS(YEAR(TrdExctnDtEOM), MONTH(TrdExctnDtEOM), 1) THEN 1
				ELSE 0
			END
	END AS CouponsPaid,
	CASE
		WHEN InterestFrequency = 0 THEN NULL
		ELSE
			CASE
				WHEN NextInterestDate <= TrdExctnDtEOM AND NextInterestDate >= DATEFROMPARTS(YEAR(TrdExctnDtEOM), MONTH(TrdExctnDtEOM), 1) THEN dbo.YearFact(TrdExctnDt, NextInterestDate, 0)
				ELSE 
					CASE
						WHEN LatestInterestDate IS NULL THEN 0
						ELSE dbo.YearFact(LatestInterestDate, TrdExctnDt, 0)
					END
			END
	END AS D
INTO
	#TEMP_TABLE
FROM (
	SELECT
		*,
		CASE 
			WHEN InterestFrequency = 0 THEN NULL
			ELSE
				CASE
					WHEN TrdExctnDt < FirstInterestDate THEN FirstInterestDate
					ELSE 
						DATEADD( 
							MONTH,
							1.0 * 360 / InterestFrequency / 30,
							DATEADD( 
								MONTH,
								1.0 * ( ABS ( dbo.YearFact(TrdExctnDt, FirstInterestDate, 0 ) ) ) / ( 1.0 * 360 / InterestFrequency ) * ( 1.0 * 360 / InterestFrequency / 30 ),
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
							1.0 * ( ABS ( dbo.YearFact(TrdExctnDt, FirstInterestDate, 0 ) ) ) / ( 1.0 * 360 / InterestFrequency ) * ( 1.0 * 360 / InterestFrequency / 30 ),
							FirstInterestDate
						) 
				END 
		END AS LatestInterestDate
	FROM (
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
				WHEN MAX(RatingNum) <= 10 THEN 'HY'
				WHEN MAX(RatingNum) >= 11 THEN 'IG'
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
				A.CusipId,
				A.TrdExctnDt,
				A.RptdPr * A.EntrdVolQt AS PriceVolumeProduct,
				A.EntrdVolQt,
				A.Coupon,
				A.PrincipalAmt,
				A.InterestFrequency,
				A.RatingNum,
				A.Maturity,
				A.FirstInterestDate,
				A.OfferingDate
			FROM
				Trace_filtered_withRatings A
			INNER JOIN (
				SELECT
					CusipId,
					MAX(TrdExctnDt) AS TrdExctnDt
				FROM (
                    SELECT
                        A.*
                    FROM
                        Trace_filtered_withRatings A
                    INNER JOIN
                        #TEMP_TopPerformers B ON A.CusipId = B.CusipId AND EOMONTH(A.TrdExctnDt) = B.TrdExctnDtEOM
                ) A
				WHERE
				    TrdExctnDt <= EOMONTH(TrdExctnDt) AND TrdExctnDt > DATEADD(DAY, -5, EOMONTH(TrdExctnDt))
				GROUP BY
					CusipId,
					EOMONTH(TrdExctnDt)
			) B ON A.CusipId = B.CusipId AND A.TrdExctnDt = B.TrdExctnDt
		) A
		GROUP BY
			CusipId,
			TrdExctnDt
		HAVING
			SUM(EntrdVolQt) <> 0 AND SUM(EntrdVolQt) IS NOT NULL
	) A
) A

-- TEMP TABLE : RETURNS
SELECT
	*,
	CASE
		WHEN InterestFrequency = 0 THEN ( WeightPrice * PrincipalAmt / 100 - LagWeightedPrice * PrincipalAmt / 100 ) / ( LagWeightedPrice * PrincipalAmt / 100 )
		ELSE ( 
			WeightPrice * PrincipalAmt / 100 + 
			CouponsPaid * Coupon * PrincipalAmt * InterestFrequency / 360 +
			AI - 
			LagWeightedPrice * PrincipalAmt / 100 -
			LagAI 
			) / ( LagWeightedPrice * PrincipalAmt / 100 + LagAI )
	END AS R
INTO
	#TEMP_RETURNS
FROM (
	SELECT
		*,
		LAG(WeightPrice) OVER (PARTITION BY CusipId ORDER BY TrdExctnDtEOM) AS LagWeightedPrice,
		LAG(AI) OVER (PARTITION BY CusipId ORDER BY TrdExctnDtEOM) AS LagAI
	FROM (
		SELECT
			B.CusipId,
			A.MonthDateEOM AS TrdExctnDtEOM,
			C.WeightPrice,
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
			C.D,
			CASE
				WHEN C.InterestFrequency = 0 THEN NULL
				ELSE C.CouponsPaid * ( C.Coupon * PrincipalAmt / 100 * C.D / C.InterestFrequency / 360 ) 
			END AS AI
		FROM
			Date A
		CROSS JOIN (
			SELECT
				DISTINCT CusipId
			FROM
				#TEMP_TABLE
		) B
		LEFT JOIN 
			#TEMP_TABLE C ON A.MonthDateEOM = C.TrdExctnDtEOM AND B.CusipId = C.CusipId
	) A
) A

SELECT
	A.*
INTO
	[dbo].[BondReturns_lastFive_topBonds]
FROM
	#TEMP_RETURNS A
INNER JOIN (
	SELECT 
		CusipId,
		MIN(TrdExctnDtEOM) AS MinTrdExctnDtEOM,
		MAX(TrdExctnDtEOM) AS MaxTrdExctnDtEOM
	FROM
		#TEMP_RETURNS
	WHERE
		WeightPrice IS NOT NULL
	GROUP BY
		CusipId
) B ON A.CusipId = B.CusipId AND A.TrdExctnDtEOM >= B.MinTrdExctnDtEOM AND A.TrdExctnDtEOM <= MaxTrdExctnDtEOM

DROP TABLE #TEMP_TABLE
DROP TABLE #TEMP_RETURNS
DROP TABLE #TEMP_TopPerformers
