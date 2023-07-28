DROP TABLE IF EXISTS [dbo].[CrspcFactors]

CREATE TABLE [dbo].[CrspcFactors](
	[Date] [date] NOT NULL,
	[MktRf] [float] NULL,
	[Smb] [float] NULL,
	[Hml] [float] NULL,
	[Rmw] [float] NULL,
	[Cma] [float] NULL,
	[Rf] [float] NULL,
	[Rm] [float] NULL,
	CONSTRAINT [PK_CrspcFactors] PRIMARY KEY CLUSTERED (
		[Date] ASC
	) WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
