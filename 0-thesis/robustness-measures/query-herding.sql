SELECT
    A.TrdExctnDt,
    A.CusipId,
    ABS(Pt - P) AS FirstTerm,
	ABS(1.0 * P * BionomialDraw / N - P) AS SecondTerm,
	1.0 * ABS(Pt - P) - 1.0 * ABS(1.0 * BionomialDraw / N - P) AS Hm
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
	A.CusipId,
	A.TrdExctnDt
