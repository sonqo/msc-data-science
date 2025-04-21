# https://www.tidy-finance.org/python/clean-enhanced-trace-with-python.html
def clean_enhanced_trace(cusips, connection, start_date, end_date):

    import pandas as pd

    # load main file
    trace_query = f'''
        SELECT 
            cusip_id,
            bond_sym_id,
            trd_exctn_dt, 
            trd_exctn_tm, 
            days_to_sttl_ct, 
            lckd_in_ind, 
            wis_fl, 
            sale_cndtn_cd, 
            msg_seq_nb, 
            trc_st, 
            trd_rpt_dt, 
            trd_rpt_tm, 
            entrd_vol_qt, 
            rptd_pr, 
            yld_pt, 
            asof_cd, 
            orig_msg_seq_nb, 
            rpt_side_cd, 
            cntra_mp_id, 
            buy_cmsn_rt,
            sell_cmsn_rt,
            stlmnt_dt, 
            spcl_trd_fl 
        FROM 
            trace.trace_enhanced 
        WHERE 
            cusip_id IN {cusips} 
            AND trd_exctn_dt >= {start_date} 
            AND trd_exctn_dt <= {end_date}
    '''

    trace_all = pd.read_sql_query(
        sql=trace_query,
        con=connection,
        parse_dates=[
            'trd_exctn_dt',
            'trd_rpt_dt',
            'stlmnt_dt'
        ]
    )

    # post 2012-06-02
    # trades (trc_st = T) and corrections (trc_st = R)
    trace_post_tr = (
        trace_all
            .query('trc_st in ["T", "R"]')
            .query('trd_rpt_dt >= "2012-06-02"')
    )

    # cancellations (trc_st = X) and correction cancellations (trc_st = C)
    trace_post_xc = (
        trace_all
            .query('trc_st in ["X", "C"]')
            .query('trd_rpt_dt >= "2012-06-02"')
            .get([
                'cusip_id',
                'msg_seq_nb',
                'entrd_vol_qt',
                'rptd_pr',
                'rpt_side_cd',
                'cntra_mp_id',
                'trd_exctn_dt',
                'trd_exctn_tm'
            ])
            .assign(drop=True)
    )

    # corrected and cancelled trades
    trace_post_tr = (
        trace_post_tr
            .merge(trace_post_xc, how='left')
            .query('drop != True')
            .drop(columns='drop')
    )

    # reversals (trc_st = Y)
    trace_post_y = (
        trace_all
            .query('trc_st == "Y"')
            .query('trd_rpt_dt >= "2012-06-02"')
            .get([
                'cusip_id',
                'orig_msg_seq_nb',
                'entrd_vol_qt',
                'rptd_pr',
                'rpt_side_cd',
                'cntra_mp_id',
                'trd_exctn_dt',
                'trd_exctn_tm'
            ])
            .assign(drop=True)
            .rename(columns={
                'orig_msg_seq_nb': 'msg_seq_nb'
            })
    )

    # clean reversals
    # match the orig_msg_seq_nb of Y-message to msg_seq_nb of main message
    trace_post = (
        trace_post_tr
            .merge(trace_post_y, how='left')
            .query('drop != True')
            .drop(columns='drop')
    )

    # pre 06-02-12
    # trades (trc_st = T)
    trace_pre_t = (
        trace_all
            .query('trd_rpt_dt < "2012-06-02"')
   )

    # cancellations (trc_st = C)
    trace_pre_c = (
        trace_all
            .query('trc_st == "C"')
            .query('trd_rpt_dt < "2012-06-02"')
            .get([
                'cusip_id',
                'orig_msg_seq_nb',
                'entrd_vol_qt',
                'rptd_pr',
                'rpt_side_cd',
                'cntra_mp_id',
                'trd_exctn_dt',
                'trd_exctn_tm'
            ])
            .assign(drop=True)
            .rename(columns={
                'orig_msg_seq_nb': 'msg_seq_nb'
            })
    )

    # remove cancellations from trades
    # match orig_msg_seq_nb of C-message to msg_seq_nb of main message
    trace_pre_t = (
        trace_pre_t
           .merge(trace_pre_c, how='left')
           .query('drop != True')
           .drop(columns='drop')
    )

    # corrections (trc_st = W)
    trace_pre_w = (
        trace_all
            .query('trc_st == "W"')
            .query('trd_rpt_dt < "2012-06-02"')
    )

    # implement corrections in a loop
    # correction control
    correction_control = len(trace_pre_w)
    correction_control_last = len(trace_pre_w)

    # correction loop
    while correction_control > 0:
        # create placeholder
        # identifying columns of trace_pre_T (for joins)
        placeholder_trace_pre_t = (
            trace_pre_t
                .get([
                    'cusip_id',
                    'trd_exctn_dt',
                    'msg_seq_nb'
                ])
                .rename(columns={
                    'msg_seq_nb': 'orig_msg_seq_nb'
                })
                .assign(matched_T=True)
        )

        # corrections that correct some msg
        trace_pre_w_correcting = (
            trace_pre_w
                .merge(placeholder_trace_pre_t, how='left')
                .query('matched_T == True')
                .drop(columns='matched_T')
        )

        # corrections that do not correct some msg
        trace_pre_w = (
            trace_pre_w
                .merge(placeholder_trace_pre_t, how='left')
                .query('matched_T != True')
                .drop(columns='matched_T')
        )

        # create placeholder
        # identifying columns of trace_pre_W_correcting (for anti-joins)
        placeholder_trace_pre_w_correcting = (
            trace_pre_w_correcting
                .get([
                    'cusip_id',
                    'trd_exctn_dt',
                    'orig_msg_seq_nb'
                ])
                .rename(columns={
                    'orig_msg_seq_nb': 'msg_seq_nb'
                })
                .assign(corrected=True)
        )

        # delete msgs that are corrected
        trace_pre_t = (
            trace_pre_t
                .merge(placeholder_trace_pre_w_correcting, how='left')
                .query('corrected != True')
                .drop(columns='corrected')
       )

        # correction msgs
        trace_pre_t = pd.concat([trace_pre_t, trace_pre_w_correcting])

        # escape if no corrections remain or they cannot be matched
        correction_control = len(trace_pre_w)

        if correction_control == correction_control_last:
            break
        else:
            correction_control_last = len(trace_pre_w)
            continue

    # reversals (asof_cd = R)
    # record reversals
    trace_pre_r = (
        trace_pre_t
            .query('asof_cd == "R"')
            .sort_values([
                'cusip_id',
                'trd_exctn_dt',
                'trd_exctn_tm',
                'trd_rpt_dt',
                'trd_rpt_tm'
            ])
    )

    # prepare final data
    trace_pre = (
        trace_pre_t
            .query(
                'asof_cd == None | asof_cd.isnull() | asof_cd not in ["R", "X", "D"]'
            )
            .sort_values([
                'cusip_id',
                'trd_exctn_dt',
                'trd_exctn_tm',
                'trd_rpt_dt',
                'trd_rpt_tm'
            ])
    )

    # add grouped row numbers
    trace_pre_r['seq'] = (
        trace_pre_r
            .groupby([
                'cusip_id',
                'trd_exctn_dt',
                'entrd_vol_qt',
                'rptd_pr',
                'rpt_side_cd',
                'cntra_mp_id'
            ])
            .cumcount()
    )

    trace_pre['seq'] = (
        trace_pre
            .groupby([
                'cusip_id',
                'trd_exctn_dt',
                'entrd_vol_qt',
                'rptd_pr',
                'rpt_side_cd',
                'cntra_mp_id'])
            .cumcount()
    )

    # select columns for reversal cleaning
    trace_pre_r = (
        trace_pre_r
            .get([
                'cusip_id',
                'trd_exctn_dt',
                'entrd_vol_qt',
                'rptd_pr',
                'rpt_side_cd',
                'cntra_mp_id',
                'seq'
            ])
            .assign(reversal=True)
    )

    # remove reversals and the reversed trade
    trace_pre = (
        trace_pre
            .merge(trace_pre_r, how='left')
            .query('reversal != True')
            .drop(columns=['reversal', 'seq'])
    )

    # combine pre and post trades
    trace_clean = pd.concat([trace_pre, trace_post])

    # keep agency sells and unmatched agency buys
    trace_agency_sells = (
        trace_clean
            .query('cntra_mp_id == "D" & rpt_side_cd == "S"')
    )

    # placeholder for trace_agency_sells with relevant columns
    placeholder_trace_agency_sells = (
        trace_agency_sells
            .get([
                'cusip_id',
                'trd_exctn_dt',
                'entrd_vol_qt',
                'rptd_pr'
            ])
            .assign(matched=True)
    )

    # agency buys that are unmatched
    trace_agency_buys_filtered = (
        trace_clean
            .query('cntra_mp_id == "D" & rpt_side_cd == "B"')
            .merge(placeholder_trace_agency_sells, how='left')
            .query('matched != True')
            .drop(columns='matched')
    )

    # non-agency
    trace_nonagency = (
        trace_clean
            .query('cntra_mp_id == "C"')
    )

    # agency cleaned
    trace_clean = pd.concat([
        trace_nonagency,
        trace_agency_sells,
        trace_agency_buys_filtered
    ])

    # additional Filters
    trace_add_filters = (
        trace_clean
            .assign(
                days_to_sttl_ct2 = lambda x: (
                    (x['stlmnt_dt']-x['trd_exctn_dt']).dt.days
                )
            )
            .assign(
                days_to_sttl_ct = lambda x: pd.to_numeric(
                    x['days_to_sttl_ct'], errors='coerce'
                )
            )
            .query('days_to_sttl_ct.isnull() | days_to_sttl_ct <= 7')
            .query('days_to_sttl_ct2.isnull() | days_to_sttl_ct2 <= 7')
            .query('wis_fl == "N"')
            .query('spcl_trd_fl.isnull() | spcl_trd_fl == ""')
            .query('asof_cd.isnull() | asof_cd == ""')
    )

    # keep necessary columns
    trace_final = (
        trace_add_filters
            .sort_values(['cusip_id', 'trd_exctn_dt', 'trd_exctn_tm'])
            .get([
                'cusip_id',
                'trd_exctn_dt',
                'trd_exctn_tm',
                'rptd_pr',
                'entrd_vol_qt',
                'yld_pt',
                'rpt_side_cd',
                'buy_cmsn_rt',
                'sell_cmsn_rt',
                'cntra_mp_id'
            ])
   )

    # rename columns
    trace_final.columns = [col.replace('_', ' ').title().replace(' ', '') for col in trace_final.columns]

    return trace_final
