SELECT
    COUNT(DISTINCT TrdExctnDt)
FROM
    TraceBond_filtered
WHERE
	TrdExctnDt >= '2002-01-1' AND TrdExctnDt < '2023-01-01'