SELECT
	*
FROM
	BondReturns A
INNER JOIN
	Trace_filtered_withRatings B ON A.Cusip = B.CusipId AND B.RatingNum <> 0
WHERE
	RatingClass IN ('0.IG', '1.HY')
