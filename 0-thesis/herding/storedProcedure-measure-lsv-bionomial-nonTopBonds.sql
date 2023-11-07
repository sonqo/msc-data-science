CREATE PROCEDURE

	[dbo].[Measures_Lsv_Bionomial_NonTopBonds] @TimeFrame INT = 1, @Investor INT = NULL, @CreditRisk INT = NULL

AS

BEGIN
	
    SET NOCOUNT ON

    SELECT
        *,
		CASE
			WHEN Pt > P THEN Hm 
		END AS Bhm,
		CASE
			WHEN Pt < P THEN Hm
		END AS Shm
    FROM (
        SELECT
            A.TrdExctnDtTF,
            A.CusipId,
            Pt,
            P,
            ABS(Pt - P) AS Ft,
            ABS(1.0 * P * BionomialDraw / N - P) AS Af,
            1.0 * ABS(Pt - P) - 1.0 * ABS(1.0 * P * BionomialDraw / N - P) AS Hm
        FROM (     
            SELECT
                TrdExctnDtTF,
                CusipId,
                MAX(CustomerBuys) + MAX(CustomerSells) AS N,
                1.0 * MAX(CustomerBuys) / (MAX(CustomerBuys) + MAX(CustomerSells)) AS Pt,
                SUM(CASE WHEN RandomDraw <= 1 - 1.0 * CustomerBuys / (CustomerBuys + CustomerSells) THEN 0 ELSE 1 END) AS BionomialDraw
            FROM (
                SELECT
                    TrdExctnDtTF,
                    CusipId,
                    RAND() AS RandomDraw,
                    SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtTF, CusipId) AS CustomerBuys,
                    SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtTF, CusipId) AS CustomerSells
                FROM (
                    SELECT
                        *,
                        CASE
                            WHEN @TimeFrame = 1 THEN TrdExctnDt -- DAY
                            WHEN @TimeFrame = 2 THEN DATEADD(DAY, 1 - DATEPART(WEEKDAY, TrdExctnDt) + 1, TrdExctnDt) -- WEEK
                            WHEN @TimeFrame = 3 THEN EOMONTH(TrdExctnDt) -- MONTH
                            WHEN @TimeFrame = 4 THEN -- QUARTER
                                CASE 
                                    WHEN DATEPART(QUARTER, TrdExctnDt) = 1 THEN DATEFROMPARTS(YEAR(TrdExctnDt), 01, 01)
                                    WHEN DATEPART(QUARTER, TrdExctnDt) = 2 THEN DATEFROMPARTS(YEAR(TrdExctnDt), 04, 01)
                                    WHEN DATEPART(QUARTER, TrdExctnDt) = 3 THEN DATEFROMPARTS(YEAR(TrdExctnDt), 07, 01)
                                    WHEN DATEPART(QUARTER, TrdExctnDt) = 4 THEN DATEFROMPARTS(YEAR(TrdExctnDt), 10, 01)
                                END
                            WHEN @TimeFrame = 5 THEN DATEFROMPARTS(YEAR(TrdExctnDt), 01, 01) -- YEAR
                        END AS TrdExctnDtTF,
                        CASE
                            WHEN EntrdVolQt < 250000 AND @Investor <> 1 THEN 2 -- RETAIL
                            WHEN EntrdVolQt >= 500000 AND @Investor <> 1 THEN 3 -- INSTITUTIONAL
                            ELSE 1 -- WHOLE
                        END AS Investor
                    FROM (
                        SELECT
                            A.*,
                            B.CusipId AS CusipId_
                        FROM
                            Trace_filteredWithRatings A
                        LEFT JOIN
                            BondReturns_topBonds B ON A.CusipId = B.CusipId AND EOMONTH(A.TrdExctnDt) = B.TrdExctnDtEOM
                    ) A  
                    WHERE
                        CntraMpId = 'C'
                        AND CusipId_ IS NULL
                        AND RatingNum > CASE WHEN @CreditRisk = 1 THEN 10 ELSE 0 END -- HY
                        AND RatingNum < CASE WHEN @CreditRisk = 2 THEN 11 ELSE 25 END -- IG
                ) A
                WHERE
                    Investor = @Investor
            ) A
            GROUP BY
                TrdExctnDtTF,
                CusipId
        ) A
        INNER JOIN (
            SELECT
                TrdExctnDtTF,
                1.0 * SUM(CustomerBuys) / (SUM(CustomerBuys) + SUM(CustomersSells)) AS P
            FROM (
                SELECT
                    TrdExctnDtTF,
                    CusipId,
                    SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) AS CustomerBuys,
                    SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) AS CustomersSells
                FROM (
                    SELECT
                        *,
                        CASE
                            WHEN @TimeFrame = 1 THEN TrdExctnDt -- DAY
                            WHEN @TimeFrame = 2 THEN DATEADD(DAY, 1 - DATEPART(WEEKDAY, TrdExctnDt) + 1, TrdExctnDt) -- WEEK
                            WHEN @TimeFrame = 3 THEN EOMONTH(TrdExctnDt) -- MONTH
                            WHEN @TimeFrame = 4 THEN -- QUARTER
                                CASE 
                                    WHEN DATEPART(QUARTER, TrdExctnDt) = 1 THEN DATEFROMPARTS(YEAR(TrdExctnDt), 01, 01)
                                    WHEN DATEPART(QUARTER, TrdExctnDt) = 2 THEN DATEFROMPARTS(YEAR(TrdExctnDt), 04, 01)
                                    WHEN DATEPART(QUARTER, TrdExctnDt) = 3 THEN DATEFROMPARTS(YEAR(TrdExctnDt), 07, 01)
                                    WHEN DATEPART(QUARTER, TrdExctnDt) = 4 THEN DATEFROMPARTS(YEAR(TrdExctnDt), 10, 01)
                                END
                            WHEN @TimeFrame = 5 THEN DATEFROMPARTS(YEAR(TrdExctnDt), 01, 01) -- YEAR
                        END AS TrdExctnDtTF,
                        CASE
                            WHEN EntrdVolQt < 250000 AND @Investor <> 1 THEN 2 -- RETAIL
                            WHEN EntrdVolQt >= 500000 AND @Investor <> 1 THEN 3 -- INSTITUTIONAL
                            ELSE 1 -- WHOLE
                        END AS Investor
                    FROM (
                        SELECT
                            A.*,
                            B.CusipId AS CusipId_
                        FROM
                            Trace_filteredWithRatings A
                        LEFT JOIN
                            BondReturns_topBonds B ON A.CusipId = B.CusipId AND EOMONTH(A.TrdExctnDt) = B.TrdExctnDtEOM
                    ) A 
                    WHERE
                        CntraMpId = 'C'
                        AND CusipId_ IS NULL
                        AND RatingNum > CASE WHEN @CreditRisk = 1 THEN 10 ELSE 0 END -- HY
                        AND RatingNum < CASE WHEN @CreditRisk = 2 THEN 11 ELSE 25 END -- IG
                ) A
                WHERE
                    Investor = @Investor
                GROUP BY
                    TrdExctnDtTF,
                    CusipId
            ) A
            GROUP BY
                TrdExctnDtTF
        ) B ON A.TrdExctnDtTF = B.TrdExctnDtTF
    ) C
	ORDER BY
		TrdExctnDtTF,
		CusipId

END
