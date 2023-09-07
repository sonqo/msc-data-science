DROP TABLE IF EXISTS [dbo].[CrspcBondLink]

CREATE TABLE [dbo].[CrspcBondLink](
	[Cusip] [nvarchar](10) NOT NULL,
	[PermNo] [nvarchar](10) NOT NULL,
	[PermCo] [nvarchar](10) NOT NULL,
	[TraceStartDate] [date] NOT NULL,
	[TraceEndDate] [date] NOT NULL,
	[CrspcStartDate] [date] NOT NULL,
	[CrspcEndDate] [date] NOT NULL,
	[LinkStartDate] [date] NOT NULL,
	[LinkEndDate] [date] NOT NULL
) ON [PRIMARY]
GO
