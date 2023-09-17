SELECT
    TrdExctnDt,
    RatingNum,
    COUNT(DISTINCT CusipId) AS DistinctCusips
FROM 
    Trace_filteredWithRatings A
WHERE
    A.TrdExctnDt >= '2002-01-1' AND A.TrdExctnDt < '2023-01-01'
	AND RatingNum <> 0
GROUP BY
    TrdExctnDt,
    RatingNum
ORDER BY
    TrdExctnDt,
    RatingNum
