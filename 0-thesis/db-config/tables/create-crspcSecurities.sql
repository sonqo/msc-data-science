DROP TABLE IF EXISTS [dbo].[CrspcSecuritiesDaily]

CREATE TABLE [dbo].[CrspcSecuritiesDaily](
	[GvKey] [nvarchar](10) NULL,
	[LPermNo] [nvarchar](10) NOT NULL,
	[IId] [nvarchar](10) NOT NULL,
	[DataDate] [date] NOT NULL,
	[Tic] [nvarchar](10) NULL,
	[Cusip] [nvarchar](10) NOT NULL,
	[CoNml] [nvarchar](100) NULL,
	[PrcCd] [float] NULL,
	[PrcHd] [float] NULL,
	[PrcLd] [float] NULL,
	[PrcOd] [float] NULL,
	[PrcStd] [float] NULL,
	[Exchg] [int] NULL,
	[Exchange] [nvarchar](50) NULL,
	[Sic] [decimal] NULL,
	[Industry] [nvarchar](15) NULL,
	[Naics] [decimal] NULL,
	[Eps] [float] NULL,
	[EpsMo] [decimal] NULL,
	[TrFd] [float] NULL,
	[Loc] [nvarchar](3) NULL,
	[Div] [float] NULL,
	[Divd] [float] NULL,
	[DivdPayDateInd] [nvarchar](1) NULL,
	[Divsp] [float] NULL,
	[DivspPayDate] [date] NULL,
	[AnncDate] [date] NULL,
	[IpoDate] [date] NULL,
	CONSTRAINT [PK_CrspcSecuritiesDaily] PRIMARY KEY CLUSTERED (
		[DataDate] ASC,
		[LPermNo] ASC,
		[IId] ASC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO