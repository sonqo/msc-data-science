ALTER TABLE
	[dbo].[BondIssuers]
ADD
	Private INT

UPDATE
	[dbo].[BondIssuers]
SET
	Private = A.Private
FROM (
	SELECT
		A.IssuerId,
		CASE WHEN B.TraceStartDate IS NULL THEN 1 ELSE 0 END AS Private
	FROM (
		SELECT
			CusipId,
			IssuerId
		FROM
			[dbo].[TraceFilteredWithRatings]
		GROUP BY
			CusipId,
			IssuerId
	) A
	LEFT JOIN 
		[dbo].[CrspBondLink] B ON A.CusipId = B.Cusip
) A
INNER JOIN
	[dbo].[BondIssuers] B ON A.IssuerId = B.IssuerId
