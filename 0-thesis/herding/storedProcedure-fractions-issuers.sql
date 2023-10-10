CREATE PROCEDURE

	[dbo].[Herding_FractionsIssuers] @Timeframe int = 1

AS

BEGIN
	
    SET NOCOUNT ON	
	
	SELECT
		TrdExctnDt,
		IssuerId,
		CASE
			WHEN VolInstitutionalDenominator <> 0 THEN 1.0 * VolInstitutionalNominator / VolInstitutionalDenominator 
			ELSE NULL
		END AS VolInstFraction,
		CASE
			WHEN VolRetailDenominator <> 0 THEN 1.0 * VolRetailNominator / VolRetailDenominator 
			ELSE NULL
		END AS VolRetFraction,
		CASE
			WHEN VolUnknownDenominator <> 0 THEN 1.0 * VolUnknownNominator / VolUnknownDenominator
			ELSE NULL
		END AS VolUnFraction,
		CASE
			WHEN CntInstitutionalDenominator <> 0 THEN 1.0 * CntInstitutionalNominator / CntInstitutionalDenominator 
			ELSE NULL
		END AS CntInstFraction,
		CASE
			WHEN CntRetailDenominator <> 0 THEN 1.0 * CntRetailNominator / CntRetailDenominator 
			ELSE NULL
		END AS CntRetFraction,
		CASE
			WHEN CntUnknownDenominator <> 0 THEN 1.0 * CntUnknownNominator / CntUnknownDenominator
			ELSE NULL
		END AS CntUnFraction
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
		B.VolInstitutionalFraction AS VolLagInstitutionalFraction,
		B.VolRetailFraction AS VolLagRetailFraction,
		B.VolUnFraction AS VolLagUnFraction,
		A.CntInstitutionalFraction AS CntInstitutionalFraction,
		A.CntRetailFraction AS CntRetailFraction,
		A.CntUnFraction AS CntUnFraction,
		B.CntInstitutionalFraction AS CntLagInstitutionalFraction,
		B.CntRetailFraction AS CntLagRetailFraction,
		B.CntUnFraction AS CntLagUnFraction
	FROM
		#TEMP_FRACTIONS A
	INNER JOIN
		#TEMP_FRACTIONS B ON A.IssuerId = B.IssuerId AND DATEDIFF(DAY, B.TrdExctnDt, A.TrdExctnDt) = @Timeframe
	ORDER BY
		A.TrdExctnDt

	DROP TABLE #TEMP_TABLE
	DROP TABLE #TEMP_FRACTIONS

END
