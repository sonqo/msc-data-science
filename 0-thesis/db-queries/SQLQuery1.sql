SELECT 
    Date,
    RetailThreshold,
    COUNT(DISTINCT Cusip) AS DistinctCusips,
    SUM(TDvolume) AS TotalVolume
FROM (
    SELECT
        Date,
        Cusip,
        TDvolume,
        CASE WHEN TDvolume < 100000 THEN 'R' ELSE 'IN' END AS RetailThreshold
    FROM
        BondReturns
    WHERE
        Date >= '2002-01-1' AND Date < '2023-01-01'
		AND RatingNum <> 0
) A
GROUP BY
	Date,
	RetailThreshold
ORDER BY
	Date, 
	RetailThreshold
