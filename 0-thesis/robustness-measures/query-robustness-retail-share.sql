-- TOP BONDS
SELECT
	*,
	1.0 * RetailVolume / (InstitutionalVolume + RetailVolume) AS VolumeFraction,
	1.0 * RetailTrades / (InstitutionalTrades + RetailTrades) AS TradesFraction
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
		TraceFilteredWithRatings A
	INNER JOIN
		TopBondsInstitutional B ON A.CusipId = B.CusipId AND EOMONTH(A.TrdExctnDt) = B.TrdExctnDtEOM
	WHERE
		A.RatingNum <> 0
	GROUP BY
		EOMONTH(A.TrdExctnDt)
) A
ORDER BY
	TrdExctnDtEOM

-- NON-TOP BONDS
SELECT
	*,
	1.0 * RetailVolume / (InstitutionalVolume + RetailVolume) AS VolumeFraction,
	1.0 * RetailTrades/ (InstitutionalTrades + RetailTrades) AS TradesFraction
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
		TraceFilteredWithRatings A
	LEFT JOIN 
		TopBondsInstitutional B ON A.CusipId = B.CusipId AND EOMONTH(A.TrdExctnDt) = B.TrdExctnDtEOM
	WHERE
		A.RatingNum <> 0
		AND B.CusipId IS NULL
	GROUP BY
		EOMONTH(A.TrdExctnDt)
) A
ORDER BY
	TrdExctnDtEOM
