DROP TABLE IF EXISTS [dbo].[BondReturnsCustomer]

SELECT
	*,
	CASE
		WHEN LatestInterestDate <= TrdExctnDt AND LatestInterestDate >= DATEFROMPARTS(YEAR(TrdExctnDt), MONTH(TrdExctnDt), 1) THEN Coupon / InterestFrequency
		ELSE 0 
	END AS CouponAmount,
	CASE
		WHEN InterestFrequency > 0 THEN (Coupon * D) / 360
		ELSE 0 
	END AS CouponAccrued
INTO
	#TEMP_TABLE_V1
FROM (
	SELECT
		*,
		CASE
			WHEN InterestFrequency = 0 THEN NULL
			ELSE
				CASE
					WHEN NextInterestDate <= TrdExctnDt AND NextInterestDate >= DATEFROMPARTS(YEAR(TrdExctnDt), MONTH(TrdExctnDt), 1) THEN dbo.YearFact(TrdExctnDt, NextInterestDate, 0)
					ELSE 
						CASE
							WHEN LatestInterestDate IS NULL THEN dbo.YearFact(OfferingDate, TrdExctnDt, 0)
							ELSE dbo.YearFact(LatestInterestDate, TrdExctnDt, 0)
						END
				END
		END AS D
	FROM (
		SELECT
			CusipId,
			TrdExctnDt,
			T_Price,
			T_Volume,
			TD_Volume,
			Coupon,
			CouponMonth,
			PrincipalAmt,
			InterestFrequency,
			RatingNum,
			RatingClass,
			Maturity,
			MaturityBand,
			OfferingDate,
			FirstInterestDate,
			LatestInterestDate,
			CASE
				WHEN TempNextInterestDate > Maturity THEN Maturity
				ELSE TempNextInterestDate
			END AS NextInterestDate
		FROM (
			 SELECT
				*,
				DATEDIFF(MONTH, FirstInterestDate, TrdExctnDt) AS CouponMonth,
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
										( ABS ( dbo.YearFact(TrdExctnDt, FirstInterestDate, 0) ) ) / ( 360 / InterestFrequency ) * ( 360 / InterestFrequency / 30 ),
										FirstInterestDate
									)
								)
						END 
				END AS TempNextInterestDate,
				CASE
					WHEN InterestFrequency = 0 THEN NULL
					ELSE
						CASE
							WHEN TrdExctnDt < FirstInterestDate THEN NULL
							ELSE
								DATEADD( 
									MONTH,
									( ABS ( dbo.YearFact(TrdExctnDt, FirstInterestDate, 0) ) ) / ( 360 / InterestFrequency ) * ( 360 / InterestFrequency / 30 ),
									FirstInterestDate
								) 
						END 
				END AS LatestInterestDate
			FROM (
				 SELECT
					CusipId,
					TrdExctnDt,
					SUM(PriceVolumeProduct) / SUM(EntrdVolQt) AS T_Price,
					SUM(EntrdVolQt) AS T_Volume,
					SUM(PriceVolumeProduct) AS TD_Volume,
					MAX(Coupon) AS Coupon,
					MAX(PrincipalAmt) AS PrincipalAmt,
					CASE
						WHEN MAX(InterestFrequency) = 14 THEN 6
						WHEN MAX(InterestFrequency) = 13 THEN 12
						WHEN MAX(InterestFrequency) IS NULL THEN 2
						WHEN MAX(InterestFrequency) < 0 OR MAX(InterestFrequency) > 14 THEN 0
						ELSE MAX(InterestFrequency)
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
					END AS FirstInterestDate,
					MAX(OfferingDate) AS OfferingDate
				FROM (
					SELECT
						A.CusipId,
						A.TrdExctnDt,
						RptdPr,
						CASE
							WHEN RptdPr <= 0 THEN NULL
							ELSE RptdPr * EntrdVolQt
						END AS PriceVolumeProduct,
						A.EntrdVolQt,
						A.Coupon,
						A.PrincipalAmt,
						A.InterestFrequency,
						A.RatingNum,
						A.Maturity,
						A.FirstInterestDate,
						A.OfferingDate
					FROM
						Trace_filteredWithRatings A
					INNER JOIN (
						SELECT
							CusipId,
							MAX(TrdExctnDt) AS TrdExctnDt
						FROM
							Trace_filteredWithRatings A
						WHERE
							CntraMpId = 'C'
							AND PrincipalAmt IN (10, 1000)
							AND TrdExctnDt <= EOMONTH(TrdExctnDt) AND TrdExctnDt > DATEADD(DAY, -5, EOMONTH(TrdExctnDt))
						GROUP BY
							CusipId,
							EOMONTH(TrdExctnDt)
					) B ON A.CusipId = B.CusipId AND A.TrdExctnDt = B.TrdExctnDt
					WHERE
						A.CntraMpId = 'C'
				) C
				GROUP BY
					CusipId,
					TrdExctnDt
				HAVING
					SUM(EntrdVolQt) IS NOT NULL AND SUM(EntrdVolQt) <> 0
					AND SUM(PriceVolumeProduct) IS NOT NULL AND SUM(PriceVolumeProduct) <> 0
			) D
		) E
	) F
) G

