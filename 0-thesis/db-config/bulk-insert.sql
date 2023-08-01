BULK INSERT  
	[dbo].[BondIssues]
FROM 
	'bondissues/bond_issues_v3.csv'
WITH (
	DATA_SOURCE = 'dataset_bondissues',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0x0a',
	BATCHSIZE=250000,
	TABLOCK 
)
