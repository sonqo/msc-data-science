DROP TABLE IF EXISTS [dbo].[crsp_BondLink]

CREATE TABLE [dbo].[crsp_BondLink](
	[Cusip] [nvarchar](10) NOT NULL,
	[PermNo] [nvarchar](10) NOT NULL,
	[PermCo] [nvarchar](10) NOT NULL,
	[TraceStartDate] [date] NOT NULL,
	[TraceEndDate] [date] NOT NULL,
	[CrspStartDate] [date] NOT NULL,
	[CrspEndDate] [date] NOT NULL,
	[LinkStartDate] [date] NOT NULL,
	[LinkEndDate] [date] NOT NULL
) ON [PRIMARY]
