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
sql_sub_wo varchar2(32000) := '';

days_back number := 0;

begin

if p4 is not null then res_limit := p4; end if;

if p1 is not null then days_back := p1; end if;

sql_sub := 
'
select 
debit_detail_code, debit_account_fund_code, debit_account_orgn_code, debit_account_account_code, debit_account_function_code, debit_account_actv_code, debit_account_locn_code, debit_account_worktag,  
credit_detail_code, credit_account_fund_code, credit_account_orgn_code, credit_account_account_code, credit_account_function_code, credit_account_actv_code, credit_account_locn_code, credit_account_worktag,
sum(debit_account_amount) account_charge
from 
(
select aa.*, bb.*
from
(
select distinct a.detail_code debit_detail_code, a.charge_balance debit_charge_balance, a.account_fund_code debit_account_fund_code, a.account_orgn_code debit_account_orgn_code, a.account_account_code debit_account_account_code,
a.account_function_code debit_account_function_code, a.account_actv_code debit_account_actv_code, a.account_locn_code debit_account_locn_code, a.account_worktag debit_account_worktag, a.account_amount debit_account_amount,
a.tran_number debit_tran_number, a.activity_date debit_activity_date, a.student_id debit_student_id
from
(
select distinct gurfeed_detail_code detail_code, gurfeed_dr_cr_ind charge_balance, 
gurfeed_fund_code account_fund_code, gurfeed_orgn_code account_orgn_code, gurfeed_acct_code account_account_code, gurfeed_prog_code account_function_code, gurfeed_actv_code account_actv_code, 
gurfeed_locn_code account_locn_code, tbracct.TBRACCT_ACCOUNT_A account_worktag, gurfeed_tran_number transaction_id,
gurfeed_trans_amt account_amount, gurfeed_activity_date activity_date, gurfeed_tran_number tran_number, gurfeed_id student_id
from daies.gurfeed, tbracct
where gurfeed_doc_code = ''' || p0 || ''' and gurfeed_dr_cr_ind = ''D'' and gurfeed.GURFEED_DETAIL_CODE = tbracct.TBRACCT_DETAIL_CODE(+) and tbracct.TBRACCT_USER_ID(+) = ''Workday''
and gurfeed_system_id like ''ACT%'' and gurfeed_rec_type != ''1''
) a
) aa,
(
select distinct b.detail_code credit_detail_code, b.charge_balance credit_charge_balance, b.account_fund_code credit_account_fund_code, b.account_orgn_code credit_account_orgn_code, b.account_account_code credit_account_account_code,
b.account_function_code credit_account_function_code, b.account_actv_code credit_account_actv_code, b.account_locn_code credit_account_locn_code, b.account_worktag credit_account_worktag, b.account_amount credit_account_amount, 
b.tran_number credit_tran_number, b.activity_date credit_activity_date, b.student_id credit_student_id
from
(
select distinct gurfeed_detail_code detail_code, gurfeed_dr_cr_ind charge_balance, 
gurfeed_fund_code account_fund_code, gurfeed_orgn_code account_orgn_code, gurfeed_acct_code account_account_code, gurfeed_prog_code account_function_code, gurfeed_actv_code account_actv_code, 
gurfeed_locn_code account_locn_code, tbracct.TBRACCT_ACCOUNT_B account_worktag, gurfeed_tran_number transaction_id,
gurfeed_trans_amt account_amount, gurfeed_activity_date activity_date, gurfeed_tran_number tran_number, gurfeed_id student_id
from daies.gurfeed, tbracct
where gurfeed_doc_code = ''' || p0 || ''' and gurfeed_dr_cr_ind = ''C'' and gurfeed.GURFEED_DETAIL_CODE = tbracct.TBRACCT_DETAIL_CODE(+) and tbracct.TBRACCT_USER_ID(+) = ''Workday''
and gurfeed_system_id like ''ACT%'' and gurfeed_rec_type != ''1''
) b
) bb
where aa.debit_tran_number = bb.credit_tran_number and aa.debit_student_id = bb.credit_student_id and aa.debit_account_amount = bb.credit_account_amount';

sql_sub_wo := ' order by aa.debit_detail_code
)
group by
debit_detail_code, debit_account_fund_code, debit_account_orgn_code, debit_account_account_code, debit_account_function_code, debit_account_actv_code, debit_account_locn_code, debit_account_worktag,  
credit_detail_code, credit_account_fund_code, credit_account_orgn_code, credit_account_account_code, credit_account_function_code, credit_account_actv_code, credit_account_locn_code, credit_account_worktag
'

;

--if p1 is not null then
sql_sub := sql_sub || ' and aa.debit_activity_date like sysdate - ' || days_back || ' and bb.credit_activity_date like sysdate - ' || days_back;
--end if;


begin
open ref_cur_out FOR
'select * from
(
select a.*, row_number() over
(order by a.debit_detail_code) rn
from
(' ||
sql_sub || sql_sub_wo ||
') a
) b
where b.rn between ' || p3 || 'and ' || res_limit ||
'order by b.rn';

end;
  
end;