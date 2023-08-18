SELECT
    IndustryCode,
    DistinctCusips,
    DistinctIssuers
FROM (
    SELECT 
        IndustryCode,
        COUNT(DISTINCT CusipId) AS DistinctCusips,
        COUNT(DISTINCT IssuerID) AS DistinctIssuers
    FROM
        Trace_withRatings_filtered
    WHERE
        TrdExctnDt >= '2002-01-1' AND TrdExctnDt < '2023-01-01'
		AND RatingNum <> 0
    GROUP BY
        IndustryCode 
) A
ORDER BY
    IndustryCode
