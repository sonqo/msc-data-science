SELECT 
    TrdExctnDt,
    COUNT(DISTINCT CusipId) AS DistinctCusips,
    SUM(EntrdVolQt) AS TotalVolume
FROM
    Trace_withRatings_filtered
WHERE
    TrdExctnDt >= '2002-01-1' AND TrdExctnDt < '2023-01-01'
	AND RatingNum <> 0
GROUP BY
    TrdExctnDt
ORDER BY
    TrdExctnDt
