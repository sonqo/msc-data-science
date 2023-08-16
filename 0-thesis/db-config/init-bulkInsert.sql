BULK INSERT  
	[dbo].[BondRatings]
FROM 
	'bond-ratings/bond_ratings.csv'
WITH (
	DATA_SOURCE = 'dataset_bond_ratings',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0x0a',
	BATCHSIZE=250000,
	TABLOCK 
)
