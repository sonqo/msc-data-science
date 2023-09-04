SELECT
	IssueId,
	CusipId,
	MIN(TrdExctnDt) RangeStart,
	MAX(TrdExctnDt) RangeEnd,
	COUNT(DISTINCT TrdExctnDt) AS GCount
FROM (
    SELECT
        *,
		DATEADD(MONTH, -ROW_NUMBER() OVER (PARTITION BY CusipId ORDER BY TrdExctnDt), TrdExctnDt) AS Grn
    FROM (
        SELECT
            IssuerId,
            CusipId,
            DATEFROMPARTS(
				YEAR(MAX(TrdExctnDt)),
				MONTH(MAX(TrdExctnDt)),
				1
			) AS TrdExctnDt,
            SUM(EntrdVolQt) AS SumVolume
        FROM
            Trace_filtered_withRatings
        GROUP BY
            IssuerId,
            CusipId,
            MONTH(TrdExctnDt),
            YEAR(TrdExctnDt)
    ) A
) B
GROUP BY
	IssueId,
	CusipId,
	Grn
ORDER BY
	MIN(TrdExctnDt)

