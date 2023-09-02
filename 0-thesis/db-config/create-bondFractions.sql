DROP TABLE IF EXISTS [dbo].[BondFractions]

SELECT
    *,
    LAG(TrdExctnDt) OVER (PARTITION BY CusipId) AS LagTrdExctnDt
FROM (
    SELECT
        CusipId,
        TrdExctnDt,
        CASE
            WHEN STDEV(RetailFraction) OVER (PARTITION BY TrdExctnDt) = 0 THEN RetailFraction
            ELSE 
                (
                    RetailFraction - AVG(RetailFraction) OVER (PARTITION BY TrdExctnDt)
                ) / STDEV(RetailFraction) OVER (PARTITION BY TrdExctnDt)
        END AS StdRetailFraction,
        CASE
            WHEN STDEV(InstitunionalFraction) OVER (PARTITION BY TrdExctnDt) = 0 THEN InstitunionalFraction
            ELSE 
                (
                    InstitunionalFraction - AVG(InstitunionalFraction) OVER (PARTITION BY TrdExctnDt)
                ) / STDEV(InstitunionalFraction) OVER (PARTITION BY TrdExctnDt)
        END AS StdInstitunionalFraction
    FROM (
        SELECT 
            A.*,
            CusipDayRetailVolume / CusipDayTotalVolume AS RetailFraction,
            CusipDayInstitVolume / CusipDayTotalVolume AS InstitunionalFraction
        FROM (
            SELECT
                CusipId,
                TrdExctnDt, 
                SUM(CASE WHEN RptSideCd = 'S' AND IntRet = 'Ret' THEN EntrdVolQt ELSE 0 END) AS CusipDayRetailVolume,
                SUM(CASE WHEN RptSideCd = 'S' AND IntRet = 'Int' THEN EntrdVolQt ELSE 0 END) AS CusipDayInstitVolume
            FROM (
                SELECT
                    CusipId,
                    TrdExctnDt,
                    EntrdVolQt,
                    RptSideCd,
                    CASE
                        WHEN EntrdVolQt < 100000 THEN 'Ret'
                        ELSE 'Int'
                    END AS IntRet
                FROM  
                    Trace_filtered_withRatings A
                WHERE
                    RatingNum <> 0
            ) B
            GROUP BY
                TrdExctnDt, 
                CusipId
        ) A
        INNER JOIN (
            SELECT
                CusipId,
                TrdExctnDt, 
                SUM(CASE WHEN IntRet = 'Int' THEN EntrdVolQt ELSE 0 END) AS CusipDayTotalVolume
            FROM (
                SELECT
                    CusipId,
                    TrdExctnDt,
                    EntrdVolQt,
                    CASE
                        WHEN EntrdVolQt < 100000 THEN 'Ret'
                        ELSE 'Int'
                    END AS IntRet
                FROM  
                    Trace_filtered_withRatings A
                WHERE
                    RatingNum <> 0
            ) B
            GROUP BY
                TrdExctnDt, 
                CusipId
        ) B ON A.CusipId = B.CusipId AND A.TrdExctnDt = B.TrdExctnDt
        WHERE
            B.CusipDayTotalVolume <> 0
    ) A
) A
