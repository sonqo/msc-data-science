CREATE VIEW uvs_crsp_SecuritiesDaily AS
    SELECT 
        Date,
        Cusip,
        MAX(PermNo) AS PermNo,
        MAX([Open]) AS 'Open',
        MAX([Close]) AS 'Close',
        MAX([High]) AS High,
        MAX([Low]) AS Low,
        MAX([Price]) AS Price,
        MAX([Volume]) AS Volume,
        MAX([PriceVlm]) AS PriceVlm,
        MAX([TotalRet]) AS TotalRet,
        MAX([PriceRet]) AS PriceRet,
        MAX([Cap]) AS Cap,
        MAX([NumTrades]) AS NumTrades,
        MAX([FactorPrc]) AS FactorPrc,
        MAX([CumFactorPrc]) AS CumFactorPrc,
        MAX([CumFactorShr]) AS CumFactorShr,
        MAX([PrimaryExch]) AS PrimaryExch
    FROM
        [dbo].[crsp_SecuritiesDaily]
    GROUP BY
        Date, Cusip
