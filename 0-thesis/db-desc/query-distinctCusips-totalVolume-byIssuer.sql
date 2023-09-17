SELECT
    TrdExctnDt,
    IssuerId,
    COUNT(DISTINCT CusipId) AS DistinctCusips,
    SUM(EntrdVolQt) AS TotalVolume
FROM 
    Trace_filteredWithRatings
WHERE
    TrdExctnDt >= '{}-01-1' AND TrdExctnDt < '{}-01-01'
	AND RatingNum <> 0
GROUP BY
    TrdExctnDt, 
    IssuerId
ORDER BY
    TrdExctnDt, 
    IssuerId
