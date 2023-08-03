BULK INSERT  
	[dbo].[BondRatings]
FROM 
	'bondratings/bond_ratings.csv'
WITH (
	DATA_SOURCE = 'dataset_bondratings',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	BATCHSIZE=250000,
	TABLOCK 
)
