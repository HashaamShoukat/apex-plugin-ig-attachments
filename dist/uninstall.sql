-- IG Attachments: removes the cleanup job, the package and the plug-in's tables with ALL their files
-- (IGA_FILES and staging). Files kept in your own tables (Storage = My Table) are not touched.
-- Remove the plug-in from your applications first.
set define off
declare
    procedure drop_it ( p_sql in varchar2 ) is
    begin
        execute immediate p_sql;
    exception
        when others then null;   -- already gone
    end drop_it;
begin
    begin dbms_scheduler.drop_job('IGA_PURGE_EXPIRED', force => true); exception when others then null; end;
    drop_it('drop package iga_api');
    drop_it('drop table iga_changes purge');
    drop_it('drop table iga_removals purge');
    drop_it('drop table iga_uploads purge');
    drop_it('drop table iga_edits purge');
    drop_it('drop table iga_files purge');
    drop_it('drop table iga_record_versions purge');
    drop_it('drop table iga_stage_locks purge');
    drop_it('drop table iga_scopes purge');
end;
/
