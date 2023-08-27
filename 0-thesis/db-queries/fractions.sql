SELECT
    TrdExctnDt,
    CusipId,
    SUM(EntrdVolQt) / MAX(Institunional) AS Institunional,
    SUM(EntrdVolQt) / MAX(Retail) AS Retail
FROM (
    SELECT
        TrdExctnDt,
        CusipId,
        EntrdVolQt,
        SUM(CASE WHEN IntRet = 'Int' THEN EntrdVolQt ELSE 0 END) OVER (PARTITION BY TrdExctnDt) AS Institunional,
        SUM(CASE WHEN IntRet = 'Ret' THEN EntrdVolQt ELSE 0 END) OVER (PARTITION BY TrdExctnDt) AS Retail
    FROM (    
        SELECT
            CusipId,
            TrdExctnDt,
            EntrdVolQt,
            CASE
                WHEN EntrdVolQt >= 100000 THEN 'Int'
                ELSE 'Ret'
            END AS IntRet
        FROM 
            Trace_filtered_withRatings
    ) A
) B
GROUP BY
    TrdExctnDt,
    CusipId
