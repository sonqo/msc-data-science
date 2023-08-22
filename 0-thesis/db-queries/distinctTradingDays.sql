SELECT
    COUNT(DISTINCT TrdExctnDt)
FROM
    Trace_filtered_withRatings
WHERE
    TrdExctnDt >= '2002-01-1' AND TrdExctnDt < '2023-01-01'
