create or replace procedure get_gift_rucl (p0 in varchar2 default null, p1 in number default 1, p2 in number, p3 in number default 0, p4 in varchar2 default null, ref_cur_out out SYS_REFCURSOR)
as
-- p0 : rucl_code
-- p1 : offset
-- p2 : limit
-- p3 : back // number of days back on GURFEED
-- p4: RUCL param

-- ref_cur_out : out REF_CURSOR

res_limit number := 1000;
sql_sub varchar2(32000);

days_back number := 0;

begin

if p2 is not null then res_limit := p2; end if;
if p3 is not null then days_back := p3; end if;

sql_sub := 
'
select distinct gurfeed_doc_code transaction_id, gurfeed_rucl_code rule_class_code, ''description of rule code'' rule_code_desc, sum(gurfeed_trans_amt) rule_class_total
from daies.gurfeed
where gurfeed_system_id = ''ALUMNI'' and gurfeed_user_id not like ''HEADER%''
';

--if p3 is not null then
sql_sub := sql_sub || ' and gurfeed_activity_date like sysdate - ' || days_back;
--end if;

if p4 is not null then
sql_sub := sql_sub || ' and gurfeed_rucl_code = ''' || p4 || ''' ';
end if;

sql_sub := sql_sub || ' group by gurfeed_doc_code, gurfeed_rucl_code, ''description of rule code'' order by gurfeed_rucl_code ';


begin
open ref_cur_out FOR

'select * from
(' ||
sql_sub
||
') b';
/*where b.rn between p1 and res_limit
order by b.rn;
*/
end;
  
  
end;