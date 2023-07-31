BULK INSERT  
	[dbo].[CrspcSecuritiesDaily]
FROM 
	'crspc/securities11.csv'
WITH (
	DATA_SOURCE = 'dataset_crspc',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	BATCHSIZE=250000,
	TABLOCK 
)
