DROP TABLE IF EXISTS [dbo].[BondReturns_volumeGroups]

-- - 100.000
-- 100.000 500.000
-- 500.000 1.000.000
-- 1.000.000 - 5.000.000
-- 5.000.000 + 

-- INSERT INTO 
-- 	[dbo].[BondReturns_volumeGroups]

SELECT
	*
INTO
	[dbo].[BondReturns_volumeGroups]
FROM (
	SELECT
		*,
		( EndPrice  - StartPrice + CouponsPaid * ( Coupon * D / InterestFrequency / 360 ) ) / StartPrice AS R,
		ABS(
			DATEDIFF(
				MONTH,
				TrdExctnDt,
				LAG(TrdExctnDt) OVER (PARTITION BY CusipId ORDER BY TrdExctnDt)
			)
		) AS MonthGap
	FROM (	
		SELECT
			A.CusipId,
			EOMONTH(A.TrdExctnDt) AS TrdExctnDt,
			A.RptdPr AS StartPrice,
			B.RptdPr AS EndPrice,
			A.EntrdVolQt,
			A.Coupon,
			A.PrincipalAmt,
			A.InterestFrequency,
			CASE
				WHEN NextInterestDate >= A.TrdExctnDt AND NextInterestDate < B.TrdExctnDt THEN 1
				ELSE 0
			END AS CouponsPaid,
			CASE
				WHEN InterestFrequency = 0 THEN NULL
				ELSE
					CASE
						WHEN NextInterestDate >= A.TrdExctnDt AND NextInterestDate < B.TrdExctnDt THEN dbo.YearFact(A.NextInterestDate, B.TrdExctnDt, 0 )
						ELSE 0
					END 
			END AS D
		FROM (
			SELECT
				*,
				CASE 
					WHEN InterestFrequency = 0 THEN NULL
					ELSE
						CASE
							WHEN TrdExctnDt < FirstInterestDate THEN FirstInterestDate
							ELSE 
								DATEADD( 
									MONTH,
									360 / InterestFrequency / 30,
									DATEADD( 
										MONTH,
										( ABS ( dbo.YearFact(TrdExctnDt, FirstInterestDate, 0 ) ) ) / ( 360 / InterestFrequency ) * (360 / InterestFrequency / 30),
										FirstInterestDate
									)
								)
						END 
				END AS NextInterestDate
			FROM (
				SELECT
					B.CusipId,
					B.TrdExctnDt,
					CONCAT(MONTH(B.TrdExctnDt), '-', YEAR(B.TrdExctnDt)) AS MontYearId,
					AVG(B.RptdPr) AS RptdPr,
					MAX(B.EntrdVolQt) AS EntrdVolQt,
					MAX(B.Coupon) AS Coupon,
					MAX(B.PrincipalAmt) AS PrincipalAmt,
					CASE
						WHEN MAX(B.InterestFrequency) IS NOT NULL THEN MAX(B.InterestFrequency)
						ELSE 2
					END AS InterestFrequency,
					CASE
						WHEN MAX(B.FirstInterestDate) IS NOT NULL THEN MAX(B.FirstInterestDate)
						ELSE MAX(B.OfferingDate)
					END AS FirstInterestDate
				FROM (
					SELECT
						CusipId,
						MIN(TrdExctnDt) AS TrdExctnDt,
						MAX(EntrdVolQt) AS EntrdVolQt
					FROM
						Trace_filtered_withRatings
					WHERE
						RatingNum <> 0
						AND EntrdVolQt = 5000000
						AND TrdExctnDt >= DATEFROMPARTS(YEAR(TrdExctnDt), MONTH(TrdExctnDt), 1) AND TrdExctnDt <= DATEFROMPARTS(YEAR(TrdExctnDt), MONTH(TrdExctnDt), 5)
					GROUP BY
						CusipId,
						MONTH(TrdExctnDt),
						YEAR(TrdExctnDt)
				) A
				INNER JOIN 
					Trace_filtered_withRatings B ON A.CusipId = B.CusipId AND A.TrdExctnDt = B.TrdExctnDt AND A.EntrdVolQt = B.EntrdVolQt
				GROUP BY
					B.CusipId,
					B.TrdExctnDt
			) A
		) A
		INNER JOIN (
			SELECT
				B.CusipId,
				B.TrdExctnDt,
				CONCAT(MONTH(B.TrdExctnDt), '-', YEAR(B.TrdExctnDt)) AS MontYearId,
				AVG(B.RptdPr) AS RptdPr,
				MAX(B.EntrdVolQt) AS EntrdVolQt
			FROM (
				SELECT
					CusipId,
					MIN(TrdExctnDt) AS TrdExctnDt,
					MAX(EntrdVolQt) AS EntrdVolQt
				FROM
					Trace_filtered_withRatings
				WHERE
					RatingNum <> 0
					AND EntrdVolQt = 5000000
					AND TrdExctnDt <= EOMONTH(TrdExctnDt) AND TrdExctnDt >= DATEADD(DAY, -5, EOMONTH(TrdExctnDt))
				GROUP BY
					CusipId,
					MONTH(TrdExctnDt),
					YEAR(TrdExctnDt)
			) A
			INNER JOIN 
				Trace_filtered_withRatings B ON A.CusipId = B.CusipId AND A.TrdExctnDt = B.TrdExctnDt AND A.EntrdVolQt = B.EntrdVolQt
			GROUP BY
				B.CusipId,
				B.TrdExctnDt
		) B ON A.CusipId = B.CusipId AND A.MontYearId = B.MontYearId
	) A
) A
ORDER BY
	TrdExctnDt
