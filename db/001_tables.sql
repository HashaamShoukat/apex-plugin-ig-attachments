-- IG Attachments plug-in: scopes, staged uploads, saved files.
-- Fresh install and upgrade from any earlier version: safe to run again, existing data is kept.
declare
    procedure ddl ( p_sql in varchar2 ) is
    begin
        execute immediate p_sql;
    exception
        when others then
            -- -955 name in use, -2260/-2261 key exists, -1408 column list indexed, -1430 column exists, -1442 already NOT NULL
            if sqlcode not in (-955, -2260, -2261, -1408, -1430, -1442) then
                raise;
            end if;
    end ddl;
begin
    -- attachment version per record: a stale editor cannot overwrite a newer save
    ddl(q'[
        create table iga_record_versions (
            workspace_id       number not null,
            application_id     number not null,
            scope_name         varchar2(64) not null,
            record_key         varchar2(512) not null,
            attachment_version number default 0 not null,
            constraint iga_record_versions_pk primary key (workspace_id, application_id, scope_name, record_key)
        )]');

    -- one edit token per open panel; its staging expires after Keep Unsaved Files (sliding)
    ddl(q'[
        create table iga_edits (
            edit_token      varchar2(32) primary key,
            workspace_id    number not null,
            application_id  number not null,
            scope_name      varchar2(64) not null,
            record_key      varchar2(512),
            session_id      number not null,
            user_name       varchar2(255) not null,
            base_version    number default 0 not null,
            max_file_count  number,
            max_total_bytes number,
            keep_minutes    number default 1440 not null,
            storage         varchar2(1000),
            page_id         number,
            column_name     varchar2(255),
            status          varchar2(1) default 'A' not null,
            created_at      timestamp with time zone default systimestamp not null,
            expires_at      timestamp with time zone default systimestamp + interval '1' day not null,
            constraint iga_edits_status check (status in ('A','S'))
        )]');
    ddl(q'[alter table iga_edits add (max_file_count number)]');
    ddl(q'[alter table iga_edits add (max_total_bytes number)]');
    ddl(q'[alter table iga_edits add (keep_minutes number default 1440 not null)]');
    ddl(q'[alter table iga_edits add (storage varchar2(1000))]');
    -- 1.0.0: the edit's page and column - finalize_edit finds the grid (and who may do what) from them
    ddl(q'[alter table iga_edits add (page_id number, column_name varchar2(255))]');
    ddl(q'[create index iga_edits_expiry on iga_edits (expires_at)]');
    ddl(q'[create index iga_edits_session on iga_edits (workspace_id, application_id, session_id, status)]');
    ddl(q'[create index iga_edits_user on iga_edits (workspace_id, application_id, user_name, status)]');

    -- saved files (Storage = Plug-in Table)
    ddl(q'[
        create table iga_files (
            file_id        varchar2(32) primary key,
            workspace_id   number not null,
            application_id number not null,
            scope_name     varchar2(64) not null,
            record_key     varchar2(512) not null,
            file_name      varchar2(255 char) not null,
            mime_type      varchar2(100) not null,
            file_bytes     number not null,
            file_blob      blob not null,
            f1 varchar2(4000), f2 varchar2(4000), f3 varchar2(4000),
            created_by     varchar2(255) not null,
            created_at     timestamp with time zone default systimestamp not null
        )]');
    ddl(q'[alter table iga_files add (f1 varchar2(4000), f2 varchar2(4000), f3 varchar2(4000))]');
    ddl(q'[create index iga_files_record on iga_files (workspace_id, application_id, scope_name, record_key)]');

    -- files added in an edit, until the grid is saved
    ddl(q'[
        create table iga_uploads (
            upload_id      varchar2(32) primary key,
            edit_token     varchar2(32) not null references iga_edits (edit_token) on delete cascade,
            file_name      varchar2(255 char) not null,
            mime_type      varchar2(100) default 'application/octet-stream' not null,
            expected_bytes number not null,
            file_blob      blob not null,
            f1 varchar2(4000), f2 varchar2(4000), f3 varchar2(4000),
            status         varchar2(1) default 'U' not null,
            constraint iga_uploads_status check (status in ('U','R'))
        )]');
    ddl(q'[alter table iga_uploads add (f1 varchar2(4000), f2 varchar2(4000), f3 varchar2(4000))]');
    -- when the upload started: saved files keep the order they were added in
    ddl(q'[alter table iga_uploads add (created_at timestamp with time zone default systimestamp not null)]');
    ddl(q'[create index iga_uploads_edit on iga_uploads (edit_token)]');

    -- saved files marked for removal in an edit (IGA_FILES or the developer's own table: no foreign key)
    ddl(q'[
        create table iga_removals (
            edit_token varchar2(32) not null references iga_edits (edit_token) on delete cascade,
            file_id    varchar2(100) not null,
            constraint iga_removals_pk primary key (edit_token, file_id)
        )]');
    for c in (select constraint_name from user_constraints
               where table_name = 'IGA_REMOVALS' and constraint_type = 'R' and r_constraint_name in
                     (select constraint_name from user_constraints where table_name = 'IGA_FILES')) loop
        execute immediate 'alter table iga_removals drop constraint ' || c.constraint_name;
    end loop;
    ddl(q'[alter table iga_removals modify (file_id varchar2(100))]');

    -- changed Extra Fields of saved files in an edit
    ddl(q'[
        create table iga_changes (
            edit_token varchar2(32) not null references iga_edits (edit_token) on delete cascade,
            file_id    varchar2(100) not null,
            file_name  varchar2(1000),
            f1 varchar2(4000), f2 varchar2(4000), f3 varchar2(4000),
            constraint iga_changes_pk primary key (edit_token, file_id)
        )]');
    ddl(q'[alter table iga_changes add (file_name varchar2(1000))]');

    -- small mutex rows: upload quota reservations of one session are serialized across tabs
    ddl(q'[
        create table iga_stage_locks (
            workspace_id   number not null,
            application_id number not null,
            session_id     number not null,
            touched_at     timestamp with time zone default systimestamp not null,
            constraint iga_stage_locks_pk primary key (workspace_id, application_id, session_id)
        )]');
end;
/
