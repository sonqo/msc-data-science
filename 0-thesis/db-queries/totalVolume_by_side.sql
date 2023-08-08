SELECT 
	TrdExctnDt,
	RptSideCd,
	SUM(EntrdVolQt) as TotalVolume
FROM
	TraceBond_filtered
WHERE
	TrdExctnDt >= '2002-01-1' AND TrdExctnDt < '2023-01-01'
GROUP BY
	TrdExctnDt, 
	RptSideCd
ORDER BY
	TrdExctnDt, 
	RptSideCd
