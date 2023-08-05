DROP TABLE IF EXISTS TraceBond_filtered;

SELECT
	A.CusipId,
	A.TrdExctnDt,
	A.TrdExctnMn,
	A.TrdExctnYr,
	A.EntrdVolQt,
	A.RptdPr,
	A.RptSideCd,
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
	TraceBond_filtered
FROM 
	Trace A
INNER JOIN
	BondIssues B ON A.CusipId = B.CompleteCusip
INNER JOIN 
	BondIssuers C ON B.IssuerId = C.IssuerId
WHERE
	A.CntraMpId = 'C' 
	AND A.TrdExctnDtInd <> 0
	AND C.IndustryGroup <> 4
	AND C.CountryDomicile = 'USA'
	AND A.TrdExctnDt <= B.Maturity
	AND B.OfferingDate < B.Maturity
	AND C.IndustryCode NOT IN (40, 41, 42, 43, 44, 45)
