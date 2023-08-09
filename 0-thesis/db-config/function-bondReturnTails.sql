CREATE FUNCTION [dbo].[leftTailBondReturns]()
RETURNS FLOAT
AS
BEGIN
    DECLARE @ret FLOAT
    SELECT @ret = PERCENTILE_CONT(0.05) WITHIN GROUP(ORDER BY Rm) OVER () FROM (
		SELECT
			SUM(RetEom / 100 * TDvolume) / SUM(TDvolume) AS Rm
		FROM
			BondReturns
		GROUP BY
			Date
	) A;
    RETURN @ret
END;

GO

CREATE FUNCTION [dbo].[rightTailBondReturns]()
RETURNS FLOAT
AS
BEGIN
    DECLARE @ret FLOAT
    SELECT @ret = PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY Rm) OVER () FROM (
		SELECT
			SUM(RetEom / 100 * TDvolume) / SUM(TDvolume) AS Rm
		FROM
			BondReturns
		GROUP BY
			Date
	) A;
    RETURN @ret
END
