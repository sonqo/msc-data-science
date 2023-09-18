-- WEEKLY: WHOLE
SELECT
    A.TrdExctnDtSOW,
    A.CusipId,
    ABS(Pt - P) AS FirstTerm,
	ABS(1.0 * P * BionomialDraw / N - P) AS SecondTerm,
	1.0 * ABS(Pt - P) - 1.0 * ABS(1.0 * P * BionomialDraw / N - P) AS Hm
FROM (     
    SELECT
        TrdExctnDtSOW,
        CusipId,
        MAX(CustomerBuys) + MAX(CustomerSells) AS N,
        1.0 * MAX(CustomerBuys) / (MAX(CustomerBuys) + MAX(CustomerSells)) AS Pt,
		SUM(CASE WHEN RandomDraw <= 1 - 1.0 * CustomerBuys / (CustomerBuys + CustomerSells) THEN 0 ELSE 1 END) AS BionomialDraw
    FROM (
        SELECT
            TrdExctnDtSOW,
            CusipId,
			RAND() AS RandomDraw,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtSOW, CusipId) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtSOW, CusipId) AS CustomerSells
        FROM (
            SELECT
                *,
                DATEADD(DAY, 1 - DATEPART(WEEKDAY, TrdExctnDt) + 1, TrdExctnDt) AS TrdExctnDtSOW
            FROM 
                Trace_filteredWithRatings
            WHERE
                CntraMpId = 'C'
        ) A
	) A
	GROUP BY
		TrdExctnDtSOW,
		CusipId
) A
INNER JOIN (
    SELECT
        TrdExctnDtSOW,
        1.0 * SUM(CustomerBuys) / (SUM(CustomerBuys) + SUM(CustomersSells)) AS P
    FROM (
        SELECT
            TrdExctnDtSOW,
            CusipId,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) AS CustomersSells
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
            TrdExctnDtSOW,
            CusipId
    ) A
    GROUP BY
        TrdExctnDtSOW
) B ON A.TrdExctnDtSOW = B.TrdExctnDtSOW
ORDER BY
	A.TrdExctnDtSOW,
	A.CusipId

-- MONTHLY: WHOLE
SELECT
    A.TrdExctnDtEOM,
    A.CusipId,
    ABS(Pt - P) AS FirstTerm,
	ABS(1.0 * P * BionomialDraw / N - P) AS SecondTerm,
	1.0 * ABS(Pt - P) - 1.0 * ABS(1.0 * P * BionomialDraw / N - P) AS Hm
FROM (     
    SELECT
        TrdExctnDtEOM,
        CusipId,
        MAX(CustomerBuys) + MAX(CustomerSells) AS N,
        1.0 * MAX(CustomerBuys) / (MAX(CustomerBuys) + MAX(CustomerSells)) AS Pt,
		SUM(CASE WHEN RandomDraw <= 1 - 1.0 * CustomerBuys / (CustomerBuys + CustomerSells) THEN 0 ELSE 1 END) AS BionomialDraw
    FROM (
        SELECT
            TrdExctnDtEOM,
            CusipId,
			RAND() AS RandomDraw,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtEOM, CusipId) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtEOM, CusipId) AS CustomerSells
        FROM (
            SELECT
                *,
                EOMONTH(TrdExctnDt) AS TrdExctnDtEOM
            FROM
                Trace_filteredWithRatings
            WHERE
                CntraMpId = 'C'
        ) A
	) A
	GROUP BY
		TrdExctnDtEOM,
		CusipId
) A
INNER JOIN (
    SELECT
        TrdExctnDtEOM,
        1.0 * SUM(CustomerBuys) / (SUM(CustomerBuys) + SUM(CustomersSells)) AS P
    FROM (
        SELECT
            TrdExctnDtEOM,
            CusipId,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) AS CustomersSells
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
            TrdExctnDtEOM,
            CusipId
    ) A
    GROUP BY
        TrdExctnDtEOM
) B ON A.TrdExctnDtEOM = B.TrdExctnDtEOM
ORDER BY
	A.TrdExctnDtEOM,
	A.CusipId

-- YEARLY: WHOLE
SELECT
    A.TrdExctnDtSOY,
    A.CusipId,
    ABS(Pt - P) AS FirstTerm,
	ABS(1.0 * P * BionomialDraw / N - P) AS SecondTerm,
	1.0 * ABS(Pt - P) - 1.0 * ABS(1.0 * P * BionomialDraw / N - P) AS Hm
