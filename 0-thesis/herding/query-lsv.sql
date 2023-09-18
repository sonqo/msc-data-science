-- DAILY: WHOLE
SELECT
    A.TrdExctnDt,
    A.CusipId,
    ABS(Pt - P) AS FirstTerm,
	ABS(1.0 * P * BionomialDraw / N - P) AS SecondTerm,
	1.0 * ABS(Pt - P) - 1.0 * ABS(1.0 * P * BionomialDraw / N - P) AS Hm
FROM (     
    SELECT
        TrdExctnDt,
        CusipId,
        MAX(CustomerBuys) + MAX(CustomerSells) AS N,
        1.0 * MAX(CustomerBuys) / (MAX(CustomerBuys) + MAX(CustomerSells)) AS Pt,
		SUM(CASE WHEN RandomDraw <= 1 - 1.0 * CustomerBuys / (CustomerBuys + CustomerSells) THEN 0 ELSE 1 END) AS BionomialDraw
    FROM (
        SELECT
            TrdExctnDt,
            CusipId,
			RAND() AS RandomDraw,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDt, CusipId) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDt, CusipId) AS CustomerSells
        FROM
            Trace_filteredWithRatings
        WHERE
            CntraMpId = 'C'
	) A
	GROUP BY
		TrdExctnDt,
		CusipId
) A
INNER JOIN (
    SELECT
        TrdExctnDt,
        1.0 * SUM(CustomerBuys) / (SUM(CustomerBuys) + SUM(CustomersSells)) AS P
    FROM (
        SELECT
            TrdExctnDt,
            CusipId,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) AS CustomersSells
        FROM
            Trace_filteredWithRatings
        WHERE
            CntraMpId = 'C'
        GROUP BY
            TrdExctnDt,
            CusipId
    ) A
    GROUP BY
        TrdExctnDt
) B ON A.TrdExctnDt = B.TrdExctnDt
ORDER BY
	A.TrdExctnDt,
	A.CusipId

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
    A.TrdExctnDtYr,
    A.CusipId,
    ABS(Pt - P) AS FirstTerm,
	ABS(1.0 * P * BionomialDraw / N - P) AS SecondTerm,
	1.0 * ABS(Pt - P) - 1.0 * ABS(1.0 * P * BionomialDraw / N - P) AS Hm
FROM (     
    SELECT
        TrdExctnDtYr,
        CusipId,
        MAX(CustomerBuys) + MAX(CustomerSells) AS N,
        1.0 * MAX(CustomerBuys) / (MAX(CustomerBuys) + MAX(CustomerSells)) AS Pt,
		SUM(CASE WHEN RandomDraw <= 1 - 1.0 * CustomerBuys / (CustomerBuys + CustomerSells) THEN 0 ELSE 1 END) AS BionomialDraw
    FROM (
        SELECT
            TrdExctnDtYr,
            CusipId,
			RAND() AS RandomDraw,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtYr, CusipId) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtYr, CusipId) AS CustomerSells
        FROM (
            SELECT
                *,
                YEAR(TrdExctnDt) AS TrdExctnDtYr
            FROM
                Trace_filteredWithRatings
            WHERE
                CntraMpId = 'C'
        ) A
	) A
	GROUP BY
		TrdExctnDtYr,
		CusipId
) A
INNER JOIN (
    SELECT
        TrdExctnDtYr,
        1.0 * SUM(CustomerBuys) / (SUM(CustomerBuys) + SUM(CustomersSells)) AS P
    FROM (
        SELECT
            TrdExctnDtYr,
            CusipId,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) AS CustomersSells
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
            TrdExctnDtYr,
            CusipId
    ) A
    GROUP BY
        TrdExctnDtYr
) B ON A.TrdExctnDtYr = B.TrdExctnDtYr
ORDER BY
	A.TrdExctnDtYr,
	A.CusipId

-- DAILY: INSTITUTIONAL
SELECT
    A.TrdExctnDt,
    A.CusipId,
    ABS(Pt - P) AS FirstTerm,
	ABS(1.0 * P * BionomialDraw / N - P) AS SecondTerm,
	1.0 * ABS(Pt - P) - 1.0 * ABS(1.0 * P * BionomialDraw / N - P) AS Hm
FROM (     
    SELECT
        TrdExctnDt,
        CusipId,
        MAX(CustomerBuys) + MAX(CustomerSells) AS N,
        1.0 * MAX(CustomerBuys) / (MAX(CustomerBuys) + MAX(CustomerSells)) AS Pt,
		SUM(CASE WHEN RandomDraw <= 1 - 1.0 * CustomerBuys / (CustomerBuys + CustomerSells) THEN 0 ELSE 1 END) AS BionomialDraw
    FROM (
        SELECT
            TrdExctnDt,
            CusipId,
			RAND() AS RandomDraw,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDt, CusipId) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDt, CusipId) AS CustomerSells
        FROM
            Trace_filteredWithRatings
        WHERE
            CntraMpId = 'C'
            AND EntrdVolQt >= 500000
	) A
	GROUP BY
		TrdExctnDt,
		CusipId
) A
INNER JOIN (
    SELECT
        TrdExctnDt,
        1.0 * SUM(CustomerBuys) / (SUM(CustomerBuys) + SUM(CustomersSells)) AS P
    FROM (
        SELECT
            TrdExctnDt,
            CusipId,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) AS CustomersSells
        FROM
            Trace_filteredWithRatings
        WHERE
            CntraMpId = 'C'
            AND EntrdVolQt >= 500000
        GROUP BY
            TrdExctnDt,
            CusipId
    ) A
    GROUP BY
        TrdExctnDt
) B ON A.TrdExctnDt = B.TrdExctnDt
ORDER BY
	A.TrdExctnDt,
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
    A.TrdExctnDtYr,
    A.CusipId,
    ABS(Pt - P) AS FirstTerm,
	ABS(1.0 * P * BionomialDraw / N - P) AS SecondTerm,
	1.0 * ABS(Pt - P) - 1.0 * ABS(1.0 * P * BionomialDraw / N - P) AS Hm
