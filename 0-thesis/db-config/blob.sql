-- MASTER KEY
CREATE MASTER KEY ENCRYPTION BY PASSWORD='bl0bstoragE_pas5word';

-- BOND ISSUES BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstorageacc.blob.core.windows.net/bondissues]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-07-26T20:46:43Z&se=2023-07-27T04:46:43Z&spr=https&sv=2022-11-02&sr=c&sig=b1xchhioxFpY%2FlZysvpyHZsLpFrWzDztk%2Bp33OP2rmc%3D'
CREATE EXTERNAL DATA SOURCE dataset_bondissues
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstorageacc.blob.core.windows.net',
    CREDENTIAL = [https://findbstorageacc.blob.core.windows.net/bondissues]
)

-- BOND ISSUERS BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstorageacc.blob.core.windows.net/bondissuers]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-07-16T09:00:43Z&se=2023-07-16T17:00:43Z&spr=https&sv=2022-11-02&sr=c&sig=KFztJGEL3jWZ%2FdM0f0VBYsxyLr5Q9ZUMq6ayvaXEgrU%3D'
CREATE EXTERNAL DATA SOURCE dataset_bondissuers
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstorageacc.blob.core.windows.net',
    CREDENTIAL = [https://findbstorageacc.blob.core.windows.net/bondissuers]
)

-- BOND RATINGS BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstorageacc.blob.core.windows.net/bondratings]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-07-26T20:46:59Z&se=2023-07-27T04:46:59Z&spr=https&sv=2022-11-02&sr=c&sig=Vu46tRrph7de6cXvYlwSX%2Ft2%2BDz%2FJX1rWZpiwPTVI3U%3D'
CREATE EXTERNAL DATA SOURCE dataset_bondratings
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstorageacc.blob.core.windows.net',
    CREDENTIAL = [https://findbstorageacc.blob.core.windows.net/bondratings]
)

-- TRACE BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstorageacc.blob.core.windows.net/trace]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-07-17T05:44:33Z&se=2023-07-17T13:44:33Z&spr=https&sv=2022-11-02&sr=c&sig=2kDBzp5iqBExqeVp%2FBlzKLWQmLsrvAthbYwcuEDY36Q%3D'
CREATE EXTERNAL DATA SOURCE dataset_trace
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstorageacc.blob.core.windows.net',
    CREDENTIAL = [https://findbstorageacc.blob.core.windows.net/trace]
)

-- CRSPC BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstorageacc.blob.core.windows.net/crspc]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-07-21T14:03:03Z&se=2023-07-21T22:03:03Z&spr=https&sv=2022-11-02&sr=c&sig=IM%2FUvRU0K2IPPGyniBRUiBSbupd4lPahLDs94%2FHB8kc%3D'
CREATE EXTERNAL DATA SOURCE dataset_crspc
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstorageacc.blob.core.windows.net',
    CREDENTIAL = [https://findbstorageacc.blob.core.windows.net/crspc]
)