SELECT
    TrdExctnDt,
    CusipId,
    EntrdVolQt,
    IntRet,
    ( Fraction - AVG(Fraction) OVER (PARTITION BY TrdExctnDt) ) / STDEV(Fraction) OVER (PARTITION BY TrdExctnDt) AS StdFraction
FROM (
    SELECT
        TrdExctnDt,
        CusipId,
        EntrdVolQt,
        CASE
            WHEN EntrdVolQt < 10000 THEN 'Ret'
            ELSE 'Int'
        END AS IntRet,
        SUM(CASE WHEN RptSideCd = 'S' THEN EntrdVolQt ELSE 0 END) OVER (PARTITION BY TrdExctnDt, CusipId) / SUM(EntrdVolQt) OVER (PARTITION BY TrdExctnDt, CusipId) AS Fraction
    FROM  
        Trace_filtered_withRatings A
) B
