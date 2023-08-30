SELECT
    RatingGroup,
    MaturityBand,
    Ntile,
    AVG(RetEom) AS PortfolioReturn
FROM (    
    SELECT
        *,
        NTILE(10) OVER (PARTITION BY RatingGroup, MaturityBand ORDER BY RetEom) AS Ntile
    FROM (   
        SELECT
            Cusip,
            CASE
                WHEN RatingNum IN (1, 2, 3) THEN 1
                WHEN RatingNum IN (4, 5, 6, 7) THEN 2
                WHEN RatingNum IN (8, 9, 10) THEN 3
                WHEN RatingNum IN (11, 12, 13, 14, 15) THEN 4
                ELSE 5
            END AS RatingGroup,
            CASE 
                WHEN ABS(DATEDIFF(DAY, Maturity, OfferingDate)) * 1.0 / 360 < 5 THEN 1
                WHEN ABS(DATEDIFF(DAY, Maturity, OfferingDate)) * 1.0 / 360 < 15 THEN 2
                ELSE 3
            END AS MaturityBand,
            RetEom / 100 AS RetEom
        FROM
            BondReturns
        WHERE
            RetEom IS NOT NULL
            AND RatingNum IS NOT NULL
    ) A
) B
GROUP BY
    RatingGroup, MaturityBand, Ntile
ORDER BY
    RatingGroup, MaturityBand, Ntile