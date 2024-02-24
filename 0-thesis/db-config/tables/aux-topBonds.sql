DROP TABLE IF EXISTS [dbo].[TopBonds-institutional]

SELECT
	*,
	ROW_NUMBER() OVER (PARTITION BY CusipId, IssuerId, DateRanking ORDER BY TrdExctnDtEOM) as ConsecutiveMonths
INTO
	[dbo].[TopBonds-institutional]
FROM (
	SELECT
		*,
		DATEPART(YEAR, TrdExctnDtEOM) * 12 + DATEPART(MONTH, TrdExctnDtEOM) - ROW_NUMBER() OVER (PARTITION BY CusipId, IssuerId ORDER BY TrdExctnDtEOM) AS DateRanking
	FROM (
		SELECT
			CusipId,
			IssuerId,
			TrdExctnDtEOM,
			RatingClass
		FROM (
			SELECT
				*,
				DENSE_RANK() OVER (PARTITION BY IssuerId, TrdExctnDtEOM ORDER BY Volume DESC) AS VolumeRanking
			FROM (
				SELECT
					IssuerId,
					CusipId,
					EOMONTH(TrdExctnDt) AS TrdExctnDtEOM,
					SUM(EntrdVolQt) AS Volume,
					CASE
						WHEN MAX(RatingNum) <= 10 THEN 'IG'
						WHEN MAX(RatingNum) >= 11 THEN 'HY'
						ELSE NULL
					END AS RatingClass
				FROM
					[dbo].[Trace-filteredWithRatings]
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
	) C
) D

CREATE CLUSTERED INDEX [IX_TopBonds] ON 
	[dbo].[TopBonds] (
			[CusipId], [TrdExctnDtEOM]
	);