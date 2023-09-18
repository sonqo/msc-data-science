-- DAILY: WHOLE
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

-- WEEKLY: WHOLE
SELECT
	CusipId,
	TrdExctnDtSOW,
	ABS(BuyAmount - SellAmount) / (BuyAmount + SellAmount) AS Hm,
	CASE
		WHEN BuyAmount > SellAmount THEN 'Buy Herding'
		WHEN SellAmount > BuyAmount THEN 'Sell Herding'
	END AS Flag
FROM (
	SELECT
		CusipId,
		TrdExctnDtSOW,
		SUM(CASE WHEN RptSideCd = 'S' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS BuyAmount,
		SUM(CASE WHEN RptSideCd = 'B' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS SellAmount
	FROM (
		SELECT
			*,
			DATEADD(DAY, 1 - DATEPART(WEEKDAY, TrdExctnDt) + 1, TrdExctnDt) AS TrdExctnDtSOW
		FROM
			Trace_filteredWithRatings
		WHERE
			CntraMpId = 'C'
	) A
	GROUP BY
		CusipId,
		TrdExctnDtSOW
) A
WHERE
	BuyAmount <> 0 AND SellAmount <> 0
ORDER BY
	TrdExctnDtSOW,
	CusipId

-- MONTHLY: WHOLE
SELECT
	CusipId,
	TrdExctnDtEOM,
	ABS(BuyAmount - SellAmount) / (BuyAmount + SellAmount) AS Hm,
	CASE
		WHEN BuyAmount > SellAmount THEN 'Buy Herding'
		WHEN SellAmount > BuyAmount THEN 'Sell Herding'
	END AS Flag
FROM (
	SELECT
		CusipId,
		TrdExctnDtEOM,
		SUM(CASE WHEN RptSideCd = 'S' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS BuyAmount,
		SUM(CASE WHEN RptSideCd = 'B' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS SellAmount
	FROM (
		SELECT
			*,
			EOMONTH(TrdExctnDt) AS TrdExctnDtEOM
		FROM
			Trace_filteredWithRatings
		WHERE
			CntraMpId = 'C'
	) A
	GROUP BY
		CusipId,
		TrdExctnDtEOM
) A
WHERE
	BuyAmount <> 0 AND SellAmount <> 0
ORDER BY
	TrdExctnDtEOM,
	CusipId

-- YEARLY: WHOLE
SELECT
	CusipId,
	TrdExctnDtYr,
	ABS(BuyAmount - SellAmount) / (BuyAmount + SellAmount) AS Hm,
	CASE
		WHEN BuyAmount > SellAmount THEN 'Buy Herding'
		WHEN SellAmount > BuyAmount THEN 'Sell Herding'
	END AS Flag
FROM (
	SELECT
		CusipId,
		TrdExctnDtYr,
		SUM(CASE WHEN RptSideCd = 'S' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS BuyAmount,
		SUM(CASE WHEN RptSideCd = 'B' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS SellAmount
	FROM (
		SELECT
			*,
			YEAR(TrdExctnDt) AS TrdExctnDtYr
		FROM
			Trace_filteredWithRatings
		WHERE
			CntraMpId = 'C'
	) A
	GROUP BY
		CusipId,
		TrdExctnDtYr
) A
WHERE
	BuyAmount <> 0 AND SellAmount <> 0
ORDER BY
	TrdExctnDtYr,
	CusipId

-- DAILY: INSTITUTIONAL
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
		AND EntrdVolQt >= 500000
	GROUP BY
		CusipId,
		TrdExctnDt
) A
WHERE
	BuyAmount <> 0 AND SellAmount <> 0
ORDER BY
	TrdExctnDt,
	CusipId

-- WEEKLY: INSTITUTIONAL
SELECT
	CusipId,
	TrdExctnDtSOW,
	ABS(BuyAmount - SellAmount) / (BuyAmount + SellAmount) AS Hm,
	CASE
		WHEN BuyAmount > SellAmount THEN 'Buy Herding'
		WHEN SellAmount > BuyAmount THEN 'Sell Herding'
	END AS Flag
FROM (
	SELECT
		CusipId,
		TrdExctnDtSOW,
		SUM(CASE WHEN RptSideCd = 'S' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS BuyAmount,
		SUM(CASE WHEN RptSideCd = 'B' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS SellAmount
	FROM (
		SELECT
			*,
			DATEADD(DAY, 1 - DATEPART(WEEKDAY, TrdExctnDt) + 1, TrdExctnDt) AS TrdExctnDtSOW
		FROM
			Trace_filteredWithRatings
		WHERE
			CntraMpId = 'C'
			AND EntrdVolQt >= 500000
	) A
	GROUP BY
		CusipId,
		TrdExctnDtSOW
) A
WHERE
	BuyAmount <> 0 AND SellAmount <> 0
ORDER BY
	TrdExctnDtSOW,
	CusipId

-- MONTHLY: INSTITUTIONAL
SELECT
	CusipId,
	TrdExctnDtEOM,
	ABS(BuyAmount - SellAmount) / (BuyAmount + SellAmount) AS Hm,
	CASE
		WHEN BuyAmount > SellAmount THEN 'Buy Herding'
		WHEN SellAmount > BuyAmount THEN 'Sell Herding'
	END AS Flag
FROM (
	SELECT
		CusipId,
		TrdExctnDtEOM,
		SUM(CASE WHEN RptSideCd = 'S' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS BuyAmount,
		SUM(CASE WHEN RptSideCd = 'B' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS SellAmount
	FROM (
		SELECT
			*,
			EOMONTH(TrdExctnDt) AS TrdExctnDtEOM
		FROM
			Trace_filteredWithRatings
		WHERE
			CntraMpId = 'C'
			AND EntrdVolQt >= 500000
	) A
	GROUP BY
		CusipId,
		TrdExctnDtEOM
) A
WHERE
	BuyAmount <> 0 AND SellAmount <> 0
ORDER BY
	TrdExctnDtEOM,
	CusipId

-- YEARLY: INSTITUTIONAL
SELECT
	CusipId,
	TrdExctnDtYr,
	ABS(BuyAmount - SellAmount) / (BuyAmount + SellAmount) AS Hm,
	CASE
		WHEN BuyAmount > SellAmount THEN 'Buy Herding'
		WHEN SellAmount > BuyAmount THEN 'Sell Herding'
	END AS Flag
FROM (
	SELECT
		CusipId,
		TrdExctnDtYr,
		SUM(CASE WHEN RptSideCd = 'S' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS BuyAmount,
		SUM(CASE WHEN RptSideCd = 'B' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS SellAmount
	FROM (
		SELECT
			*,
			YEAR(TrdExctnDt) AS TrdExctnDtYr
		FROM
			Trace_filteredWithRatings
		WHERE
			CntraMpId = 'C'
			AND EntrdVolQt >= 500000
	) A
	GROUP BY
		CusipId,
		TrdExctnDtYr
) A
WHERE
	BuyAmount <> 0 AND SellAmount <> 0
ORDER BY
	TrdExctnDtYr,
	CusipId

-- DAILY: RETAIL
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
		AND EntrdVolQt < 250000
	GROUP BY
		CusipId,
		TrdExctnDt
) A
WHERE
	BuyAmount <> 0 AND SellAmount <> 0
ORDER BY
	TrdExctnDt,
	CusipId

-- WEEKLY: RETAIL
SELECT
	CusipId,
	TrdExctnDtSOW,
	ABS(BuyAmount - SellAmount) / (BuyAmount + SellAmount) AS Hm,
	CASE
		WHEN BuyAmount > SellAmount THEN 'Buy Herding'
		WHEN SellAmount > BuyAmount THEN 'Sell Herding'
	END AS Flag
FROM (
	SELECT
		CusipId,
		TrdExctnDtSOW,
		SUM(CASE WHEN RptSideCd = 'S' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS BuyAmount,
		SUM(CASE WHEN RptSideCd = 'B' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS SellAmount
	FROM (
		SELECT
			*,
			DATEADD(DAY, 1 - DATEPART(WEEKDAY, TrdExctnDt) + 1, TrdExctnDt) AS TrdExctnDtSOW
		FROM
			Trace_filteredWithRatings
		WHERE
			CntraMpId = 'C'
			AND EntrdVolQt < 250000
	) A
	GROUP BY
		CusipId,
		TrdExctnDtSOW
) A
WHERE
	BuyAmount <> 0 AND SellAmount <> 0
ORDER BY
	TrdExctnDtSOW,
	CusipId

-- MONTHLY: RETAIL
SELECT
	CusipId,
	TrdExctnDtEOM,
	ABS(BuyAmount - SellAmount) / (BuyAmount + SellAmount) AS Hm,
	CASE
		WHEN BuyAmount > SellAmount THEN 'Buy Herding'
		WHEN SellAmount > BuyAmount THEN 'Sell Herding'
	END AS Flag
FROM (
	SELECT
		CusipId,
		TrdExctnDtEOM,
		SUM(CASE WHEN RptSideCd = 'S' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS BuyAmount,
		SUM(CASE WHEN RptSideCd = 'B' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS SellAmount
	FROM (
		SELECT
			*,
			EOMONTH(TrdExctnDt) AS TrdExctnDtEOM
		FROM
			Trace_filteredWithRatings
		WHERE
			CntraMpId = 'C'
			AND EntrdVolQt < 250000
	) A
	GROUP BY
		CusipId,
		TrdExctnDtEOM
) A
WHERE
	BuyAmount <> 0 AND SellAmount <> 0
ORDER BY
	TrdExctnDtEOM,
	CusipId

-- YEARLY: RETAIL
SELECT
	CusipId,
	TrdExctnDtYr,
	ABS(BuyAmount - SellAmount) / (BuyAmount + SellAmount) AS Hm,
	CASE
		WHEN BuyAmount > SellAmount THEN 'Buy Herding'
		WHEN SellAmount > BuyAmount THEN 'Sell Herding'
	END AS Flag
FROM (
	SELECT
		CusipId,
		TrdExctnDtYr,
		SUM(CASE WHEN RptSideCd = 'S' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS BuyAmount,
		SUM(CASE WHEN RptSideCd = 'B' THEN EntrdVolQt * RptdPr / 100 ELSE 0 END) AS SellAmount
	FROM (
		SELECT
			*,
			YEAR(TrdExctnDt) AS TrdExctnDtYr
		FROM
			Trace_filteredWithRatings
		WHERE
			CntraMpId = 'C'
			AND EntrdVolQt < 250000
	) A
	GROUP BY
		CusipId,
		TrdExctnDtYr
) A
WHERE
	BuyAmount <> 0 AND SellAmount <> 0
ORDER BY
	TrdExctnDtYr,
	CusipId
