-- TOP BONDS
SELECT
	A.*
FROM
	BondReturns_fromTrace_last5DaysMonth A
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
			GROUP BY
				IssuerId,
				CusipId,
				EOMONTH(TrdExctnDt)
		) A
	) B
	WHERE
		VolumeRanking <= 3
) B ON A.CusipId = B.CusipId AND A.TrdExctnDtEOM = B.TrdExctnDtEOM
ORDER BY
	B.CusipId,
	B.TrdExctnDtEOM

-- NON-TOP BONDS
SELECT
	B.*
FROM (
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
		AND EntrdVolQt < 500000 -- retail
		AND PrincipalAmt IS NOT NULL
	GROUP BY
		IssuerId,
		CusipId,
		EOMONTH(TrdExctnDt)
) A
INNER JOIN
	BondReturns_fromTrace_last5DaysMonth B ON A.CusipId = B.CusipId AND A.TrdExctnDtEOM = B.TrdExctnDtEOM
ORDER BY
	B.CusipId,
	B.TrdExctnDtEOM