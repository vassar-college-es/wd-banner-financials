create or replace procedure get_stuacct_trans_rollup (p0 in varchar2 default null, p1 in number default 0, p2 in varchar2 default null, p3 in number default 1, p4 in number, p5 in varchar2, ref_cur_out out SYS_REFCURSOR)
as
-- p0 : doc ref_code
-- p1: back // days back on GURFEED
-- p2: doc ref param
-- p3 : offset
-- p4 : limit
-- p5 : doc ref param

-- ref_cur_out : out REF_CURSOR

res_limit number := 100;

sql_sub varchar2(32000) := '';
days_back number := 0;

begin

if p4 is not null then res_limit := p4; end if;

if p1 is not null then days_back := p1; end if;

sql_sub := 
'
select distinct a.detail_code debit_detail_code, a.charge_balance debit_charge_balance, a.account_fund_code debit_account_fund_code, a.account_orgn_code debit_account_orgn_code, a.account_account_code debit_account_account_code,
a.account_function_code debit_account_function_code, a.account_actv_code debit_account_actv_code, a.account_locn_code debit_account_locn_code, a.account_worktag debit_account_worktag, a.account_amount debit_account_amount,
b.detail_code credit_detail_code, b.charge_balance credit_charge_balance, b.account_fund_code credit_account_fund_code, b.account_orgn_code credit_account_orgn_code, b.account_account_code credit_account_account_code,
b.account_function_code credit_account_function_code, b.account_actv_code credit_account_actv_code, b.account_locn_code credit_account_locn_code, b.account_worktag credit_account_worktag, b.account_amount credit_account_amount
from
(
select gurfeed_detail_code detail_code, gurfeed_dr_cr_ind charge_balance, 
gurfeed_fund_code account_fund_code, gurfeed_orgn_code account_orgn_code, gurfeed_acct_code account_account_code, gurfeed_prog_code account_function_code, gurfeed_actv_code account_actv_code, 
gurfeed_locn_code account_locn_code, tbracct.TBRACCT_ACCOUNT_A account_worktag, gurfeed_tran_number transaction_id,
sum(gurfeed_trans_amt) account_amount, gurfeed_activity_date activity_date
from daies.gurfeed, tbracct
where gurfeed_doc_code = ''' || p0 || ''' and gurfeed_dr_cr_ind = ''D'' and gurfeed.GURFEED_DETAIL_CODE = tbracct.TBRACCT_DETAIL_CODE(+) and tbracct.TBRACCT_USER_ID(+) = ''Workday''
and gurfeed_system_id like ''ACT%'' and gurfeed_rec_type != ''1''
group by gurfeed_detail_code, gurfeed_dr_cr_ind, gurfeed_fund_code, gurfeed_orgn_code, gurfeed_acct_code, gurfeed_prog_code, gurfeed_actv_code, gurfeed_locn_code, tbracct.TBRACCT_ACCOUNT_A, gurfeed_tran_number, gurfeed_activity_date
) a, 
(
select gurfeed_detail_code detail_code, gurfeed_dr_cr_ind charge_balance, 
gurfeed_fund_code account_fund_code, gurfeed_orgn_code account_orgn_code, gurfeed_acct_code account_account_code, gurfeed_prog_code account_function_code, gurfeed_actv_code account_actv_code, 
gurfeed_locn_code account_locn_code, tbracct.TBRACCT_ACCOUNT_B account_worktag, gurfeed_tran_number transaction_id,
sum(gurfeed_trans_amt) account_amount, gurfeed_activity_date activity_date
from daies.gurfeed, tbracct
where gurfeed_doc_code = ''' || p0 || ''' and gurfeed_dr_cr_ind = ''C'' and gurfeed.GURFEED_DETAIL_CODE = tbracct.TBRACCT_DETAIL_CODE(+) and tbracct.TBRACCT_USER_ID(+) = ''Workday''
and gurfeed_system_id like ''ACT%'' and gurfeed_rec_type != ''1''
group by gurfeed_detail_code, gurfeed_dr_cr_ind, gurfeed_fund_code, gurfeed_orgn_code, gurfeed_acct_code, gurfeed_prog_code, gurfeed_actv_code, gurfeed_locn_code, tbracct.TBRACCT_ACCOUNT_B, gurfeed_tran_number, gurfeed_activity_date
order by account_fund_code, account_orgn_code, account_account_code, account_function_code, account_actv_code, account_locn_code, charge_balance
) b
where a.transaction_id = b.transaction_id
'

;

--if p1 is not null then
sql_sub := sql_sub || ' and a.activity_date like sysdate - ' || days_back || ' and b.activity_date like sysdate - ' || days_back;
--end if;

/*if p2 is not null then
sql_sub := sql_sub || ' and a.gurfeed_doc_code = ''' || p2 || ''' and b.gurfeed_doc_code = ''' || p2 || ''' ';
end if;
*/
/*sql_sub := sql_sub || ' group by 
GURFEED_FUND_CODE, GURFEED_ORGN_CODE, GURFEED_ACCT_CODE, GURFEED_PROG_CODE, GURFEED_ACTV_CODE, GURFEED_LOCN_CODE, adbdesg_gl_no_credit
';
*/

begin
open ref_cur_out FOR
'select * from
(
select a.*, row_number() over
(order by a.debit_detail_code) rn
from
(' ||
sql_sub ||
') a
) b
where b.rn between ' || p3 || 'and ' || res_limit ||
'order by b.rn';

/*where b.rn between p1 and res_limit
order by b.rn;
*/
end;
  
end;