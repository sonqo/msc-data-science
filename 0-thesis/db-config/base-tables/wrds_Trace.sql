DROP TABLE IF EXISTS [dbo].[wrds_Trace]

CREATE TABLE [dbo].[wrds_Trace](
	[CusipId] [nvarchar](10) NULL,
	[BondSymId] [nvarchar](50) NULL,
	[CompanySymbol] [nvarchar](10) NULL,
	[TrdExctnDt] [date] NULL,
	[TrdExctnTm] [time](7) NULL,
	[TrdRptDt] [date] NULL,
	[TrdRptTm] [time](7) NULL,
	[MsgSeqNb] [int] NULL,
	[TrcSt] [nvarchar](1) NULL,
	[ScrtyTypeCd] [nvarchar](50) NULL,
	[WisFl] [nvarchar](1) NULL,
	[CmsnTrd] [nvarchar](1) NULL,
	[EntrdVolQt] [decimal] NULL,
	[RptdPr] [float] NULL,
	[YldSignCd] [nvarchar](1) NULL,
	[YldPt] [float] NULL,
	[DaysToSttlCt] [decimal] NULL,
	[SaleCndtnCd] [nvarchar](1) NULL,
	[SaleCndtn2Cd] [nvarchar](1) NULL,
	[RptSideCd] [nvarchar](1) NULL,
	[BuyCmsnRt] [float] NULL,
	[BuyCpctyCd] [nvarchar](1) NULL,
	[SellCmsnRt] [float] NULL,
	[SellCpctyCd] [nvarchar](1) NULL,
	[CntraMpId] [nvarchar](1) NULL,
	[AguQsrId] [nvarchar](10) NULL,
	[TrdgMktCd] [nvarchar](10) NULL,
	[DissemFl] [nvarchar](1) NULL,
	[OrigMsgSeqNb] [decimal] NULL,
	[BloombergIdentifier] [nvarchar](50) NULL,
	[SubPrdct] [nvarchar](10) NULL,
	[StlmntDt] [date] NULL,
	[TrdMod3] [nvarchar](1) NULL,
	[TrdMod4] [nvarchar](1) NULL,
	[RptgPartyType] [nvarchar](1) NULL,
	[LckdInInd] [nvarchar](1) NULL,
	[AtsIndicator] [nvarchar](1) NULL,
	[PrTrdDt] [date] NULL,
	[FirstTradeCtrlDate] [date] NULL,
	[FirstTradeCtrlNum] [decimal] NULL,
	[Agency] [nvarchar](5) NULL
) ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [IX_wrds_Trace] ON 
	dbo.[wrds_Trace] (
			[TrdExctnDt], [CusipId]
	);
