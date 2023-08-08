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
		TraceBond_filtered
	WHERE
		TrdExctnDt >= '2002-01-1' AND TrdExctnDt < '2023-01-01'
	GROUP BY
		IndustryCode 
) A
ORDER BY
	IndustryCode
