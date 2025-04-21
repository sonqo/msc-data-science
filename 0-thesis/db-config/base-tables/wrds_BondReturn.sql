DROP TABLE IF EXISTS [dbo].[wrds_BondReturn]

CREATE TABLE [dbo].[wrds_BondReturn](
    [CusipId] [nvarchar](10) NOT NULL,
	[Date] [date] NOT NULL,
    [NumCoupons] [int] NULL,
    [RatingNum] [float] NULL,
    [RatingCat] [nvarchar](10) NULL,
    [TDate] [date] NULL,
    [TVolume] [float] NULL,
    [TDvolume] [float] NULL,
    [TSpread] [float] NULL, -- percent
    [Yield] [float] NULL, -- percent
    [PriceEOM] [float] NULL,
    [PriceL5M] [float] NULL,
    [PriceLDM] [float] NULL,
    [PrincipalAmt] [float] NULL,
    [Gap] [float] NULL,
    [CoupMonth] [float] NULL,
    [NextCoup] [date] NULL,
    [CoupAmt] [float] NULL,
    [CoupAcc] [float] NULL,
    [MultiCoups] [int] NULL,
    [RetEOM] [float] NULL,
    [RetL5M] [float] NULL,
    [RetLDM] [float] NULL,
    [RemCoups] [float] NULL,
    [Duration] [float] NULL,
    [Defaulted] [nvarchar](1) NULL,
    [DefaultDate] [date] NULL,
    [Reinstated] [nvarchar](1) NULL,
    [ReinstatedDate] [date] NULL
	CONSTRAINT [PK_wrds_BondReturn] PRIMARY KEY CLUSTERED (
		[Date] ASC,
        [CusipId] ASC
	) WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
