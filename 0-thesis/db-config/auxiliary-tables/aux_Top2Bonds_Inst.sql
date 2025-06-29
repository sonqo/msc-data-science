DROP TABLE IF EXISTS [dbo].[aux_Top2Bonds_Inst]

SELECT
	*,
	ROW_NUMBER() OVER (PARTITION BY CusipId, IssuerId, DateRanking ORDER BY TrdExctnDtEOM) as ConsecutiveMonths
INTO
	[dbo].[aux_Top2Bonds_Inst]
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
					[dbo].[wrds_Trace_FilteredWithRatings]
				WHERE
					RatingNum <> 0
					AND EntrdVolQt >= 500000 -- institunional
					AND PrincipalAmount IS NOT NULL
					AND TrdExctnDt <= EOMONTH(TrdExctnDt) AND TrdExctnDt > DATEADD(DAY, -5, EOMONTH(TrdExctnDt))
				GROUP BY
					IssuerId,
					CusipId,
					EOMONTH(TrdExctnDt)
			) A
		) B
		WHERE
			VolumeRanking <= 2
	) C
) D

CREATE CLUSTERED INDEX [IX_aux_Top2Bonds_Inst] ON 
	[dbo].[aux_Top2Bonds_Inst] (
		[TrdExctnDtEOM], [CusipId]
	)
