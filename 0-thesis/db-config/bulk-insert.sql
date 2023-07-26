BULK INSERT  
	[dbo].[BondIssues]
FROM 
	'bondissues/bond_issues.csv'
WITH (
	DATA_SOURCE = 'dataset_bondissues',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	BATCHSIZE=250000,
	TABLOCK 
)
