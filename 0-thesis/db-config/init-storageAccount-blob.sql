-- MASTER KEY
CREATE MASTER KEY ENCRYPTION BY PASSWORD='bl0bstoragE_pas5word';

-- MERGENT BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstorageaccount.blob.core.windows.net//mergent]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-08-16T11:41:27Z&se=2023-08-16T19:41:27Z&spr=https&sv=2022-11-02&sr=c&sig=orMZuHSgCOyEgJXoTpfdrxdHZ6U7YsAgRtC9%2BwT0KRo%3D'
CREATE EXTERNAL DATA SOURCE dataset_mergent
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstorageaccount.blob.core.windows.net',
    CREDENTIAL = [https://findbstorageaccount.blob.core.windows.net//mergent]
)

-- CRSPC BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstorageaccount.blob.core.windows.net//crsp]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-09-30T11:27:00Z&se=2023-09-30T19:27:00Z&spr=https&sv=2022-11-02&sr=c&sig=EpuEzgxrf4Zcofi9lWTN1PDAk2%2FWP0BQXVFI4f9GM4w%3D'
CREATE EXTERNAL DATA SOURCE dataset_crsp
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstorageaccount.blob.core.windows.net',
    CREDENTIAL = [https://findbstorageaccount.blob.core.windows.net//crsp]
)

-- TRACE BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstorageaccount.blob.core.windows.net//trace]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-09-04T08:11:28Z&se=2023-09-04T16:11:28Z&spr=https&sv=2022-11-02&sr=c&sig=NNMEaD38%2FWoa8xGwj2rmE5sKkxNBJKm%2BrFsLtFliGlg%3D'
CREATE EXTERNAL DATA SOURCE dataset_trace
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstorageaccount.blob.core.windows.net',
    CREDENTIAL = [https://findbstorageaccount.blob.core.windows.net//trace]
)
