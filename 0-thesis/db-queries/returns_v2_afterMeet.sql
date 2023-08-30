SELECT
	A.CusipId,
	EOMONTH(A.TrdExctnDt) AS TrdExctnDt,
	A.RptdPr AS StartPrice,
	B.RptdPr AS EndPrice,
	A.Coupon,
	A.PrincipalAmt,
	A.InterestFrequency,
	A.FirstInterestDate
FROM (
	SELECT
		B.CusipId,
		B.TrdExctnDt,
		CONCAT(MONTH(B.TrdExctnDt), '-', YEAR(B.TrdExctnDt)) AS MontYearId,
		AVG(B.RptdPr) AS RptdPr,
		MAX(B.Coupon) AS Coupon,
		MAX(B.PrincipalAmt) AS PrincipalAmt,
		CASE
			WHEN MAX(B.InterestFrequency) IS NOT NULL THEN MAX(B.InterestFrequency)
			ELSE 2
		END AS InterestFrequency,
		CASE
			WHEN MAX(B.FirstInterestDate) IS NOT NULL THEN MAX(B.FirstInterestDate)
			ELSE MAX(B.OfferingDate)
		END AS FirstInterestDate
	FROM (
		SELECT
			CusipId,
			MIN(TrdExctnDt) AS TrdExctnDt
		FROM
			Trace_filtered_withRatings
		WHERE
			RatingNum <> 0
			AND EntrdVolQt = 100000
			AND TrdExctnDt >= DATEFROMPARTS(YEAR(TrdExctnDt), MONTH(TrdExctnDt), 1) AND TrdExctnDt <= DATEFROMPARTS(YEAR(TrdExctnDt), MONTH(TrdExctnDt), 5)
		GROUP BY
			CusipId,
			MONTH(TrdExctnDt),
			YEAR(TrdExctnDt)
	) A
	INNER JOIN 
		Trace_filtered_withRatings B ON A.CusipId = B.CusipId AND A.TrdExctnDt = B.TrdExctnDt
	GROUP BY
		B.CusipId,
		B.TrdExctnDt
) A
INNER JOIN (
	SELECT
		B.CusipId,
		B.TrdExctnDt,
		CONCAT(MONTH(B.TrdExctnDt), '-', YEAR(B.TrdExctnDt)) AS MontYearId,
		AVG(B.RptdPr) AS RptdPr
	FROM (
		SELECT
			CusipId,
			MIN(TrdExctnDt) AS TrdExctnDt
		FROM
			Trace_filtered_withRatings
		WHERE
			RatingNum <> 0
			AND EntrdVolQt = 100000
			AND TrdExctnDt <= EOMONTH(TrdExctnDt) AND TrdExctnDt >= DATEADD(DAY, -5, EOMONTH(TrdExctnDt))
		GROUP BY
			CusipId,
			MONTH(TrdExctnDt),
			YEAR(TrdExctnDt)
	) A
	INNER JOIN 
		Trace_filtered_withRatings B ON A.CusipId = B.CusipId AND A.TrdExctnDt = B.TrdExctnDt
	GROUP BY
		B.CusipId,
		B.TrdExctnDt
) B ON A.CusipId = B.CusipId AND A.MontYearId = B.MontYearId
ORDER BY
	A.CusipId,
	EOMONTH(A.TrdExctnDt)
