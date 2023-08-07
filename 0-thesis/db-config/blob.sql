-- MASTER KEY
CREATE MASTER KEY ENCRYPTION BY PASSWORD='bl0bstoragE_pas5word';

-- BOND ISSUES BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findstacc.blob.core.windows.net/bondissues]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-08-07T04:50:38Z&se=2023-08-07T12:50:38Z&spr=https&sv=2022-11-02&sr=c&sig=uFWod50ka%2FmMReCd2WyOk3vjda7KoXxkoGjkZi6TPds%3D'
CREATE EXTERNAL DATA SOURCE dataset_bondissues
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findstacc.blob.core.windows.net',
    CREDENTIAL = [https://findstacc.blob.core.windows.net/bondissues]
)

-- BOND ISSUERS BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findstacc.blob.core.windows.net/bondissuers]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-08-07T04:50:23Z&se=2023-08-07T12:50:23Z&spr=https&sv=2022-11-02&sr=c&sig=ZQCOVp4YLppml1m%2FDm%2FnzctSkZzSdL82s88vj8AfZjw%3D'
CREATE EXTERNAL DATA SOURCE dataset_bondissuers
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findstacc.blob.core.windows.net',
    CREDENTIAL = [https://findstacc.blob.core.windows.net/bondissuers]
)

-- BOND RATINGS BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findstacc.blob.core.windows.net/bondratings]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-08-07T04:50:52Z&se=2023-08-07T12:50:52Z&spr=https&sv=2022-11-02&sr=c&sig=Cwk%2Ft78f%2BS6T%2FgHofvsOKUr8oaVb4SimaAgkiSF088g%3D'
CREATE EXTERNAL DATA SOURCE dataset_bondratings
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findstacc.blob.core.windows.net',
    CREDENTIAL = [https://findstacc.blob.core.windows.net/bondratings]
)

-- TRACE BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findstacc.blob.core.windows.net/trace]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-08-07T04:51:19Z&se=2023-08-07T12:51:19Z&spr=https&sv=2022-11-02&sr=c&sig=upMsRUO58IpOyZCXd7G0E4T3J%2FP6EVcLj9NasCbCPPI%3D'
CREATE EXTERNAL DATA SOURCE dataset_trace
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findstacc.blob.core.windows.net',
    CREDENTIAL = [https://findstacc.blob.core.windows.net/trace]
)

-- CRSPC BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findstacc.blob.core.windows.net/crspc]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-08-07T04:51:06Z&se=2023-08-07T12:51:06Z&spr=https&sv=2022-11-02&sr=c&sig=VJpvjFoVb0hhQs67yucwUnvSoaPX4oXuEwk5W5eVBnU%3D'
CREATE EXTERNAL DATA SOURCE dataset_crspc
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findstacc.blob.core.windows.net',
    CREDENTIAL = [https://findstacc.blob.core.windows.net/crspc]
)
