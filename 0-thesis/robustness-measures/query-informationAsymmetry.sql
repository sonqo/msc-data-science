SELECT
    *,
    Qt * EntrdVolQt AS QtVt,
    LAG(RptdPr) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) AS LagRptPr
FROM (    
    SELECT
        TrdExctnDt,
        CusipId,
        RptdPr,
        EntrdVolQt,
        RptSideCd,
        CASE WHEN RptSideCd = 'B' THEN 1 WHEN RptSideCd = 'S' THEN -1 END AS Qt
    FROM
        Trace_filteredWithRatings
    WHERE
        CntraMpId = 'C'
        AND EntrdVolQt <> 1000000 AND EntrdVolQt <> 5000000
) A
WHERE
    DATEDIFF(DAY, LAG(TrdExctnDt) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt), TrdExctnDt) = 1