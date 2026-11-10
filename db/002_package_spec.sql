create or replace package iga_api authid definer as
    -- IG Attachments 1.0.0
    --
    -- Who may see and change a row's files is decided by the grid itself: a user may READ the files of a
    -- row that is in their grid (the grid's own query, with its WHERE clause and page items), CREATE files
    -- for new rows when the grid allows adding rows, WRITE when it allows updating the row and DELETE when
    -- it allows deleting it - including the grid's Add / Update / Delete authorization schemes and its
    -- Allowed Row Operations Column. CREATE and WRITE also need the column not to be read only (the Read
    -- Only conditions of the page, the grid and the column; a column condition evaluated for each row
    -- on the saved row's values). The column's optional
    -- Authorization Function can refuse more. finalize_edit accepts a token only for the column that
    -- saves, and a new row's token only while that row is inserted.

    -- Call in the grid's row process (Interactive Grid - Automatic Row Processing, PL/SQL Code) after the
    -- row's INSERT or UPDATE, in the same transaction:
    --     iga_api.finalize_edit(:ATTACHMENT_EDIT, :ID);
    -- Links the files of the edit to the row (adds, removes, changed fields) and checks Minimum Files per
    -- Row. Never commits. Afterwards :ATTACHMENT_EDIT holds the row's file count (shown in the cell).
    -- p_raise => false (default): a refusal ("Add an attachment to this row.") is shown by APEX as a plain
    --   message and APEX rolls the row back, but code after this call still runs.
    -- p_raise => true: a refusal raises ORA-20001, so nothing after the call runs.
    -- p_column: the attachment column's name or Static ID - only needed when a page has more than one.
    procedure finalize_edit(p_edit_token in out varchar2, p_record_key varchar2,
                            p_raise boolean default false, p_column varchar2 default null);

    -- Call BEFORE deleting a row (the Authorization Function may read it), in the same transaction:
    --     iga_api.delete_record_files(:ID);
    -- Removes the row's files (plug-in table or your own table).
    procedure delete_record_files(p_record_key varchar2, p_raise boolean default false,
                                  p_column varchar2 default null);

    -- Removes expired edits and their staged files. The installation creates the job IGA_PURGE_EXPIRED
    -- (every 10 minutes); without it, schedule this yourself and commit.
    procedure purge_expired;

    -- Storage = Plug-in Table keeps saved files per application and Storage Name (without one:
    -- P<page>.<column Static ID or name>). After moving the grid to another page, renaming the column,
    -- giving it a Storage Name or importing the application under another ID, move the files once -
    -- while nobody edits that grid's attachments - and COMMIT:
    --     iga_api.move_files('P300.ATTACHMENT_EDIT', 'EXPENSES', 1530, 2530);
    -- p_to_application_id defaults to p_from_application_id. Prints how many files were moved.
    -- (Storage = My Table: the files are in your table and need nothing.)
    procedure move_files(p_from_scope varchar2, p_to_scope varchar2,
                         p_from_application_id number, p_to_application_id number default null);

    procedure render(
        p_item in apex_plugin.t_item, p_plugin in apex_plugin.t_plugin,
        p_param in apex_plugin.t_item_render_param,
        p_result in out nocopy apex_plugin.t_item_render_result);
    procedure ajax(
        p_item in apex_plugin.t_item, p_plugin in apex_plugin.t_plugin,
        p_param in apex_plugin.t_item_ajax_param,
        p_result in out nocopy apex_plugin.t_item_ajax_result);
end iga_api;
/
