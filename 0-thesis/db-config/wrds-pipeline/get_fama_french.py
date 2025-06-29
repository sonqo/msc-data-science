# https://www.tidy-finance.org/python/accessing-and-managing-financial-data.html#fama-french-data
# The following code populates local SQL-lite database with Fama-French 5 Factor Model.

import sqlite3
import pandas as pd
import pandas_datareader as pdr

start_date = '2002-01-01'
end_date = '2023-12-31'

# local sql-lite connection
tidy_finance = sqlite3.connect(database='data/local_findb.sqlite')

# read
factors_ff5_monthly_raw = pdr.DataReader(
    name='F-F_Research_Data_5_Factors_2x3_daily',
    data_source='famafrench', 
    start=start_date, 
    end=end_date
)[0]

# preprocessing
factors_ff5_monthly = (factors_ff5_monthly_raw
  .divide(100)
  .reset_index(names='date')
  .assign(date=lambda x: pd.to_datetime(x['date'].astype(str)))
  .rename(columns={
      'date': 'Date',
      'Mkt-RF': 'Mkt-Rf',
      'SMB': 'Smb',
      'HML': 'Hml',
      'RMW': 'Rmw',
      'CMA': 'Cma',
      'RF': 'Rf'
  })
)

# drop if exists
cursor = tidy_finance.cursor()
cursor.execute('DROP TABLE IF EXISTS ff_MarketFactors')
tidy_finance.commit()

# store to local sql-lite
factors_ff5_monthly.to_sql(
    name='ff_MarketFactors', 
    con=tidy_finance, 
    if_exists='replace',
    index=False
)
