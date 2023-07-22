DROP TABLE IF EXISTS [dbo].[CrspcSecuritiesDaily]

CREATE TABLE [dbo].[CrspcSecuritiesDaily](
	[LPermNo] [int] NULL,
	[LPermCo] [int] NULL,
	[DataDate] [date] NOT NULL,
	[Tic] [nvarchar](10) NULL,
	[Cusip] [nvarchar](10) NOT NULL,
	[CoNm] [nvarchar](50) NULL,
	[Div] [decimal] NULL,
	[CurCdd] [nvarchar](3) NULL,
	[Cshoc] [decimal] NULL,
	[CshTrd] [decimal] NULL,
	[Eps] [decimal] NULL,
	[EpsMo] [decimal] NULL,
	[PrcCd] [decimal] NULL,
	[PrcHd] [decimal] NULL,
	[PrcLd] [decimal] NULL,
	[PrcOd] [decimal] NULL,
	[PrcStd] [decimal] NULL,
	[TrFd] [decimal] NULL,
	[Exchg] [int] NULL,
	[SecStat] [nvarchar](1) NULL,
	[Loc] [nvarchar](3) NULL,
	[Naics] [decimal] NULL,
	[Sic] [decimal] NULL,
	[IpoDate] [date] NULL,
	CONSTRAINT [PK_CrspcSecuritiesDaily] PRIMARY KEY CLUSTERED (
		[DataDate] ASC,
		[Cusip] ASC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
