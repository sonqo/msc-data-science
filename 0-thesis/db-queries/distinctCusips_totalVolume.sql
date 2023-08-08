SELECT 
	TrdExctnDt,
	COUNT(DISTINCT CusipId) AS DistinctCusips,
	SUM(EntrdVolQt) AS TotalVolume
FROM
	TraceBond_filtered
WHERE
	TrdExctnDt >= '2002-01-1' AND TrdExctnDt < '2023-01-01'
GROUP BY
	TrdExctnDt
ORDER BY
	TrdExctnDt
