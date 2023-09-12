SELECT
	TrdExctnDt,
	CusipId,
	1.0 * InstitunionalNominator / InstitunionalDenominator AS InstFraction,
	1.0 * RetailNominator / RetailDenominator AS RetFraction
INTO
	#TEMP_TABLE
FROM (
	SELECT
		TrdExctnDt,
		CusipId,
		SUM(CASE WHEN RptSideCd = 'S' AND EntrdVolQt >= 500000 THEN EntrdVolQt ELSE 0 END) AS InstitunionalNominator,
		SUM(CASE WHEN EntrdVolQt >= 500000 THEN EntrdVolQt ELSE 0 END) AS InstitunionalDenominator,
		SUM(CASE WHEN RptSideCd = 'S' AND EntrdVolQt < 250000 THEN EntrdVolQt ELSE 0 END) AS RetailNominator,
		SUM(CASE WHEN EntrdVolQt < 250000 THEN EntrdVolQt ELSE 0 END) AS RetailDenominator
	FROM
		Trace_filteredWithRatings
	WHERE
		EntrdVolQt <> 0
	GROUP BY
		TrdExctnDt,
		CusipId
) A
WHERE
	RetailDenominator <> 0	
	AND InstitunionalDenominator <> 0

SELECT
	A.TrdExctnDt,
	A.CusipId,
	CASE 
		WHEN StdInstFraction <> 0 THEN (InstFraction - AverageInstFraction) / StdInstFraction 
		ELSE InstFraction
	END AS InstitunionalFraction,
	CASE
		WHEN StdRetFraction <> 0 THEN (RetFraction - AverageRetFraction) / StdRetFraction
		ELSE RetFraction
	END AS RetailFraction
INTO
	#TEMP_FRACTIONS
FROM
	#TEMP_TABLE A
INNER JOIN (
	SELECT
		TrdExctnDt,
		AVG(InstFraction) AS AverageInstFraction,
		STDEV(InstFraction) AS StdInstFraction,
		AVG(RetFraction) AS AverageRetFraction,
		STDEV(RetFraction) AS StdRetFraction
	FROM
		#TEMP_TABLE
	GROUP BY
		TrdExctnDt
) B ON A.TrdExctnDt = B.TrdExctnDt

SELECT 
	A.TrdExctnDt,
	A.CusipId,
	A.InstitunionalFraction AS InstitunionalFraction,
	A.RetailFraction AS RetailFraction,
	B.InstitunionalFraction AS LagWeekInstitunionalFraction,
	B.RetailFraction AS LagWeekRetailFraction,
	C.InstitunionalFraction AS LagMonthInstitunionalFraction,
	C.RetailFraction AS LagMonthRetailFraction
FROM
	#TEMP_FRACTIONS A
INNER JOIN
	#TEMP_FRACTIONS B ON A.CusipId = B.CusipId AND DATEDIFF(DAY, B.TrdExctnDt, A.TrdExctnDt) = 7
INNER JOIN
	#TEMP_FRACTIONS C ON A.CusipId = C.CusipId AND DATEDIFF(DAY, C.TrdExctnDt, A.TrdExctnDt) = 30
