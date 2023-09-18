CREATE PROCEDURE

	[dbo].[Herding_fractions]

AS

BEGIN
	
    SET NOCOUNT ON	
	
	SELECT
		TrdExctnDt,
		IssuerId,
		1.0 * InstitutionalNominator / InstitutionalDenominator AS InstFraction,
		1.0 * RetailNominator / RetailDenominator AS RetFraction,
		1.0 * UnknownNominator / UnknownDenominator AS UnFraction
	INTO
		#TEMP_TABLE
	FROM (
		SELECT
			TrdExctnDt,
			IssuerId,
			SUM(CASE WHEN RptSideCd = 'S' AND EntrdVolQt >= 500000 THEN EntrdVolQt ELSE 0 END) AS InstitutionalNominator,
			SUM(CASE WHEN EntrdVolQt >= 500000 THEN EntrdVolQt ELSE 0 END) AS InstitutionalDenominator,
			SUM(CASE WHEN RptSideCd = 'S' AND EntrdVolQt < 250000 THEN EntrdVolQt ELSE 0 END) AS RetailNominator,
			SUM(CASE WHEN EntrdVolQt < 250000 THEN EntrdVolQt ELSE 0 END) AS RetailDenominator,
			SUM(CASE WHEN RptSideCd = 'S' AND EntrdVolQt >= 250000 AND EntrdVolQt < 500000 THEN EntrdVolQt ELSE 0 END) AS UnknownNominator,
			SUM(CASE WHEN EntrdVolQt >= 250000 AND EntrdVolQt < 500000 THEN EntrdVolQt ELSE 0 END) AS UnknownDenominator
		FROM
			Trace_filteredWithRatings
		WHERE
			EntrdVolQt <> 0
		GROUP BY
			TrdExctnDt,
			IssuerId
	) A
	WHERE
		RetailDenominator <> 0	
		AND UnknownDenominator <> 0
		AND InstitutionalDenominator <> 0

	SELECT
		A.TrdExctnDt,
		A.IssuerId,
		CASE 
			WHEN StdInstFraction <> 0 THEN (InstFraction - AverageInstFraction) / StdInstFraction 
			ELSE InstFraction
		END AS InstitutionalFraction,
		CASE
			WHEN StdRetFraction <> 0 THEN (RetFraction - AverageRetFraction) / StdRetFraction
			ELSE RetFraction
		END AS RetailFraction,
		CASE
			WHEN StdUnFraction <> 0 THEN (UnFraction - AverageUnFraction) / StdUnFraction
			ELSE UnFraction
		END AS UnFraction
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
			STDEV(RetFraction) AS StdRetFraction,
			AVG(UnFraction) AS AverageUnFraction,
			STDEV(UnFraction) AS StdUnFraction
		FROM
			#TEMP_TABLE
		GROUP BY
			TrdExctnDt
	) B ON A.TrdExctnDt = B.TrdExctnDt

	SELECT 
		A.TrdExctnDt,
		A.IssuerId,
		A.InstitutionalFraction AS InstitutionalFraction,
		A.RetailFraction AS RetailFraction,
		A.UnFraction AS UnFraction,
		B.InstitutionalFraction AS LagWeekInstitutionalFraction,
		B.RetailFraction AS LagWeekRetailFraction,
		B.UnFraction AS LagWeekUnFraction,
		C.InstitutionalFraction AS LagMonthInstitutionalFraction,
		C.RetailFraction AS LagMonthRetailFraction,
		C.UnFraction AS LagMonthUnFraction
	FROM
		#TEMP_FRACTIONS A
	INNER JOIN
		#TEMP_FRACTIONS B ON A.IssuerId = B.IssuerId AND DATEDIFF(DAY, B.TrdExctnDt, A.TrdExctnDt) = 7
	INNER JOIN
		#TEMP_FRACTIONS C ON A.IssuerId = C.IssuerId AND DATEDIFF(DAY, C.TrdExctnDt, A.TrdExctnDt) = 30

	DROP TABLE #TEMP_TABLE
	DROP TABLE #TEMP_FRACTIONS

END
