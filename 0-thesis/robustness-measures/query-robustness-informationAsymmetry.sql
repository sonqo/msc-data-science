-- DAILY
SELECT
	CusipId,
	TrdExctnDt,
	RptdPr,
	EntrdVolQt,
	LagRptdPr,
	RptdPr - LagRptdPr AS DPt,
	Qt,
	LagQt,
	Qt - LagQt AS DQt,
	QtVt,
	LagQtVt,
	QtVt - LagQtVt AS DQtVt
FROM (
	SELECT
		*,
		LAG(RptdPr) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) AS LagRptdPr,
		LAG(Qt) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) AS LagQt,
		LAG(QtVt) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) AS LagQtVt,
		DATEDIFF(DAY, LAG(TrdExctnDt) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt), TrdExctnDt) AS TimeId
	FROM (
		SELECT
			A.CusipId,
			A.TrdExctnDt,
			A.RptdPr,
			A.EntrdVolQt,
			A.RptSideCd,
			CASE WHEN RptSideCd = 'S' THEN 1 WHEN RptSideCd = 'B' THEN -1 END AS Qt,
			CASE WHEN RptSideCd = 'S' THEN 1 * EntrdVolQt WHEN RptSideCd = 'B' THEN -1 * EntrdVolQt END AS QtVt
		FROM
			TraceFilteredWithRatings A
		INNER JOIN (
			SELECT
				CusipId,
				TrdExctnDt,
				MIN(TrdExctnTm) AS MinTrdExctnTm
			FROM
				TraceFilteredWithRatings
			WHERE
				CntraMpId = 'C'
				AND EntrdVolQt <> CASE WHEN RatingNum <= 10 THEN 5000000 WHEN RatingNum >= 11 THEN 1000000 END
			GROUP BY
				CusipId,
				TrdExctnDt
		) B ON A.CusipId = B.CusipId AND A.TrdExctnDt = B.TrdExctnDt AND A.TrdExctnTm = B.MinTrdExctnTm
		WHERE
			CntraMpId = 'C'
			AND EntrdVolQt <> CASE WHEN RatingNum <= 10 THEN 5000000 WHEN RatingNum >= 11 THEN 1000000 END
	) A
) B
WHERE
	TimeId = 1
	AND	Qt - LagQt IS NOT NULL
	AND QtVt - LagQtVt IS NOT NULL
	AND RptdPr - LagRptdPr IS NOT NULL
ORDER BY
	TrdExctnDt,
	CusipId

-- WEEKLY
SELECT
	CusipId,
	DATEADD(DAY, 1 - DATEPART(WEEKDAY, TrdExctnDt) + 1, TrdExctnDt) AS TrdExctnDtSOW,
	RptdPr,
	EntrdVolQt,
	LagRptdPr,
	RptdPr - LagRptdPr AS DPt,
	Qt,
	LagQt,
	Qt - LagQt AS DQt,
	QtVt,
	LagQtVt,
	QtVt - LagQtVt AS DQtVt
FROM (
	SELECT
		*,
		LAG(RptdPr) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) AS LagRptdPr,
		LAG(Qt) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) AS LagQt,
		LAG(QtVt) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) AS LagQtVt,
		DATEDIFF(WEEK, LAG(TrdExctnDt) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt), TrdExctnDt) AS TimeId
	FROM (
		SELECT
			A.CusipId,
			A.TrdExctnDt,
			A.RptdPr,
			A.EntrdVolQt,
			A.RptSideCd,
			CASE WHEN RptSideCd = 'S' THEN 1 WHEN RptSideCd = 'B' THEN -1 END AS Qt,
			CASE WHEN RptSideCd = 'S' THEN 1 * EntrdVolQt WHEN RptSideCd = 'B' THEN -1 * EntrdVolQt END AS QtVt
		FROM
			TraceFilteredWithRatings A
		INNER JOIN (
			SELECT
				CusipId,
				TrdExctnDtSOW,
				MIN(TrdExctnDt) AS MinTrdExctnDt,
				MIN(TrdExctnTm) AS MinTrdExctnTm
			FROM (
				SELECT
					*,
					DATEADD(DAY, 1 - DATEPART(WEEKDAY, TrdExctnDt) + 1, TrdExctnDt) AS TrdExctnDtSOW
				FROM
					TraceFilteredWithRatings
			) A
			WHERE
				CntraMpId = 'C'
				AND EntrdVolQt <> CASE WHEN RatingNum <= 10 THEN 5000000 WHEN RatingNum >= 11 THEN 1000000 END
			GROUP BY
				CusipId,
				TrdExctnDtSOW
		) B ON A.CusipId = B.CusipId AND A.TrdExctnDt = B.MinTrdExctnDt AND A.TrdExctnTm = B.MinTrdExctnTm
		WHERE
			CntraMpId = 'C'
			AND EntrdVolQt <> CASE WHEN RatingNum <= 10 THEN 5000000 WHEN RatingNum >= 11 THEN 1000000 END
	) A
) B
WHERE
	TimeId = 1
	AND	Qt - LagQt IS NOT NULL
	AND QtVt - LagQtVt IS NOT NULL
	AND RptdPr - LagRptdPr IS NOT NULL
