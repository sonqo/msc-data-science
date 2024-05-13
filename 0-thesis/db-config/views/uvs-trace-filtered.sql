ALTER TABLE [dbo].[Trace] ADD [RptdPr_prcs] DECIMAL;
UPDATE [dbo].[Trace] SET [RptdPr_prcs] = Cast([RptdPr] AS DECIMAL);

CREATE VIEW 
    [dbo].[uvs_TraceFiltered]
WITH SCHEMABINDING
AS
SELECT
	A.CusipId,
	A.TrdExctnDt,
	A.TrdExctnTm,
	A.EntrdVolQt,
	A.RptdPr_prcs,
	A.RptSideCd,
	A.BuyCmsnRt,
	A.SellCmsnRt,
	A.CntraMpId,
	B.InterestFrequency,
	B.Coupon,
	B.OfferingDate,
	B.DeliveryDate,
	B.FirstInterestDate,
	B.LastInterestDate,
	B.EffectiveDate,
	B.Maturity,
	C.IssuerId,
	C.IndustryCode,
	C.IndustryGroup
FROM 
	[dbo].[Trace] A
INNER JOIN
	[dbo].[BondIssues] B ON A.CusipId = B.CompleteCusip
INNER JOIN 
	[dbo].[BondIssuers] C ON B.IssuerId = C.IssuerId
WHERE
	C.IndustryGroup <> 4 -- government
	AND C.CountryDomicile = 'USA' 
	AND A.TrdExctnDt <= B.Maturity
	AND B.OfferingDate < B.Maturity
	AND RptdPr_prcs >= 10 AND RptdPr_prcs <= 500
	AND C.IndustryCode NOT IN (40, 41, 42, 43, 44, 45) -- government

CREATE UNIQUE CLUSTERED INDEX [IX_TraceFiltered]
   ON [dbo].[uvs_Trace-filtered] (TrdExctnDt, CusipId);
GO
