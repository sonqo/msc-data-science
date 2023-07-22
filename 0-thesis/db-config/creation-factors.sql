DROP TABLE IF EXISTS [dbo].[CrspcFactors]

CREATE TABLE [dbo].[CrspcFactors](
	[Date] [date] NOT NULL,
	[MktRf] [decimal] NULL,
	[Smb] [decimal] NULL,
	[Hml] [decimal] NULL,
	[Rmw] [decimal] NULL,
	[Cma] [decimal] NULL,
	[Rf] [decimal] NULL,
	[Rm] [decimal] NULL,
	CONSTRAINT [PK_CrspcFactors] PRIMARY KEY CLUSTERED (
		[Date] ASC
	) WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
