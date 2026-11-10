-- IG Attachments: install or upgrade in the application's parsing schema (SQLcl or SQL*Plus).
-- Safe to run again: tables are created or upgraded, existing files are kept.
--   sql user/password@db @install.sql
-- dist/install.sql is the same in one file (for SQL Workshop > SQL Scripts).
set define off
set serveroutput on
whenever sqlerror exit sql.sqlcode rollback
@@001_tables.sql
@@002_package_spec.sql
@@003_package_body.sql
whenever sqlerror continue
show errors package body iga_api
declare
    n number;
begin
    select count(*) into n from user_errors where name = 'IGA_API';
    if n > 0 then raise_application_error(-20000, 'IGA_API does not compile: see USER_ERRORS.'); end if;
end;
/
@@004_purge_job.sql
