-- TOP BONDS
SELECT
	*,
	RetailVolume / (InstitutionalVolume + RetailVolume) AS VolumeFraction,
	RetailTrades / (InstitutionalTrades + RetailTrades) AS TradesFraction
FROM (
	SELECT
		EOMONTH(A.TrdExctnDt) AS TrdExctnDtEOM,
		SUM(CASE WHEN EntrdVolQt >= 500000 THEN EntrdVolQt ELSE 0 END) AS InstitutionalVolume,
		SUM(CASE WHEN EntrdVolQt < 250000 THEN EntrdVolQt ELSE 0 END) AS RetailVolume,
		SUM(CASE WHEN EntrdVolQt >= 500000 THEN 1 ELSE 0 END) AS InstitutionalTrades,
		SUM(CASE WHEN EntrdVolQt < 250000 THEN 1 ELSE 0 END) AS RetailTrades,
		COUNT(DISTINCT (CASE WHEN EntrdVolQt >= 500000 THEN A.CusipId END)) AS InstitutionalCusips,
		COUNT(DISTINCT (CASE WHEN EntrdVolQt < 250000 THEN A.CusipId END)) AS RetailCusips
	FROM
		Trace_filteredWithRatings A
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
	) B ON A.CusipId = B.CusipId AND EOMONTH(A.TrdExctnDt) = B.TrdExctnDtEOM
	GROUP BY
		EOMONTH(A.TrdExctnDt)
) A
ORDER BY
	TrdExctnDtEOM

-- NON-TOP BONDS
SELECT
	*,
	RetailVolume / (InstitutionalVolume + RetailVolume) AS VolumeFraction,
	RetailTrades / (InstitutionalTrades + RetailTrades) AS TradesFraction
FROM (
	SELECT
		EOMONTH(A.TrdExctnDt) AS TrdExctnDtEOM,
		SUM(CASE WHEN EntrdVolQt >= 500000 THEN EntrdVolQt ELSE 0 END) AS InstitutionalVolume,
		SUM(CASE WHEN EntrdVolQt < 250000 THEN EntrdVolQt ELSE 0 END) AS RetailVolume,
		SUM(CASE WHEN EntrdVolQt >= 500000 THEN 1 ELSE 0 END) AS InstitutionalTrades,
		SUM(CASE WHEN EntrdVolQt < 250000 THEN 1 ELSE 0 END) AS RetailTrades,
		COUNT(DISTINCT (CASE WHEN EntrdVolQt >= 500000 THEN A.CusipId END)) AS InstitutionalCusips,
		COUNT(DISTINCT (CASE WHEN EntrdVolQt < 250000 THEN A.CusipId END)) AS RetailCusips
	FROM
		Trace_filteredWithRatings A
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
			VolumeRanking > 3

		UNION

		SELECT
			CusipId,
			TrdExctnDtEOM
		FROM (
			SELECT
				*,
				NULL AS VolumeRanking
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
					AND EntrdVolQt < 500000
					AND PrincipalAmt IS NOT NULL
					AND TrdExctnDt <= EOMONTH(TrdExctnDt) AND TrdExctnDt > DATEADD(DAY, -5, EOMONTH(TrdExctnDt))
				GROUP BY
					IssuerId,
					CusipId,
					EOMONTH(TrdExctnDt)
			) A
		) B

	) B ON A.CusipId = B.CusipId AND EOMONTH(A.TrdExctnDt) = B.TrdExctnDtEOM
	GROUP BY
		EOMONTH(A.TrdExctnDt)
) A
ORDER BY
	TrdExctnDtEOM
