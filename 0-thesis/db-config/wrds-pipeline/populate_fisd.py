# https://www.tidy-finance.org/python/trace-and-fisd.html
# The following code populates Azure (or local SQL-Lite) with fisd_BondIssue, fisd_BondIssuer, fisd_BondRating

import os
import sqlite3
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

load_dotenv()

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
fisd_issue_query = '''
    SELECT
        complete_cusip AS "CusipId",
        issue_id AS "IssueId",
        issuer_id AS "IssuerId",
        dated_date AS "DatedDate",
        offering_date AS "OfferingDate",
        offering_amt AS "OfferingAmt",
        offering_price AS "OfferingPrice",
        offering_yield AS "OfferingYield",
        action_amount AS "ActionAmount",
        action_price AS "ActionPrice",
        principal_amt AS "PrincipalAmount",
        coupon AS "Coupon",
        interest_frequency AS "InterestFrequency", 
        maturity AS "Maturity",
        amount_outstanding AS "AmountOutstanding",
        first_interest_date AS "FirstInterestDate",
        last_interest_date AS "LastInterestDate",
        delivery_date AS "DeliveryDate",
        effective_date AS "EffectiveDate"
    FROM 
        fisd.fisd_mergedissue
    WHERE 
        security_level = 'SEN' 
        AND (slob = 'N' OR slob IS NULL) 
        AND security_pledge IS NULL               
        AND (asset_backed = 'N' OR asset_backed IS NULL) 
        AND (defeased = 'N' OR defeased IS NULL) 
        AND defeased_date IS NULL 
        AND bond_type IN ('CDEB', 'CMTN', 'CMTZ', 'CZ', 'USBN') 
        AND (pay_in_kind != 'Y' OR pay_in_kind IS NULL) 
        AND pay_in_kind_exp_date IS NULL 
        AND (yankee = 'N' OR yankee IS NULL) 
        AND (canadian = 'N' OR canadian IS NULL) 
        AND foreign_currency = 'N' 
        AND coupon_type IN ('F', 'Z') 
        AND fix_frequency IS NULL 
        AND coupon_change_indicator = 'N' 
        AND interest_frequency IN ('0', '1', '2', '4', '12') 
        AND rule_144a = 'N' 
        AND (private_placement = 'N' OR private_placement IS NULL) 
        AND defaulted = 'N' 
        AND filing_date IS NULL 
        AND settlement IS NULL 
        AND convertible = 'N' 
        AND exchange IS NULL 
        AND (putable = 'N' OR putable IS NULL) 
        AND (unit_deal = 'N' OR unit_deal IS NULL) 
        AND (exchangeable = 'N' OR exchangeable IS NULL) 
        AND perpetual = 'N' 
        AND (preferred_security = 'N' OR preferred_security IS NULL)
'''

# read fisd-issue query
fisd_issue = pd.read_sql_query(
    sql=fisd_issue_query,
    con=wrds,
    dtype={
        'CusipId': str,
        'IssueId': int,
        'IssuerId': int,
        'OfferingAmt': float,
        'OfferingYield': float,
        'ActionAmount': float,
        'ActionPrice': float,
        'Coupon': float,
        'InterestFrequency': int,
        'AmountOutstanding': float
    },
    parse_dates=[
        'DatedDate',
        'OfferingDate',
        'Maturity',
        'FirstInterestDate',
        'LastInterestDate',
        'DeliveryDate',
        'EffectiveDate'
    ]
)
print('Executed fisd-issues query ✓')

# transform datetime columns
date_columns = [
    'DatedDate',
    'OfferingDate',
    'Maturity',
    'FirstInterestDate',
    'LastInterestDate',
    'DeliveryDate',
    'EffectiveDate'
]
for col in date_columns:
    fisd_issue[col] = pd.to_datetime(fisd_issue[col]).dt.date

# issuer info
fisd_issuer_query = '''
    SELECT
        issuer_id AS "IssuerId",
        agent_id AS "AgentId",
        parent_id AS "ParentId",
        cusip_name AS "CusipName",
        CASE WHEN industry_group IS NULL THEN '0' ELSE industry_group END AS "IndustryGroup",
        industry_code AS "IndustryCode",
        country AS "Country",
        country_domicile AS "CountryDomicile",
        in_bankruptcy AS "InBankruptcy",
        esop AS "Esop",
        sic_code AS "SicCode",
        naics_code AS "NaicsCode"
    FROM
        fisd.fisd_mergedissuer
    WHERE
        country_domicile = 'USA'
'''

