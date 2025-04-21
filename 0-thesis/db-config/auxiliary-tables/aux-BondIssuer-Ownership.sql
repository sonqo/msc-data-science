ALTER TABLE
	[dbo].[BondIssuer]
ADD
	Private INT

UPDATE
	[dbo].[BondIssuer]
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
			[dbo].[wrds_Trace_FilteredWithRatings]
		GROUP BY
			CusipId,
			IssuerId
	) A
	LEFT JOIN 
		[dbo].[CrspBondLink] B ON A.CusipId = B.Cusip
) A
INNER JOIN
	[dbo].[BondIssuer] B ON A.IssuerId = B.IssuerId