FROM (     
    SELECT
        TrdExctnDtSOY,
        CusipId,
        MAX(CustomerBuys) + MAX(CustomerSells) AS N,
        1.0 * MAX(CustomerBuys) / (MAX(CustomerBuys) + MAX(CustomerSells)) AS Pt,
		SUM(CASE WHEN RandomDraw <= 1 - 1.0 * CustomerBuys / (CustomerBuys + CustomerSells) THEN 0 ELSE 1 END) AS BionomialDraw
    FROM (
        SELECT
            TrdExctnDtSOY,
            CusipId,
			RAND() AS RandomDraw,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtSOY, CusipId) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtSOY, CusipId) AS CustomerSells
        FROM (
            SELECT
                *,
                DATEFROMPARTS(1, 1, YEAR(TrdExctnDt)) AS TrdExctnDtSOY
            FROM
                Trace_filteredWithRatings
            WHERE
                CntraMpId = 'C'
        ) A
	) A
	GROUP BY
		TrdExctnDtSOY,
		CusipId
) A
INNER JOIN (
    SELECT
        TrdExctnDtSOY,
        1.0 * SUM(CustomerBuys) / (SUM(CustomerBuys) + SUM(CustomersSells)) AS P
    FROM (
        SELECT
            TrdExctnDtSOY,
            CusipId,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) AS CustomersSells
        FROM (
            SELECT
                *,
                DATEFROMPARTS(1, 1, YEAR(TrdExctnDt)) AS TrdExctnDtSOY
            FROM
                Trace_filteredWithRatings
            WHERE
                CntraMpId = 'C'
        ) A
        GROUP BY
            TrdExctnDtSOY,
            CusipId
    ) A
    GROUP BY
        TrdExctnDtSOY
) B ON A.TrdExctnDtSOY = B.TrdExctnDtSOY
ORDER BY
	A.TrdExctnDtSOY,
	A.CusipId

-- WEEKLY: INSTITUTIONAL
SELECT
    A.TrdExctnDtSOW,
    A.CusipId,
    ABS(Pt - P) AS FirstTerm,
	ABS(1.0 * P * BionomialDraw / N - P) AS SecondTerm,
	1.0 * ABS(Pt - P) - 1.0 * ABS(1.0 * P * BionomialDraw / N - P) AS Hm
FROM (     
    SELECT
        TrdExctnDtSOW,
        CusipId,
        MAX(CustomerBuys) + MAX(CustomerSells) AS N,
        1.0 * MAX(CustomerBuys) / (MAX(CustomerBuys) + MAX(CustomerSells)) AS Pt,
		SUM(CASE WHEN RandomDraw <= 1 - 1.0 * CustomerBuys / (CustomerBuys + CustomerSells) THEN 0 ELSE 1 END) AS BionomialDraw
    FROM (
        SELECT
            TrdExctnDtSOW,
            CusipId,
			RAND() AS RandomDraw,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtSOW, CusipId) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtSOW, CusipId) AS CustomerSells
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
	) A
	GROUP BY
		TrdExctnDtSOW,
		CusipId
) A
INNER JOIN (
    SELECT
        TrdExctnDtSOW,
        1.0 * SUM(CustomerBuys) / (SUM(CustomerBuys) + SUM(CustomersSells)) AS P
    FROM (
        SELECT
            TrdExctnDtSOW,
            CusipId,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) AS CustomersSells
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
            TrdExctnDtSOW,
            CusipId
    ) A
    GROUP BY
        TrdExctnDtSOW
) B ON A.TrdExctnDtSOW = B.TrdExctnDtSOW
ORDER BY
	A.TrdExctnDtSOW,
	A.CusipId

-- MONTHLY: INSTITUNIONAL
SELECT
    A.TrdExctnDtEOM,
    A.CusipId,
    ABS(Pt - P) AS FirstTerm,
	ABS(1.0 * P * BionomialDraw / N - P) AS SecondTerm,
	1.0 * ABS(Pt - P) - 1.0 * ABS(1.0 * P * BionomialDraw / N - P) AS Hm
FROM (     
    SELECT
        TrdExctnDtEOM,
        CusipId,
        MAX(CustomerBuys) + MAX(CustomerSells) AS N,
        1.0 * MAX(CustomerBuys) / (MAX(CustomerBuys) + MAX(CustomerSells)) AS Pt,
		SUM(CASE WHEN RandomDraw <= 1 - 1.0 * CustomerBuys / (CustomerBuys + CustomerSells) THEN 0 ELSE 1 END) AS BionomialDraw
    FROM (
        SELECT
            TrdExctnDtEOM,
            CusipId,
			RAND() AS RandomDraw,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtEOM, CusipId) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtEOM, CusipId) AS CustomerSells
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
	) A
	GROUP BY
		TrdExctnDtEOM,
		CusipId
) A
INNER JOIN (
    SELECT
        TrdExctnDtEOM,
        1.0 * SUM(CustomerBuys) / (SUM(CustomerBuys) + SUM(CustomersSells)) AS P
    FROM (
        SELECT
            TrdExctnDtEOM,
            CusipId,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) AS CustomersSells
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
            TrdExctnDtEOM,
            CusipId
    ) A
    GROUP BY
        TrdExctnDtEOM
) B ON A.TrdExctnDtEOM = B.TrdExctnDtEOM
ORDER BY
	A.TrdExctnDtEOM,
	A.CusipId

