-- MASTER KEY
CREATE MASTER KEY ENCRYPTION BY PASSWORD='bl0bstoragE_pas5word';

-- MERGENT BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstorageacc.blob.core.windows.net//wrds]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2025-04-18T20:19:23Z&se=2025-04-19T04:19:23Z&spr=https&sv=2024-11-04&sr=c&sig=gc9U4faRY9FnZhDbg1i2csFZuaidZmXZpSMrjTjiiNw%3D'
CREATE EXTERNAL DATA SOURCE dataset_wrds
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstorageacc.blob.core.windows.net',
    CREDENTIAL = [https://findbstorageacc.blob.core.windows.net//wrds]
)

-- TRACE BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstorageacc.blob.core.windows.net//trace]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-09-04T08:11:28Z&se=2023-09-04T16:11:28Z&spr=https&sv=2022-11-02&sr=c&sig=NNMEaD38%2FWoa8xGwj2rmE5sKkxNBJKm%2BrFsLtFliGlg%3D'
CREATE EXTERNAL DATA SOURCE dataset_trace
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstorageacc.blob.core.windows.net',
    CREDENTIAL = [https://findbstorageacc.blob.core.windows.net//trace]
)

-- CRSPC BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstorageacc.blob.core.windows.net//crsp]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2025-04-20T10:11:32Z&se=2025-04-20T18:11:32Z&spr=https&sv=2024-11-04&sr=c&sig=PyaOS6Uy16AahKKlri0kSPjCw0adnCTVfajEa2gzr4w%3D'
CREATE EXTERNAL DATA SOURCE dataset_crsp
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstorageacc.blob.core.windows.net',
    CREDENTIAL = [https://findbstorageacc.blob.core.windows.net//crsp]
)
