SELECT
    Datadate,
    MktRf, Smb, Hml, Rmw, Cma, Rf, Rm, 
    ABS(Rm) AS AbsoluteRm,
    POWER(Rm, 2) AS SquaredRm, 
    Sum / Count AS Measure
FROM (
    SELECT
        DataDate, 
        MktRf, Smb, Hml, Rmw, Cma, Rf, Rm,
        ABS(SUM(DReturn) - Rm) AS Sum,
        COUNT(DISTINCT LPermNo) AS Count
    FROM (
        SELECT
            A.LPermNo,
            A.DataDate,
            COALESCE(A.PrcCd / NULLIF(LAG(A.PrcCd) OVER (PARTITION BY A.LPermNo ORDER BY A.DataDate), 0), 0) - 1 AS DReturn,
            B.*
        FROM
            [dbo].[CrspcSecuritiesDaily] A
        INNER JOIN
            [dbo].[CrspcFactors] B ON A.DataDate = B.Date
    ) A
    GROUP BY
        DataDate,
        MktRf, Smb, Hml, Rmw, Cma, Rf, Rm
) B
ORDER BY
    DataDate