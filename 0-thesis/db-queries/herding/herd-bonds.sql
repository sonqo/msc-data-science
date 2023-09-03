SELECT
	Date,
	Rm,
	ABS(Rm) AS AbsoluteRm,
    POWER(Rm, 2) AS SquaredRm,
    Sum / Count AS Csad,
	CASE 
        WHEN Rm <= [dbo].[leftTailBondReturns]() THEN 1
        ELSE 0
    END AS LeftTail,
    CASE 
        WHEN Rm >= [dbo].[rightTailBondReturns]() THEN 1
        ELSE 0
    END AS RightTail
FROM (
	SELECT
		Date,
		Rm,
		ABS(SUM(RetEom) - Rm) AS Sum,
		COUNT(DISTINCT Cusip) AS Count
	FROM (
		SELECT
			A.Date,
			A.Cusip,
			A.RetEom,
			B.Rm
		FROM
			BondReturns A
		INNER JOIN (
			-- MONTHLY RM
			SELECT
				Date,
				SUM(RetEom / 100 * TDvolume) / SUM(TDvolume) AS Rm
			FROM
				BondReturns
			WHERE
				Date >= '2002-01-01' AND Date < '2023-01-01'
			GROUP BY
				Date
		) B ON A.Date = B.Date
	) A
	GROUP BY
		Date,
		Rm
) B
ORDER BY
	Date
