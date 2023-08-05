-- MASTER KEY
CREATE MASTER KEY ENCRYPTION BY PASSWORD='bl0bstoragE_pas5word';

-- BOND ISSUES BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstorageaccount.blob.core.windows.net/bondissues]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-08-01T10:32:26Z&se=2023-08-01T18:32:26Z&spr=https&sv=2022-11-02&sr=c&sig=finkVWqt1dVgXcgP8K8FsjUITtMSkjmvx4I8BCiVREM%3D'
CREATE EXTERNAL DATA SOURCE dataset_bondissues
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstorageaccount.blob.core.windows.net',
    CREDENTIAL = [https://findbstorageaccount.blob.core.windows.net/bondissues]
)

-- BOND ISSUERS BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstorageaccount.blob.core.windows.net/bondissuers]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-07-16T09:00:43Z&se=2023-07-16T17:00:43Z&spr=https&sv=2022-11-02&sr=c&sig=KFztJGEL3jWZ%2FdM0f0VBYsxyLr5Q9ZUMq6ayvaXEgrU%3D'
CREATE EXTERNAL DATA SOURCE dataset_bondissuers
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstorageaccount.blob.core.windows.net',
    CREDENTIAL = [https://findbstorageaccount.blob.core.windows.net/bondissuers]
)

-- BOND RATINGS BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstorageaccount.blob.core.windows.net/bondratings]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-07-26T20:46:59Z&se=2023-07-27T04:46:59Z&spr=https&sv=2022-11-02&sr=c&sig=Vu46tRrph7de6cXvYlwSX%2Ft2%2BDz%2FJX1rWZpiwPTVI3U%3D'
CREATE EXTERNAL DATA SOURCE dataset_bondratings
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstorageaccount.blob.core.windows.net',
    CREDENTIAL = [https://findbstorageaccount.blob.core.windows.net/bondratings]
)

-- TRACE BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstorageaccount.blob.core.windows.net/trace]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-07-17T05:44:33Z&se=2023-07-17T13:44:33Z&spr=https&sv=2022-11-02&sr=c&sig=2kDBzp5iqBExqeVp%2FBlzKLWQmLsrvAthbYwcuEDY36Q%3D'
CREATE EXTERNAL DATA SOURCE dataset_trace
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstorageaccount.blob.core.windows.net',
    CREDENTIAL = [https://findbstorageaccount.blob.core.windows.net/trace]
)

-- CRSPC BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstorageaccount.blob.core.windows.net/crspc]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-08-05T09:08:18Z&se=2023-08-05T17:08:18Z&spr=https&sv=2022-11-02&sr=c&sig=zD3pqFhD7FtDcqWYYTJLBtzZci7JgeaUXMXfs9CSh%2FY%3D'
CREATE EXTERNAL DATA SOURCE dataset_crspc
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstorageaccount.blob.core.windows.net',
    CREDENTIAL = [https://findbstorageaccount.blob.core.windows.net/crspc]
)
