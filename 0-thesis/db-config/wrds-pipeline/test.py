import os
import sqlite3
import pandas as pd
from tqdm import tqdm
import tidyfinance as tf
from dotenv import load_dotenv
from urllib.parse import quote_plus
from sqlalchemy import create_engine

load_dotenv()

start_year = 2002
end_year = 2024

tidy_finance = sqlite3.connect(database='data/local_findb.sqlite')

connection_string = (
    'postgresql+psycopg2://{}:{}@wrds-pgdata.wharton.upenn.edu:9737/wrds'.format(
        os.getenv('WRDS_USER'),
        os.getenv('WRDS_PASSWORD'),
    )
)
wrds = create_engine(connection_string, pool_pre_ping=True)

# get factors
factors_ff5_daily = pd.read_sql(
  sql='SELECT * FROM ff_MarketFactors', 
  con=tidy_finance,
  parse_dates={'Date'}
)

permnos = pd.read_sql(
  sql="SELECT DISTINCT permno FROM crsp.stksecurityinfohist", 
  con=wrds,
  dtype={"permno": int}
)

print(permnos)
