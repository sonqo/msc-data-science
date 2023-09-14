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
        ABS(SUM(RetEom) - Rm) AS Sum,
        COUNT(DISTINCT Cusip) AS Count
    FROM (
        SELECT
            A.TrdExctnDtEOM AS Date,
            A.CusipId AS Cusip,
            A.R AS RetEom,
            B.Rm
        FROM
            BondReturns_customerOnly A
        INNER JOIN (
            -- MONTHLY RM
            SELECT
                TrdExctnDtEOM AS Date,
                SUM(R / 100 * TD_volume) / SUM(TD_volume) AS Rm
            FROM
                BondReturns_customerOnly
            GROUP BY
                TrdExctnDtEOM
        ) B ON A.TrdExctnDtEOM = B.Date
    ) A
    GROUP BY
        Date,
        Rm
) B
WHERE
	Rm IS NOT NULL
ORDER BY
    Date
