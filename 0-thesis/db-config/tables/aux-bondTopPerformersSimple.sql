
SELECT
	B.CusipId,
	B.TrdExctnDt,
	B.RptdPr * B.EntrdVolQt AS PriceVolumeProduct,
	B.EntrdVolQt,
	B.Coupon,
	B.PrincipalAmt,
	B.InterestFrequency,
	B.RatingNum,
	B.Maturity,
	B.FirstInterestDate,
	B.OfferingDate
FROM (
	-- Calculate top bonds per issuer in terms of the WHOLE month
	SELECT
		*,
		DENSE_RANK() OVER (PARTITION BY IssuerId, TrdExctnDt ORDER BY Volume DESC) AS VolumeRanking
	FROM (
		SELECT
			IssuerId,
			CusipId,
			MAX(TrdExctnDt) AS TrdExctnDt,
			EOMONTH(TrdExctnDt) AS TrdExctnDtEOM,
			SUM(EntrdVolQt) AS Volume
		FROM
			Trace_filtered_withRatings 
		WHERE
			RatingNum <> 0
			AND EntrdVolQt >= 500000 -- institunional
		GROUP BY
			IssuerId,
			CusipId,
			EOMONTH(TrdExctnDt)
	) A
) A
INNER JOIN
	Trace_filtered_withRatings B ON A.CusipId = B.CusipId AND A.TrdExctnDt = B.TrdExctnDt
WHERE
	A.VolumeRanking <= 3
