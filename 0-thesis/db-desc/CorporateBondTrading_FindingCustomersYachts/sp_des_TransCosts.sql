CREATE PROCEDURE dbo.sp_des_TransCosts
    @StartYear INT,
    @EndYear INT
AS
BEGIN
    SET NOCOUNT ON    
    SELECT
        TrdExctnQrDt,
        AVG(TransactionCosts) AS TransactionCosts
    FROM (
        SELECT
            TrdExctnQrDt,
            (LOG(RptdPr / BenchmarkPrice) * TradeSign) * 10000 AS TransactionCosts
        FROM (
            SELECT
                DATEFROMPARTS(
                    YEAR(A.TrdExctnDt),
                    CASE DATEPART(QUARTER, A.TrdExctnDt)
                        WHEN 1 THEN 1
                        WHEN 2 THEN 4
                        WHEN 3 THEN 7
                        WHEN 4 THEN 10
                    END,
                    1
                ) AS TrdExctnQrDt,
                A.CusipId,
                A.RptdPr,
                CASE A.RptSideCd
                    WHEN 'B' THEN -1
                    ELSE 1
                END AS TradeSign,
                B.BenchmarkPrice
            FROM
                wrds_Trace_FilteredWithRatings A
            INNER JOIN (
                SELECT
                    TrdExctnDt,
                    CusipId,
                    MIN(RptdPr) AS BenchmarkPrice
                FROM
                    wrds_Trace_FilteredWithRatings
                WHERE
                    CntraMpId = 'D'
                    AND TrdExctnDt >= DATEFROMPARTS(@StartYear, 1, 1)
                    AND TrdExctnDt < DATEFROMPARTS(@EndYear, 1, 1)
                GROUP BY
                    TrdExctnDt,
                    CusipId
            ) B ON A.TrdExctnDt = B.TrdExctnDt AND A.CusipId = B.CusipId
            WHERE
                A.CntraMpId = 'C'
                AND A.TrdExctnDt >= DATEFROMPARTS(@StartYear, 1, 1)
                AND A.TrdExctnDt < DATEFROMPARTS(@EndYear, 1, 1)
        ) C
    ) D
    GROUP BY
        TrdExctnQrDt
    ORDER BY
        TrdExctnQrDt
END
