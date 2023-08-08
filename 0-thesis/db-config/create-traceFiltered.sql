DROP TABLE IF EXISTS [dbo].[TraceBond_filtered];

SELECT
	A.CusipId,
	A.TrdExctnDt,
	A.TrdExctnMn,
	A.TrdExctnYr,
	A.EntrdVolQt,
	A.RptdPr,
	A.RptSideCd,
	A.BuyCmsnRt,
	A.SellCmsnRt,
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
	[dbo].[TraceBond_filtered]
FROM 
	Trace A
INNER JOIN
	BondIssues B ON A.CusipId = B.CompleteCusip
INNER JOIN 
	BondIssuers C ON B.IssuerId = C.IssuerId
WHERE
	A.CntraMpId = 'C' -- customer
	AND A.TrdExctnDtInd <> 0 -- last trade of the month (if in last 5-days)
	AND C.IndustryGroup <> 4 -- governemt
	AND C.CountryDomicile = 'USA' 
	AND A.TrdExctnDt <= B.Maturity
	AND B.OfferingDate < B.Maturity
	AND C.IndustryCode NOT IN (40, 41, 42, 43, 44, 45)
