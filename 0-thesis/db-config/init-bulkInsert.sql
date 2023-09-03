BULK INSERT  
	[dbo].[CrspcBondLink]
FROM 
	'crspc/bond-crspc-link.csv'
WITH (
	DATA_SOURCE = 'dataset_crspc',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0x0a',
	BATCHSIZE=250000,
	TABLOCK 
)
