BULK INSERT  
	[dbo].[Trace]
FROM 
	'trace/trace_enhanced-2002.csv'
WITH (
	DATA_SOURCE = 'dataset_trace',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0x0a',
	BATCHSIZE=250000,
	TABLOCK 
)