FROM (     
    SELECT
        TrdExctnDtYr,
        CusipId,
        MAX(CustomerBuys) + MAX(CustomerSells) AS N,
        1.0 * MAX(CustomerBuys) / (MAX(CustomerBuys) + MAX(CustomerSells)) AS Pt,
		SUM(CASE WHEN RandomDraw <= 1 - 1.0 * CustomerBuys / (CustomerBuys + CustomerSells) THEN 0 ELSE 1 END) AS BionomialDraw
    FROM (
        SELECT
            TrdExctnDtYr,
            CusipId,
			RAND() AS RandomDraw,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtYr, CusipId) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtYr, CusipId) AS CustomerSells
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
	) A
	GROUP BY
		TrdExctnDtYr,
		CusipId
) A
INNER JOIN (
    SELECT
        TrdExctnDtYr,
        1.0 * SUM(CustomerBuys) / (SUM(CustomerBuys) + SUM(CustomersSells)) AS P
    FROM (
        SELECT
            TrdExctnDtYr,
            CusipId,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) AS CustomersSells
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
            TrdExctnDtYr,
            CusipId
    ) A
    GROUP BY
        TrdExctnDtYr
) B ON A.TrdExctnDtYr = B.TrdExctnDtYr
ORDER BY
	A.TrdExctnDtYr,
	A.CusipId

-- DAILY: RETAIL
SELECT
    A.TrdExctnDt,
    A.CusipId,
    ABS(Pt - P) AS FirstTerm,
	ABS(1.0 * P * BionomialDraw / N - P) AS SecondTerm,
	1.0 * ABS(Pt - P) - 1.0 * ABS(1.0 * P * BionomialDraw / N - P) AS Hm
FROM (     
    SELECT
        TrdExctnDt,
        CusipId,
        MAX(CustomerBuys) + MAX(CustomerSells) AS N,
        1.0 * MAX(CustomerBuys) / (MAX(CustomerBuys) + MAX(CustomerSells)) AS Pt,
		SUM(CASE WHEN RandomDraw <= 1 - 1.0 * CustomerBuys / (CustomerBuys + CustomerSells) THEN 0 ELSE 1 END) AS BionomialDraw
    FROM (
        SELECT
            TrdExctnDt,
            CusipId,
			RAND() AS RandomDraw,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDt, CusipId) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDt, CusipId) AS CustomerSells
        FROM
            Trace_filteredWithRatings
        WHERE
            CntraMpId = 'C'
            AND EntrdVolQt < 250000
	) A
	GROUP BY
		TrdExctnDt,
		CusipId
) A
INNER JOIN (
    SELECT
        TrdExctnDt,
        1.0 * SUM(CustomerBuys) / (SUM(CustomerBuys) + SUM(CustomersSells)) AS P
    FROM (
        SELECT
            TrdExctnDt,
            CusipId,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) AS CustomersSells
        FROM
            Trace_filteredWithRatings
        WHERE
            CntraMpId = 'C'
            AND EntrdVolQt < 250000
        GROUP BY
            TrdExctnDt,
            CusipId
    ) A
    GROUP BY
        TrdExctnDt
) B ON A.TrdExctnDt = B.TrdExctnDt
ORDER BY
	A.TrdExctnDt,
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
    A.TrdExctnDtYr,
    A.CusipId,
    ABS(Pt - P) AS FirstTerm,
	ABS(1.0 * P * BionomialDraw / N - P) AS SecondTerm,
	1.0 * ABS(Pt - P) - 1.0 * ABS(1.0 * P * BionomialDraw / N - P) AS Hm
FROM (     
    SELECT
        TrdExctnDtYr,
        CusipId,
        MAX(CustomerBuys) + MAX(CustomerSells) AS N,
        1.0 * MAX(CustomerBuys) / (MAX(CustomerBuys) + MAX(CustomerSells)) AS Pt,
		SUM(CASE WHEN RandomDraw <= 1 - 1.0 * CustomerBuys / (CustomerBuys + CustomerSells) THEN 0 ELSE 1 END) AS BionomialDraw
    FROM (
        SELECT
            TrdExctnDtYr,
            CusipId,
			RAND() AS RandomDraw,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtYr, CusipId) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) OVER (PARTITION BY TrdExctnDtYr, CusipId) AS CustomerSells
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
	) A
	GROUP BY
		TrdExctnDtYr,
		CusipId
) A
INNER JOIN (
    SELECT
        TrdExctnDtYr,
        1.0 * SUM(CustomerBuys) / (SUM(CustomerBuys) + SUM(CustomersSells)) AS P
    FROM (
        SELECT
            TrdExctnDtYr,
            CusipId,
            SUM(CASE WHEN RptSideCd = 'S' THEN 1 ELSE 0 END) AS CustomerBuys,
            SUM(CASE WHEN RptSideCd = 'B' THEN 1 ELSE 0 END) AS CustomersSells
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
            TrdExctnDtYr,
            CusipId
    ) A
    GROUP BY
        TrdExctnDtYr
) B ON A.TrdExctnDtYr = B.TrdExctnDtYr
ORDER BY
	A.TrdExctnDtYr,
	A.CusipId
