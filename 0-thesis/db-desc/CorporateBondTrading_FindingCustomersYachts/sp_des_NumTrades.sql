CREATE PROCEDURE dbo.sp_des_NumTrades
    @StartYear INT,
    @EndYear INT
AS
BEGIN
    SET NOCOUNT ON
    SELECT 
        TrdExctnQrDt,
        SizeCategory,
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
            CASE 
                WHEN EntrdVolQt <= 100000 THEN 'Retail'
                WHEN EntrdVolQt <= 1000000 THEN 'Odd Lot'
                WHEN EntrdVolQt <= 5000000 THEN 'Round Lot'
                ELSE 'Block'
            END AS SizeCategory,
            EntrdVolQt
        FROM
            wrds_Trace_FilteredWithRatings
        WHERE
            CntraMpId = 'C'
            AND TrdExctnDt >= DATEFROMPARTS(@StartYear, 1, 1)
            AND TrdExctnDt < DATEFROMPARTS(@EndYear, 1, 1)
    ) A
    GROUP BY
        TrdExctnQrDt,
        SizeCategory
    ORDER BY
        TrdExctnQrDt,
        SizeCategory
END
