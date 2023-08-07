BULK INSERT  
	[dbo].[CrspcSecuritiesDaily]
FROM 
	'crspc/securities_daily-2002.csv'
WITH (
	DATA_SOURCE = 'dataset_crspc',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	BATCHSIZE=250000,
	TABLOCK 
)