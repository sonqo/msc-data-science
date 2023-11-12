CREATE PROCEDURE

	[dbo].[Herding-Measures-Wermers] @TimeFrame INT = 1, @Investor INT = NULL

AS

BEGIN
	
    SET NOCOUNT ON

	SELECT
		CusipId,
		TrdExctnDtTF,
		ABS(BuyAmount - SellAmount) / (BuyAmount + SellAmount) AS Hm,
		CASE
			WHEN BuyAmount > SellAmount THEN 'Buy Herding'
			WHEN SellAmount > BuyAmount THEN 'Sell Herding'
		END AS Flag
	FROM (
		SELECT
			CusipId,
			TrdExctnDtTF,
			SUM(CASE WHEN RptSideCd = 'S' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS BuyAmount,
			SUM(CASE WHEN RptSideCd = 'B' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS SellAmount
		FROM (
			SELECT
				*,
				CASE
					WHEN @TimeFrame = 1 THEN TrdExctnDt -- DAY
					WHEN @TimeFrame = 2 THEN DATEADD(DAY, 1 - DATEPART(WEEKDAY, TrdExctnDt) + 1, TrdExctnDt) -- WEEK
					WHEN @TimeFrame = 3 THEN EOMONTH(TrdExctnDt) -- MONTH
					WHEN @TimeFrame = 4 THEN -- QUARTER
						CASE 
							WHEN DATEPART(QUARTER, TrdExctnDt) = 1 THEN DATEFROMPARTS(YEAR(TrdExctnDt), 01, 01)
							WHEN DATEPART(QUARTER, TrdExctnDt) = 2 THEN DATEFROMPARTS(YEAR(TrdExctnDt), 04, 01)
							WHEN DATEPART(QUARTER, TrdExctnDt) = 3 THEN DATEFROMPARTS(YEAR(TrdExctnDt), 07, 01)
							WHEN DATEPART(QUARTER, TrdExctnDt) = 4 THEN DATEFROMPARTS(YEAR(TrdExctnDt), 10, 01)
						END
					WHEN @TimeFrame = 5 THEN DATEFROMPARTS(YEAR(TrdExctnDt), 01, 01) -- YEAR
				END AS TrdExctnDtTF,
				CASE
					WHEN EntrdVolQt < 250000 AND @Investor <> 1 THEN 2 -- RETAIL
					WHEN EntrdVolQt >= 500000 AND @Investor <> 1 THEN 3 -- INSTITUTIONAL
					ELSE 1 -- WHOLE
				END AS Investor
			FROM
				TraceFilteredWithRatings
			WHERE
				CntraMpId = 'C'
		) A
		WHERE
			Investor = @Investor
		GROUP BY
			CusipId,
			TrdExctnDtTF
	) A
	WHERE
		BuyAmount <> 0 
		AND SellAmount <> 0
	ORDER BY
		TrdExctnDtTF,
		CusipId

END
