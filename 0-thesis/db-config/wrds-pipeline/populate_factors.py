# The following code populates Azure (or local SQL-Lite) with ff_MarketFactors

import os
import sqlite3
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

load_dotenv()

start_year = 2002
end_year = 2024

# wrds connection
connection_string = (
    'postgresql+psycopg2://{}:{}@wrds-pgdata.wharton.upenn.edu:9737/wrds'.format(
        os.getenv('WRDS_USER'),
        os.getenv('WRDS_PASSWORD'),
    )
)
wrds = create_engine(connection_string, pool_pre_ping=True)
print('Connected to Wrds ✓')

# local sql-lite connection
tidy_finance = sqlite3.connect(database='data/local_findb.sqlite')
print('Connected to local SQL-Lite ✓')

# azure connection
azure = create_engine(
    'mssql://{}:{}@{}/{}?driver=ODBC+Driver+18+for+SQL+Server'.format(
        os.getenv('DB_USER'), os.getenv('DB_PASSWORD'), os.getenv('DB_SERVER'), os.getenv('DB_NAME')
    )
)
print('Connected to Azure ✓')

# issue centered fisd filtering
ff_factors_query = '''
    SELECT
        date AS "Date",
        smb AS "Smb",
        hml AS "Hml",
        rmw AS "Rmw",
        cma AS "Cma",
        umd AS "Umd",
        rf AS "Rf",
        mktrf AS "MktRf"
    FROM 
        ff_all.fivefactors_monthly
    WHERE
        date >= '{}-01-01'
        AND date <= '{}-12-31'
'''.format(start_year, end_year)

# read fisd-issue query
ff_factors = pd.read_sql_query(
    sql=ff_factors_query,
    con=wrds,
    dtype={
        'Smb': float,
        'Hml': float,
        'Rmw': float,
        'Cma': float,
        'Umd': float,
        'Rf': float,
        'MktRf': float,
    },
    parse_dates=[
        'Date'
    ]
)
print('Executed ff-factors query ✓')

# transform datetime columns
ff_factors['Date'] = pd.to_datetime(ff_factors['Date']).dt.date

# save factors
ff_factors = ff_factors.drop_duplicates()
ff_factors.to_sql(
    name='ff_MarketFactors',
    con=azure,
    if_exists='replace',
    index=False
)
print('Populated MarketFactor ✓')
