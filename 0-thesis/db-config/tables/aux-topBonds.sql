DROP TABLE IF EXISTS [dbo].[BondReturns_topBonds]

SELECT
	CusipId,
	TrdExctnDtEOM
INTO
	[dbo].[BondReturns_topBonds]
FROM (
	SELECT
		*,
		DENSE_RANK() OVER (PARTITION BY IssuerId, TrdExctnDtEOM ORDER BY Volume DESC) AS VolumeRanking
	FROM (
		SELECT
			IssuerId,
			CusipId,
			EOMONTH(TrdExctnDt) AS TrdExctnDtEOM,
			SUM(EntrdVolQt) AS Volume
		FROM
			Trace_filteredWithRatings
		WHERE
			RatingNum <> 0
			AND EntrdVolQt >= 500000 -- institunional
			AND PrincipalAmt IS NOT NULL
			AND TrdExctnDt <= EOMONTH(TrdExctnDt) AND TrdExctnDt > DATEADD(DAY, -5, EOMONTH(TrdExctnDt))
		GROUP BY
			IssuerId,
			CusipId,
			EOMONTH(TrdExctnDt)
	) A
) B
WHERE
	VolumeRanking <= 3
