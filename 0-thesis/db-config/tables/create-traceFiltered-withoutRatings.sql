DROP TABLE IF EXISTS [dbo].[Trace_filtered_withoutRatings];

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
	[dbo].[Trace_filtered_withoutRatings]
FROM 
	Trace A
INNER JOIN
	BondIssues B ON A.CusipId = B.CompleteCusip
INNER JOIN 
	BondIssuers C ON B.IssuerId = C.IssuerId
WHERE
	C.IndustryGroup <> 4 -- governemt
	AND C.CountryDomicile = 'USA' 
	AND A.TrdExctnDt <= B.Maturity
	AND B.OfferingDate < B.Maturity
	AND C.IndustryCode NOT IN (40, 41, 42, 43, 44, 45) -- goverment
