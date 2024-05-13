SELECT
	Datadate,
	MktRf, Smb, Hml, Rmw, Cma, Rf, Rm,
	ABS(Rm) AS AbsoluteRm,
	POWER(Rm, 2) AS SquaredRm, 
	Sum / Count AS Csad
FROM (
	SELECT
		DataDate,
		MktRf, Smb, Hml, Rmw, Cma, Rf, Rm,
		ABS(SUM(MonthlyReturns) - Rm) AS Sum,
		COUNT(DISTINCT LPermNo) AS Count
	FROM (
		SELECT
			A.LPermNo,
			EOMONTH(A.DataDate) AS DataDate,
			(PrcCd / LAG(A.PrcCd)  OVER (PARTITION BY A.LPermNo ORDER BY EOMONTH(A.DataDate))) - 1 AS MonthlyReturns,
			C.*
		FROM
			CrspSecuritiesDaily A
		INNER JOIN (
			SELECT
				LPermNo,
				MAX(DataDate) AS MaxDate
			FROM
				CrspSecuritiesDaily A
			GROUP BY
				LPermNo,
				EOMONTH(DataDate)
		) B ON A.LPermNo = B.LPermNo AND A.DataDate = B.MaxDate
		INNER JOIN
			MarketFactors C ON EOMONTH(A.DataDate) = C.Date
	) A
	GROUP BY
		DataDate,
		MktRf, Smb, Hml, Rmw, Cma, Rf, Rm
) A
ORDER BY
	DataDate

-- DISTINCT PERMNOs IN DATASET
SELECT
	COUNT(DISTINCT LPermNo)
FROM
	CrspSecuritiesDaily A

-- DISTINCT PERMNOs BY EXCHANGE
SELECT
	Exchange,
	COUNT(DISTINCT LPermNo)
FROM
	CrspSecuritiesDaily A
GROUP BY
	Exchange

-- DISTINCT PERMNOs BY INDUSTRY
SELECT
	Industry,
	COUNT(DISTINCT LPermNo)
FROM
	CrspSecuritiesDaily A
GROUP BY
	Industry
