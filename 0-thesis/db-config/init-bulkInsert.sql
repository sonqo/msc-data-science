BULK INSERT  
	[dbo].[BondReturns]
FROM 
	'bondreturns/bond_returns.csv'
WITH (
	DATA_SOURCE = 'dataset_bondreturns',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0x0a', -- 0x0a for Unix systems
	BATCHSIZE=250000,
	TABLOCK 
)
