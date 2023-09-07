-- TOP BONDS
SELECT
	B.*
FROM
	BondReturns_fromTrace_last5DaysMonth B
LEFT JOIN (
	SELECT
		*
	FROM (
		SELECT
			*,
			DENSE_RANK() OVER (PARTITION BY IssuerId, TrdExctnDtEOM ORDER BY Volume DESC) AS VolumeRanking
		FROM (
			SELECT
				IssuerId,
				CusipId,
				MAX(TrdExctnDt) AS TrdExctnDt,
				EOMONTH(TrdExctnDt) AS TrdExctnDtEOM,
				SUM(EntrdVolQt) AS Volume
			FROM
				Trace_filtered_withRatings A
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
) A ON A.CusipId = B.CusipId AND A.TrdExctnDtEOM = B.TrdExctnDtEOM
ORDER BY
	B.CusipId,
	B.TrdExctnDtEOM

-- NON-TOP BONDS
SELECT
	B.*
FROM 
	BondReturns_fromTrace_last5DaysMonth B
LEFT JOIN (
	SELECT
		IssuerId,
		CusipId,
		TrdExctnDt,
		TrdExctnDtEOM,
		Volume
	FROM (
		SELECT
			*,
			DENSE_RANK() OVER (PARTITION BY IssuerId, TrdExctnDtEOM ORDER BY Volume DESC) AS VolumeRanking
		FROM (
			SELECT
				IssuerId,
				CusipId,
				MAX(TrdExctnDt) AS TrdExctnDt,
				EOMONTH(TrdExctnDt) AS TrdExctnDtEOM,
				SUM(EntrdVolQt) AS Volume
			FROM
				Trace_filtered_withRatings A
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

	UNION ALL

	SELECT
		IssuerId,
		CusipId,
		MAX(TrdExctnDt) AS TrdExctnDt,
		EOMONTH(TrdExctnDt) AS TrdExctnDtEOM,
		SUM(EntrdVolQt) AS Volume
	FROM
		Trace_filtered_withRatings A
	WHERE
		RatingNum <> 0
		AND EntrdVolQt < 500000 -- institunional
		AND PrincipalAmt IS NOT NULL
	GROUP BY
		IssuerId,
		CusipId,
		EOMONTH(TrdExctnDt)
) A ON A.CusipId = B.CusipId AND A.TrdExctnDtEOM = B.TrdExctnDtEOM
ORDER BY
	B.CusipId,
	B.TrdExctnDtEOM