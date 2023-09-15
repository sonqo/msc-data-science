import numpy as np
import pandas as pd
from scipy import stats
import matplotlib.pyplot as plt
from pandas.tseries.offsets import *

for com in [(i, j) for i in range(1, 13) for j in range(1, 13)]:

    # read
    directory = 'source/topBonds.csv'
    df = pd.read_csv(directory, parse_dates=['TrdExctnDtEOM'])
    df = df[['CusipId', 'TrdExctnDtEOM', 'TD_Volume', 'Coupon', 'RatingClass', 'MaturityBand', 'R']]
    df.columns = ['Cusip', 'Date', 'Volume', 'Coupon', 'RatingClass', 'MaturityBand', 'R']
    df = df.sort_values(by=['Cusip', 'Date'])

    # outliers
    df['quantiles'] = pd.qcut(df.R, np.linspace(0, 1, 201), labels=np.linspace(0, 1, 200)).astype(float)
    df['outliers'] = np.where((df['quantiles'] > 0.995) | (df['quantiles'] < 0.005), 1, 0)
    df['Year'] = df['Date'].dt.year
    df_g = df.groupby('Year')['outliers'].sum().reset_index()
    df['R'] = np.where(df['outliers'] == 0, df['R'], np.nan)

    # formation period
    df['LogR'] = np.log(1 + df['R'])
    J = com[0]
    df_ = df[['Cusip', 'Date', 'R', 'LogR']].sort_values(['Cusip', 'Date']).set_index('Date')
    cumulative_r = df_.groupby(['Cusip'])['LogR'].rolling(J, min_periods=J).sum().reset_index()
    cumulative_r = cumulative_r.rename(columns = {'LogR': 'SumLogR'})
    cumulative_r['CumReturns'] = np.exp(cumulative_r['SumLogR'])-1
    r = 10 
    cumulative_r = cumulative_r.dropna(axis=0, subset=['CumReturns'])
    cumulative_r['MomentumRanking'] = cumulative_r.groupby('Date')['CumReturns'].transform(lambda x: pd.qcut(x, r, labels=False))
    cumulative_r['MomentumRanking'] = 1 + cumulative_r['MomentumRanking'].astype(int)

    # holding period
    K = com[1]
    cumulative_r['FormationDate'] = cumulative_r['Date']
    cumulative_r['HoldingDate1'], cumulative_r['HoldingDate2'] = cumulative_r['Date'] + MonthBegin(1), cumulative_r['Date'] + MonthEnd(K)
    cumulative_r = cumulative_r[['Cusip', 'FormationDate', 'MomentumRanking', 'HoldingDate1', 'HoldingDate2']]
    portfolios = pd.merge(df[['Cusip', 'Date', 'R']], cumulative_r, on=['Cusip'], how='inner')
    portfolios = portfolios[(portfolios['HoldingDate1'] <= portfolios['Date']) & (portfolios['Date'] <= portfolios['HoldingDate2'])]
    portfolios = portfolios[['Cusip', 'FormationDate', 'MomentumRanking', 'HoldingDate1', 'HoldingDate2', 'Date', 'R']]
    agg_portfolios = portfolios.groupby(['Date', 'MomentumRanking', 'FormationDate'])['R'].mean().reset_index()
    agg_portfolios = agg_portfolios.loc[agg_portfolios.Date.dt.year >= agg_portfolios['Date'].dt.year.min() + 2]
    agg_portfolios = agg_portfolios.sort_values(by=['Date', 'MomentumRanking'])
    eq_weighted_return = agg_portfolios.groupby(['Date', 'MomentumRanking'])['R'].mean().reset_index()
    eq_weighted_std = agg_portfolios.groupby(['Date', 'MomentumRanking'])['R'].std().reset_index()
    eq_weighted_return = eq_weighted_return.rename(columns={'R': 'EqualWeightedReturn'})
    eq_weighted_std = eq_weighted_std.rename(columns={'R': 'EqualWeightedStd'})
    eq_weighted_return_df = pd.merge(eq_weighted_return, eq_weighted_std, on=['Date', 'MomentumRanking'], how='inner')
    eq_weighted_return_df = eq_weighted_return_df.sort_values(by=['MomentumRanking', 'Date'])

    # winners and losers
    eq_weighted_return_tdf = eq_weighted_return_df.pivot(index='Date', columns='MomentumRanking', values='EqualWeightedReturn') 
    eq_weighted_return_tdf = eq_weighted_return_tdf.add_prefix('Portfolio-') 
    eq_weighted_return_tdf = eq_weighted_return_tdf.rename(columns={'Portfolio-1': 'Losers', 'Portfolio-10': 'Winners'})
    eq_weighted_return_tdf['LongShort'] = eq_weighted_return_tdf.Winners - eq_weighted_return_tdf.Losers

    # compute cumulative returns
    eq_weighted_return_tdf['CumulativeReturns_Winners'] = (1 + eq_weighted_return_tdf.Winners).cumprod() - 1 
    eq_weighted_return_tdf['CumulativeReturns_Losers'] = (1 + eq_weighted_return_tdf.Losers).cumprod() - 1
    eq_weighted_return_tdf['CumulativeReturns_LongShort'] = (1 + eq_weighted_return_tdf.LongShort).cumprod() - 1
    momentum_mean = eq_weighted_return_tdf[['Winners', 'Losers', 'LongShort']].mean().to_frame()
    momentum_mean = momentum_mean.rename(columns={0: 'mean'}).reset_index()

    # t-statistics for winners, losers, long-short
    t_losers = pd.Series(stats.ttest_1samp(eq_weighted_return_tdf['Losers'], 0.0)).to_frame().T 
    t_winners = pd.Series(stats.ttest_1samp(eq_weighted_return_tdf['Winners'], 0.0)).to_frame().T 
    t_long_short = pd.Series(stats.ttest_1samp(eq_weighted_return_tdf['LongShort'], 0.0)).to_frame().T
    t_losers['MomentumRanking'] = 'Losers'
    t_winners['MomentumRanking'] = 'Winners'
    t_long_short['MomentumRanking'] = 'LongShort'
    t_output = pd.concat([t_winners, t_losers, t_long_short]).rename(columns={0: 't-stat', 1: 'p-value'}) 
    momentum_output = pd.merge(momentum_mean, t_output, on=['MomentumRanking'], how='inner')
    momentum_output['mean'] = momentum_output['mean'].map('{:.2%}'.format) 
    momentum_output['t-stat'] = momentum_output['t-stat'].map('{:.2f}'.format) 
    momentum_output['p-value'] = momentum_output['p-value'].map('{:.2f}'.format) 

    # print
    print('\nMomentum Strategy Summary for J={}, K={}:\n'.format(com[0], com[1]), momentum_output)
