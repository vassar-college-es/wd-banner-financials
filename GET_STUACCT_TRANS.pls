create or replace procedure get_stuacct_trans (p0 in varchar2 default null, p1 in number default 0, p2 in varchar2 default null, p3 in number default 1, p4 in number, p5 in varchar2, ref_cur_out out SYS_REFCURSOR)
as
-- p0 : rucl_code
-- p1: back // days back on GURFEED
-- p2: RUCL param
-- p3 : offset
-- p4 : limit

-- ref_cur_out : out REF_CURSOR

res_limit number := 100;

sql_sub varchar2(32000) := '';
days_back number := 0;

begin

if p4 is not null then res_limit := p4; end if;

if p1 is not null then days_back := p1; end if;

sql_sub := 
'
select distinct tbracct_detail_code detail_code, gurfeed_trans_amt charge_amount, GURFEED_FUND_CODE charge_fund_code, GURFEED_ORGN_CODE charge_orgn_code, 
GURFEED_ACCT_CODE charge_account_code, GURFEED_PROG_CODE charge_prog_code, GURFEED_ACTV_CODE charge_actv_code, GURFEED_LOCN_CODE charge_locn_code, tbracct.TBRACCT_ACCOUNT_A debit_worktag, tbracct.TBRACCT_ACCOUNT_B credit_worktag,
gurfeed_id student_identifier, decode(gurfeed_dr_cr_ind,''D'',''Debit'',''Credit'') charge_balance, GURFEED_SEQ_NUM
from daies.gurfeed, tbracct
where gurfeed_system_id like ''ACT%'' and gurfeed_rec_type != ''1''
and gurfeed.GURFEED_DETAIL_CODE = tbracct.TBRACCT_DETAIL_CODE(+) and tbracct.TBRACCT_USER_ID(+) = ''Workday''
and GURFEED_RUCL_CODE = ''' || p0 || '''
and GURFEED_DOC_CODE = ''' || p5 || '''
'

;

--if p1 is not null then
sql_sub := sql_sub || ' and gurfeed_activity_date like sysdate - ' || days_back;
--end if;

if p2 is not null then
sql_sub := sql_sub || ' and gurfeed_rucl_code = ''' || p2 || ''' ';
end if;

/*sql_sub := sql_sub || ' group by 
GURFEED_FUND_CODE, GURFEED_ORGN_CODE, GURFEED_ACCT_CODE, GURFEED_PROG_CODE, GURFEED_ACTV_CODE, GURFEED_LOCN_CODE, adbdesg_gl_no_credit
';
*/

begin
open ref_cur_out FOR
'select * from
(
select a.*, row_number() over
(order by a.student_identifier, a.gurfeed_seq_num) rn
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