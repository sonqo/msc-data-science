DROP TABLE IF EXISTS [dbo].[BondIssues]

CREATE TABLE [dbo].[BondIssues](
	[CompleteCusip] [nvarchar](10) NOT NULL,
	[Maturity] [date] NULL,
	[OfferingAmt] [decimal] NULL,
	[OfferingDate] [date] NULL,
	[OfferingPrice] [decimal] NULL,
	[OfferingYield] [decimal] NULL,
	[ActionAmount] [decimal] NULL,
	[ActionPrice] [decimal] NULL,
	[AmountOutstanding] [decimal] NULL,
	[InterestFrequency] [int] NULL,
	[Coupon] [decimal] NULL,
	[IssueId] [int] NULL,
	[IssuerId] [int] NULL,
	[IssueCusip] [nvarchar](10) NULL,
	[IssuerCusip] [nvarchar](10) NULL,
	CONSTRAINT [PK_BondIssues] PRIMARY KEY CLUSTERED (
		[CompleteCusip] ASC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
