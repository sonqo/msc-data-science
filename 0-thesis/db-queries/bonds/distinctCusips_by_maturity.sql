SELECT
	MaturityBand,
	COUNT(DISTINCT CusipId) AS DistinctCusips
FROM (
	SELECT
		CASE 
			WHEN ABS(DATEDIFF(DAY, Maturity, OfferingDate)) * 1.0 / 360 < 5 THEN 1
			WHEN ABS(DATEDIFF(DAY, Maturity, OfferingDate)) * 1.0 / 360 < 15 THEN 2
			ELSE 3
		END AS MaturityBand,
		CusipId
	FROM
		TraceBond_filtered
	WHERE
		TrdExctnDt >= '2002-01-1' AND TrdExctnDt < '2023-01-01'
) A
GROUP BY
	MaturityBand
ORDER BY
	MaturityBand
