DECLARE @LeftTail FLOAT
SET @LeftTail = (
	SELECT DISTINCT PERCENTILE_CONT(0.05) WITHIN GROUP(ORDER BY Rm) OVER () FROM MarketFactors
)

DECLARE @RightTail FLOAT
SET @RightTail = (
	SELECT DISTINCT PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY Rm) OVER () FROM MarketFactors
)

SELECT
    Datadate,
    MktRf, Smb, Hml, Rmw, Cma, Rf, Mom, Rm, 
    ABS(Rm) AS AbsoluteRm,
    POWER(Rm, 2) AS SquaredRm, 
    Sum / Count AS Csad,
    CASE 
        WHEN Rm <= @LeftTail THEN 1
        ELSE 0
    END AS LeftTail,
    CASE 
        WHEN Rm >= @RightTail THEN 1
        ELSE 0
    END AS RightTail
FROM (
    SELECT
        DataDate, 
        MktRf, Smb, Hml, Rmw, Cma, Rf, Mom, Rm,
        ABS(SUM(DailyReturns) - Rm) AS Sum,
        COUNT(DISTINCT LPermNo) AS Count
    FROM (
        SELECT
            A.LPermNo,
            A.DataDate,
            B.*,
            (PrcCd / LAG(A.PrcCd)  OVER (PARTITION BY A.LPermNo ORDER BY A.DataDate)) - 1 AS DailyReturns
        FROM
            CrspcSecuritiesDaily A
		INNER JOIN (
			SELECT DISTINCT
				PermNo
			FROM
				CrspcCodes
			WHERE
				Shrcd IN (10, 11)
				AND Exchcd IN (1, 2, 3)
		) C ON A.LPermNo = C.PermNo
        INNER JOIN
            MarketFactors B ON A.DataDate = B.Date
        WHERE
			PrcCd <> 0
            AND B.Date >= '2002-01-1' AND B.Date < '2022-01-01'
    ) A
    GROUP BY
        DataDate,
        MktRf, Smb, Hml, Rmw, Cma, Rf, Mom, Rm
) B
ORDER BY
	DataDate

-- DISTINCT CUSIPS IN DATASET
SELECT
	COUNT(DISTINCT LPermNo)
FROM
	CrspcSecuritiesDaily A
INNER JOIN (
	SELECT DISTINCT
		PermNo
	FROM
		CrspcCodes
	WHERE
		Shrcd IN (10, 11)
		AND Exchcd IN (1, 2, 3)
) B ON A.LPermNo = B.PermNo
WHERE
	DataDate >= '2002-01-1' AND DataDate < '2022-01-01'

-- DISTINCT CUSIPS BY EXCHANGE
SELECT
	Exchange,
	COUNT(DISTINCT LPermNo)
FROM
	CrspcSecuritiesDaily A
INNER JOIN (
	SELECT DISTINCT
		PermNo
	FROM
		CrspcCodes
	WHERE
		Shrcd IN (10, 11)
		AND Exchcd IN (1, 2, 3)
) B ON A.LPermNo = B.PermNo
WHERE
	DataDate >= '2002-01-1' AND DataDate < '2022-01-01'
GROUP BY
	Exchange

-- DISTINCT CUSIPS BY INDUSTRY
SELECT
	Industry,
	COUNT(DISTINCT LPermNo)
FROM
	CrspcSecuritiesDaily A
INNER JOIN (
	SELECT DISTINCT
		PermNo
	FROM
		CrspcCodes
	WHERE
		Shrcd IN (10, 11)
		AND Exchcd IN (1, 2, 3)
) B ON A.LPermNo = B.PermNo
WHERE
	DataDate >= '2002-01-1' AND DataDate < '2022-01-01'
GROUP BY
	Industry