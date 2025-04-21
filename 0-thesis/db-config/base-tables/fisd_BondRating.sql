DROP TABLE IF EXISTS [dbo].[fisd_BondRating]

CREATE TABLE [dbo].[fisd_BondRating](
	[CusipId] [nvarchar](10) NOT NULL,
	[RatingDate] [date] NOT NULL,
	[OfferingDate] [date] NULL,
	[Maturity] [date] NULL,
	[RatingType] [nvarchar](10) NOT NULL,
	[Rating] [nvarchar](10) NULL,
	[RatingStatus] [nvarchar](10) NULL,
	[Reason] [nvarchar](10) NULL,
	[RatingStatusDate] [date] NULL,
	[InvestmentGrade] [nvarchar](1) NULL,
	[RatingCategory] [int] NULL,
	CONSTRAINT [PK_fisd_BondRating] PRIMARY KEY CLUSTERED (
		[CusipId] ASC,
		[RatingDate] ASC,
		[RatingType] ASC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
