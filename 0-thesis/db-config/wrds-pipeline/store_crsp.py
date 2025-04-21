import os
import sqlite3
import pandas as pd
from tqdm import tqdm
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

# azure connection
azure = create_engine(
    'mssql://{}:{}@{}/{}?driver=ODBC+Driver+18+for+SQL+Server'.format(
        os.getenv('DB_USER'), os.getenv('DB_PASSWORD'), os.getenv('DB_SERVER'), os.getenv('DB_NAME')
    )
)
print('Connected to Azure ✓')

# bond-link
bond_link_query = '''
    SELECT 
        cusip AS "CusipId",
        permno AS "PermNo",
        permco AS "PermCo",
        trace_startdt AS "TraceStartDt",
        trace_enddt AS "TraceEndDt",
        crsp_startdt AS "CrspStartDt",
        crsp_enddt AS "CrspEndDt",
        link_startdt AS "LinkStartDt",
        link_enddt AS "LinkEndDt" 
    FROM
        wrdsapps.bondcrsp_link
'''

# read bond-link query
bond_link = pd.read_sql_query(
    sql=bond_link_query,
    con=wrds,
    dtype={
        'CusipId': str,
        'PermNo': int,
        'PermCo': int
    },
    parse_dates=[
        'TraceStartDt',
        'TraceEndDt',
        'CrspStartDt',
        'CrspEndDt',
        'LinkStartDt',
        'LinkEndDt'
    ]
)
print('Executed bond-link query ✓')

# transform datetime columns
date_columns = [
    'TraceStartDt',
    'TraceEndDt',
    'CrspStartDt',
    'CrspEndDt',
    'LinkStartDt',
    'LinkEndDt'
]
for col in date_columns:
    bond_link[col] = pd.to_datetime(bond_link[col]).dt.date

# save link
bond_link = bond_link.drop_duplicates()
bond_link.to_csv('data/crsp_BondLink.csv', index=False)
print('Stored BondLink ✓')

# securities daily query
securities_query = '''
    SELECT 
        dlycaldt AS "Date",
        cusip9 AS "Cusip",
        ticker AS "Ticker",
        permno AS "PermNo",
        permco AS "PermCo",
        dlyopen AS "Open",
        dlyclose AS "Close",
        dlyhigh AS "High",
        dlylow AS "Low",
        dlyprc AS "Price",
        dlyvol AS "Volume",
        dlyprcvol AS "PriceVlm",
        dlyret AS "TotalRet",
        dlyretx AS "PriceRet",
        dlycap AS "Cap",
        dlynumtrd AS "NumTrades",
        dlyfacprc AS "FactorPrc",
        disdivamt AS "DistrDividendAmt",
        disfacpr AS "DistrFactorPrc",
        disfacshr AS "DistrFactorShr",
        disfreqtype AS "DistrFreqType",
        dispaydt AS "DistrPaymentDt",
        dlycumfacpr AS "CumFactorPrc",
        dlycumfacshr AS "CumFactorShr",
        primaryexch AS "PrimaryExch"
    FROM 
        crsp.wrds_dsfv2_query 
    WHERE
        dlycaldt >= '{}-01-01'
        AND dlycaldt <= '{}-12-31'
'''

dtype_dict = {
    'Cusip': str,
    'Ticker': str,
    'PermNo': int,
    'PermCo': int,
    'Open': float,
    'Close': float,
    'High': float,
    'Low': float,
    'Price': float,
    'Volume': float,
    'PriceVlm': float,
    'TotalRet': float,
    'PriceRet': float,
    'Cap': float,
    'NumTrades': float,
    'FactorPrc': float,
    'DistrDividendAmt': float,
    'DistrFactorPrc': float,
    'DistrFactorShr': float,
    'DistrFreqType': str,
    'CumFactorPrc': float,
    'CumFactorShr': float,
    'PrimaryExch': str
}

# securities loop
for curr_year in tqdm(range(start_year, end_year+1), desc='Years', unit='year', ncols=100):
    # read
    securities = pd.read_sql_query(
        sql=securities_query.format(curr_year, curr_year),
        con=wrds,
        dtype=dtype_dict,
        parse_dates=[
            'Date',
            'DistrPaymentDt'
        ]
    )
    # transform datetime columns
    date_columns = [
        'Date',
        'DistrPaymentDt'
    ]
    for col in date_columns:
        securities[col] = pd.to_datetime(securities[col]).dt.date
    # save link
    securities = securities.drop_duplicates()
    securities.to_csv('data/crsp/crsp_SecuritiesDaily_{}.csv'.format(curr_year), index=False)
