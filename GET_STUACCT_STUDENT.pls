create or replace procedure get_stuacct_student (p0 in varchar2 default null, ref_cur_out out SYS_REFCURSOR)
as
-- p0 : student_identifier
-- ref_cur_out : out REF_CURSOR

begin

begin
open ref_cur_out FOR

select * from
(
select distinct spriden_id student_vassar_id, spriden_first_name first_name, spriden_last_name last_name
from spriden
where spriden_change_ind is null 
and spriden_id = p0
) b;
/*where b.rn between p1 and res_limit
order by b.rn;
*/
end;
  
end;