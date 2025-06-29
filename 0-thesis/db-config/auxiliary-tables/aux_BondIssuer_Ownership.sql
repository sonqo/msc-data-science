ALTER TABLE
	[dbo].[fisd_BondIssuer]
ADD
	Private INT

UPDATE
	[dbo].[fisd_BondIssuer]
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
		[dbo].[crsp_BondLink] B ON A.CusipId = B.Cusip
) A
INNER JOIN
	[dbo].[fisd_BondIssuer] B ON A.IssuerId = B.IssuerId

UPDATE
	[dbo].[fisd_BondIssuer]
SET
	Private = 0
WHERE
	Private IS NULL
