SELECT
    InvestmentGrade,
    COUNT(DISTINCT CusipId) AS DistinctCusips
FROM (
    SELECT
        CusipId,
        CASE
            WHEN RatingNum = 0 THEN 'NR'
            WHEN RatingNum < 11 THEN 'Y'
            ELSE 'N'
        END AS InvestmentGrade
    FROM 
        Trace_withRatings_filtered
    WHERE
        TrdExctnDt >= '2002-01-1' AND TrdExctnDt < '2023-01-01'
) A
GROUP BY
    InvestmentGrade
ORDER BY
    InvestmentGrade
