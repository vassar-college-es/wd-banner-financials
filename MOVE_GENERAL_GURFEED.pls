create or replace PROCEDURE move_general_gurfeed 
AS

begin
begin
insert into DAIES.GURFEED
(
select * from GENERAL.GURFEED where gurfeed_activity_date like sysdate and gurfeed_trans_date >= to_date('01-JUL-2017','DD-MON-YYYY')
);
end;
commit;

end;
