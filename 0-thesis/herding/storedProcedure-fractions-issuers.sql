CREATE PROCEDURE

	[dbo].[Herding_fractions_cusips]

AS

BEGIN
	
    SET NOCOUNT ON	
	
	SELECT
		TrdExctnDt,
		IssuerId,
		1.0 * VolInstitutionalNominator / VolInstitutionalDenominator AS VolInstFraction,
		1.0 * VolRetailNominator / VolRetailDenominator AS VolRetFraction,
		1.0 * VolUnknownNominator / VolUnknownDenominator AS VolUnFraction,
		1.0 * CntInstitutionalNominator / CntInstitutionalDenominator AS CntInstFraction,
		1.0 * CntRetailNominator / CntRetailDenominator AS CntRetFraction,
		1.0 * CntUnknownNominator / CntUnknownDenominator AS CntUnFraction
	INTO
		#TEMP_TABLE
	FROM (
		SELECT
			TrdExctnDt,
			IssuerId,
			SUM(CASE WHEN RptSideCd = 'S' AND EntrdVolQt >= 500000 THEN EntrdVolQt ELSE 0 END) AS VolInstitutionalNominator,
			SUM(CASE WHEN EntrdVolQt >= 500000 THEN EntrdVolQt ELSE 0 END) AS VolInstitutionalDenominator,
			SUM(CASE WHEN RptSideCd = 'S' AND EntrdVolQt < 250000 THEN EntrdVolQt ELSE 0 END) AS VolRetailNominator,
			SUM(CASE WHEN EntrdVolQt < 250000 THEN EntrdVolQt ELSE 0 END) AS VolRetailDenominator,
			SUM(CASE WHEN RptSideCd = 'S' AND EntrdVolQt >= 250000 AND EntrdVolQt < 500000 THEN EntrdVolQt ELSE 0 END) AS VolUnknownNominator,
			SUM(CASE WHEN EntrdVolQt >= 250000 AND EntrdVolQt < 500000 THEN EntrdVolQt ELSE 0 END) AS VolUnknownDenominator,
			SUM(CASE WHEN RptSideCd = 'S' AND EntrdVolQt >= 500000 THEN 1 ELSE 0 END) AS CntInstitutionalNominator,
			SUM(CASE WHEN EntrdVolQt >= 500000 THEN 1 ELSE 0 END) AS CntInstitutionalDenominator,
			SUM(CASE WHEN RptSideCd = 'S' AND EntrdVolQt < 250000 THEN 1 ELSE 0 END) AS CntRetailNominator,
			SUM(CASE WHEN EntrdVolQt < 250000 THEN 1 ELSE 0 END) AS CntRetailDenominator,
			SUM(CASE WHEN RptSideCd = 'S' AND EntrdVolQt >= 250000 AND EntrdVolQt < 500000 THEN 1 ELSE 0 END) AS CntUnknownNominator,
			SUM(CASE WHEN EntrdVolQt >= 250000 AND EntrdVolQt < 500000 THEN 1 ELSE 0 END) AS CntUnknownDenominator
		FROM
			Trace_filteredWithRatings
		WHERE
			EntrdVolQt <> 0
		GROUP BY
			TrdExctnDt,
			IssuerId
	) A
	WHERE
		VolRetailDenominator <> 0 AND CntRetailDenominator <> 0	
		AND VolUnknownDenominator <> 0 AND CntUnknownDenominator <> 0
		AND VolInstitutionalDenominator <> 0 AND CntInstitutionalDenominator <> 0

	SELECT
		A.TrdExctnDt,
		A.IssuerId,
		CASE 
			WHEN VolStdInstFraction <> 0 THEN (VolInstFraction - VolAverageInstFraction) / VolStdInstFraction 
			ELSE VolInstFraction
		END AS VolInstitutionalFraction,
		CASE
			WHEN VolStdRetFraction <> 0 THEN (VolRetFraction - VolAverageRetFraction) / VolStdRetFraction
			ELSE VolRetFraction
		END AS VolRetailFraction,
		CASE
			WHEN VolStdUnFraction <> 0 THEN (VolUnFraction - VolAverageUnFraction) / VolStdUnFraction
			ELSE VolUnFraction
		END AS VolUnFraction,
		CASE 
			WHEN CntStdInstFraction <> 0 THEN (CntInstFraction - CntAverageInstFraction) / CntStdInstFraction 
			ELSE CntInstFraction
		END AS CntInstitutionalFraction,
		CASE
			WHEN CntStdRetFraction <> 0 THEN (CntRetFraction - CntAverageRetFraction) / CntStdRetFraction
			ELSE CntRetFraction
		END AS CntRetailFraction,
		CASE
			WHEN CntStdUnFraction <> 0 THEN (CntUnFraction - CntAverageUnFraction) / CntStdUnFraction
			ELSE CntUnFraction
		END AS CntUnFraction
	INTO
		#TEMP_FRACTIONS
	FROM
		#TEMP_TABLE A
	INNER JOIN (
		SELECT
			TrdExctnDt,
			AVG(VolInstFraction) AS VolAverageInstFraction,
			STDEV(VolInstFraction) AS VolStdInstFraction,
			AVG(VolRetFraction) AS VolAverageRetFraction,
			STDEV(VolRetFraction) AS VolStdRetFraction,
			AVG(VolUnFraction) AS VolAverageUnFraction,
			STDEV(VolUnFraction) AS VolStdUnFraction,
			AVG(CntInstFraction) AS CntAverageInstFraction,
			STDEV(CntInstFraction) AS CntStdInstFraction,
			AVG(CntRetFraction) AS CntAverageRetFraction,
			STDEV(CntRetFraction) AS CntStdRetFraction,
			AVG(CntUnFraction) AS CntAverageUnFraction,
			STDEV(CntUnFraction) AS CntStdUnFraction
		FROM
			#TEMP_TABLE
		GROUP BY
			TrdExctnDt
	) B ON A.TrdExctnDt = B.TrdExctnDt

	SELECT 
		A.TrdExctnDt,
		A.IssuerId,
		A.VolInstitutionalFraction AS VolInstitutionalFraction,
		A.VolRetailFraction AS VolRetailFraction,
		A.VolUnFraction AS VolUnFraction,
		B.VolInstitutionalFraction AS VolLagDayInstitutionalFraction,
		B.VolRetailFraction AS VolLagDayRetailFraction,
		B.VolUnFraction AS VolLagDayUnFraction,
		C.VolInstitutionalFraction AS VolLagWeekInstitutionalFraction,
		C.VolRetailFraction AS VolLagWeekRetailFraction,
		C.VolUnFraction AS VolLagWeekUnFraction,
		D.VolInstitutionalFraction AS VolLagMonthInstitutionalFraction,
		D.VolRetailFraction AS VolLagMonthRetailFraction,
		D.VolUnFraction AS VolLagMonthUnFraction,
		E.VolInstitutionalFraction AS VolLagYearInstitutionalFraction,
		E.VolRetailFraction AS VolLagYearRetailFraction,
		E.VolUnFraction AS VolLagYearUnFraction,
		A.CntInstitutionalFraction AS CntInstitutionalFraction,
		A.CntRetailFraction AS CntRetailFraction,
		A.CntUnFraction AS CntUnFraction,
		B.CntInstitutionalFraction AS CntLagDayInstitutionalFraction,
		B.CntRetailFraction AS CntLagDayRetailFraction,
		B.CntUnFraction AS CntLagDayUnFraction,
		C.CntInstitutionalFraction AS CntLagWeekInstitutionalFraction,
		C.CntRetailFraction AS CntLagWeekRetailFraction,
		C.CntUnFraction AS CntLagWeekUnFraction,
		D.CntInstitutionalFraction AS CntLagMonthInstitutionalFraction,
		D.CntRetailFraction AS CntLagMonthRetailFraction,
		D.CntUnFraction AS CntLagMonthUnFraction,
		E.CntInstitutionalFraction AS CntLagYearInstitutionalFraction,
		E.CntRetailFraction AS CntLagYearRetailFraction,
		E.CntUnFraction AS CntLagYearUnFraction
	FROM
		#TEMP_FRACTIONS A
	INNER JOIN
		#TEMP_FRACTIONS B ON A.IssuerId = B.IssuerId AND DATEDIFF(DAY, B.TrdExctnDt, A.TrdExctnDt) = 1
	INNER JOIN
		#TEMP_FRACTIONS C ON A.IssuerId = C.IssuerId AND DATEDIFF(DAY, C.TrdExctnDt, A.TrdExctnDt) = 7
	INNER JOIN
		#TEMP_FRACTIONS D ON A.IssuerId = D.IssuerId AND DATEDIFF(DAY, D.TrdExctnDt, A.TrdExctnDt) = 30
	INNER JOIN
		#TEMP_FRACTIONS E ON A.IssuerId = E.IssuerId AND DATEDIFF(DAY, E.TrdExctnDt, A.TrdExctnDt) = 360
	ORDER BY
		A.TrdExctnDt

	DROP TABLE #TEMP_TABLE
	DROP TABLE #TEMP_FRACTIONS

END