ORDER BY
	TrdExctnDt,
	CusipId

-- MONTHLY
SELECT
	CusipId,
	EOMONTH(TrdExctnDt) AS TrdExctnDtEOM,
	RptdPr,
	EntrdVolQt,
	LagRptdPr,
	RptdPr - LagRptdPr AS DPt,
	Qt,
	LagQt,
	Qt - LagQt AS DQt,
	QtVt,
	LagQtVt,
	QtVt - LagQtVt AS DQtVt
FROM (
	SELECT
		*,
		LAG(RptdPr) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) AS LagRptdPr,
		LAG(Qt) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) AS LagQt,
		LAG(QtVt) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) AS LagQtVt,
		DATEDIFF(MONTH, LAG(TrdExctnDt) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt), TrdExctnDt) AS TimeId
	FROM (
		SELECT
			A.CusipId,
			A.TrdExctnDt,
			A.RptdPr,
			A.EntrdVolQt,
			A.RptSideCd,
			CASE WHEN RptSideCd = 'S' THEN 1 WHEN RptSideCd = 'B' THEN -1 END AS Qt,
			CASE WHEN RptSideCd = 'S' THEN 1 * EntrdVolQt WHEN RptSideCd = 'B' THEN -1 * EntrdVolQt END AS QtVt
		FROM
			TraceFilteredWithRatings A
		INNER JOIN (
			SELECT
				CusipId,
				TrdExctnDtEOM,
				MIN(TrdExctnDt) AS MinTrdExctnDt,
				MIN(TrdExctnTm) AS MinTrdExctnTm
			FROM (
				SELECT
					*,
					EOMONTH(TrdExctnDt) AS TrdExctnDtEOM
				FROM
					TraceFilteredWithRatings
			) A
			WHERE
				CntraMpId = 'C'
				AND EntrdVolQt <> CASE WHEN RatingNum <= 10 THEN 5000000 WHEN RatingNum >= 11 THEN 1000000 END
			GROUP BY
				CusipId,
				TrdExctnDtEOM
		) B ON A.CusipId = B.CusipId AND A.TrdExctnDt = B.MinTrdExctnDt AND A.TrdExctnTm = B.MinTrdExctnTm
		WHERE
			CntraMpId = 'C'
			AND EntrdVolQt <> CASE WHEN RatingNum <= 10 THEN 5000000 WHEN RatingNum >= 11 THEN 1000000 END
	) A
) B
WHERE
	TimeId = 1
	AND	Qt - LagQt IS NOT NULL
	AND QtVt - LagQtVt IS NOT NULL
	AND RptdPr - LagRptdPr IS NOT NULL
ORDER BY
	TrdExctnDt,
	CusipId

-- YEARLY
SELECT
	CusipId,
	YEAR(TrdExctnDt) AS TrdExctnDtYr,
	RptdPr,
	EntrdVolQt,
	LagRptdPr,
	RptdPr - LagRptdPr AS DPt,
	Qt,
	LagQt,
	Qt - LagQt AS DQt,
	QtVt,
	LagQtVt,
	QtVt - LagQtVt AS DQtVt
FROM (
	SELECT
		*,
		LAG(RptdPr) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) AS LagRptdPr,
		LAG(Qt) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) AS LagQt,
		LAG(QtVt) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt) AS LagQtVt,
		DATEDIFF(YEAR, LAG(TrdExctnDt) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt), TrdExctnDt) AS TimeId
	FROM (
		SELECT
			A.CusipId,
			A.TrdExctnDt,
			A.RptdPr,
			A.EntrdVolQt,
			A.RptSideCd,
			CASE WHEN RptSideCd = 'S' THEN 1 WHEN RptSideCd = 'B' THEN -1 END AS Qt,
			CASE WHEN RptSideCd = 'S' THEN 1 * EntrdVolQt WHEN RptSideCd = 'B' THEN -1 * EntrdVolQt END AS QtVt
		FROM
			TraceFilteredWithRatings A
		INNER JOIN (
			SELECT
				CusipId,
				YEAR(TrdExctnDt) AS TrdExctnDtYr,
				MIN(TrdExctnDt) AS MinTrdExctnDt,
				MIN(TrdExctnTm) AS MinTrdExctnTm
			FROM 
				TraceFilteredWithRatings
			WHERE
				CntraMpId = 'C'
				AND EntrdVolQt <> CASE WHEN RatingNum <= 10 THEN 5000000 WHEN RatingNum >= 11 THEN 1000000 END
			GROUP BY
				CusipId,
				YEAR(TrdExctnDt)
		) B ON A.CusipId = B.CusipId AND A.TrdExctnDt = B.MinTrdExctnDt AND A.TrdExctnTm = B.MinTrdExctnTm
		WHERE
			CntraMpId = 'C'
			AND EntrdVolQt <> CASE WHEN RatingNum <= 10 THEN 5000000 WHEN RatingNum >= 11 THEN 1000000 END
	) A
) B
WHERE
	TimeId = 1
	AND	Qt - LagQt IS NOT NULL
	AND QtVt - LagQtVt IS NOT NULL
	AND RptdPr - LagRptdPr IS NOT NULL
ORDER BY
	TrdExctnDt,
	CusipId
