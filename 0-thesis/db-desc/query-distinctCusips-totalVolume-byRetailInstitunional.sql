SELECT 
    TrdExctnDt,
    RetailThreshold,
    COUNT(DISTINCT CusipId) AS DistinctCusips,
    SUM(EntrdVolQt) AS TotalVolume
FROM (
    SELECT
        TrdExctnDt,
        CASE WHEN EntrdVolQt < 250000 THEN 'R' WHEN EntrdVolQt >= 500000 THEN 'IN' END AS RetailThreshold,
        CusipId,
        EntrdVolQt
    FROM
        TraceFilteredWithRatings
    WHERE
        TrdExctnDt >= '2002-01-1' AND TrdExctnDt < '2023-01-01'
		AND RatingNum <> 0
) A
GROUP BY
    TrdExctnDt,
    RetailThreshold
ORDER BY
    TrdExctnDt, 
    RetailThreshold
