-- TODO: WEEKLY/MONTHLY
SELECT
	CusipId,
	TrdExctnDt,
	ABS(BuyAmount - SellAmount) / (BuyAmount + SellAmount) AS Hm,
	CASE
		WHEN BuyAmount > SellAmount THEN 'Buy Herding'
		WHEN SellAmount > BuyAmount THEN 'Sell Herding'
	END AS Flag
FROM (
	SELECT
		CusipId,
		TrdExctnDt,
		SUM(CASE WHEN RptSideCd = 'S' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS BuyAmount,
		SUM(CASE WHEN RptSideCd = 'B' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS SellAmount
	FROM
		Trace_filteredWithRatings
	WHERE
		CntraMpId = 'C'
	GROUP BY
		CusipId,
		TrdExctnDt
) A
WHERE
	BuyAmount <> 0 AND SellAmount <> 0
ORDER BY
	TrdExctnDt,
	CusipId
