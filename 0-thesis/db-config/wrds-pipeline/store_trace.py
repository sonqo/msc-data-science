# The following code creates multiple .csv files for Trace per year

import os
import sqlite3
import warnings
import numpy as np
import pandas as pd
from tqdm import tqdm
from dotenv import load_dotenv
from sqlalchemy import create_engine

from functions.clean_enhanced_trace import *

load_dotenv()
warnings.simplefilter(action='ignore', category=FutureWarning)

start_year = 2002
end_year = 2024

# wrds connection
connection_string = (
  'postgresql+psycopg2://'
  f'{os.getenv('WRDS_USER')}:{os.getenv('WRDS_PASSWORD')}'
  '@wrds-pgdata.wharton.upenn.edu:9737/wrds'
)
wrds = create_engine(connection_string, pool_pre_ping=True)

# local sql-lite connection
tidy_finance = sqlite3.connect(database='data/local_findb.sqlite')
fisd = pd.read_sql('SELECT CusipId FROM fisd_BondIssue', con=tidy_finance)

# read trace in batches
cusips = list(fisd['CusipId'].unique())
batch_size = 1000
batches = np.ceil(len(cusips) / batch_size).astype(int)

# reading loop
for year in tqdm(range(start_year, end_year+1), desc='Years', unit='year', ncols=100):
    acc = []
    start_date = "'01/01/{}'".format(year)
    end_date = "'12/31/{}'".format(year)
    for j in tqdm(range(1, batches + 1), desc='Data Batches', unit='batch', ncols=100):
        cusip_batch = cusips[
            ((j - 1) * batch_size) : (min(j * batch_size, len(cusips)))
        ]
        cusip_batch_formatted = ', '.join(f"'{cusip}'" for cusip in cusip_batch)
        cusip_string = f'({cusip_batch_formatted})'
        trace_enhanced_sub = clean_enhanced_trace(
            cusips = cusip_string,
            connection = wrds,
            start_date = start_date,
            end_date = end_date,
        )
        trace_enhanced_sub['TrdExctnDt'] = pd.to_datetime(trace_enhanced_sub['TrdExctnDt']).dt.date
        if not trace_enhanced_sub.empty:
            acc.append(trace_enhanced_sub)

    # store year in .csv format
    final_df = pd.concat(acc, ignore_index=True)
    final_df.to_csv('data/trace_enhanced_{}.csv'.format(year), index=False)
