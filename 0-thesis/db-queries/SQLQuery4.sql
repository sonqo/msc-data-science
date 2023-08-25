SELECT 
    Date,
    COUNT(DISTINCT Cusip) AS DistinctCusips,
    SUM(TDvolume) AS TotalVolume
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
    AND Date >= '{}-01-1' AND Date < '{}-01-01'
    AND C.IndustryCode NOT IN (40, 41, 42, 43, 44, 45)
	AND RatingNum <> 0
GROUP BY
    Date
ORDER BY
    Date
