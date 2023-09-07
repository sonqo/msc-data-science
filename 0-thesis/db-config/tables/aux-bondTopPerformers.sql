DROP TABLE IF EXISTS [dbo].[BondTopPerformers]

DECLARE @FormationPeriod INT
DECLARE @TopPerformers INT

SET @FormationPeriod = 6
SET @TopPerformers = 3

SELECT
    A.*,
    RangeStart,
    RangeEnd
INTO
    #TEMP_BondTopPerformers
FROM
    Trace_filtered_withRatings A
INNER JOIN (
    -- GET CUSIPS THAT WERE TRADED AT LEAST FP-CONSECUTIVE MONTHS
    SELECT
        IssuerId,
        CusipId,
        RangeStart,
        RangeEnd
    FROM (    
        SELECT
            IssuerId,
            CusipId,
            MIN(TrdExctnDt) RangeStart,
            MAX(TrdExctnDt) RangeEnd,
            COUNT(DISTINCT TrdExctnDt) AS GCount
        FROM (
            SELECT
                *,
                DATEADD(MONTH, -ROW_NUMBER() OVER (PARTITION BY CusipId ORDER BY BaseTrdExctnDt), BaseTrdExctnDt) AS Grn
            FROM (
                SELECT
                    IssuerId,
                    CusipId,
                    MAX(TrdExctnDt) AS TrdExctnDt,
                    DATEFROMPARTS(
                        YEAR(MAX(TrdExctnDt)),
                        MONTH(MAX(TrdExctnDt)),
                        1
                    ) AS BaseTrdExctnDt
                FROM (
                    -- GET CUSIPS THAT TRADED IN MONTH AND RETURNS CAN BE CALCULATED
                    SELECT
                        A.*
                    FROM (
                        -- GET CUSIPS TRADED IN THE FIRST 5 DAYS OF MONTH
                        SELECT
                            *,
                            CONCAT(MONTH(TrdExctnDt), '-', YEAR(TrdExctnDt)) AS MonthYearId
                        FROM
                            Trace_filtered_withRatings A
                        WHERE
                            A.TrdExctnDt <= EOMONTH(A.TrdExctnDt) AND A.TrdExctnDt > DATEADD(DAY, -5, EOMONTH(A.TrdExctnDt))
                    ) A
                    INNER JOIN (
                        -- GET CUSIPS TRADED IN THE LAST 5 DAYS OF MONTH
                        SELECT
                            *,
                            CONCAT(MONTH(TrdExctnDt), '-', YEAR(TrdExctnDt)) AS MonthYearId
                        FROM
                            Trace_filtered_withRatings A
                        WHERE
                            TrdExctnDt >= DATEFROMPARTS(YEAR(TrdExctnDt), MONTH(TrdExctnDt), 1) AND TrdExctnDt <= DATEFROMPARTS(YEAR(TrdExctnDt), MONTH(TrdExctnDt), 5)
                    ) B ON A.CusipId = B.CusipId AND A.MonthYearId = B.MonthYearId
                ) A
                GROUP BY
                    IssuerId,
                    CusipId,
                    MONTH(TrdExctnDt),
                    YEAR(TrdExctnDt)
            ) A
        ) B
        GROUP BY
            IssuerId,
            CusipId,
            Grn
    ) C
    WHERE
        GCount >= @FormationPeriod
) B ON A.CusipId = B.CusipId AND TrdExctnDt >= RangeStart AND TrdExctnDt <= RangeEnd

SELECT
    IssuerId,
    CusipId,
    DATEFROMPARTS(
        YEAR(
            DATEADD(MONTH, -Count+1, Date)
        ),
        MONTH(
            DATEADD(MONTH, -Count+1, Date)
        ), 
    1) AS RangeStart,
    DATEFROMPARTS(YEAR(Date), MONTH(Date), 1) AS RangeEnd
INTO
    [dbo].[BondTopPerformers]
FROM (
    SELECT
        a.IssuerId,
        a.CusipId,
        a.Date,
        COUNT(B.Date) AS Count
    FROM (
        SELECT
            *
        FROM (
            SELECT
                *,
                DENSE_RANK() OVER (PARTITION BY IssuerId, Date ORDER BY Volume DESC) AS Ranking  
            FROM (
                SELECT
                    IssuerId,
                    CusipId,
                    Date,
                    SUM(EntrdVolQt) AS Volume
                FROM (
                    SELECT 
                        *,
                        EOMONTH(TrdExctnDt) AS Date
                    FROM 
                        #TEMP_BondTopPerformers
                ) A
                GROUP BY
                    IssuerId,
                    CusipId,
                    Date
            ) B
        ) C
        WHERE
            Ranking <= @TopPerformers
    ) A
    INNER JOIN (
        SELECT
            *
        FROM (
            SELECT
                *,
                DENSE_RANK() OVER (PARTITION BY IssuerId, Date ORDER BY Volume DESC) AS Ranking  
            FROM (
                SELECT
                    IssuerId,
                    CusipId,
                    Date,
                    SUM(EntrdVolQt) AS Volume
                FROM (
                    SELECT 
                        *,
                        EOMONTH(TrdExctnDt) AS Date
                    FROM 
                        #TEMP_BondTopPerformers
                ) A
                GROUP BY
                    IssuerId,
                    CusipId,
                    Date
            ) B
        ) C
        WHERE
            Ranking <= @TopPerformers
    ) B ON A.CusipId = B.CusipId AND DATEDIFF(MONTH, B.Date, A.Date) < 6 AND DATEDIFF(MONTH, B.Date, A.Date) > 0
    GROUP BY
        a.IssuerId,
        a.CusipId,
        a.Date,
        a.Volume
) E
WHERE
    Count = @FormationPeriod - 1
ORDER BY
    IssuerId, Date

DROP TABLE #TEMP_BondTopPerformers
