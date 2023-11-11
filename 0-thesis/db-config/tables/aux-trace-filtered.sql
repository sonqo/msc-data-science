DROP TABLE IF EXISTS [dbo].[TraceFiltered];

SELECT
	A.CusipId,
	A.TrdExctnDt,
	A.TrdExctnTm,
	A.TrdExctnMn,
	A.TrdExctnYr,
	A.EntrdVolQt,
	A.RptdPr,
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
INTO
	[dbo].[TraceFiltered]
FROM 
	Trace A
INNER JOIN
	BondIssues B ON A.CusipId = B.CompleteCusip
INNER JOIN 
	BondIssuers C ON B.IssuerId = C.IssuerId
WHERE
	C.IndustryGroup <> 4 -- government
	AND C.CountryDomicile = 'USA' 
	AND A.TrdExctnDt <= B.Maturity
	AND B.OfferingDate < B.Maturity
	AND RptdPr >= 10 AND RptdPr <= 500
	AND C.IndustryCode NOT IN (40, 41, 42, 43, 44, 45) -- government
