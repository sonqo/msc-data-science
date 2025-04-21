DROP TABLE IF EXISTS [dbo].[fisd_BondIssuer]

CREATE TABLE [dbo].[fisd_BondIssuer](
	[IssuerId] [int] NOT NULL,
	[AgentId] [int] NULL,
	[CusipName] [nvarchar](100) NULL,
	[IndustryGroup] [int] NULL,
	[IndustryCode] [int] NULL,
	[Esop] [nvarchar](1) NULL,
	[InBankruptcy] [nvarchar](1) NULL,
	[ParentId] [int] NULL,
	[NaicsCode] [int] NULL,
	[CountryDomicile] [nvarchar](3) NULL,
	[LegalName] [nvarchar](250) NULL,
	[Addr1] [nvarchar](100) NULL,
	[Addr2] [nvarchar](100) NULL,
	[City] [nvarchar](100) NULL,
	[State] [nvarchar](2) NULL,
	[Zipcode] [nvarchar](100) NULL,
	[Province] [nvarchar](100) NULL,
	[Country] [nvarchar](3) NULL,
	[MainPhone] [nvarchar](100) NULL,
	[MainFax] [nvarchar](100) NULL,
	[Note] [nvarchar](500) NULL,
	[SicCode] [int] NULL,
	CONSTRAINT [PK_fisd_BondIssuer] PRIMARY KEY CLUSTERED (
		[IssuerId] ASC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
