SELECT
    Date,
    Rm,
    ABS(Rm) AS AbsoluteRm,
    POWER(Rm, 2) AS SquaredRm,
    Sum / Count AS Csad
FROM (
    SELECT
        Date,
        Rm,
        ABS(SUM(R) - Rm) AS Sum,
        COUNT(DISTINCT Cusip) AS Count
    FROM (    
        SELECT
            A.TrdExctnDt AS Date,
            A.CusipId AS Cusip,
            A.R,
            B.Rm
        FROM
            BondReturns_fromTrace A
        INNER JOIN (
            SELECT
                Date,
                SUM(RetEod * EntrdVolQt) / SUM(EntrdVolQt) AS Rm
            FROM (
                SELECT
                    TrdExctnDt AS Date,
                    R AS RetEod,
                    EntrdVolQt
                FROM
                    BondReturns_fromTrace
                WHERE
                    Rated = 1
                    AND TrdExctnDt >= '2002-01-01' AND TrdExctnDt < '2023-01-01'
            ) A
            GROUP BY 
                Date
        ) B ON A.TrdExctnDt = B.Date
    ) C
    GROUP BY
        Date,
        Rm
) D
ORDER BY
    Date
