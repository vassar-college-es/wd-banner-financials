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
select agvglst_gift_code type, agvglst_desg designation, agvglst_amt amount, adbdesg_gl_no_credit ref_id, adbdesg_gl_no_debit award, adbdesg_gl_no_credit_pldg award_sponsor
from agvglst, adbdesg
where agvglst_pidm = ' || p0 || ' and agvglst_gift_no = ''' || p1 || '''
and agvglst_desg = adbdesg_desg
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