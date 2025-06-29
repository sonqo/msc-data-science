--- Total sample per Size Categories frequencies
SELECT
    AVG(TradeValuePerBond) AS TradeValuePerBond,
    SUM(SmallTradeVolume) AS SmallTradeVolume,
    SUM(MediumTradeVolume) AS MediumTradeVolume,
    SUM(InstTradeVolume) AS InstTradeVolume
FROM (
    SELECT
        CusipId,
        AVG(EntrdVolQt * RptdPr * PrincipalAmount / 100 / 1000) AS TradeValuePerBond,
        SUM(CASE WHEN EntrdVolQt <= 100000 THEN EntrdVolQt * RptdPr * PrincipalAmount / 100 / 1000 ELSE 0 END) AS SmallTradeVolume,
        SUM(CASE WHEN EntrdVolQt > 100000 AND EntrdVolQt < 500000 THEN EntrdVolQt * RptdPr * PrincipalAmount / 100 / 1000 ELSE 0 END) AS MediumTradeVolume,
        SUM(CASE WHEN EntrdVolQt >= 500000 THEN EntrdVolQt * RptdPr * PrincipalAmount / 100 / 1000 ELSE 0 END) AS InstTradeVolume
    FROM
        wrds_Trace_FilteredWithRatings
    WHERE
        CntraMpId = 'C'
        AND TrdExctnDt >= '2002-01-01' 
        AND TrdExctnDt < '2024-01-01'
    GROUP BY
        CusipId
) A

--- Total sample per year
SELECT
    TrdExctnYr,
    AVG(TradeValuePerBond) AS TradeValuePerBondPerYear,
    SUM(SmallTradeVolume) AS SmallTradeVolumePerYear,
    SUM(MediumTradeVolume) AS MediumTradeVolumePerYear,
    SUM(InstTradeVolume) AS InstTradeVolumePerYear
FROM (
    SELECT
        TrdExctnMn,
        TrdExctnYr,
        CusipId,
        AVG(EntrdVolQt * RptdPr * PrincipalAmount / 100 / 1000) AS TradeValuePerBond,
        SUM(CASE WHEN EntrdVolQt <= 100000 THEN EntrdVolQt * RptdPr * PrincipalAmount / 100 / 1000 ELSE 0 END) AS SmallTradeVolume,
        SUM(CASE WHEN EntrdVolQt > 100000 AND EntrdVolQt < 500000 THEN EntrdVolQt * RptdPr * PrincipalAmount / 100 / 1000 ELSE 0 END) AS MediumTradeVolume,
        SUM(CASE WHEN EntrdVolQt >= 500000 THEN EntrdVolQt * RptdPr * PrincipalAmount / 100 / 1000 ELSE 0 END) AS InstTradeVolume
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
    AVG(TradeValuePerBond) AS TradeValuePerBondPerSizeCategoryPerYear
FROM (
    SELECT
        TrdExctnMn,
        TrdExctnYr,
        CusipId,
        SizeCategory,
        AVG(TradeValue) AS TradeValuePerBond
    FROM (
        SELECT
            TrdExctnMn,
            TrdExctnYr,
            CusipId,
            CASE
                WHEN EntrdVolQt <= 100000 THEN 'Small'
                WHEN EntrdVolQt < 500000 THEN 'Medium'
                ELSE 'Inst'
            END AS SizeCategory,
            EntrdVolQt * RptdPr * PrincipalAmount / 100 / 1000 AS TradeValue
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
    AVG(TradeValuePerBond) AS TradeValuePerBondPerSizeCategory
FROM (
    SELECT
        TrdExctnMn,
        TrdExctnYr,
        CusipId,
        SizeCategory,
        AVG(TradeValue) AS TradeValuePerBond
    FROM (
        SELECT
            TrdExctnMn,
            TrdExctnYr,
            CusipId,
            CASE
                WHEN EntrdVolQt <= 100000 THEN 'Small'
                WHEN EntrdVolQt < 500000 THEN 'Medium'
                ELSE 'Inst'
            END AS SizeCategory,
            EntrdVolQt * RptdPr * PrincipalAmount / 100 / 1000 AS TradeValue
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
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY TradeValuePerBond) OVER (PARTITION BY SizeCategory) AS P25,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY TradeValuePerBond) OVER (PARTITION BY SizeCategory) AS P50,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY TradeValuePerBond) OVER (PARTITION BY SizeCategory) AS P75,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY TradeValuePerBond) OVER (PARTITION BY SizeCategory) AS P90,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY TradeValuePerBond) OVER (PARTITION BY SizeCategory) AS P99
FROM (
    SELECT
        TrdExctnMn,
        TrdExctnYr,
        CusipId,
        SizeCategory,
        AVG(TradeValue) AS TradeValuePerBond
    FROM (
        SELECT
            TrdExctnMn,
            TrdExctnYr,
            CusipId,
            CASE
                WHEN EntrdVolQt <= 100000 THEN 'Small'
                WHEN EntrdVolQt < 500000 THEN 'Medium'
                ELSE 'Inst'
            END AS SizeCategory,
            EntrdVolQt * RptdPr * PrincipalAmount / 100 / 1000 AS TradeValue
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
