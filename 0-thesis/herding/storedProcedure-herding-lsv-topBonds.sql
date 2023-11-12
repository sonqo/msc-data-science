CREATE PROCEDURE

	[dbo].[Herding-Measures-Lsv-TopBonds] @TimeFrame INT = 1, @Investor INT = NULL, @CreditRisk INT = NULL

AS

BEGIN
	
    SET NOCOUNT ON

    SELECT
        TrdExctnDtTF,
        CusipId,
        P,
        Pt,
        Ni,
		BionimDistEV,
        Af,
        CASE
            WHEN Pt <> P THEN ABS(Pt - P) - ABS(Af) 
            ELSE NULL
        END AS Hm,
        CASE
            WHEN Pt > P THEN ABS(Pt - P) - ABS(Af)
            ELSE NULL
        END AS Bhm,
        CASE
            WHEN Pt < P THEN ABS(Pt - P) - ABS(Af)
            ELSE NULL
        END AS Shm
    FROM (
        SELECT
            TrdExctnDtTF,
            CusipId,
            P,
            1.0 * CustomerBuys / (CustomerBuys + CustomerSells) AS Pt,
            CustomerBuys + CustomerSells AS Ni,
            1.0 * BionomialProcess / (CustomerBuys + CustomerSells) AS BionimDistEV,
            1.0 * BionomialProcess / (CustomerBuys + CustomerSells) - P AS AF
        FROM (
            SELECT
                A.TrdExctnDtTF,
                A.CusipId,
                B.P,
                SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) AS CustomerBuys,
                SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) AS CustomerSells,
                SUM(CASE WHEN RandomDraw < P THEN 1 ELSE 0 END) AS BionomialProcess
            FROM (
                SELECT
                    A.*,
                    RAND(CHECKSUM(NEWID())) AS RandomDraw,
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
                FROM
                    TraceFilteredWithRatings A
                INNER JOIN
                    BondReturnsTopBonds B ON A.CusipId = B.CusipId AND EOMONTH(A.TrdExctnDt) = B.TrdExctnDtEOM
                WHERE
                    CntraMpId = 'C'
                    AND RatingNum > CASE WHEN @CreditRisk = 1 THEN 10 ELSE 0 END -- HY
                    AND RatingNum < CASE WHEN @CreditRisk = 2 THEN 11 ELSE 25 END -- IG
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
                            A.*,
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
                        FROM
                            TraceFilteredWithRatings A
                        INNER JOIN
                            BondReturnsTopBonds B ON A.CusipId = B.CusipId AND EOMONTH(A.TrdExctnDt) = B.TrdExctnDtEOM
                        WHERE
                            CntraMpId = 'C'
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
            WHERE
                A.Investor = @Investor
            GROUP BY
                A.TrdExctnDtTF,
                A.CusipId,
				B.P
        ) A
    ) B

END
