--- Total sample per year
SELECT
    TrdExctnYr,
    COUNT(DISTINCT CusipId) AS DistCusipsPerYear
FROM
    wrds_Trace_FilteredWithRatings
WHERE
    CntraMpId = 'C'
    AND TrdExctnDt >= '2002-01-01' 
    AND TrdExctnDt < '2024-01-01'
GROUP BY
    TrdExctnYr
ORDER BY 
    TrdExctnYr

--- Total sample
SELECT
    COUNT(DISTINCT CusipId) AS DistCusips
FROM
    wrds_Trace_FilteredWithRatings
WHERE
    CntraMpId = 'C'
    AND TrdExctnDt >= '2002-01-01' 
    AND TrdExctnDt < '2024-01-01'

--- Size Categories per year
SELECT
    TrdExctnYr,
    SizeCategory,
    COUNT(DISTINCT CusipId) AS DistCusipsPerSizeCategoryPerYear
FROM (
    SELECT
        TrdExctnYr,
        CusipId,
        CASE
            WHEN EntrdVolQt <= 100000 THEN 'Small'
            WHEN EntrdVolQt < 500000 THEN 'Medium'
            ELSE 'Inst'
        END AS SizeCategory
    FROM
        wrds_Trace_FilteredWithRatings
    WHERE
        CntraMpId = 'C'
        AND TrdExctnDt >= '2002-01-01' 
        AND TrdExctnDt < '2024-01-01'
) A
GROUP BY
    TrdExctnYr,
    SizeCategory
ORDER BY 
    TrdExctnYr,
    SizeCategory

--- Size Categories per sample
SELECT
    SizeCategory,
    COUNT(DISTINCT CusipId) AS DistCusipsPerSizeCategory
FROM (
    SELECT
        CusipId,
        CASE
            WHEN EntrdVolQt <= 100000 THEN 'Small'
            WHEN EntrdVolQt < 500000 THEN 'Medium'
            ELSE 'Inst'
        END AS SizeCategory
    FROM
        wrds_Trace_FilteredWithRatings
    WHERE
        CntraMpId = 'C'
        AND TrdExctnDt >= '2002-01-01' 
        AND TrdExctnDt < '2024-01-01'
) A
GROUP BY
    SizeCategory
ORDER BY 
    SizeCategory