# read fisd-issuer query
fisd_issuer = pd.read_sql_query(
    sql=fisd_issuer_query,
    con=wrds,
    dtype={
        'IssuerId': int,
        'AgentId': int,
        'ParentId': float,
        'IndustryGroup': int,
        'IndustryCode': int,
        'SicCode': float,
        'NaicsCode': float,
    }
)
print('Executed fisd-issuers query ✓')

# filter bonds through issuers
fisd_issue= fisd_issue.merge(
    fisd_issuer[['IssuerId']],
    on='IssuerId',
    how='inner',
)

# save bonds
fisd_issue = fisd_issue.drop_duplicates()
fisd_issue.to_sql(
    name='fisd_BondIssue',
    con=azure,
    if_exists='replace',
    index=False
)
print('Populated BondIssue ✓')

# filter issuers through bonds
fisd_issuer = fisd_issuer.merge(
    fisd_issue[['IssuerId']],
    on='IssuerId',
    how='inner',
)

# save issuers
fisd_issuer = fisd_issuer.drop_duplicates()
fisd_issuer.to_sql(
    name='fisd_BondIssuer',
    con=azure,
    if_exists='replace',
    index=False
)
print('Populated BondIssuer ✓')

# ratings
fisd_rating_query = '''
    SELECT 
        issue_id AS "IssueId",
        rating_type AS "RatingType",
        rating_date AS "RatingDate",
        rating AS "Rating",
        rating_status AS "RatingStatus",
        reason AS "Reason",
        rating_status_date AS "RatingStatusDate",
        investment_grade AS "InvestmentGrade"
    FROM
        fisd.fisd_rating
'''.format(list(fisd_issue['IssueId'].unique()))

# read fisd-rating query
fisd_rating = pd.read_sql_query(
    sql=fisd_rating_query,
    con=wrds,
    dtype={
        'IssueId': int
    },
    parse_dates=[
        'RatingDate',
        'RatingStatusDate'
    ]
)
print('Executed fisd-ratings query ✓')

# ratings classification
rating_mapping = {
    '1': ['AAA', 'Aaa'],
    '2': ['AA+', 'Aa1'],
    '3': ['AA', 'Aa2'],
    '4': ['AA-', 'Aa3'],
    '5': ['A+', 'A1'],
    '6': ['A', 'A2'],
    '7': ['A-', 'A3'],
    '8': ['BBB+', 'Baa1'],
    '9': ['BBB', 'Baa', 'Baa2'],
    '10': ['BBB-', 'Baa3'],
    '11': ['BB+', 'Ba1'],
    '12': ['BB', 'Ba2', 'Ba'],
    '13': ['BB-', 'Ba3'],
    '14': ['B+', 'B1'],
    '15': ['B', 'B2'],
    '16': ['B-', 'B3'],
    '17': ['CCC+', 'Caa1'],
    '18': ['CCC', 'Caa', 'Caa2'],
    '19': ['CCC-', 'Caa3'],
    '20': ['CC', 'Ca'],
    '21': ['C'],
    '22': ['DDD'],
    '23': ['DD'],
    '24': ['D']
}
flat_mapping = {rating: key for key, values in rating_mapping.items() for rating in values}

# transform ratings
fisd_rating['RatingNum'] = fisd_rating['Rating'].map(flat_mapping)
fisd_rating['RatingNum'] = fisd_rating['RatingNum'].fillna(0)

# filter through bonds and get CusipId
fisd_rating = fisd_rating.merge(
    fisd_issue[['CusipId', 'IssueId']],
    on='IssueId',
    how='inner'
).get([
    'CusipId',
    'RatingDate',
    'RatingNum',
    'RatingType',
    'RatingStatus',
    'RatingStatusDate'
])

# transform date
fisd_rating['RatingDate'] = pd.to_datetime(fisd_rating['RatingDate']).dt.date

# save ratings
fisd_rating = fisd_rating.drop_duplicates()
fisd_rating.to_sql(
    name='fisd_BondRating',
    con=azure,
    if_exists='replace',
    index=False
)
print('Populated BondRating ✓')
