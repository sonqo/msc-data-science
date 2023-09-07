-- PUBLIC
SELECT
	A.
FROM 
	BondReturns_fromTrace_last5DaysMonth A
INNER JOIN
	CrspcBondLink B ON A.CusipId = B.Cusip

-- PUBLIC
SELECT
	A.*
FROM 
	BondReturns_fromTrace_last5DaysMonth A
LEFT JOIN
	CrspcBondLink B ON A.CusipId = B.Cusip
WHERE
	PermNo IS NULL
