DROP TABLE IF EXISTS [dbo].[MarketFactors]

CREATE TABLE [dbo].[MarketFactors](
	[Date] [date] NOT NULL,
	[MktRf] [float] NULL,
	[Smb] [float] NULL,
	[Hml] [float] NULL,
	[Rmw] [float] NULL,
	[Cma] [float] NULL,
	[Rf] [float] NULL,
	[Rm] [float] NULL,
	[Mom] [float] NULL,
	CONSTRAINT [PK_MarketFactors] PRIMARY KEY CLUSTERED (
		[Date] ASC
	) WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
