-- MASTER KEY
CREATE MASTER KEY ENCRYPTION BY PASSWORD='bl0bstoragE_pas5word';

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

-- BOND ISSUES BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findstacc.blob.core.windows.net/bondissues]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-08-08T16:22:20Z&se=2023-08-09T00:22:20Z&spr=https&sv=2022-11-02&sr=c&sig=jFnlVPH6BIuK%2BUbvs49wSZT05dkxtpOys%2BK9%2FvGa2TU%3D'
CREATE EXTERNAL DATA SOURCE dataset_bondissues
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findstacc.blob.core.windows.net',
    CREDENTIAL = [https://findstacc.blob.core.windows.net/bondissues]
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

-- BOND RETURNS BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findstacc.blob.core.windows.net/bondreturns]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-08-08T10:50:16Z&se=2023-08-08T18:50:16Z&spr=https&sv=2022-11-02&sr=c&sig=0h9X3LuqhCZQlGwvft%2FuKlNrpkW3it%2F1HxHvoeMYaWs%3D'
CREATE EXTERNAL DATA SOURCE dataset_bondreturns
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findstacc.blob.core.windows.net',
    CREDENTIAL = [https://findstacc.blob.core.windows.net/bondreturns]
)

-- CRSPC BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findstacc.blob.core.windows.net/crspc]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-08-08T16:28:01Z&se=2023-08-09T00:28:01Z&spr=https&sv=2022-11-02&sr=c&sig=NXPKSweoIKxYT29bXDg65vr1DZwIWO1C%2FiuiDYOE7wI%3D'
CREATE EXTERNAL DATA SOURCE dataset_crspc
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findstacc.blob.core.windows.net',
    CREDENTIAL = [https://findstacc.blob.core.windows.net/crspc]
)

-- TRACE BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findstacc.blob.core.windows.net/trace]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-08-08T20:19:26Z&se=2023-08-09T04:19:26Z&spr=https&sv=2022-11-02&sr=c&sig=Y85VVDSyqSjczmiHhra6kRzv6QzSDmlpqbVPU0OJuz4%3D'
CREATE EXTERNAL DATA SOURCE dataset_trace
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findstacc.blob.core.windows.net',
    CREDENTIAL = [https://findstacc.blob.core.windows.net/trace]
)
