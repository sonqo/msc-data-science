SELECT
	A.Date,
	A.BondsRm,
	A.BondsAbsoluteRm,
	A.BondsSquaredRm,
	A.BondsCsad,
	B.StocksRm,
	B.StocksAbsoluteRm,
	B.StocksSquaredRm,
	B.StocksCsad
FROM (
	SELECT
		Date,
		Rm AS BondsRm,
		ABS(Rm) AS BondsAbsoluteRm,
		POWER(Rm, 2) AS BondsSquaredRm,
		Sum / Count AS BondsCsad
	FROM (
		SELECT
			Date,
			Rm,
			ABS(SUM(RetEom) - Rm) AS Sum,
			COUNT(DISTINCT Cusip) AS Count
		FROM (
			SELECT
				A.TrdExctnDtEOM AS Date,
				A.CusipId AS Cusip,
				A.R AS RetEom,
				C.Rm
			FROM
				BondReturnsCustomer A
			INNER JOIN (
				SELECT DISTINCT
					A.CusipId,
					A.TrdExctnDtEOM,
					B.PermNo
				FROM
					BondReturnsTopBonds A
				INNER JOIN
					CrspcBondLink B ON A.CusipId = B.Cusip
				INNER JOIN
					CrspcSecuritiesDaily C ON B.PermNo = C.LPermNo
			) B ON A.CusipId = B.CusipId AND A.TrdExctnDtEOM = B.TrdExctnDtEOM
			INNER JOIN (
				SELECT
					TrdExctnDtEOM AS Date,
					SUM(R * TD_volume) / SUM(TD_volume) AS Rm
				FROM
					BondReturnsCustomer
				GROUP BY
					TrdExctnDtEOM
			) C ON A.TrdExctnDtEOM = C.Date
			WHERE
				R IS NOT NULL
		) A
		GROUP BY
			Date,
			Rm
	) B
	WHERE
		Rm IS NOT NULL
) A
INNER JOIN (
	SELECT
		Datadate,
		Rm AS StocksRm,
		ABS(Rm) AS StocksAbsoluteRm,
		POWER(Rm, 2) AS StocksSquaredRm, 
		Sum / Count AS StocksCsad
	FROM (
		SELECT
			DataDate,
			Rm,
			ABS(SUM(MonthlyReturns) - Rm) AS Sum,
			COUNT(DISTINCT LPermNo) AS Count
		FROM (
			SELECT
				A.LPermNo,
				EOMONTH(A.DataDate) AS DataDate,
				(PrcCd / LAG(A.PrcCd)  OVER (PARTITION BY A.LPermNo ORDER BY EOMONTH(A.DataDate))) - 1 AS MonthlyReturns,
				Rm
			FROM
				CrspcSecuritiesDaily A
			INNER JOIN (
				SELECT
					LPermNo,
					MAX(DataDate) AS MaxDate
				FROM
					CrspcSecuritiesDaily A
				INNER JOIN (
					SELECT DISTINCT
						A.CusipId,
						A.TrdExctnDtEOM,
						B.PermNo
					FROM
						BondReturnsTopBonds A
					INNER JOIN
						CrspcBondLink B ON A.CusipId = B.Cusip
					INNER JOIN
						CrspcSecuritiesDaily C ON B.PermNo = C.LPermNo
				) B ON A.LPermNo = B.PermNo
				GROUP BY
					LPermNo,
					EOMONTH(DataDate)
			) B ON A.LPermNo = B.LPermNo AND A.DataDate = B.MaxDate
			INNER JOIN
				MarketFactors C ON EOMONTH(A.DataDate) = C.Date
		) A
		GROUP BY
			DataDate,
			Rm
	) A
) B ON A.Date = B.Datadate
ORDER BY
	A.Date

-- DISTINCT ISSUERS AND PERMCOs
SELECT
	COUNT(DISTINCT A.IssuerId) AS DistinctIssuers,
	COUNT(DISTINCT C.LPermNo) AS DistinctPermCos
FROM
	BondReturnsTopBonds A
INNER JOIN
	CrspcBondLink B ON A.CusipId = B.Cusip
INNER JOIN
	CrspcSecuritiesDaily C ON B.PermNo = C.LPermNo
