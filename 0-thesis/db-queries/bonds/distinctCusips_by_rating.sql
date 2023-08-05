SELECT
    TrdExctnDt,
    MinimumRating,
    COUNT(DISTINCT CusipId) AS DistinctCusips
FROM (
    SELECT
        A.CusipId,
        A.TrdExctnDt,
        MIN(B.RatingCategory) AS MinimumRating
    FROM (
        SELECT
            A.CusipId, 
            A.TrdExctnDt, 
            MAX(B.RatingDate) AS MaxRatingDate
        FROM 
            TraceBond_filtered A
        LEFT JOIN 
            BondRatings B ON A.CusipId = B.CompleteCusip 
			AND B.RatingDate <= A.TrdExctnDt 
			AND B.RatingCategory IS NOT NULL
        WHERE
            A.TrdExctnDt >= '2002-01-1' AND A.TrdExctnDt < '2023-01-01'
        GROUP BY
            A.CusipId,
            A.TrdExctnDt
    ) A
    INNER JOIN 
        BondRatings B ON B.CompleteCusip = A.CusipId AND RatingDate = MaxRatingDate
    GROUP BY
        A.CusipId,
        A.TrdExctnDt
) B
GROUP BY
    TrdExctnDt,
    MinimumRating
ORDER BY
    TrdExctnDt,
    MinimumRating