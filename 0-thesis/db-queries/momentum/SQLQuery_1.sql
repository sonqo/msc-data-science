SELECT
    *
FROM (
    SELECT
        *,
        SUM(CASE WHEN LeadDiff = 6 THEN 1 ELSE 0 END) OVER (ORDER BY TrdExctnDt) AS LeadDiffCount,
        SUM(CASE WHEN LagDiff = 6 THEN 1 ELSE 0 END) OVER (ORDER BY TrdExctnDt DESC) AS LagDiffCount
    FROM (    
        SELECT
            *,
            DATEDIFF(
                MONTH, 
                DATEFROMPARTS(
                    YEAR(TrdExctnDt),
                    MONTH(TrdExctnDt),
                    1
                ),
                DATEFROMPARTS(
                    YEAR(
                        LEAD(TrdExctnDt, 6) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt ASC)
                    ),
                    MONTH(
                        LEAD(TrdExctnDt, 6) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt ASC)
                    ),
                    1
                )
            ) AS LeadDiff,
            DATEDIFF(
                MONTH, 
                DATEFROMPARTS(
                    YEAR(
                        Lag(TrdExctnDt, 6) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt ASC)
                    ),
                    MONTH(
                        Lag(TrdExctnDt, 6) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt ASC)
                    ),
                    1
                ),
                DATEFROMPARTS(
                    YEAR(TrdExctnDt),
                    MONTH(TrdExctnDt),
                    1
                )
            ) AS LagDiff
        FROM (
            SELECT
                *,
                DENSE_RANK() OVER (PARTITION BY CusipId ORDER BY TrdExctnDt ASC) + 6 AS DateRanking
            FROM (
                SELECT
                    IssuerId,
                    CusipId,
                    MAX(TrdExctnDt) AS TrdExctnDt,
                    CONCAT(MONTH(TrdExctnDt), '-', YEAR(TrdExctnDt)) AS MonthYearId,
                    SUM(EntrdVolQt) AS SumVolume
                FROM
                    Trace_filtered_withRatings
                WHERE
                    CusipId IN ('00440EAC1')
                GROUP BY
                    IssuerId,
                    CusipId,
                    MONTH(TrdExctnDt),
                    YEAR(TrdExctnDt)
            ) A
        ) B
    ) C
) D
ORDER BY
    IssuerId,
    CusipId,
    TrdExctnDt
