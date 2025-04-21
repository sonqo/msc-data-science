DROP TABLE IF EXISTS [dbo].[fisd_BondIssue]

CREATE TABLE [dbo].[fisd_BondIssue](
	[CusipId] [nvarchar](10) NOT NULL,
	[OfferingAmt] [decimal] NULL,
	[OfferingPrice] [float] NULL,
	[OfferingYield] [float] NULL,
	[ActionAmount] [float] NULL,
	[ActionPrice] [float] NULL,
	[AmountOutstanding] [float] NULL,
	[InterestFrequency] [int] NULL,
	[Coupon] [float] NULL,
	[IssueId] [int] NULL,
	[IssuerId] [int] NULL,
	[IssueCusip] [nvarchar](10) NULL,
	[IssuerCusip] [nvarchar](10) NULL,	
	[DeliveryDate] [date] NULL,
	[OfferingDate] [date] NULL,
	[DatedDate] [date] NULL,
	[LastInterestDate] [date] NULL,
	[FirstInterestDate] [date] NULL,
	[EffectiveDate] [date] NULL,
	[Maturity] [date] NULL,
	CONSTRAINT [PK_fisd_BondIssue] PRIMARY KEY CLUSTERED (
		[CompleteCusip] ASC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
