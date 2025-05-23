CREATE PROCEDURE

	[dbo].[Momentum-TopBondsRetail] @CreditRisk NVARCHAR(10) = NULL, @Ownership NVARCHAR(10) = NULL

AS

BEGIN
	
    SET NOCOUNT ON

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
						WHEN NextInterestDate <= TrdExctnDt AND NextInterestDate >= DATEFROMPARTS(YEAR(TrdExctnDt), MONTH(TrdExctnDt), 1) THEN dbo.YearFrac(TrdExctnDt, NextInterestDate, 0)
						ELSE 
							CASE
								WHEN LatestInterestDate IS NULL THEN dbo.YearFrac(OfferingDate, TrdExctnDt, 0)
								ELSE dbo.YearFrac(LatestInterestDate, TrdExctnDt, 0)
							END
					END
			END AS D
		FROM (
			SELECT
				CusipId,
				IssuerId,
				IssuerOwnership,
				TrdExctnDt,
				T_Price,
				T_Volume,
				TD_Volume,
				InstitunionalTradeShare,
				InstitunionalVolumeShare,
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
				END AS NextInterestDate,
				ConsecutiveMonths
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
											( ABS ( dbo.YearFrac(TrdExctnDt, FirstInterestDate, 0) ) ) / ( 360 / InterestFrequency ) * ( 360 / InterestFrequency / 30 ),
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
										( ABS ( dbo.YearFrac(TrdExctnDt, FirstInterestDate, 0) ) ) / ( 360 / InterestFrequency ) * ( 360 / InterestFrequency / 30 ),
										FirstInterestDate
									) 
							END 
					END AS LatestInterestDate
				FROM (
					SELECT
						CusipId,
						MAX(IssuerId) AS IssuerId,
						MAX(IssuerOwnership) AS IssuerOwnership,
						TrdExctnDt,
						SUM(PriceVolumeProduct) / SUM(EntrdVolQt) AS T_Price,
						SUM(EntrdVolQt) AS T_Volume,
						SUM(PriceVolumeProduct) AS TD_Volume,
						1.0 * SUM(CASE WHEN EntrdVolQt >= 500000 THEN 1 ELSE 0 END) / SUM(1) AS InstitunionalTradeShare,
						1.0 * SUM(CASE WHEN EntrdVolQt >= 500000 THEN EntrdVolQt ELSE 0 END) / SUM(EntrdVolQt) AS InstitunionalVolumeShare,
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
						MAX(OfferingDate) AS OfferingDate,
						MAX(ConsecutiveMonths) AS ConsecutiveMonths
					FROM (
						SELECT
							A.CusipId,
							A.IssuerId,
							C.Private AS IssuerOwnership,
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
							A.OfferingDate,
							B.ConsecutiveMonths
						FROM
							TraceFilteredWithRatings A
						INNER JOIN (
							SELECT
								A.CusipId,
								MAX(A.TrdExctnDt) AS TrdExctnDt,
								MAX(B.ConsecutiveMonths) AS ConsecutiveMonths
							FROM
								TraceFilteredWithRatings A
							INNER JOIN
								TopBondsRetail B ON A.CusipId = B.CusipId AND EOMONTH(A.TrdExctnDt) = B.TrdExctnDtEOM
							INNER JOIN
								BondIssuersOwnership C ON A.IssuerId = C.IssuerId
							WHERE
								PrincipalAmt IN (10, 1000)
								AND Private < CASE WHEN @Ownership = 'Public' THEN 1 ELSE 2 END
								AND RatingNum > CASE WHEN @CreditRisk = 'HY' THEN 10 ELSE 0 END
								AND RatingNum < CASE WHEN @CreditRisk = 'IG' THEN 11 ELSE 25 END
								AND Private > CASE WHEN @Ownership = 'Private' THEN 0 ELSE -1 END
								AND TrdExctnDt <= EOMONTH(TrdExctnDt) AND TrdExctnDt > DATEADD(DAY, -5, EOMONTH(TrdExctnDt))
							GROUP BY
								A.CusipId,
								EOMONTH(A.TrdExctnDt)
						) B ON A.CusipId = B.CusipId AND A.TrdExctnDt = B.TrdExctnDt
						INNER JOIN
							BondIssuersOwnership C ON A.IssuerId = C.IssuerId
						WHERE
							RatingNum > CASE WHEN @CreditRisk = 'HY' THEN 10 ELSE 0 END
							AND RatingNum < CASE WHEN @CreditRisk = 'IG' THEN 11 ELSE 25 END
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
			IssuerId,
			IssuerOwnership,
			TrdExctnDtEOM,
			T_Price,
			LAG(T_Price) OVER (PARTITION BY CusipId ORDER BY TrdExctnDtEOM) AS LagT_Price,
			T_Volume,
			TD_Volume,
			InstitunionalTradeShare,
			InstitunionalVolumeShare,
			PrincipalAmt,
			InterestFrequency,
			Coupon,
			CouponAmount,
			CouponAccrued,
			LAG(CouponAccrued) OVER (PARTITION BY CusipId ORDER BY TrdExctnDtEOM) AS LagCouponAccrued,
			RatingNum,
			RatingClass,
			OfferingDate,
			FirstInterestDate,
			LatestInterestDate,
			NextInterestDate,
			Maturity,
			MaturityBand,
			ConsecutiveMonths
		FROM (
			SELECT
				B.CusipId,
				C.IssuerId,
				C.IssuerOwnership,
				A.MonthDateEOM AS TrdExctnDtEOM,
				C.T_Price,
				C.T_Volume,
				C.TD_Volume,
				C.InstitunionalTradeShare,
				C.InstitunionalVolumeShare,
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
				C.D,
				C.ConsecutiveMonths
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
		A.*,
		C.TopBondGrouping
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
	INNER JOIN (
		SELECT
			IssuerId,
			TrdExctnDtEOM,
			CASE
				WHEN TopCusips = TotalCusips THEN 'G3'
				WHEN TopCusips = 0 OR TopCusips IS NULL THEN 'G1'
				ELSE 'G2'
			END AS TopBondGrouping
		FROM (
			SELECT
				A.IssuerId,
				EOMONTH(A.TrdExctnDt) AS TrdExctnDtEOM,
				COUNT(DISTINCT A.CusipId) AS TotalCusips,
				COUNT(DISTINCT B.CusipId) AS TopCusips
			FROM
				TraceFilteredWithRatings A
			LEFT JOIN
				TopBondsRetail B ON A.IssuerId = B.IssuerId AND  EOMONTH(A.TrdExctnDt) = B.TrdExctnDtEOM
			GROUP BY
				A.IssuerId,
				EOMONTH(A.TrdExctnDt)
		) A
	) C ON A.IssuerId = C.IssuerId AND A.TrdExctnDtEOM = C.TrdExctnDtEOM

	DROP TABLE #TEMP_TABLE_V1
	DROP TABLE #TEMP_TABLE_V2

END