-- YEARLY: INSTITUTIONAL
SELECT
    A.TrdExctnDtSOY,
    A.CusipId,
    ABS(Pt - P) AS FirstTerm,
	ABS(1.0 * P * BionomialDraw / N - P) AS SecondTerm,
	1.0 * ABS(Pt - P) - 1.0 * ABS(1.0 * P * BionomialDraw / N - P) AS Hm
FROM (     
    SELECT
        TrdExctnDtSOY,
        CusipId,
        MAX(CustomerBuys) + MAX(CustomerSells) AS N,
        1.0 * MAX(CustomerBuys) / (MAX(CustomerBuys) + MAX(CustomerSells)) AS Pt,
		SUM(CASE WHEN RandomDraw <= 1 - 1.0 * CustomerBuys / (CustomerBuys + CustomerSells) THEN 0 ELSE 1 END) AS BionomialDraw
    FROM (
        SELECT
            TrdExctnDtSOY,
            CusipId,
			RAND() AS RandomDraw,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtSOY, CusipId) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtSOY, CusipId) AS CustomerSells
        FROM (
            SELECT
                *,
                DATEFROMPARTS(1, 1, YEAR(TrdExctnDt)) AS TrdExctnDtSOY
            FROM
                Trace_filteredWithRatings
            WHERE
                CntraMpId = 'C'
                AND EntrdVolQt >= 500000
        ) A
	) A
	GROUP BY
		TrdExctnDtSOY,
		CusipId
) A
INNER JOIN (
    SELECT
        TrdExctnDtSOY,
        1.0 * SUM(CustomerBuys) / (SUM(CustomerBuys) + SUM(CustomersSells)) AS P
    FROM (
        SELECT
            TrdExctnDtSOY,
            CusipId,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) AS CustomersSells
        FROM (
            SELECT
                *,
                DATEFROMPARTS(1, 1, YEAR(TrdExctnDt)) AS TrdExctnDtSOY
            FROM
                Trace_filteredWithRatings
            WHERE
                CntraMpId = 'C'
                AND EntrdVolQt >= 500000
        ) A
        GROUP BY
            TrdExctnDtSOY,
            CusipId
    ) A
    GROUP BY
        TrdExctnDtSOY
) B ON A.TrdExctnDtSOY = B.TrdExctnDtSOY
ORDER BY
	A.TrdExctnDtSOY,
	A.CusipId

-- WEEKLY: RETAIL
SELECT
    A.TrdExctnDtSOW,
    A.CusipId,
    ABS(Pt - P) AS FirstTerm,
	ABS(1.0 * P * BionomialDraw / N - P) AS SecondTerm,
	1.0 * ABS(Pt - P) - 1.0 * ABS(1.0 * P * BionomialDraw / N - P) AS Hm
FROM (     
    SELECT
        TrdExctnDtSOW,
        CusipId,
        MAX(CustomerBuys) + MAX(CustomerSells) AS N,
        1.0 * MAX(CustomerBuys) / (MAX(CustomerBuys) + MAX(CustomerSells)) AS Pt,
		SUM(CASE WHEN RandomDraw <= 1 - 1.0 * CustomerBuys / (CustomerBuys + CustomerSells) THEN 0 ELSE 1 END) AS BionomialDraw
    FROM (
        SELECT
            DATEADD(DAY, 1 - DATEPART(WEEKDAY, TrdExctnDt) + 1, TrdExctnDt) AS TrdExctnDtSOW,
            CusipId,
			RAND() AS RandomDraw,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) OVER (PARTITION BY EOMONTH(TrdExctnDt), CusipId) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) OVER (PARTITION BY EOMONTH(TrdExctnDt), CusipId) AS CustomerSells
        FROM 
			Trace_filteredWithRatings
		WHERE
            CntraMpId = 'C'
            AND EntrdVolQt < 250000
	) A
	GROUP BY
		TrdExctnDtSOW,
		CusipId
) A
INNER JOIN (
    SELECT
        TrdExctnDtSOW,
        1.0 * SUM(CustomerBuys) / (SUM(CustomerBuys) + SUM(CustomersSells)) AS P
    FROM (
        SELECT
            DATEADD(DAY, 1 - DATEPART(WEEKDAY, TrdExctnDt) + 1, TrdExctnDt) AS TrdExctnDtSOW,
            CusipId,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) AS CustomersSells
        FROM
            Trace_filteredWithRatings
        WHERE
            CntraMpId = 'C'
            AND EntrdVolQt < 250000
        GROUP BY
            DATEADD(DAY, 1 - DATEPART(WEEKDAY, TrdExctnDt) + 1, TrdExctnDt),
            CusipId
    ) A
    GROUP BY
        TrdExctnDtSOW
) B ON A.TrdExctnDtSOW = B.TrdExctnDtSOW
ORDER BY
	A.TrdExctnDtSOW,
	A.CusipId

