-- DAILY
SELECT DISTINCT
    TrdExctnDt,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Amihud) OVER (PARTITION BY TrdExctnDt) * 1000000 AS MedianAmihud
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
        WHERE
            B.Volume <> 0
    ) C
) D
ORDER BY
    TrdExctnDt

-- WEEKLY
SELECT DISTINCT
    TrdExctnDtSOW,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Amihud) OVER (PARTITION BY TrdExctnDtSOW) * 1000000 AS MedianAmihud
FROM (
    SELECT
        CusipId,
        TrdExctnDtSOW,
        ABS(RptdPr - LagRptdPr) / Volume AS Amihud
    FROM (    
        SELECT
            A.CusipId,
            A.TrdExctnDtSOW,
            A.RptdPr,
            LAG(A.RptdPr) OVER (PARTITION BY A.CusipId ORDER BY A.TrdExctnDtSOW) AS LagRptdPr,
            B.Volume
        FROM (
            SELECT
                *,
                DATEADD(DAY, 1 - DATEPART(WEEKDAY, TrdExctnDt) + 1, TrdExctnDt) AS TrdExctnDtSOW
            FROM 
                Trace_filteredWithRatings
        ) A
        INNER JOIN (    
            SELECT
                CusipId,
                DATEADD(DAY, 1 - DATEPART(WEEKDAY, TrdExctnDt) + 1, TrdExctnDt) AS TrdExctnDtSOW,
                MAX(TrdExctnTm) AS CloseTime,
                SUM(EntrdVolQt) AS Volume
            FROM
                Trace_filteredWithRatings
            GROUP BY
                CusipId,
                DATEADD(DAY, 1 - DATEPART(WEEKDAY, TrdExctnDt) + 1, TrdExctnDt)
        ) B ON A.CusipId = B.CusipId AND A.TrdExctnDtSOW = B.TrdExctnDtSOW AND A.TrdExctnTm = B.CloseTime
        WHERE
            B.Volume <> 0
    ) C
) D
ORDER BY
    TrdExctnDtSOW

-- MONTHLY
SELECT DISTINCT
    TrdExctnDtEOM,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Amihud) OVER (PARTITION BY TrdExctnDtEOM) * 1000000 AS MedianAmihud
FROM (
    SELECT
        CusipId,
        TrdExctnDtEOM,
        ABS(RptdPr - LagRptdPr) / Volume AS Amihud
    FROM (    
        SELECT
            A.CusipId,
            A.TrdExctnDtEOM,
            A.RptdPr,
            LAG(A.RptdPr) OVER (PARTITION BY A.CusipId ORDER BY A.TrdExctnDtEOM) AS LagRptdPr,
            B.Volume
        FROM (
            SELECT
                *,
                EOMONTH(TrdExctnDt) AS TrdExctnDtEOM
            FROM 
                Trace_filteredWithRatings
        ) A
        INNER JOIN (    
            SELECT
                CusipId,
                EOMONTH(TrdExctnDt) AS TrdExctnDtEOM,
                MAX(TrdExctnTm) AS CloseTime,
                SUM(EntrdVolQt) AS Volume
            FROM
                Trace_filteredWithRatings
            GROUP BY
                CusipId,
                EOMONTH(TrdExctnDt)
        ) B ON A.CusipId = B.CusipId AND A.TrdExctnDtEOM = B.TrdExctnDtEOM AND A.TrdExctnTm = B.CloseTime
        WHERE
            B.Volume <> 0
    ) C
) D
ORDER BY
    TrdExctnDtEOM

-- YEARLY
SELECT DISTINCT
    TrdExctnDtYr,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Amihud) OVER (PARTITION BY TrdExctnDtYr) * 1000000 AS MedianAmihud
FROM (
    SELECT
        CusipId,
        TrdExctnDtYr,
        ABS(RptdPr - LagRptdPr) / Volume AS Amihud
    FROM (    
        SELECT
            A.CusipId,
            A.TrdExctnDtYr,
            A.RptdPr,
            LAG(A.RptdPr) OVER (PARTITION BY A.CusipId ORDER BY A.TrdExctnDtYr) AS LagRptdPr,
            B.Volume
        FROM (
            SELECT
                *,
                YEAR(TrdExctnDt) AS TrdExctnDtYr
            FROM 
                Trace_filteredWithRatings
        ) A
        INNER JOIN (    
            SELECT
                CusipId,
                YEAR(TrdExctnDt) AS TrdExctnDtYr,
                MAX(TrdExctnTm) AS CloseTime,
                SUM(EntrdVolQt) AS Volume
            FROM
                Trace_filteredWithRatings
            GROUP BY
                CusipId,
                YEAR(TrdExctnDt)
        ) B ON A.CusipId = B.CusipId AND A.TrdExctnDtYr = B.TrdExctnDtYr AND A.TrdExctnTm = B.CloseTime
        WHERE
            B.Volume <> 0
    ) C
) D
ORDER BY
    TrdExctnDtYr
