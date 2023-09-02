BULK INSERT  
	[dbo].[CrspcSecuritiesDaily]
FROM 
	'crspc/CRSPC_12-2002.csv'
WITH (
	DATA_SOURCE = 'dataset_crspc',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0x0a',
	BATCHSIZE=250000,
	TABLOCK 
)
