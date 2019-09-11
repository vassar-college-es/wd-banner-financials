create or replace procedure get_gift_donor (p0 in varchar2 default null, p1 in varchar2 default null, p2 in varchar2 default null, ref_cur_out out SYS_REFCURSOR)
as
-- p0 : donor_identifier
-- p1 : gift_identifier
-- p2 : trans tpye (gift/grant)
-- ref_cur_out : out REF_CURSOR

sql_sub varchar2(32000);

begin

sql_sub := 
'
select distinct agvglst_gift_code type, adbdesg_orgn_code gift_orgn_code, agvglst_desg designation, 
GURFEED_FUND_CODE gift_fund_code,  
GURFEED_ACCT_CODE gift_account_code, GURFEED_PROG_CODE gift_prog_code, GURFEED_ACTV_CODE gift_actv_code, GURFEED_LOCN_CODE gift_locn_code,
agvglst_amt amount, to_char(agvglst_gift_date,''MM/DD/YYYY'') gift_date, adbdesg_gl_no_credit ref_id, adbdesg_gl_no_debit award, adbdesg_gl_no_credit_pldg award_sponsor
from agvglst, daies.gurfeed, adbdesg
where agvglst_pidm = ' || p0 || ' and agvglst_gift_no = ''' || p1 || '''
and gurfeed_doc_ref_num = agvglst_gift_no
and gurfeed_vendor_pidm = agvglst_pidm
and agvglst_desg = adbdesg_desg
and adbdesg_locn_code = gurfeed_locn_code
and adbdesg_fund_code = gurfeed_fund_code
and adbdesg.ADBDESG_ACCT_CODE = gurfeed_acct_code
';

if p2 = 'grant' then
sql_sub := sql_sub || ' and agvglst_gift_code in (''WP'', ''GP'', ''WD'', ''GD'')';
end if;
if p2 = 'gift' then
sql_sub := sql_sub || ' and agvglst_gift_code not in (''WP'', ''GP'', ''WD'', ''GD'')';
end if;

begin
open ref_cur_out FOR

'select * from
(' ||
sql_sub ||
') b'
;

end;
  
end;