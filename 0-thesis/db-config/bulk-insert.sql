BULK INSERT  
	[dbo].[CrspcSecuritiesDaily]
FROM 
	'crspc/securities03.csv'
WITH (
	DATA_SOURCE = 'dataset_crspc',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	BATCHSIZE=250000,
	TABLOCK 
)

BULK INSERT  
	[dbo].[CrspcSecuritiesDaily]
FROM 
	'crspc/securities04.csv'
WITH (
	DATA_SOURCE = 'dataset_crspc',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	BATCHSIZE=250000,
	TABLOCK 
)

BULK INSERT  
	[dbo].[CrspcSecuritiesDaily]
FROM 
	'crspc/securities05.csv'
WITH (
	DATA_SOURCE = 'dataset_crspc',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	BATCHSIZE=250000,
	TABLOCK 
)

BULK INSERT  
	[dbo].[CrspcSecuritiesDaily]
FROM 
	'crspc/securities06.csv'
WITH (
	DATA_SOURCE = 'dataset_crspc',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	BATCHSIZE=250000,
	TABLOCK 
)

BULK INSERT  
	[dbo].[CrspcSecuritiesDaily]
FROM 
	'crspc/securities07.csv'
WITH (
	DATA_SOURCE = 'dataset_crspc',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	BATCHSIZE=250000,
	TABLOCK 
)

BULK INSERT  
	[dbo].[CrspcSecuritiesDaily]
FROM 
	'crspc/securities08.csv'
WITH (
	DATA_SOURCE = 'dataset_crspc',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	BATCHSIZE=250000,
	TABLOCK 
)

BULK INSERT  
	[dbo].[CrspcSecuritiesDaily]
FROM 
	'crspc/securities09.csv'
WITH (
	DATA_SOURCE = 'dataset_crspc',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	BATCHSIZE=250000,
	TABLOCK 
)

BULK INSERT  
	[dbo].[CrspcSecuritiesDaily]
FROM 
	'crspc/securities10.csv'
WITH (
	DATA_SOURCE = 'dataset_crspc',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	BATCHSIZE=250000,
	TABLOCK 
)
