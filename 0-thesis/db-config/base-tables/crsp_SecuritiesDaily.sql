DROP TABLE IF EXISTS [dbo].[crsp_SecuritiesDaily]

CREATE TABLE [dbo].[crsp_SecuritiesDaily] (
    [Date] nvarchar(10) NOT NULL,
    [Cusip] nvarchar(10) NULL,
    [Ticker] nvarchar(10) NULL,
    [PermNo] int NOT NULL,
    [PermCo] int NULL,
    [Open] float NULL,
    [Close] float NULL,
    [High] float NULL,
    [Low] float NULL,
    [Price] float NULL,
    [Volume] float NULL,
    [PriceVlm] float NULL,
    [TotalRet] float NULL,
    [PriceRet] float NULL,
    [Cap] float NULL,
    [NumTrades] float NULL,
    [FactorPrc] float NULL,
    [DistrDividendAmt] float NULL,
    [DistrFactorPrc] float NULL,
    [DistrFactorShr] float NULL,
    [DistrFreqType] nvarchar(10) NOT NULL,
    [DistrPaymentDt] date NULL,
    [CumFactorPrc] float NULL,
    [CumFactorShr] float NULL,
    [PrimaryExch] nvarchar(10) NULL
) ON [PRIMARY]

CREATE CLUSTERED INDEX [IX_crsp_SecuritiesDaily] ON
    [dbo].[crsp_SecuritiesDaily] (
        [Date] ASC,
        [PermNo] ASC
    ) WITH (
        STATISTICS_NORECOMPUTE = OFF, 
        DROP_EXISTING = OFF, 
        ONLINE = OFF, 
        OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
    ) ON [PRIMARY]
