SELECT
	*
FROM (
	SELECT
		EOMONTH(A.TrdExctnDt) AS TrdExctnDtEOM,
		SUM(CASE WHEN EntrdVolQt >= 500000 THEN EntrdVolQt ELSE 0 END) AS InstitunionalVolume,
		SUM(CASE WHEN EntrdVolQt < 250000 THEN EntrdVolQt ELSE 0 END) AS RetailVolume,
		COUNT(CASE WHEN EntrdVolQt >= 500000 THEN 1 ELSE 0 END) AS InstitunionalTrades,
		COUNT(CASE WHEN EntrdVolQt < 250000 THEN 1 ELSE 0 END) AS RetailTrades,
		COUNT(DISTINCT (CASE WHEN EntrdVolQt >= 500000 THEN A.CusipId END)) AS InstitutionalCusips,
		COUNT(DISTINCT (CASE WHEN EntrdVolQt < 250000 THEN A.CusipId END)) AS RetailCusips
	FROM
		Trace_filtered_withRatings A
	INNER JOIN (
		SELECT
			CusipId,
			TrdExctnDtEOM
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
				FROM (
					SELECT
						A.*
					FROM
						Trace_filtered_withRatings A
					INNER JOIN
						BondIssuers_privatePublic B ON A.IssuerId = B.IssuerId
				) A
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
	) B ON A.CusipId = B.CusipId AND EOMONTH(A.TrdExctnDt) = B.TrdExctnDtEOM
	GROUP BY
		EOMONTH(A.TrdExctnDt)
) A
ORDER BY
	TrdExctnDtEOM
