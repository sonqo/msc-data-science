CREATE PROCEDURE dbo.sp_des_TradeVolume
    @StartYear INT,
    @EndYear INT
AS
BEGIN
    SET NOCOUNT ON
    SELECT 
        TrdExctnQrDt,
        InvestGrade,
        SUM(EntrdVolQt) AS TotalVolume
    FROM (
        SELECT
            DATEFROMPARTS(
                YEAR(TrdExctnDt),
                CASE DATEPART(QUARTER, TrdExctnDt)
                    WHEN 1 THEN 1
                    WHEN 2 THEN 4
                    WHEN 3 THEN 7
                    WHEN 4 THEN 10
                END,
                1
            ) AS TrdExctnQrDt,
            EntrdVolQt,
            CASE 
                WHEN RatingNum BETWEEN 1 AND 10 THEN 'IG'
                ELSE 'HY'
            END AS InvestGrade
        FROM
            wrds_Trace_FilteredWithRatings
        WHERE
            CntraMpId = 'C'
            AND TrdExctnDt >= DATEFROMPARTS(@StartYear, 1, 1)
            AND TrdExctnDt < DATEFROMPARTS(@EndYear, 1, 1)
    ) A
    GROUP BY
        TrdExctnQrDt,
        InvestGrade
    ORDER BY
        TrdExctnQrDt,
        InvestGrade
END
