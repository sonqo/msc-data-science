-- MASTER KEY
CREATE MASTER KEY ENCRYPTION BY PASSWORD='bl0bstoragE_pas5word';

-- BOND ISSUERS BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstore.blob.core.windows.net/bond-issuers]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-08-16T11:41:27Z&se=2023-08-16T19:41:27Z&spr=https&sv=2022-11-02&sr=c&sig=orMZuHSgCOyEgJXoTpfdrxdHZ6U7YsAgRtC9%2BwT0KRo%3D'
CREATE EXTERNAL DATA SOURCE dataset_bond_issuers
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstore.blob.core.windows.net',
    CREDENTIAL = [https://findbstore.blob.core.windows.net/bond-issuers]
)

-- BOND ISSUES BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstore.blob.core.windows.net/bond-issues]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-08-16T11:43:12Z&se=2023-08-16T19:43:12Z&spr=https&sv=2022-11-02&sr=c&sig=oXHAMNKoYwUbV6KV9vkxDt03To%2BwM1gi0AAgP%2BxraYE%3D'
CREATE EXTERNAL DATA SOURCE dataset_bond_issues
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstore.blob.core.windows.net',
    CREDENTIAL = [https://findbstore.blob.core.windows.net/bond-issues]
)

-- BOND RATINGS BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstore.blob.core.windows.net/bond-ratings]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-08-16T22:37:31Z&se=2023-08-17T06:37:31Z&spr=https&sv=2022-11-02&sr=c&sig=WnUodot04pIWMoFY0UonZbRN4eq6icvlBSbkbAluXw8%3D'
CREATE EXTERNAL DATA SOURCE dataset_bond_ratings
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstore.blob.core.windows.net',
    CREDENTIAL = [https://findbstore.blob.core.windows.net/bond-ratings]
)

-- BOND RETURNS BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstore.blob.core.windows.net/bond-returns]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-08-16T11:44:32Z&se=2023-08-16T19:44:32Z&spr=https&sv=2022-11-02&sr=c&sig=MZtN8RdL8HpEVYyxb5TNlqYJCILoV31PdtRSQE95tgs%3D'
CREATE EXTERNAL DATA SOURCE dataset_bond_returns
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstore.blob.core.windows.net',
    CREDENTIAL = [https://findbstore.blob.core.windows.net/bond-returns]
)

-- CRSPC BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstore.blob.core.windows.net/crspc]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-08-16T11:50:09Z&se=2023-08-16T19:50:09Z&spr=https&sv=2022-11-02&sr=c&sig=orUhlAsNPz0waIJAonK%2BqIEwrijDzKkcGNrbz8VDZYo%3D'
CREATE EXTERNAL DATA SOURCE dataset_crspc
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstore.blob.core.windows.net',
    CREDENTIAL = [https://findbstore.blob.core.windows.net/crspc]
)

-- TRACE BLOB
CREATE DATABASE SCOPED CREDENTIAL [https://findbstore.blob.core.windows.net/trace]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2023-08-16T12:14:19Z&se=2023-08-16T20:14:19Z&spr=https&sv=2022-11-02&sr=c&sig=TsTRP0ihafQZEh9v6F05tuBAx1RB0XzjURgfGwWLxs8%3D'
CREATE EXTERNAL DATA SOURCE dataset_trace
WITH 
(
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://findbstore.blob.core.windows.net',
    CREDENTIAL = [https://findbstore.blob.core.windows.net/trace]
)
