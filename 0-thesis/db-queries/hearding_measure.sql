DECLARE @LeftTail FLOAT
SET @LeftTail = (SELECT DISTINCT PERCENTILE_CONT(0.05) WITHIN GROUP(ORDER BY Rm) OVER () FROM [dbo].[CrspcFactors])

DECLARE @RightTail FLOAT
SET @RightTail = (SELECT DISTINCT PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY Rm) OVER () FROM [dbo].[CrspcFactors])

-- distinct cusips in dataset
-- analysis distinct cusip by exchange and industry

SELECT
    Datadate,
    MktRf, Smb, Hml, Rmw, Cma, Rf, Rm, 
    ABS(Rm) AS AbsoluteRm,
    POWER(Rm, 2) AS SquaredRm, 
    Sum / Count AS Measure,
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
        MktRf, Smb, Hml, Rmw, Cma, Rf, Rm,
        ABS(SUM(DReturn) - Rm) AS Sum,
        COUNT(DISTINCT Cusip) AS Count
    FROM (
        SELECT
            Cusip,
            DataDate,
            MktRf, Smb, Hml, Rmw, Cma, Rf, Rm, PrcCd,
            LOG(PrcCd + 0.0000000001, ROUND(EXP(1), 2))
        FROM(
            SELECT
                A.Cusip,
                A.DataDate,
                A.PrcCd,
                LAG(A.PrcCd) OVER (PARTITION BY A.Cusip ORDER BY A.DataDate) AS LagPrcCd,
                B.*
            FROM
                [dbo].[CrspcSecuritiesDaily] A
            INNER JOIN
                [dbo].[CrspcFactors] B ON A.DataDate = B.Date
            WHERE
                B.Date >= '2002-01-1' AND B.Date < '2004-01-01'
        ) B
        where PrcCd between 0 and 1
    ) A
    GROUP BY
        DataDate,
        MktRf, Smb, Hml, Rmw, Cma, Rf, Rm
) B

SELECT LOG(NULL) AS SAMPLE