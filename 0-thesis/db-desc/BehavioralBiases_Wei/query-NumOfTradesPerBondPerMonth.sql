--- Total sample per Size Categories frequencies
SELECT
    AVG(TradesPerBond) AS TradesPerBond,
    SUM(SmallTrades) AS SmallTrades,
    SUM(MediumTrades) AS MediumTrades,
    SUM(InstTrades) AS InstTrades
FROM (
    SELECT
        CusipId,
        COUNT(*) AS TradesPerBond,
        SUM(CASE WHEN EntrdVolQt <= 100000 THEN 1 ELSE 0 END) AS SmallTrades,
        SUM(CASE WHEN EntrdVolQt > 100000 AND EntrdVolQt < 500000 THEN 1 ELSE 0 END) AS MediumTrades,
        SUM(CASE WHEN EntrdVolQt >= 500000 THEN 1 ELSE 0 END) AS InstTrades
    FROM
        wrds_Trace_FilteredWithRatings
    WHERE
        CntraMpId = 'C'
        AND TrdExctnDt >= '2002-01-01' 
        AND TrdExctnDt < '2024-01-01'
    GROUP BY
        CusipId
) A

--- Total sample per year and Size Categories frequencies per year
SELECT
    TrdExctnYr,
    AVG(TradesPerBond) AS TradesPerBondPerYear,
    SUM(SmallTrades) AS SmallTradesPerYear,
    SUM(MediumTrades) AS MediumTradesPerYear,
    SUM(InstTrades) AS InstTradesPerYear
FROM (
    SELECT
        TrdExctnMn,
        TrdExctnYr,
        CusipId,
        COUNT(*) AS TradesPerBond,
        SUM(CASE WHEN EntrdVolQt <= 100000 THEN 1 ELSE 0 END) AS SmallTrades,
        SUM(CASE WHEN EntrdVolQt > 100000 AND EntrdVolQt < 500000 THEN 1 ELSE 0 END) AS MediumTrades,
        SUM(CASE WHEN EntrdVolQt >= 500000 THEN 1 ELSE 0 END) AS InstTrades
    FROM
        wrds_Trace_FilteredWithRatings
    WHERE
        CntraMpId = 'C'
        AND TrdExctnDt >= '2002-01-01' 
        AND TrdExctnDt < '2024-01-01'
    GROUP BY
        TrdExctnMn,
        TrdExctnYr,
        CusipId
) A
GROUP BY
    TrdExctnYr
ORDER BY
    TrdExctnYr

--- Size Categories per year
SELECT
    TrdExctnYr,
    SizeCategory,
    AVG(TradesPerBond) AS TradesPerBondPerSizeCategoryPerYear
FROM (
    SELECT
        TrdExctnMn,
        TrdExctnYr,
        CusipId,
        SizeCategory,
        COUNT(*) AS TradesPerBond
    FROM (
        SELECT
            TrdExctnMn,
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
        TrdExctnMn,
        TrdExctnYr,
        CusipId,
        SizeCategory
) A
GROUP BY
    TrdExctnYr,
    SizeCategory
ORDER BY
    TrdExctnYr,
    SizeCategory

--- Total sample per Size Categories
SELECT
    SizeCategory,
    AVG(TradesPerBond) AS TradesPerBondPerSizeCategory
FROM (
    SELECT
        TrdExctnMn,
        TrdExctnYr,
        CusipId,
        SizeCategory,
        COUNT(*) AS TradesPerBond
    FROM (
        SELECT
            TrdExctnMn,
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
        TrdExctnMn,
        TrdExctnYr,
        CusipId,
        SizeCategory
) A
GROUP BY
    SizeCategory
ORDER BY
    SizeCategory

--- Total sample per Size Categories percentiles
SELECT DISTINCT
    SizeCategory,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY TradesPerBond) OVER (PARTITION BY SizeCategory) AS P25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY TradesPerBond) OVER (PARTITION BY SizeCategory) AS P50,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY TradesPerBond) OVER (PARTITION BY SizeCategory) AS P75,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY TradesPerBond) OVER (PARTITION BY SizeCategory) AS P90,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY TradesPerBond) OVER (PARTITION BY SizeCategory) AS P99
FROM (
    SELECT
        TrdExctnMn,
        TrdExctnYr,
        CusipId,
        SizeCategory,
        COUNT(*) AS TradesPerBond
    FROM (
        SELECT
            TrdExctnMn,
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
        TrdExctnMn,
        TrdExctnYr,
        CusipId,
        SizeCategory
) A
