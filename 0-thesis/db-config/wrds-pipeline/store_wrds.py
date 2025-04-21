# The following code creates a single .csv files for wrds_BondReturn

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

# local sql-lite connection
tidy_finance = sqlite3.connect(database='data/local_findb.sqlite')

# azure connection
azure = create_engine(
    'mssql://{}:{}@{}/{}?driver=ODBC+Driver+18+for+SQL+Server'.format(
        os.getenv('DB_USER'), os.getenv('DB_PASSWORD'), os.getenv('DB_SERVER'), os.getenv('DB_NAME')
    )
)

# getfisd-bonds
fisd_issue = pd.read_sql('SELECT * FROM fisd_BondIssue', azure)

# bond returns
wrds_rating_query = '''
    SELECT
        cusip AS "CusipId",
        date AS "Date",
        ncoups AS "NumCoupons",
        CASE WHEN rating_num IS NULL THEN 0 ELSE rating_num END AS "RatingNum",
        rating_cat AS "RatingCat",
        t_date AS "TDate",
        t_volume AS "TVolume",
        t_dvolume AS "TDVolume",
        t_spread AS "TSpread",
        yield AS "Yield",
        price_eom AS "PriceEOM",
        price_l5m AS "PriceL5M",
        price_ldm AS "PriceLDM",
        principal_amt AS "PrincipalAmt",
        gap AS "Gap",
        coupmonth AS "CoupMonth",
        nextcoup AS "NextCoup",
        coupamt AS "CoupAmt",
        coupacc AS "CoupAcc",
        multicoups AS "MultiCoups",
        ret_eom AS "RetEOM",
        ret_l5m AS "RetL5M",
        ret_ldm AS "RetLDM",
        remcoups AS "RemCoups",
        duration AS "Duration",
        defaulted AS "Defaulted",
        default_date AS "DefaultDate",
        reinstated AS "Reinstated",
        reinstated_date AS "ReinstatedDate"
    FROM 
        wrdsapps_bondret.bondret
    WHERE
        date >= '{}-01-01'
        AND date <= '{}-12-31'
'''.format(start_year, end_year)

# read wrds-returns query
wrds_return = pd.read_sql_query(
    sql=wrds_rating_query,
    con=wrds,
    dtype={
        'NumCoupons': int,
        'RatingNum': int,
        'TVolume': float,
        'TDVolume': float,
        'TSpread': float,
        'Yield': float,
        'PriceEOM': float,
        'PriceL5M': float,
        'PriceLDM': float,
        'Gap': float,
        'CoupMonth': float,
        'CoupAmt': float,
        'CoupAcc': float,
        'MultiCoups': int,
        'RetEOM': float,
        'RetL5M': float,
        'RetLDM': float,
        'RemCoups': float,
        'Duration': float
    },
    parse_dates=[
        'Date',
        'TDate',
        'NextCoup',
        'DefaultDate',
        'ReinstatedDate'
    ]
)
print('Executed wrds-returns query ✓')

# filter through bonds and get CusipId
wrds_return = wrds_return.merge(
    fisd_issue[['CusipId']],
    on='CusipId',
    how='inner'
)

date_columns = [
    'Date',
    'TDate',
    'NextCoup',
    'DefaultDate',
    'ReinstatedDate',
]
for col in date_columns:
    wrds_return[col] = pd.to_datetime(wrds_return[col]).dt.date

# save returns csv
wrds_return.drop_duplicates()
wrds_return.to_csv('data/wrds_BondReturns.csv', index=False)
print('Stored BondReturn ✓')