-- MONTHLY: RETAIL
SELECT
    A.TrdExctnDtEOM,
    A.CusipId,
    ABS(Pt - P) AS FirstTerm,
	ABS(1.0 * P * BionomialDraw / N - P) AS SecondTerm,
	1.0 * ABS(Pt - P) - 1.0 * ABS(1.0 * P * BionomialDraw / N - P) AS Hm
FROM (     
    SELECT
        TrdExctnDtEOM,
        CusipId,
        MAX(CustomerBuys) + MAX(CustomerSells) AS N,
        1.0 * MAX(CustomerBuys) / (MAX(CustomerBuys) + MAX(CustomerSells)) AS Pt,
		SUM(CASE WHEN RandomDraw <= 1 - 1.0 * CustomerBuys / (CustomerBuys + CustomerSells) THEN 0 ELSE 1 END) AS BionomialDraw
    FROM (
        SELECT
            TrdExctnDtEOM,
            CusipId,
			RAND() AS RandomDraw,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtEOM, CusipId) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtEOM, CusipId) AS CustomerSells
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
	) A
	GROUP BY
		TrdExctnDtEOM,
		CusipId
) A
INNER JOIN (
    SELECT
        TrdExctnDtEOM,
        1.0 * SUM(CustomerBuys) / (SUM(CustomerBuys) + SUM(CustomersSells)) AS P
    FROM (
        SELECT
            TrdExctnDtEOM,
            CusipId,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) AS CustomersSells
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
            TrdExctnDtEOM,
            CusipId
    ) A
    GROUP BY
        TrdExctnDtEOM
) B ON A.TrdExctnDtEOM = B.TrdExctnDtEOM
ORDER BY
	A.TrdExctnDtEOM,
	A.CusipId

-- YEARLY: RETAIL
SELECT
    A.TrdExctnDtSOY,
    A.CusipId,
    ABS(Pt - P) AS FirstTerm,
	ABS(1.0 * P * BionomialDraw / N - P) AS SecondTerm,
	1.0 * ABS(Pt - P) - 1.0 * ABS(1.0 * P * BionomialDraw / N - P) AS Hm
FROM (     
    SELECT
        TrdExctnDtSOY,
        CusipId,
        MAX(CustomerBuys) + MAX(CustomerSells) AS N,
        1.0 * MAX(CustomerBuys) / (MAX(CustomerBuys) + MAX(CustomerSells)) AS Pt,
		SUM(CASE WHEN RandomDraw <= 1 - 1.0 * CustomerBuys / (CustomerBuys + CustomerSells) THEN 0 ELSE 1 END) AS BionomialDraw
    FROM (
        SELECT
            TrdExctnDtSOY,
            CusipId,
			RAND() AS RandomDraw,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtSOY, CusipId) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtSOY, CusipId) AS CustomerSells
        FROM (
            SELECT
                *,
                DATEFROMPARTS(1, 1, YEAR(TrdExctnDt)) AS TrdExctnDtSOY
            FROM
                Trace_filteredWithRatings
            WHERE
                CntraMpId = 'C'
                AND EntrdVolQt < 250000
        ) A
	) A
	GROUP BY
		TrdExctnDtSOY,
		CusipId
) A
INNER JOIN (
    SELECT
        TrdExctnDtSOY,
        1.0 * SUM(CustomerBuys) / (SUM(CustomerBuys) + SUM(CustomersSells)) AS P
    FROM (
        SELECT
            TrdExctnDtSOY,
            CusipId,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) AS CustomersSells
        FROM (
            SELECT
                *,
                DATEFROMPARTS(1, 1, YEAR(TrdExctnDt)) AS TrdExctnDtSOY
            FROM
                Trace_filteredWithRatings
            WHERE
                CntraMpId = 'C'
                AND EntrdVolQt < 250000
        ) A
        GROUP BY
            TrdExctnDtSOY,
            CusipId
    ) A
    GROUP BY
        TrdExctnDtSOY
) B ON A.TrdExctnDtSOY = B.TrdExctnDtSOY
ORDER BY
	A.TrdExctnDtSOY,
	A.CusipId
