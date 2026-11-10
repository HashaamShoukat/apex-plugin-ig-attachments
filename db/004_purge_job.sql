-- IG Attachments: the job that removes files users added but never saved (after Keep Unsaved Files).
-- Safe to run again. Needs the CREATE JOB privilege; without it the install goes on and says so.
declare
    l_n number;
begin
    select count(*) into l_n from user_scheduler_jobs where job_name = 'IGA_PURGE_EXPIRED';
    if l_n = 0 then
        dbms_scheduler.create_job(
            job_name        => 'IGA_PURGE_EXPIRED',
            job_type        => 'PLSQL_BLOCK',
            job_action      => 'begin iga_api.purge_expired; commit; end;',
            start_date      => systimestamp,
            repeat_interval => 'FREQ=MINUTELY; INTERVAL=10',
            enabled         => true,
            comments        => 'IG Attachments: removes expired edits and their staged files');
    end if;
exception
    when others then
        if sqlcode = -27486 or sqlcode = -1031 then
            dbms_output.put_line('IG Attachments: no CREATE JOB privilege - schedule "begin iga_api.purge_expired; commit; end;" yourself (e.g. an APEX Automation every 10 minutes).');
        else
            raise;
        end if;
end;
/
