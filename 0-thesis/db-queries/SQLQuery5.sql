SELECT
    MaturityBand,
    COUNT(DISTINCT Cusip) AS DistinctCusips
FROM (
    SELECT
        Cusip,
        CASE 
            WHEN ABS(DATEDIFF(DAY, A.Maturity, A.OfferingDate)) * 1.0 / 360 < 5 THEN 1
            WHEN ABS(DATEDIFF(DAY, A.Maturity, A.OfferingDate)) * 1.0 / 360 < 15 THEN 2
            ELSE 3
        END AS MaturityBand
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
) A
GROUP BY
    MaturityBand
ORDER BY
    MaturityBand
