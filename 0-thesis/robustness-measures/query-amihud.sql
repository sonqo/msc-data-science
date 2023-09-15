SELECT DISTINCT
    TrdExctnDt,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Amihud) OVER (PARTITION BY TrdExctnDt) AS MedianAmihud
FROM (
    SELECT
        CusipId,
        TrdExctnDt,
        ABS(RptdPr - LagRptdPr) / Volume AS Amihud
    FROM (    
        SELECT
            A.CusipId,
            A.TrdExctnDt,
            A.RptdPr,
            LAG(A.RptdPr) OVER (PARTITION BY A.CusipId ORDER BY A.TrdExctnDt) AS LagRptdPr,
            B.Volume
        FROM
            Trace_filteredWithRatings A
        INNER JOIN (    
            SELECT
                CusipId,
                TrdExctnDt,
                MAX(TrdExctnTm) AS CloseTime,
                SUM(EntrdVolQt) AS Volume
            FROM
                Trace_filteredWithRatings
            GROUP BY
                CusipId,
                TrdExctnDt
        ) B ON A.CusipId = B.CusipId AND A.TrdExctnDt = B.TrdExctnDt AND A.TrdExctnTm = B.CloseTime
    ) C
) D
