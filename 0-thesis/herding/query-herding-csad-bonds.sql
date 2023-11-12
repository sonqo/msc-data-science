-- WHOLE MONTHLY
SELECT
    Date,
    Rm,
    ABS(Rm) AS AbsoluteRm,
    POWER(Rm, 2) AS SquaredRm,
    Sum / Count AS Csad
FROM (
    SELECT
        Date,
        Rm,
        ABS(SUM(RetEom) - Rm) AS Sum,
        COUNT(DISTINCT Cusip) AS Count
    FROM (
        SELECT
            A.TrdExctnDtEOM AS Date,
            A.CusipId AS Cusip,
            A.R AS RetEom,
            B.Rm
        FROM
            BondReturnsCustomer A
        INNER JOIN (
            SELECT
                TrdExctnDtEOM AS Date,
                SUM(R * TD_volume) / SUM(TD_volume) AS Rm
            FROM
                BondReturnsCustomer
            GROUP BY
                TrdExctnDtEOM
        ) B ON A.TrdExctnDtEOM = B.Date
    ) A
    GROUP BY
        Date,
        Rm
) B
WHERE
	Rm IS NOT NULL
ORDER BY
    Date

-- WHOLE QUARTERLY
SELECT
    Date,
    Rm,
    ABS(Rm) AS AbsoluteRm,
    POWER(Rm, 2) AS SquaredRm,
    Sum / Count AS Csad
FROM (	
	SELECT
		Date,
		Rm,
		ABS(SUM(RetEom) - Rm) AS Sum,
		COUNT(DISTINCT Cusip) AS Count
	FROM (	
		SELECT
			A.*,
			B.Rm
		FROM (
			SELECT
				Date,
				Cusip,
				EXP(SUM(LOG(RetEom))) - 1 AS RetEom
			FROM (
				SELECT
					A.TrdExctnDtEOM,
					CASE 
						WHEN DATEPART(QUARTER, TrdExctnDtEOM) = 1 THEN DATEFROMPARTS(YEAR(TrdExctnDtEOM), 01, 01)
						WHEN DATEPART(QUARTER, TrdExctnDtEOM) = 2 THEN DATEFROMPARTS(YEAR(TrdExctnDtEOM), 04, 01)
						WHEN DATEPART(QUARTER, TrdExctnDtEOM) = 3 THEN DATEFROMPARTS(YEAR(TrdExctnDtEOM), 07, 01)
						WHEN DATEPART(QUARTER, TrdExctnDtEOM) = 4 THEN DATEFROMPARTS(YEAR(TrdExctnDtEOM), 10, 01)
					END AS Date,
					A.CusipId AS Cusip,
					A.R + 1 AS RetEom
				FROM
					BondReturnsCustomer A
			) A
			GROUP BY
				A.Date,
				A.Cusip
		) A
		INNER JOIN (
			SELECT
				Date,
				EXP(SUM(LOG(Rm))) - 1 AS Rm
			FROM (
				SELECT
					TrdExctnDtEOM,
					CASE 
						WHEN DATEPART(QUARTER, TrdExctnDtEOM) = 1 THEN DATEFROMPARTS(YEAR(TrdExctnDtEOM), 01, 01)
						WHEN DATEPART(QUARTER, TrdExctnDtEOM) = 2 THEN DATEFROMPARTS(YEAR(TrdExctnDtEOM), 04, 01)
						WHEN DATEPART(QUARTER, TrdExctnDtEOM) = 3 THEN DATEFROMPARTS(YEAR(TrdExctnDtEOM), 07, 01)
						WHEN DATEPART(QUARTER, TrdExctnDtEOM) = 4 THEN DATEFROMPARTS(YEAR(TrdExctnDtEOM), 10, 01)
					END AS Date,
					SUM(R * TD_volume) / SUM(TD_volume) + 1 AS Rm
				FROM
					BondReturnsCustomer
				GROUP BY
					TrdExctnDtEOM
			) A
			GROUP BY
				Date
		) B ON A.Date = B.Date
	) A
	GROUP BY
		Date,
		Rm
) B
WHERE
	Rm IS NOT NULL
ORDER BY
    Date

-- INSTITUTIONAL
SELECT
    Date,
    Rm,
    ABS(Rm) AS AbsoluteRm,
    POWER(Rm, 2) AS SquaredRm,
    Sum / Count AS Csad
FROM (
    SELECT
        Date,
        Rm,
        ABS(SUM(RetEom) - Rm) AS Sum,
        COUNT(DISTINCT Cusip) AS Count
    FROM (
        SELECT
            A.TrdExctnDtEOM AS Date,
            A.CusipId AS Cusip,
            A.R AS RetEom,
            B.Rm
        FROM
            BondReturnsCustomer_institutional A
        INNER JOIN (
            SELECT
                TrdExctnDtEOM AS Date,
                SUM(R * TD_volume) / SUM(TD_volume) AS Rm
            FROM
                BondReturnsCustomer_institutional
            GROUP BY
                TrdExctnDtEOM
        ) B ON A.TrdExctnDtEOM = B.Date
    ) A
    GROUP BY
        Date,
        Rm
) B
WHERE
	Rm IS NOT NULL
ORDER BY
    Date

-- RETAIL
SELECT
    Date,
    Rm,
    ABS(Rm) AS AbsoluteRm,
    POWER(Rm, 2) AS SquaredRm,
    Sum / Count AS Csad
FROM (
    SELECT
        Date,
        Rm,
        ABS(SUM(RetEom) - Rm) AS Sum,
        COUNT(DISTINCT Cusip) AS Count
    FROM (
        SELECT
            A.TrdExctnDtEOM AS Date,
            A.CusipId AS Cusip,
            A.R AS RetEom,
            B.Rm
        FROM
            BondReturnsCustomer_retail A
        INNER JOIN (
            SELECT
                TrdExctnDtEOM AS Date,
                SUM(R * TD_volume) / SUM(TD_volume) AS Rm
            FROM
                BondReturnsCustomer_retail
            GROUP BY
                TrdExctnDtEOM
        ) B ON A.TrdExctnDtEOM = B.Date
    ) A
    GROUP BY
        Date,
        Rm
) B
WHERE
	Rm IS NOT NULL
ORDER BY
    Date
