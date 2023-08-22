SELECT 
    TrdExctnDt,
    RptSideCd,
    SUM(EntrdVolQt) as TotalVolume
FROM
    Trace_filtered_withRatings
WHERE
    TrdExctnDt >= '2002-01-1' AND TrdExctnDt < '2023-01-01'
	AND RatingNum <> 0
GROUP BY
    TrdExctnDt, 
    RptSideCd
ORDER BY
    TrdExctnDt, 
    RptSideCd
