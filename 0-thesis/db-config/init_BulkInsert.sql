-- LOOP INSERT
DECLARE @year INT = 2002;
DECLARE @sql NVARCHAR(MAX);
DECLARE @filePath NVARCHAR(255);

WHILE @year <= 2023
BEGIN
    SET @filePath = CONCAT('crsp/crsp_SecuritiesDaily_', @year, '.csv');
    SET @sql = N'
    BULK INSERT [dbo].[crsp_SecuritiesDaily]
    FROM ''' + @filePath + ''' 
    WITH (
        DATA_SOURCE = ''dataset_crsp'',
        FIRSTROW = 2,
        FIELDTERMINATOR = '','',
        ROWTERMINATOR = ''0x0a'',
        BATCHSIZE=250000,
        TABLOCK
    );';

    EXEC sp_executesql @sql;

    SET @year = @year + 1;
END;

-- SINGLE INSERT
BULK INSERT  
	[dbo].[crsp_BondLink]
FROM 
	'crsp/crsp_BondLink.csv'
WITH (
	DATA_SOURCE = 'dataset_crsp',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0x0a',
	BATCHSIZE=250000,
	TABLOCK 
)
