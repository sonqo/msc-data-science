SELECT 
	TrdExctnDt,
	RetailThreshold,
	COUNT(DISTINCT CusipId) AS DistinctCusips,
	SUM(EntrdVolQt) AS TotalVolume
FROM (
	SELECT
		TrdExctnDt,
		CASE WHEN EntrdVolQt < 100000 THEN 'R' ELSE 'IN' END AS RetailThreshold,
		CusipId,
		EntrdVolQt
	FROM
		TraceBond_filtered
	WHERE
		TrdExctnDt >= '2002-01-1' AND TrdExctnDt < '2023-01-01'
) A
GROUP BY
	TrdExctnDt,
	RetailThreshold
ORDER BY
	TrdExctnDt, 
	RetailThreshold