SELECT
	*,
	(T_Price + CouponAccrued + CouponAmount - LagT_Price - LagCouponAccrued) / (LagT_Price + LagCouponAccrued) AS R
INTO
	#TEMP_TABLE_V2
FROM (
	SELECT
		CusipId,
		TrdExctnDtEOM,
		T_Price,
		LAG(T_Price) OVER (PARTITION BY CusipId ORDER BY TrdExctnDtEOM) AS LagT_Price,
		T_Volume,
		TD_Volume,
		PrincipalAmt,
		InterestFrequency,
		Coupon,
		CouponAmount,
		CouponAccrued,
		LAG(CouponAccrued) OVER (PARTITION BY CusipId ORDER BY TrdExctnDtEOM) AS LagCouponAccrued,
		D,
		RatingNum,
		RatingClass,
		FirstInterestDate,
		LatestInterestDate,
		NextInterestDate,
		Maturity,
		MaturityBand
	FROM (
		SELECT
			B.CusipId,
			A.MonthDateEOM AS TrdExctnDtEOM,
			C.T_Price,
			C.T_Volume,
			C.TD_Volume,
			C.PrincipalAmt,
			C.InterestFrequency,
			C.Coupon,
			C.CouponAmount,
			C.CouponAccrued,
			C.RatingNum,
			C.RatingClass,
			C.OfferingDate,
			C.FirstInterestDate,
			C.LatestInterestDate,
			C.NextInterestDate,
			C.Maturity,
			C.MaturityBand,
			C.D
		FROM
			Date A
		CROSS JOIN (
			SELECT
				DISTINCT CusipId
			FROM
				#TEMP_TABLE_V1
		) B
		LEFT JOIN 
			#TEMP_TABLE_V1 C ON A.MonthDateEOM = EOMONTH(C.TrdExctnDt) AND B.CusipId = C.CusipId
	) A
) B

SELECT
    A.*
INTO
	[dbo].[BondReturnsCustomer]
FROM
    #TEMP_TABLE_V2 A
INNER JOIN (
    SELECT 
        CusipId,
        MIN(TrdExctnDtEOM) AS MinTrdExctnDtEOM,
        MAX(TrdExctnDtEOM) AS MaxTrdExctnDtEOM
    FROM
        #TEMP_TABLE_V2
    WHERE
        T_Price IS NOT NULL
    GROUP BY
        CusipId
) B ON A.CusipId = B.CusipId AND A.TrdExctnDtEOM >= B.MinTrdExctnDtEOM AND A.TrdExctnDtEOM <= MaxTrdExctnDtEOM

DROP TABLE #TEMP_TABLE_V1
DROP TABLE #TEMP_TABLE_V2
