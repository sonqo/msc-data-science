DROP TABLE IF EXISTS [dbo].[ff_MarketFactors]

CREATE TABLE [dbo].[ff_MarketFactors](
	[Date] [date] NOT NULL,
	[Smb] [float] NULL,
	[Hml] [float] NULL,
	[Rmw] [float] NULL,
	[Cma] [float] NULL,
	[Umd] [float] NULL,
	[Rf] [float] NULL,
	[MktRf] [float] NULL
	CONSTRAINT [PK_ff_MarketFactors] PRIMARY KEY CLUSTERED (
		[Date] ASC
	) WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
