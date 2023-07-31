DROP TABLE IF EXISTS [dbo].[CrspcSecuritiesDaily]

CREATE TABLE [dbo].[CrspcSecuritiesDaily](
	[GvKey] [nvarchar](10) NULL,
	[IId] [int] NULL,
	[DataDate] [date] NOT NULL,
	[Tic] [nvarchar](10) NULL,
	[Cusip] [nvarchar](10) NOT NULL,
	[CoNml] [nvarchar](100) NULL,
	[PrcCd] [numeric](18, 5) NULL,
	[PrcHd] [numeric](18, 5) NULL,
	[PrcLd] [numeric](18, 5) NULL,
	[PrcOd] [numeric](18, 5) NULL,
	[PrcStd] [numeric](18, 5) NULL,
	[Exchg] [int] NULL,
	[Exchange] [nvarchar](15) NULL,
	[Sic] [decimal] NULL,
	[Industry] [nvarchar](15) NULL,
	[Naics] [decimal] NULL,
	[Eps] [decimal] NULL,
	[EpsMo] [decimal] NULL,
	[TrFd] [decimal] NULL,
	[Loc] [nvarchar](3) NULL,
	[Div] [decimal] NULL,
	[Divd] [decimal] NULL,
	[DivdPayDateInd] [nvarchar](1) NULL,
	[Divsp] [decimal] NULL,
	[DivdPayDate] [date] NULL,
	[DivspPayDate] [date] NULL,
	[AnncDate] [date] NULL,
	[IpoDate] [date] NULL,
	CONSTRAINT [PK_CrspcSecuritiesDaily] PRIMARY KEY CLUSTERED (
		[DataDate] ASC,
		[Cusip] ASC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
