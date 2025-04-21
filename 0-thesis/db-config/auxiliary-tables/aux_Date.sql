DROP TABLE IF EXISTS [dbo].[Date]

CREATE TABLE [dbo].[Date] (
    [MonthDate] Date NOT NULL,
	[MonthDateEOM] Date NOT NULL
    CONSTRAINT [PK_Date] PRIMARY KEY CLUSTERED (
		[MonthDate] ASC
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
)
 
DECLARE @StartDate DATE
DECLARE @EndDate DATE

SET @StartDate = '2002-01-01'
SET @EndDate = '2023-12-31'

WHILE @StartDate <= @EndDate
    BEGIN
        INSERT INTO [dbo].[Date] VALUES (
            @StartDate,
			EOMONTH(@StartDate)
        )
        SET @StartDate = DATEADD(MONTH, 1, @StartDate)
    END
