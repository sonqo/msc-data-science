CREATE PROCEDURE

	[dbo].[Momentum_wholeDataset] @CreditRisk NVARCHAR(10) = NULL

AS

BEGIN
	
    SET NOCOUNT ON
   
    -- TEMP TABLE : RETURN PARTICULARS
    SELECT
        *,
        CASE
            WHEN InterestFrequency = 0 THEN NULL
            ELSE
                CASE
                    WHEN LatestInterestDate <= TrdExctnDtEOM AND LatestInterestDate >= DATEFROMPARTS(YEAR(TrdExctnDtEOM), MONTH(TrdExctnDtEOM), 1) THEN 1
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
                                360 / InterestFrequency / 30,
                                DATEADD( 
                                    MONTH,
                                    ( ABS ( dbo.YearFact(TrdExctnDt, FirstInterestDate, 0) ) ) / ( 360 / InterestFrequency ) * ( 360 / InterestFrequency / 30 ),
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
                                ( ABS ( dbo.YearFact(TrdExctnDt, FirstInterestDate, 0) ) ) / ( 360 / InterestFrequency ) * ( 360 / InterestFrequency / 30 ),
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
                    Trace_filteredWithRatings A
                INNER JOIN (
                    SELECT
                        CusipId,
                        MAX(TrdExctnDt) AS TrdExctnDt
                    FROM
						Trace_filteredWithRatings A
                    WHERE
						PrincipalAmt IS NOT NULL
						AND RatingNum > CASE WHEN @CreditRisk = 'HY' THEN 10 ELSE 0 END
						AND RatingNum < CASE WHEN @CreditRisk = 'IG' THEN 11 ELSE 25 END
                        AND TrdExctnDt <= EOMONTH(TrdExctnDt) AND TrdExctnDt > DATEADD(DAY, -5, EOMONTH(TrdExctnDt))
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
            WHEN InterestFrequency = 0 THEN ( WeightPrice - LagWeightedPrice ) / ( LagWeightedPrice )
            ELSE ( 
                WeightPrice + 
                CouponsPaid * Coupon / 100 * PrincipalAmt / InterestFrequency +
                AI - 
                LagWeightedPrice -
                LagAI 
                ) / ( LagWeightedPrice + LagAI )
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

    -- FINAL
    SELECT
        A.*
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

END

select * from #TEMP_RETURNS order by cusipid, TrdExctnDtEOM