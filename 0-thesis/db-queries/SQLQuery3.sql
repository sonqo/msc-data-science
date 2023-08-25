SELECT
    IndustryCode,
    DistinctCusips,
    DistinctIssuers
FROM (
    SELECT 
        C.IndustryCode,
        COUNT(DISTINCT A.Cusip) AS DistinctCusips,
        COUNT(DISTINCT C.IssuerID) AS DistinctIssuers
    FROM
        BondReturns A
	INNER JOIN
		BondIssues B ON A.Cusip = B.CompleteCusip
	INNER JOIN 
		BondIssuers C ON B.IssuerId = C.IssuerId
	WHERE
		C.IndustryGroup <> 4 -- governemt
		AND C.CountryDomicile = 'USA' 
		AND B.OfferingDate < B.Maturity
        AND A.Date >= '{}-01-1' AND A.Date < '{}-01-01'
		AND C.IndustryCode NOT IN (40, 41, 42, 43, 44, 45)
		AND A.RatingNum <> 0
    GROUP BY
        IndustryCode 
) A
ORDER BY
    IndustryCode
