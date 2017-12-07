create or replace procedure get_gift_trans (p0 in varchar2 default null, p1 in number default 0, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null,  ref_cur_out out SYS_REFCURSOR)
as
-- p0 : rucl_code
-- p1: back // days back on GURFEED
-- p2: RUCL param
-- p3 : transaction_id (batch number)
-- p4 : gift_number

-- ref_cur_out : out REF_CURSOR

sql_sub varchar2(32000) := '';
days_back number := 0;

begin

if p1 is not null then days_back := p1; end if;

sql_sub := 
'
select distinct GURFEED_FUND_CODE gift_fund_code,  
GURFEED_ACCT_CODE gift_account_code, GURFEED_PROG_CODE gift_prog_code, GURFEED_ACTV_CODE gift_actv_code, GURFEED_LOCN_CODE gift_locn_code, 
gurfeed_vendor_pidm gift_donor_identifier, gurfeed_doc_ref_num gift_number, decode(gurfeed_dr_cr_ind,''D'',''Debit'',''Credit'') gift_balance
from daies.gurfeed, adbdesg
where gurfeed_system_id = ''ALUMNI'' and gurfeed_user_id not like ''HEADER%''
and adbdesg_name(+) = gurfeed.GURFEED_TRANS_DESC
and gurfeed_doc_code = ''' || p3 || '''
and GURFEED_RUCL_CODE = ''' || p0 || ''''
;

--if p1 is not null then
sql_sub := sql_sub || ' and gurfeed_activity_date like sysdate - ' || days_back;
--end if;

if p2 is not null then
sql_sub := sql_sub || ' and gurfeed_rucl_code = ''' || p2 || ''' ';
end if;

if p4 is not null then
sql_sub := sql_sub || ' and gurfeed_doc_ref_num = ''' || p4 || ''' ';
end if;

/*sql_sub := sql_sub || ' group by 
GURFEED_FUND_CODE, GURFEED_ORGN_CODE, GURFEED_ACCT_CODE, GURFEED_PROG_CODE, GURFEED_ACTV_CODE, GURFEED_LOCN_CODE, adbdesg_gl_no_credit
';
*/

begin
open ref_cur_out FOR
'select * from
(' ||
sql_sub ||
') b'
;
/*where b.rn between p1 and res_limit
order by b.rn;
*/
end;
  
end;