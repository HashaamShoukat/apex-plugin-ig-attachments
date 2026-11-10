create or replace package body iga_api as
    -- IG Attachments 1.0.0
    g_workspace number;
    g_app number;
    g_session number;
    g_user varchar2(255);

    -- limits of a column: Page Designer settings, else the plug-in's defaults; staging limits from the
    -- plug-in's Component Settings
    type t_cfg is record (
        max_file_bytes number := 10485760, max_file_count number := 10,
        allowed_extensions varchar2(1000) := 'pdf,png,jpg,jpeg,txt',
        session_quota_bytes number := 104857600, user_quota_bytes number := 209715200,
        total_quota_bytes number := 268435456);
    -- The grid that holds the attachment column, as Page Designer saved it. It decides who may see and
    -- change a row's files (see the package spec). Read once per request.
    type t_grid is record (
        page_id number, region_id number, column_name varchar2(255), scope varchar2(255),
        pk varchar2(255), qtype varchar2(30), src clob, towner varchar2(128), tname varchar2(128),
        twhere varchar2(32767), ops varchar2(30), add_auth varchar2(255), upd_auth varchar2(255),
        del_auth varchar2(255), auth_fn varchar2(261), attrs clob, row_ops varchar2(255),
        -- Read Only conditions of the page, the grid region and the column (type code, expressions)
        page_ro varchar2(255), page_e1 varchar2(4000), page_e2 varchar2(4000),
        reg_ro varchar2(255), reg_e1 varchar2(4000), reg_e2 varchar2(4000),
        col_ro varchar2(255), col_e1 varchar2(4000), col_e2 varchar2(4000), col_each_row boolean,
        ro_known boolean, ro boolean,
        -- Authorization Scheme and Build Option of the grid region and of the column; Edit Enabled
        reg_auth varchar2(255), reg_bo varchar2(255), col_auth varchar2(255), col_bo varchar2(255),
        editable varchar2(10), used_known boolean, used boolean);
    g_grid t_grid;
    g_grid_key varchar2(400);
    type t_auth is table of boolean index by varchar2(700);
    g_auth t_auth;

    -- Where saved files live: the plug-in's IGA_FILES, or the developer's own table (Storage = My Table).
    -- Names come from the column's attributes (never from the browser) and pass DBMS_ASSERT.
    type t_names is varray(3) of varchar2(200);
    type t_store is record (
        kind varchar2(10), tab varchar2(261), pk varchar2(128), fk varchar2(128),
        fname varchar2(128), mime varchar2(128), content varchar2(128), fsize varchar2(128),
        -- Extra Fields 1-3: column (null = field not used), required Y/N, label
        fcol t_names := t_names(null, null, null), freq varchar2(3) := 'NNN',
        flabel t_names := t_names(null, null, null));
    g_store t_store;
    -- Extra Field settings of the column
    type t_field is record (
        kind varchar2(10), label varchar2(200), col varchar2(128), dkind varchar2(10), dval varchar2(128), req boolean,
        -- the length the developer's column holds (Storage = My Table): characters (maxchar) or bytes
        maxlen number, maxchar boolean);
    type t_fields is table of t_field index by pls_integer;
    g_fields t_fields;
    type t_vals is varray(3) of varchar2(4000);
    -- the file name column of the developer's table (Storage = My Table): its length (see col_len)
    g_fname_len number;
    g_fname_char boolean;

    procedure fail(p_message varchar2) is
    begin raise_application_error(-20001, p_message); end;

    -- a new request: nothing read before may be reused (package state survives in pooled sessions)
    procedure begin_request is
    begin
        g_auth.delete;
        g_grid_key := null;
    end;

    -- A refusal in the grid's row process. Raised, APEX shows it as "ORA-20001: ...", so in a page
    -- request (unless p_raise) the plain message goes on the APEX error stack instead: APEX rolls the
    -- row back and the save stops, but the row process continues after the call.
    procedure row_error(p_sqlcode number, p_sqlerrm varchar2, p_raise boolean) is
        l_msg varchar2(4000) := case when p_sqlcode = -20001 then substr(p_sqlerrm, 12) else p_sqlerrm end;
    begin
        if p_sqlcode = -20001 and not p_raise and v('APP_PAGE_ID') is not null then
            -- (APEX gives the grid's row processing no row number - APEX$ROW_NUM is empty there - so the
            -- message cannot be put on the row's cell; it goes to the page notification)
            apex_debug.info('IG Attachments: save refused (row status %s, column %s): %s',
                            v('APEX$ROW_STATUS'), g_grid.column_name, l_msg);
            apex_error.add_error(p_message => l_msg, p_display_location => apex_error.c_inline_in_notification);
        else
            raise_application_error(-20001, l_msg);
        end if;
    end;

    function is_token(p varchar2) return boolean is
    begin return p is not null and regexp_like(p, '^[A-F0-9]{32}$'); end;

    function own return boolean is begin return g_store.kind = 'TABLE'; end;

    function checked(p_kind varchar2, p_tab varchar2, p_pk varchar2, p_fk varchar2, p_fname varchar2,
                     p_mime varchar2, p_content varchar2, p_fsize varchar2,
                     p_fcols t_names default t_names(null, null, null), p_freq varchar2 default 'NNN',
                     p_flabels t_names default t_names(null, null, null)) return t_store is
        s t_store;
        function col(p_name varchar2) return varchar2 is
        begin return dbms_assert.simple_sql_name(upper(trim(p_name))); end;
    begin
        s.kind := nvl(p_kind, 'PLUGIN');
        if s.kind = 'TABLE' then
            s.tab := dbms_assert.sql_object_name(upper(trim(p_tab)));
            s.pk := col(p_pk); s.fk := col(p_fk); s.fname := col(p_fname);
            s.mime := col(p_mime); s.content := col(p_content);
            if trim(p_fsize) is not null then s.fsize := col(p_fsize); end if;
        end if;
        for i in 1 .. 3 loop
            if trim(p_fcols(i)) is not null then
                -- the plug-in table has fixed columns F1-F3
                s.fcol(i) := case when s.kind = 'TABLE' then col(p_fcols(i)) else 'F' || i end;
            end if;
            s.flabel(i) := substr(replace(p_flabels(i), '|', '/'), 1, 200);
        end loop;
        s.freq := rpad(nvl(p_freq, 'NNN'), 3, 'N');
        return s;
    exception when others then
        fail('Check the Storage settings of the attachment column: ' || sqlerrm);
        return s;
    end;

    function attr(p_item apex_plugin.t_item, p_no pls_integer) return varchar2 is
    begin
        if p_item.attributes is null then return null; end if;
        return p_item.attributes.get_varchar2('attribute_' || to_char(p_no, 'FM00'));
    end;

    function num(p_value varchar2) return number is
    begin
        return to_number(replace(trim(p_value), ',', '.'), '99999990D999999', 'NLS_NUMERIC_CHARACTERS=''.,''');
    exception when others then return null;
    end;

    -- Extra Field i: b = type (TEXT or HIDDEN), b+1 label, b+2 column, b+4 value from (COLUMN or ITEM),
    -- b+5 the grid column or page item, b+6 required
    function fields_of(p_item apex_plugin.t_item) return t_fields is
        l t_fields;
        b pls_integer;
    begin
        for i in 1 .. 3 loop
            b := 19 + (i - 1) * 7;
            l(i).kind := case nvl(attr(p_item, b), 'NONE') when 'NONE' then 'NONE' when 'HIDDEN' then 'HIDDEN' else 'TEXT' end;
            l(i).label := nvl(attr(p_item, b + 1), 'Field ' || i);
            l(i).col := attr(p_item, b + 2);
            l(i).dkind := case when attr(p_item, b + 4) in ('COLUMN', 'ITEM') and trim(attr(p_item, b + 5)) is not null
                               then attr(p_item, b + 4) else 'NONE' end;
            l(i).dval := upper(trim(attr(p_item, b + 5)));
            -- Required only for a Text Field: a Hidden value cannot be filled in by the user
            l(i).req := nvl(attr(p_item, b + 6) in ('Y', 'true') and l(i).kind = 'TEXT', false);
        end loop;
        return l;
    end;

    -- How much text a column of the developer's table holds: characters (CHAR semantics) or bytes; null
    -- when it is no text column or cannot be read (the database then says it on save, as before).
    procedure col_len(p_tab varchar2, p_col varchar2, p_len out number, p_char out boolean) is
        l_owner varchar2(128); l_name varchar2(128); l_used varchar2(1); l_chars number; l_bytes number;
    begin
        p_len := null; p_char := false;
        if p_tab is null or p_col is null then return; end if;
        if instr(p_tab, '.') > 0 then
            l_owner := replace(substr(p_tab, 1, instr(p_tab, '.') - 1), '"');
            l_name := replace(substr(p_tab, instr(p_tab, '.') + 1), '"');
        else
            l_owner := sys_context('userenv', 'current_schema'); l_name := replace(p_tab, '"');
        end if;
        select char_used, char_length, data_length into l_used, l_chars, l_bytes from all_tab_columns
         where owner = l_owner and table_name = l_name and column_name = replace(p_col, '"')
           and data_type in ('VARCHAR2', 'NVARCHAR2', 'CHAR', 'NCHAR');
        p_char := l_used = 'C';
        p_len := case when p_char then l_chars else l_bytes end;
    exception when others then p_len := null; p_char := false;
    end;

    function store_of(p_item apex_plugin.t_item) return t_store is
        l_cols t_names := t_names(null, null, null);
        l_labels t_names := t_names(null, null, null);
        l_req varchar2(3);
        l_kind varchar2(10) := attr(p_item, 11);
        l_store t_store;
    begin
        g_fields := fields_of(p_item);
        for i in 1 .. 3 loop
            if g_fields(i).kind <> 'NONE' then
                if nvl(l_kind, 'PLUGIN') = 'TABLE' and trim(g_fields(i).col) is null then
                    fail('Extra Field ' || i || ' (' || g_fields(i).label || ') needs a Column of the attachments table.');
                end if;
                l_cols(i) := nvl(g_fields(i).col, 'F' || i);
            end if;
            l_labels(i) := g_fields(i).label;
            l_req := l_req || case when g_fields(i).req then 'Y' else 'N' end;
        end loop;
        l_store := checked(l_kind, attr(p_item, 12), attr(p_item, 13), attr(p_item, 14), attr(p_item, 15),
                           attr(p_item, 16), attr(p_item, 17), attr(p_item, 18), l_cols, l_req, l_labels);
        g_fname_len := null; g_fname_char := false;
        if l_store.kind = 'TABLE' then
            for i in 1 .. 3 loop
                if g_fields(i).kind <> 'NONE' then col_len(l_store.tab, l_store.fcol(i), g_fields(i).maxlen, g_fields(i).maxchar); end if;
            end loop;
            col_len(l_store.tab, l_store.fname, g_fname_len, g_fname_char);
        end if;
        return l_store;
    end;

    -- kept with the edit token: finalize_edit runs in the row process, without the column
    function store_text(s t_store) return varchar2 is
    begin
        return s.kind || '|' || s.tab || '|' || s.pk || '|' || s.fk || '|' || s.fname || '|' || s.mime || '|' || s.content ||
            '|' || s.fsize || '|' || s.fcol(1) || '|' || s.fcol(2) || '|' || s.fcol(3) || '|' || s.freq ||
            '|' || s.flabel(1) || '|' || s.flabel(2) || '|' || s.flabel(3);
    end;

    function store_from(p_text varchar2) return t_store is
        l apex_t_varchar2 := apex_string.split(p_text, '|');
    begin
        if p_text is null or l.count < 8 then return checked('PLUGIN', null, null, null, null, null, null, null); end if;
        if l.count < 15 then return checked(l(1), l(2), l(3), l(4), l(5), l(6), l(7), l(8)); end if;
        return checked(l(1), l(2), l(3), l(4), l(5), l(6), l(7), l(8),
                       t_names(l(9), l(10), l(11)), l(12), t_names(l(13), l(14), l(15)));
    end;

    -- select-list expression of Extra Field i in queries on the developer's table (alias t)
    function fexpr(i pls_integer) return varchar2 is
    begin return case when g_store.fcol(i) is not null then 't.' || g_store.fcol(i) else 'null' end; end;

    -- what the browser sent for the fields of a file (Hidden values: from the grid column or page item
    -- when the file is added; they stay as they are on saved files)
    function field_values(p_key varchar2, p_old t_vals default null) return t_vals is
        l t_vals := t_vals(null, null, null);
        l_v varchar2(32767);
    begin
        for i in 1 .. 3 loop
            l_v := case when apex_application.g_f02.exists(i) then apex_application.g_f02(i) end;
            if g_fields(i).kind = 'NONE' then
                l_v := null;
            elsif g_fields(i).kind = 'HIDDEN' and p_old is not null then
                l_v := p_old(i);
            elsif g_fields(i).kind = 'HIDDEN' and g_fields(i).dkind = 'NONE' then
                -- a Hidden field without Value From gets nothing from the browser
                l_v := null;
            end if;
            -- the staging columns hold 4000 bytes; the developer's column may hold less
            if length(l_v) > 4000 or lengthb(l_v) > 4000 then fail(g_fields(i).label || ' is too long.'); end if;
            if l_v is not null and g_fields(i).maxlen is not null and
               (case when g_fields(i).maxchar then length(l_v) else lengthb(l_v) end) > g_fields(i).maxlen then
                fail(g_fields(i).label || ' is too long (at most ' || g_fields(i).maxlen ||
                     case when g_fields(i).maxchar then ' characters).' else ' bytes).' end);
            end if;
            l(i) := l_v;
        end loop;
        return l;
    end;

    -- size of a saved file in the developer's table: the size column, else the BLOB's length
    function size_expr return varchar2 is
    begin return case when g_store.fsize is not null then 't.' || g_store.fsize else 'dbms_lob.getlength(t.' || g_store.content || ')' end; end;

    -- the request's APEX context and the plug-in's default limits
    function settings(p_scope varchar2 default null) return t_cfg is
        l t_cfg;
    begin
        g_workspace := apex_custom_auth.get_security_group_id;
        g_app := apex_application.g_flow_id;
        g_session := to_number(v('APP_SESSION'));
        g_user := v('APP_USER');
        if not apex_authentication.is_authenticated then fail('Sign in to manage attachments.'); end if;
        return l;
    end;

    function q(p_name varchar2) return varchar2 is begin return dbms_assert.enquote_name(p_name, false); end;

    -- The attachment column p_column (name or Static ID; null = the only one) of page p_page and its grid.
    -- p_column_id: the column's id (render and Ajax of the plug-in pass their own). The column is found by
    -- its id, its Static ID or the DOM id APEX gives a column without a Static ID (C<column id>) first,
    -- then by its name - so the same name in two grids of a page is no problem.
    procedure load_grid(p_page number, p_column varchar2, p_column_id number default null) is
        l_key varchar2(400) := p_page || '|' || upper(p_column) || '|' || p_column_id;
        l_n number;
        l_col number;
        l_each varchar2(10);
        l_static varchar2(255);
    begin
        if g_grid_key = l_key then return; end if;
        g_grid := null;
        select count(*), max(column_id) into l_n, l_col from apex_appl_page_ig_columns
         where application_id = g_app and page_id = p_page and item_type like 'PLUGIN\_%IG\_ATTACHMENTS' escape '\'
           and (column_id = p_column_id or upper(static_id) = upper(p_column) or 'C' || column_id = upper(p_column));
        if l_n <> 1 then
            select count(*), max(column_id) into l_n, l_col from apex_appl_page_ig_columns
             where application_id = g_app and page_id = p_page and item_type like 'PLUGIN\_%IG\_ATTACHMENTS' escape '\'
               and (p_column is null or upper(static_id) = upper(p_column) or upper(name) = upper(p_column));
            if l_n = 0 then fail('No IG Attachments column ' || p_column || ' on page ' || p_page || '.'); end if;
            if l_n > 1 then fail('Page ' || p_page || ' has more than one IG Attachments column: pass p_column.'); end if;
        end if;
        select region_id, name, static_id, attributes, read_only_condition_type_code,
               read_only_condition_exp1, read_only_condition_exp2, readonly_for_each_row,
               to_char(authorization_scheme_id), to_char(build_option_id)
          into g_grid.region_id, g_grid.column_name, l_static, g_grid.attrs, g_grid.col_ro,
               g_grid.col_e1, g_grid.col_e2, l_each, g_grid.col_auth, g_grid.col_bo
          from apex_appl_page_ig_columns
         where application_id = g_app and page_id = p_page and column_id = l_col;
        g_grid.page_id := p_page;
        g_grid.col_each_row := upper(substr(l_each, 1, 1)) = 'Y';
        g_grid.auth_fn := trim(json_value(g_grid.attrs, '$.attribute_59'));
        -- files of the plug-in table are kept under the column's Storage Name, else page and column
        g_grid.scope := substr(nvl(trim(json_value(g_grid.attrs, '$.attribute_01')),
                                   'P' || p_page || '.' || upper(nvl(l_static, g_grid.column_name))), 1, 64);
        -- Two attachment columns of the page with the same default name (e.g. ATTACHMENT_EDIT in two grids)
        -- would keep their files together: they need a Static ID or a Storage Name.
        if trim(json_value(g_grid.attrs, '$.attribute_01')) is null then
            select count(*) into l_n from apex_appl_page_ig_columns
             where application_id = g_app and page_id = p_page and item_type like 'PLUGIN\_%IG\_ATTACHMENTS' escape '\'
               and column_id <> l_col and trim(json_value(attributes, '$.attribute_01')) is null
               and substr('P' || p_page || '.' || upper(nvl(static_id, name)), 1, 64) = g_grid.scope;
            if l_n > 0 then
                fail('Page ' || p_page || ' has two IG Attachments columns named ' || g_grid.column_name ||
                     ': give each a Static ID or a Storage Name.');
            end if;
        end if;
        begin
            select name into g_grid.pk from apex_appl_page_ig_columns
             where region_id = g_grid.region_id and is_primary_key = 'Yes';
        exception
            when no_data_found then fail('IG Attachments needs a grid with a primary key column.');
            when too_many_rows then fail('IG Attachments needs a grid with one primary key column.');
        end;
        select query_type_code, region_source, table_owner, table_name, where_clause,
               read_only_condition_type_code, read_only_condition_exp1, read_only_condition_exp2,
               to_char(authorization_scheme_id), to_char(build_option_id)
          into g_grid.qtype, g_grid.src, g_grid.towner, g_grid.tname, g_grid.twhere,
               g_grid.reg_ro, g_grid.reg_e1, g_grid.reg_e2, g_grid.reg_auth, g_grid.reg_bo
          from apex_application_page_regions where region_id = g_grid.region_id;
        select edit_operations, add_authorization_scheme, update_authorization_scheme, delete_authorization_scheme,
               edit_row_operations_column, is_editable
          into g_grid.ops, g_grid.add_auth, g_grid.upd_auth, g_grid.del_auth, g_grid.row_ops, g_grid.editable
          from apex_appl_page_igs where region_id = g_grid.region_id;
        select read_only_condition_type_code, read_only_condition_exp1, read_only_condition_exp2
          into g_grid.page_ro, g_grid.page_e1, g_grid.page_e2
          from apex_application_pages where application_id = g_app and page_id = p_page;
        g_grid_key := l_key;
    end;

    -- Is the row in this user's grid, and may it be changed (U) or deleted (D)? The grid's own query
    -- (its WHERE clause, page items, :APP_USER ...) filtered by the primary key; with an Allowed Row
    -- Operations Column the row's value of it must contain the operation (null = neither).
    function grid_from return varchar2 is
    begin
        if g_grid.qtype = 'SQL' then
            return '(' || rtrim(rtrim(dbms_lob.substr(g_grid.src, 32000, 1)), ';') || ') iga_q where ';
        elsif g_grid.qtype = 'TABLE' then
            return case when g_grid.towner is not null then q(g_grid.towner) || '.' end || q(g_grid.tname) ||
                   ' iga_q where ' || case when g_grid.twhere is not null then '(' || g_grid.twhere || ') and ' end;
        end if;
        fail('IG Attachments needs a grid whose source is a SQL Query or a Table / View.');
        return null;
    end;

    function row_allows(p_key varchar2, p_op varchar2 default null) return boolean is
        l_sql varchar2(32767);
        l_from varchar2(32767);
        l_ctx apex_exec.t_context;
        l_params apex_exec.t_parameters;
        l_n number := 0;
        l_ops varchar2(4000);
    begin
        if p_key is null then return false; end if;
        l_from := grid_from;
        l_sql := 'select count(*), ' || case when g_grid.row_ops is not null then 'max(to_char(iga_q.' || q(g_grid.row_ops) || '))'
                                             else 'null' end ||
                 ' from ' || l_from || 'iga_q.' || q(g_grid.pk) || ' = :IGA_ROW_KEY';
        apex_exec.add_parameter(l_params, 'IGA_ROW_KEY', p_key);
        l_ctx := apex_exec.open_query_context(p_location => apex_exec.c_location_local_db,
                     p_sql_query => l_sql, p_sql_parameters => l_params);
        if apex_exec.next_row(l_ctx) then
            l_n := apex_exec.get_number(l_ctx, 1);
            l_ops := apex_exec.get_varchar2(l_ctx, 2);
        end if;
        apex_exec.close(l_ctx);
        if l_n = 0 then return false; end if;
        return p_op is null or g_grid.row_ops is null or nvl(instr(upper(l_ops), p_op), 0) > 0;
    exception when others then
        begin apex_exec.close(l_ctx); exception when others then null; end;
        raise;
    end;

    -- A Read Only condition of Page Designer, as APEX evaluates it: true = read only. A condition the
    -- server cannot evaluate counts as read only.
    function condition_true(p_type varchar2, p_e1 varchar2, p_e2 varchar2) return boolean is
    begin
        if p_type is null or p_type = 'NEVER' then return false; end if;
        if p_type = 'ALWAYS' then return true; end if;
        return nvl(apex_plugin_util.is_component_used(p_build_option_id => null, p_authorization_scheme_id => null,
            p_condition_type => p_type, p_condition_expression1 => p_e1, p_condition_expression2 => p_e2), true);
    exception when others then
        -- safe, but say why the files are read only
        apex_debug.warn('IG Attachments: Read Only condition %s could not be evaluated, treated as read only: %s', p_type, sqlerrm);
        return true;
    end;

    -- Is the column read only - by the page, the grid region or the column itself? (A column condition
    -- APEX evaluates for each row: row_read_only.)
    function read_only return boolean is
    begin
        if not nvl(g_grid.ro_known, false) then
            g_grid.ro := condition_true(g_grid.page_ro, g_grid.page_e1, g_grid.page_e2)
                or condition_true(g_grid.reg_ro, g_grid.reg_e1, g_grid.reg_e2)
                or case when nvl(g_grid.col_each_row, false) and nvl(g_grid.col_ro, 'NEVER') <> 'ALWAYS' then false
                        else condition_true(g_grid.col_ro, g_grid.col_e1, g_grid.col_e2) end;
            g_grid.ro_known := true;
        end if;
        return g_grid.ro;
    end;

    -- A column Read Only condition APEX evaluates for each row, on a saved row's values - as APEX does when
    -- it fetches the row (new rows are not fetched: like APEX, their files can be added). In the grid's
    -- row processing APEX has set the row's values already; otherwise the row is read through the grid's
    -- query and its values are set for the evaluation. A row that cannot be read counts as read only.
    function row_read_only(p_key varchar2) return boolean is
        l_cols apex_plugin_util.t_column_list;
        l_binds apex_plugin_util.t_bind_list;
        l_ro boolean;
    begin
        if p_key is null or not nvl(g_grid.col_each_row, false) or nvl(g_grid.col_ro, 'NEVER') in ('NEVER', 'ALWAYS') then
            return false;
        end if;
        if v('APEX$ROW_STATUS') is not null then
            return condition_true(g_grid.col_ro, g_grid.col_e1, g_grid.col_e2);
        end if;
        l_binds(1).name := 'IGA_ROW_KEY';
        l_binds(1).value := p_key;
        l_cols := apex_plugin_util.get_data2(
            p_sql_statement  => 'select iga_q.* from ' || grid_from || 'iga_q.' || q(g_grid.pk) || ' = :IGA_ROW_KEY',
            p_min_columns    => 1,
            p_max_columns    => 999,
            p_component_name => null,
            p_max_rows       => 1,
            p_bind_list      => l_binds);
        if l_cols.count = 0 or l_cols(1).value_list.count = 0 then return true; end if;
        apex_plugin_util.set_component_values(p_column_value_list => l_cols, p_row_num => 1);
        l_ro := condition_true(g_grid.col_ro, g_grid.col_e1, g_grid.col_e2);
        apex_plugin_util.clear_component_values;
        return l_ro;
    exception when others then
        begin apex_plugin_util.clear_component_values; exception when others then null; end;
        apex_debug.warn('IG Attachments: row %s could not be read for its Read Only condition, treated as read only: %s', p_key, sqlerrm);
        return true;
    end;

    function scheme_ok(p_scheme varchar2) return boolean is
    begin
        return p_scheme is null or apex_authorization.is_authorized(p_authorization_name => p_scheme);
    exception when others then
        apex_debug.warn('IG Attachments: authorization scheme %s could not be checked, treated as not authorized: %s', p_scheme, sqlerrm);
        return false;
    end;

    -- Are the grid region and the column there for this user - their Authorization Scheme and Build
    -- Option, as APEX checks them when it renders the page? (Server-side Conditions are not evaluated:
    -- one like "Request = SAVE" is false in every plug-in request.) Anything unclear counts as no.
    function component_used return boolean is
        function one(p_bo varchar2, p_auth varchar2) return boolean is
        begin
            if p_bo is null and p_auth is null then return true; end if;
            return nvl(apex_plugin_util.is_component_used(p_build_option_id => to_number(p_bo),
                p_authorization_scheme_id => p_auth, p_condition_type => null,
                p_condition_expression1 => null, p_condition_expression2 => null), false);
        exception when others then
            apex_debug.warn('IG Attachments: build option / authorization of the grid could not be checked, treated as unavailable: %s', sqlerrm);
            return false;
        end;
    begin
        if not nvl(g_grid.used_known, false) then
            g_grid.used := one(g_grid.reg_bo, g_grid.reg_auth) and one(g_grid.col_bo, g_grid.col_auth);
            g_grid.used_known := true;
        end if;
        return g_grid.used;
    end;

    -- Edit Enabled of the grid (the stored Allowed Operations stay when editing is switched off)
    function grid_editable return boolean is
    begin return nvl(upper(substr(g_grid.editable, 1, 1)), 'Y') = 'Y'; end;

    -- Limits set on the column in Page Designer override the plug-in's defaults.
    function limits(p_item apex_plugin.t_item, p_scope varchar2) return t_cfg is
        l_cfg t_cfg := settings(p_scope);
        l_types varchar2(1000) := lower(regexp_replace(replace(attr(p_item, 7), ';', ','), '[[:space:].]', ''));
    begin
        -- Maximum File Size is in KB
        if num(attr(p_item, 5)) > 0 then l_cfg.max_file_bytes := least(round(num(attr(p_item, 5)) * 1024), 52428800); end if;
        if num(attr(p_item, 6)) >= 1 then l_cfg.max_file_count := least(trunc(num(attr(p_item, 6))), 50); end if;
        if l_types is not null then l_cfg.allowed_extensions := trim(both ',' from l_types); end if;
        return l_cfg;
    end;

    -- Keep Unsaved Files (minutes, default 120) and Maximum Total Size per Row (KB) of the column
    function keep_of(p_item apex_plugin.t_item) return number is
    begin return least(greatest(nvl(trunc(num(attr(p_item, 47))), 120), 5), 10080); end;

    function max_total_bytes(p_item apex_plugin.t_item) return number is
    begin return case when num(attr(p_item, 48)) > 0 then round(num(attr(p_item, 48)) * 1024) end; end;

    -- saved files of a row that are not marked for removal in this edit
    function saved_count(p_scope varchar2, p_key varchar2, p_token varchar2) return number is
        l_n number;
    begin
        if p_key is null then return 0; end if;
        if own then
            execute immediate 'select count(*) from ' || g_store.tab || ' t where t.' || g_store.fk || ' = :k
                and not exists (select 1 from iga_removals d where d.edit_token = :t and d.file_id = to_char(t.' || g_store.pk || '))'
                into l_n using p_key, p_token;
        else
            select count(*) into l_n from iga_files f where f.workspace_id = g_workspace and f.application_id = g_app
               and f.scope_name = p_scope and f.record_key = p_key
               and not exists (select 1 from iga_removals d where d.edit_token = p_token and d.file_id = f.file_id);
        end if;
        return l_n;
    end;

    function saved_bytes(p_scope varchar2, p_key varchar2, p_token varchar2) return number is
        l_n number;
    begin
        if p_key is null then return 0; end if;
        if own then
            execute immediate 'select nvl(sum(' || size_expr || '), 0) from ' || g_store.tab || ' t where t.' || g_store.fk || ' = :k
                and not exists (select 1 from iga_removals d where d.edit_token = :t and d.file_id = to_char(t.' || g_store.pk || '))'
                into l_n using p_key, p_token;
        else
            select nvl(sum(file_bytes), 0) into l_n from iga_files f where f.workspace_id = g_workspace and f.application_id = g_app
               and f.scope_name = p_scope and f.record_key = p_key
               and not exists (select 1 from iga_removals d where d.edit_token = p_token and d.file_id = f.file_id);
        end if;
        return l_n;
    end;

    -- One saved file of the row; no_data_found when it is not this row's. The row key comes first in the
    -- condition, so the foreign-key index finds the row's few files; the file id is compared on those.
    procedure saved_file(p_scope varchar2, p_key varchar2, p_id varchar2,
                         p_blob out blob, p_name out varchar2, p_mime out varchar2) is
    begin
        if own then
            execute immediate 'select t.' || g_store.content || ', t.' || g_store.fname || ', t.' || g_store.mime ||
                ' from ' || g_store.tab || ' t where t.' || g_store.fk || ' = :k and to_char(t.' || g_store.pk || ') = :id'
                into p_blob, p_name, p_mime using p_key, p_id;
        else
            select file_blob, file_name, mime_type into p_blob, p_name, p_mime from iga_files
             where file_id = p_id and workspace_id = g_workspace and application_id = g_app
               and scope_name = p_scope and record_key = p_key;
        end if;
    end;

    -- The grid decides (each operation and key once per request): READ - the row is in the user's grid;
    -- CREATE - the grid can add rows; WRITE / DELETE - the row is in the grid and the grid can update /
    -- delete it (authorization schemes and the Allowed Row Operations Column included). CREATE and WRITE
    -- also need the column not to be read only (see read_only).
    -- Then the column's optional Authorization Function: f(p_key varchar2, p_operation varchar2) return boolean.
    procedure authorize(p_scope varchar2, p_key varchar2, p_operation varchar2) is
        l_allowed boolean;
        l_ck varchar2(700) := p_operation || '|' || substr(p_key, 1, 512);
    begin
        if g_auth.exists(l_ck) then return; end if;
        -- the grid and the column must be there for the user at all; changes need an editable grid
        if not component_used or (p_operation <> 'READ' and not grid_editable) then
            fail('Attachment access denied.');
        end if;
        l_allowed := case p_operation
            when 'CREATE' then instr(g_grid.ops, 'i') > 0 and scheme_ok(g_grid.add_auth) and not read_only
            -- SAVE: WRITE when the grid saves a row whose edit was opened with WRITE (each panel request
            -- checked the row in the grid then). The row's new values may leave the grid's filter or
            -- meet a per-row Read Only condition - as in APEX, that does not refuse the save itself.
            when 'SAVE'   then instr(g_grid.ops, 'u') > 0 and scheme_ok(g_grid.upd_auth) and not read_only
            when 'READ'   then row_allows(p_key)
            when 'WRITE'  then instr(g_grid.ops, 'u') > 0 and scheme_ok(g_grid.upd_auth) and not read_only and row_allows(p_key, 'U')
                               and not row_read_only(p_key)
            when 'DELETE' then instr(g_grid.ops, 'd') > 0 and scheme_ok(g_grid.del_auth) and row_allows(p_key, 'D')
            else false end;
        if l_allowed and g_grid.auth_fn is not null then
            -- only the developer's function named on the column, never browser input
            execute immediate 'begin :r := ' || dbms_assert.qualified_sql_name(g_grid.auth_fn) || '(:k, :o); end;'
                using out l_allowed, in p_key, in case p_operation when 'SAVE' then 'WRITE' else p_operation end;
        end if;
        if l_allowed is null or not l_allowed then fail('Attachment access denied.'); end if;
        g_auth(l_ck) := true;
    end;

    -- authorize without the refusal: true when the operation is allowed
    function allowed(p_scope varchar2, p_key varchar2, p_operation varchar2) return boolean is
    begin
        authorize(p_scope, p_key, p_operation);
        return true;
    exception when others then
        if sqlcode = -20001 then return false; end if;
        raise;
    end;

    function get_edit(p_scope varchar2, p_token varchar2, p_key varchar2)
        return iga_edits%rowtype is
        l_edit iga_edits%rowtype;
    begin
        if not is_token(p_token) then fail('Invalid attachment edit token.'); end if;
        select * into l_edit from iga_edits where edit_token = p_token
          and workspace_id = g_workspace and application_id = g_app and scope_name = p_scope
          and session_id = g_session and user_name = g_user and expires_at > systimestamp
          for update;
        if nvl(l_edit.record_key, chr(1)) <> nvl(p_key, chr(1)) then
            fail('Attachments belong to a different record. Reopen the cell.');
        end if;
        if l_edit.status = 'A' then
            -- Keep Unsaved Files counts from the last action in the panel
            update iga_edits set expires_at = systimestamp + numtodsinterval(keep_minutes, 'MINUTE')
             where edit_token = p_token;
        end if;
        return l_edit;
    exception when no_data_found then
        fail('Attachment edits have expired. Reopen the cell.');
        return l_edit;
    end;

    procedure active_edit(p_scope varchar2, p_token varchar2, p_key varchar2) is
        l_edit iga_edits%rowtype;
    begin
        authorize(p_scope, p_key, case when p_key is null then 'CREATE' else 'WRITE' end);
        l_edit := get_edit(p_scope, p_token, p_key);
        if l_edit.status <> 'A' then fail('This edit was already saved. Reopen the cell.'); end if;
    end;

    procedure ensure_version(p_scope varchar2, p_key varchar2) is
    begin
        insert into iga_record_versions(workspace_id, application_id, scope_name, record_key)
        values(g_workspace, g_app, p_scope, p_key);
    exception when dup_val_on_index then null;
    end;

    function new_edit(p_scope varchar2, p_key varchar2, p_max_count number, p_max_total number,
                      p_keep number, p_storage varchar2) return varchar2 is
        l_token varchar2(32) := rawtohex(sys_guid());
        l_version number := 0;
        l_count number;
    begin
        authorize(p_scope, p_key, case when p_key is null then 'CREATE' else 'WRITE' end);
        if p_key is not null then
            ensure_version(p_scope, p_key);
            select attachment_version into l_version from iga_record_versions
             where workspace_id = g_workspace and application_id = g_app
               and scope_name = p_scope and record_key = p_key;
            -- An empty edit of this row (opened and closed without a change) is reused only when the panel
            -- presents its token (see refresh_empty_edit): another tab of the same session gets its own.
        end if;
        -- a few expired edits go now, too: staging cannot fill up when the IGA_PURGE_EXPIRED job is missing
        delete from iga_edits where expires_at < systimestamp and rownum <= 50;
        -- only edits that hold something count: viewing rows never locks a user out
        select count(*) into l_count from iga_edits e where workspace_id = g_workspace
          and application_id = g_app and session_id = g_session and status = 'A'
          and expires_at > systimestamp
          and (exists (select 1 from iga_uploads u where u.edit_token = e.edit_token)
               or exists (select 1 from iga_removals d where d.edit_token = e.edit_token)
               or exists (select 1 from iga_changes c where c.edit_token = e.edit_token));
        if l_count >= 100 then fail('Too many pending rows. Save changes or reopen later.'); end if;
        -- empty edits (e.g. new rows opened without a change) are kept to the newest 100 of the session
        select count(*) into l_count from iga_edits e where workspace_id = g_workspace
          and application_id = g_app and session_id = g_session and status = 'A'
          and not exists (select 1 from iga_uploads u where u.edit_token = e.edit_token)
          and not exists (select 1 from iga_removals d where d.edit_token = e.edit_token)
          and not exists (select 1 from iga_changes c where c.edit_token = e.edit_token);
        if l_count >= 200 then
            delete from iga_edits where edit_token in (
                select edit_token from iga_edits e where workspace_id = g_workspace
                   and application_id = g_app and session_id = g_session and status = 'A'
                   and not exists (select 1 from iga_uploads u where u.edit_token = e.edit_token)
                   and not exists (select 1 from iga_removals d where d.edit_token = e.edit_token)
                   and not exists (select 1 from iga_changes c where c.edit_token = e.edit_token)
                 order by created_at desc offset 100 rows);
        end if;
        -- The token keeps the column's limits and storage: finalize_edit has no column to read them from.
        insert into iga_edits(edit_token, workspace_id, application_id, scope_name, record_key, session_id, user_name,
            base_version, max_file_count, max_total_bytes, keep_minutes, storage, expires_at, page_id, column_name)
        values(l_token, g_workspace, g_app, p_scope, p_key, g_session, g_user,
            l_version, p_max_count, p_max_total, p_keep, p_storage, systimestamp + numtodsinterval(p_keep, 'MINUTE'),
            g_grid.page_id, g_grid.column_name);
        return l_token;
    end;

    -- The panel presents its own empty edit of the row again (opened and closed without a change): it is
    -- reused with the column's current settings and the row's current version (a save by somebody else
    -- in between is no conflict - nothing was changed in this edit yet).
    procedure refresh_empty_edit(p_scope varchar2, p_key varchar2, p_token varchar2, p_max_count number,
                                 p_max_total number, p_keep number, p_storage varchar2) is
        l_version number := 0;
    begin
        if p_key is null then return; end if;
        ensure_version(p_scope, p_key);
        select attachment_version into l_version from iga_record_versions
         where workspace_id = g_workspace and application_id = g_app and scope_name = p_scope and record_key = p_key;
        update iga_edits e set base_version = l_version, max_file_count = p_max_count, max_total_bytes = p_max_total,
               keep_minutes = p_keep, storage = p_storage, expires_at = systimestamp + numtodsinterval(p_keep, 'MINUTE')
         where edit_token = p_token and status = 'A'
           and not exists (select 1 from iga_uploads u where u.edit_token = e.edit_token)
           and not exists (select 1 from iga_removals d where d.edit_token = e.edit_token)
           and not exists (select 1 from iga_changes c where c.edit_token = e.edit_token);
    end;

    procedure list_files(p_scope varchar2, p_key varchar2, p_token varchar2) is
        l_edit iga_edits%rowtype;
        c sys_refcursor;
        l_fid varchar2(100); l_fname varchar2(1000); l_mime varchar2(255); l_bytes number; l_removed number;
        l_v1 varchar2(4000); l_v2 varchar2(4000); l_v3 varchar2(4000); l_changed boolean;
        procedure vals(p1 varchar2, p2 varchar2, p3 varchar2) is
        begin
            apex_json.open_array('values');
            apex_json.write(p1); apex_json.write(p2); apex_json.write(p3);
            apex_json.close_array;
        end;
    begin
        authorize(p_scope, p_key, case when p_key is null then 'CREATE' else 'READ' end);
        if p_token is not null then l_edit := get_edit(p_scope, p_token, p_key); end if;
        apex_json.open_array('files');
        if p_key is not null then
            if own then
                open c for 'select to_char(t.' || g_store.pk || '), t.' || g_store.fname || ', t.' || g_store.mime ||
                    ', ' || size_expr || ', ' || fexpr(1) || ', ' || fexpr(2) || ', ' || fexpr(3) ||
                    ' from ' || g_store.tab || ' t where t.' || g_store.fk || ' = :k order by t.' || g_store.pk
                    using p_key;
            else
                open c for select file_id, file_name, mime_type, file_bytes, f1, f2, f3 from iga_files
                    where workspace_id = g_workspace and application_id = g_app
                      and scope_name = p_scope and record_key = p_key order by created_at, file_id;
            end if;
            loop
                fetch c into l_fid, l_fname, l_mime, l_bytes, l_v1, l_v2, l_v3;
                exit when c%notfound;
                select count(*) into l_removed from iga_removals where edit_token = p_token and file_id = l_fid;
                l_changed := false;
                for ch in (select f1, f2, f3 from iga_changes where edit_token = p_token and file_id = l_fid) loop
                    l_v1 := ch.f1; l_v2 := ch.f2; l_v3 := ch.f3; l_changed := true;
                end loop;
                apex_json.open_object;
                apex_json.write('id', l_fid); apex_json.write('name', l_fname);
                apex_json.write('mime', nvl(l_mime, 'application/octet-stream')); apex_json.write('size', l_bytes);
                apex_json.write('staged', false); apex_json.write('removed', l_removed > 0);
                apex_json.write('changed', l_changed); vals(l_v1, l_v2, l_v3);
                apex_json.write('ready', true); apex_json.close_object;
            end loop;
            close c;
        end if;
        if p_token is not null and l_edit.status = 'A' then
            for r in (select upload_id, file_name, mime_type, expected_bytes, status, f1, f2, f3,
                             dbms_lob.getlength(file_blob) received
                        from iga_uploads where edit_token = p_token order by upload_id) loop
                apex_json.open_object;
                apex_json.write('id', r.upload_id); apex_json.write('name', r.file_name);
                apex_json.write('mime', r.mime_type); apex_json.write('size', r.expected_bytes);
                apex_json.write('received', r.received); apex_json.write('staged', true);
                apex_json.write('removed', false); apex_json.write('ready', r.status = 'R');
                vals(r.f1, r.f2, r.f3);
                apex_json.close_object;
            end loop;
        end if;
        apex_json.close_array;
    end;

    procedure lock_row(p_workspace number, p_app number, p_id number) is
        l_n number;
    begin
        begin
            insert into iga_stage_locks(workspace_id, application_id, session_id)
            values(p_workspace, p_app, p_id);
        exception when dup_val_on_index then null; end;
        -- waits at most 10 seconds for another reservation (never hangs behind a stuck request)
        begin
            select session_id into l_n from iga_stage_locks where workspace_id = p_workspace
              and application_id = p_app and session_id = p_id for update wait 10;
        exception when others then
            if sqlcode in (-30006, -54) then fail('Other uploads are being reserved right now. Try again in a moment.'); end if;
            raise;
        end;
        update iga_stage_locks set touched_at = systimestamp where workspace_id = p_workspace
          and application_id = p_app and session_id = p_id;
    end;

    -- Staging reservations wait for each other, so no two can pass a limit together: this session's,
    -- this user's (a negative id from the user name; two users sharing one only wait more) and the
    -- installation's. Always in this order, so they cannot deadlock.
    procedure lock_session is
    begin
        lock_row(g_workspace, g_app, g_session);
        lock_row(g_workspace, g_app, -1 - dbms_utility.get_hash_value(upper(g_user), 1, 1073741824));
        lock_row(0, 0, -1);
    end;

    function mb(p_bytes number) return varchar2 is
    begin return to_char(round(p_bytes / 1048576)) || ' MB'; end;

    function start_upload(p_scope varchar2, p_key varchar2, p_token varchar2, l_cfg t_cfg) return varchar2 is
        l_name varchar2(255 char) := substr(regexp_replace(apex_application.g_x05, '[[:cntrl:]/\\]', '_'), 1, 255);
        l_ext varchar2(255);
        l_size number := to_number(apex_application.g_x06);
        l_count number; l_bytes number; l_edit iga_edits%rowtype;
        l_id varchar2(32) := rawtohex(sys_guid());
        l_vals t_vals;
    begin
        lock_session;
        active_edit(p_scope, p_token, p_key);
        select * into l_edit from iga_edits where edit_token = p_token;
        -- a name longer than the file name column of the developer's table is shortened; the extension stays
        if g_fname_len is not null and instr(l_name, '.') > 0 and
           (case when g_fname_char then length(l_name) else lengthb(l_name) end) > g_fname_len then
            l_ext := substr(l_name, instr(l_name, '.', -1));
            l_name := substr(l_name, 1, instr(l_name, '.', -1) - 1);
            while length(l_name) > 1 and (case when g_fname_char then length(l_name || l_ext) else lengthb(l_name || l_ext) end) > g_fname_len loop
                l_name := substr(l_name, 1, length(l_name) - 1);
            end loop;
            l_name := l_name || l_ext;
        end if;
        l_ext := lower(regexp_substr(l_name, '[^.]+$'));
        if l_name is null or instr(l_name, '.') = 0 or
           instr(',' || lower(replace(l_cfg.allowed_extensions, ' ', '')) || ',', ',' || l_ext || ',') = 0 then
            fail(l_name || ': this file type is not allowed.');
        end if;
        if l_size is null or l_size <> trunc(l_size) or l_size < 1 then
            fail(l_name || ' is empty.');
        end if;
        if l_size > l_cfg.max_file_bytes then
            fail(l_name || ' is larger than the ' || round(l_cfg.max_file_bytes / 1024) || ' KB limit.');
        end if;
        select count(*), nvl(sum(expected_bytes), 0) into l_count, l_bytes from iga_uploads where edit_token = p_token;
        if l_count + saved_count(p_scope, p_key, p_token) >= nvl(l_edit.max_file_count, l_cfg.max_file_count) then
            fail('Attachment count limit reached.');
        end if;
        if l_edit.max_total_bytes is not null and l_bytes + saved_bytes(p_scope, p_key, p_token) + l_size > l_edit.max_total_bytes then
            fail(l_name || ' would make the files of this row larger than ' || round(l_edit.max_total_bytes / 1024) || ' KB together.');
        end if;
        -- Staging limits: this session, this user, everybody (lock_session above serializes the reservations).
        -- (expired edits do not count: the purge removes them, and the user quota leaves them out too)
        select nvl(sum(u.expected_bytes), 0) into l_bytes from iga_uploads u join iga_edits e on e.edit_token = u.edit_token
         where e.workspace_id = g_workspace and e.application_id = g_app and e.session_id = g_session and e.status = 'A'
           and e.expires_at > systimestamp;
        if l_bytes + l_size > l_cfg.session_quota_bytes then
            fail('Files not saved yet in this session would exceed ' || mb(l_cfg.session_quota_bytes) || '. Save or remove files.');
        end if;
        select nvl(sum(u.expected_bytes), 0) into l_bytes from iga_uploads u join iga_edits e on e.edit_token = u.edit_token
         where e.workspace_id = g_workspace and e.application_id = g_app and e.user_name = g_user and e.status = 'A'
           and e.expires_at > systimestamp;
        if l_bytes + l_size > l_cfg.user_quota_bytes then
            fail('Your files not saved yet would exceed ' || mb(l_cfg.user_quota_bytes) || '. Save or remove files.');
        end if;
        select nvl(sum(expected_bytes), 0) into l_bytes from iga_uploads;
        if l_bytes + l_size > l_cfg.total_quota_bytes then
            fail('The space for files not saved yet is full. Try again later.');
        end if;
        l_vals := field_values(p_key);
        insert into iga_uploads(upload_id, edit_token, file_name, expected_bytes, file_blob, f1, f2, f3)
        values(l_id, p_token, l_name, l_size, empty_blob(), l_vals(1), l_vals(2), l_vals(3));
        return l_id;
    end;

    function upload_chunk(p_scope varchar2, p_key varchar2, p_token varchar2, p_id varchar2, l_offset number) return number is
        l_blob blob; l_piece blob; l_raw raw(32767); l_expected number;
        l_length number; l_size number; l_edit iga_edits%rowtype;
    begin
        -- The parts of a file: START checked who may add it, FINISH checks again before the file counts.
        -- In between the edit token (this session, user and row) is enough - no grid query per part.
        l_edit := get_edit(p_scope, p_token, p_key);
        if l_edit.status <> 'A' then fail('This edit was already saved. Reopen the cell.'); end if;
        select file_blob, expected_bytes into l_blob, l_expected from iga_uploads
         where upload_id = p_id and edit_token = p_token and status = 'U' for update;
        dbms_lob.createtemporary(l_piece, true);
        if apex_application.g_f01.count > 40 then fail('Upload chunk is too large.'); end if;
        for i in 1 .. apex_application.g_f01.count loop
            if length(apex_application.g_f01(i)) > 8000 then fail('Upload chunk is too large.'); end if;
            l_raw := utl_encode.base64_decode(utl_raw.cast_to_raw(apex_application.g_f01(i)));
            if l_raw is not null then dbms_lob.writeappend(l_piece, utl_raw.length(l_raw), l_raw); end if;
        end loop;
        l_size := dbms_lob.getlength(l_piece); l_length := dbms_lob.getlength(l_blob);
        if l_offset is null or l_offset < 0 or l_offset <> trunc(l_offset)
           or l_size < 1 or l_size > 196608 or l_offset + l_size > l_expected then fail('Invalid upload chunk.'); end if;
        if l_offset = l_length then
            dbms_lob.append(l_blob, l_piece);
        elsif l_offset + l_size <= l_length then
            if dbms_lob.compare(l_blob, l_piece, l_size, l_offset + 1, 1) <> 0 then
                fail('Upload retry did not match the stored bytes.');
            end if;
        else fail('Upload offset mismatch.'); end if;
        dbms_lob.freetemporary(l_piece);
        return dbms_lob.getlength(l_blob);
    exception when others then
        if dbms_lob.istemporary(l_piece) = 1 then dbms_lob.freetemporary(l_piece); end if;
        raise;
    end;

    -- p_check: the column's File Check Function, f(p_file_name, p_mime_type, p_content) return varchar2
    -- (an error message, or null when the file is fine) - e.g. a virus scan
    procedure finish_upload(p_scope varchar2, p_key varchar2, p_token varchar2, p_id varchar2, p_check varchar2) is
        l_blob blob; l_expected number; l_name varchar2(255 char); l_ext varchar2(20);
        l_head varchar2(32); l_mime varchar2(100); l_err varchar2(4000);
    begin
        active_edit(p_scope, p_token, p_key);
        select file_blob, expected_bytes, file_name into l_blob, l_expected, l_name
          from iga_uploads where upload_id = p_id and edit_token = p_token for update;
        if dbms_lob.getlength(l_blob) <> l_expected then fail('Upload is incomplete.'); end if;
        l_head := rawtohex(dbms_lob.substr(l_blob, 12, 1));
        l_ext := lower(regexp_substr(l_name, '[^.]+$'));
        -- Never trust browser MIME. Pictures and PDF are checked by their first bytes (only those get a
        -- preview); other common types are named by their extension so the download opens in the right
        -- program (always sent as an attachment with nosniff). Anything else stays octet-stream.
        l_mime := case
          when l_ext = 'png' and l_head like '89504E470D0A1A0A%' then 'image/png'
          when l_ext in ('jpg','jpeg') and l_head like 'FFD8FF%' then 'image/jpeg'
          when l_ext = 'gif' and l_head like '47494638%' then 'image/gif'
          when l_ext = 'webp' and l_head like '52494646________57454250%' then 'image/webp'
          when l_ext = 'pdf' and l_head like '255044462D%' then 'application/pdf'
          when l_ext in ('png','jpg','jpeg','gif','webp','pdf') then null
          when l_ext in ('txt','log') then 'text/plain'
          when l_ext = 'csv' then 'text/csv'
          when l_ext = 'doc' then 'application/msword'
          when l_ext = 'docx' then 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          when l_ext = 'xls' then 'application/vnd.ms-excel'
          when l_ext = 'xlsx' then 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
          when l_ext = 'ppt' then 'application/vnd.ms-powerpoint'
          when l_ext = 'pptx' then 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
          when l_ext = 'odt' then 'application/vnd.oasis.opendocument.text'
          when l_ext = 'ods' then 'application/vnd.oasis.opendocument.spreadsheet'
          when l_ext = 'rtf' then 'application/rtf'
          when l_ext = 'zip' then 'application/zip'
          when l_ext = 'mp3' then 'audio/mpeg'
          when l_ext = 'mp4' then 'video/mp4'
          when l_ext = 'msg' then 'application/vnd.ms-outlook'
          when l_ext = 'eml' then 'message/rfc822'
          else 'application/octet-stream' end;
        if l_mime is null then
            fail('The file content does not match its extension.');
        end if;
        if trim(p_check) is not null then
            execute immediate 'begin :r := ' || dbms_assert.qualified_sql_name(trim(p_check)) || '(:n, :m, :b); end;'
                using out l_err, in l_name, in l_mime, in l_blob;
            if l_err is not null then fail(l_name || ': ' || l_err); end if;
        end if;
        update iga_uploads set status = 'R', mime_type = l_mime
         where upload_id = p_id and edit_token = p_token;
    end;

    procedure remove_file(p_scope varchar2, p_key varchar2, p_token varchar2) is
        l_blob blob; l_name varchar2(1000); l_mime varchar2(255);
    begin
        active_edit(p_scope, p_token, p_key);
        delete from iga_uploads where upload_id = apex_application.g_x04 and edit_token = p_token;
        if sql%rowcount > 0 then return; end if;
        begin
            saved_file(p_scope, p_key, apex_application.g_x04, l_blob, l_name, l_mime);
        exception when no_data_found or too_many_rows then fail('Attachment not found.');
        end;
        if apex_application.g_x05 = 'RESTORE' then
            delete from iga_removals where edit_token = p_token and file_id = apex_application.g_x04;
        else
            begin
                insert into iga_removals values(p_token, apex_application.g_x04);
            exception when dup_val_on_index then null; end;
        end if;
    end;

    -- null-safe comparison: never returns NULL (a = b alone is NULL when one side is NULL)
    function same(a varchar2, b varchar2) return boolean is
    begin
        if a is null and b is null then return true; end if;
        if a is null or b is null then return false; end if;
        return a = b;
    end;

    procedure set_fields(p_scope varchar2, p_key varchar2, p_token varchar2) is
        l_old t_vals := t_vals(null, null, null);
        l_new t_vals;
        l_id varchar2(100) := apex_application.g_x04;
        l_name varchar2(1000);
    begin
        active_edit(p_scope, p_token, p_key);
        -- a file added in this edit
        for u in (select f1, f2, f3 from iga_uploads where upload_id = l_id and edit_token = p_token) loop
            l_new := field_values(p_key, t_vals(u.f1, u.f2, u.f3));
            update iga_uploads set f1 = l_new(1), f2 = l_new(2), f3 = l_new(3)
             where upload_id = l_id and edit_token = p_token;
            return;
        end loop;
        -- a saved file: the change waits in IGA_CHANGES until the grid is saved
        if p_key is null then fail('Attachment not found.'); end if;
        begin
            if own then
                execute immediate 'select t.' || g_store.fname || ', ' || fexpr(1) || ', ' || fexpr(2) || ', ' || fexpr(3) ||
                    ' from ' || g_store.tab || ' t where t.' || g_store.fk || ' = :k and to_char(t.' || g_store.pk || ') = :id'
                    into l_name, l_old(1), l_old(2), l_old(3) using p_key, l_id;
            else
                select file_name, f1, f2, f3 into l_name, l_old(1), l_old(2), l_old(3) from iga_files
                 where file_id = l_id and workspace_id = g_workspace and application_id = g_app
                   and scope_name = p_scope and record_key = p_key;
            end if;
        exception when no_data_found or too_many_rows then fail('Attachment not found.');
        end;
        l_new := field_values(p_key, l_old);
        delete from iga_changes where edit_token = p_token and file_id = l_id;
        if not (same(l_new(1), l_old(1)) and same(l_new(2), l_old(2)) and same(l_new(3), l_old(3))) then
            insert into iga_changes(edit_token, file_id, file_name, f1, f2, f3)
            values (p_token, l_id, l_name, l_new(1), l_new(2), l_new(3));
        end if;
    end;

    -- the column's settings as Page Designer saved them (ATTRIBUTES JSON)
    function column_attrs(p_scope varchar2) return clob is
    begin return g_grid.attrs; end;

    -- Minimum Files per Row: the row must end its save with at least that many files
    procedure check_minimum(p_scope varchar2, p_key varchar2, p_token varchar2) is
        l_attrs clob := column_attrs(p_scope);
        l_min number;
        l_n number;
        function a(p_no pls_integer) return varchar2 is
        begin return json_value(l_attrs, '$.attribute_' || to_char(p_no, 'FM00')); end;
    begin
        if l_attrs is null then return; end if;
        l_min := to_number(regexp_substr(a(40), '^\d+$'));
        if nvl(l_min, 0) < 1 then return; end if;
        if p_token is null then
            -- no edit: the column's own storage settings
            g_store := checked(a(11), a(12), a(13), a(14), a(15), a(16), a(17), a(18));
        end if;
        l_n := saved_count(p_scope, p_key, p_token);
        if l_n < l_min then
            fail(case when l_min = 1 then 'Add an attachment to this row.'
                      else 'Add at least ' || l_min || ' attachments to this row.' end);
        end if;
    end;

    -- the column's Storage settings with the Extra Field columns (for calls without an edit)
    function column_store return t_store is
        l_attrs clob := g_grid.attrs;
        l_cols t_names := t_names(null, null, null);
        b pls_integer;
        function a(p_no pls_integer) return varchar2 is
        begin return json_value(l_attrs, '$.attribute_' || to_char(p_no, 'FM00')); end;
    begin
        for i in 1 .. 3 loop
            b := 19 + (i - 1) * 7;
            if nvl(a(b), 'NONE') <> 'NONE' then
                l_cols(i) := case when nvl(a(11), 'PLUGIN') = 'TABLE' then a(b + 2) else 'F' || i end;
            end if;
        end loop;
        return checked(a(11), a(12), a(13), a(14), a(15), a(16), a(17), a(18), l_cols);
    end;

    -- Hidden Extra Fields from a Grid Column or Page Item follow the row: the value when the row is saved
    -- (session state in the row process, not the browser) goes to all the row's files, new and saved.
    -- A page item that changes on the page belongs in the grid's Page Items to Submit.
    -- p_authorized: the caller already checked WRITE / CREATE. Otherwise a change needs WRITE on the
    -- row; without it the files keep their values (the row itself still saves).
    procedure sync_grid_values(p_key varchar2, p_authorized boolean default false) is
        l_attrs clob := g_grid.attrs;
        l_v varchar2(4000);
        l_col varchar2(128);
        l_n number;
        l_checked boolean := p_authorized;
        b pls_integer;
        function a(p_no pls_integer) return varchar2 is
        begin return json_value(l_attrs, '$.attribute_' || to_char(p_no, 'FM00')); end;
    begin
        if l_attrs is null or p_key is null then return; end if;
        for i in 1 .. 3 loop
            b := 19 + (i - 1) * 7;
            if a(b) = 'HIDDEN' and a(b + 4) in ('COLUMN', 'ITEM') and trim(a(b + 5)) is not null then
                l_v := substr(v(upper(trim(a(b + 5)))), 1, 4000);
                if not l_checked then
                    -- any file to change?
                    l_n := 0;
                    if own then
                        if g_store.fcol(i) is not null then
                            execute immediate 'select count(*) from ' || g_store.tab || ' t where t.' || g_store.fk ||
                                ' = :k and decode(t.' || g_store.fcol(i) || ', :v, 0, 1) = 1' into l_n using p_key, l_v;
                        end if;
                    else
                        select count(*) into l_n from iga_files where workspace_id = g_workspace and application_id = g_app
                           and scope_name = g_grid.scope and record_key = p_key
                           and decode(case i when 1 then f1 when 2 then f2 else f3 end, l_v, 0, 1) = 1;
                    end if;
                    if l_n > 0 then
                        begin
                            authorize(g_grid.scope, p_key, 'WRITE');
                        exception when others then
                            if sqlcode = -20001 then return; end if;
                            raise;
                        end;
                        l_checked := true;
                    end if;
                end if;
                if own then
                    l_col := g_store.fcol(i);
                    if l_col is not null then
                        execute immediate 'update ' || g_store.tab || ' t set t.' || l_col || ' = :v where t.' || g_store.fk ||
                            ' = :k and decode(t.' || l_col || ', :v, 0, 1) = 1' using l_v, p_key, l_v;
                    end if;
                elsif i = 1 then
                    update iga_files set f1 = l_v where workspace_id = g_workspace and application_id = g_app
                       and scope_name = g_grid.scope and record_key = p_key and decode(f1, l_v, 0, 1) = 1;
                elsif i = 2 then
                    update iga_files set f2 = l_v where workspace_id = g_workspace and application_id = g_app
                       and scope_name = g_grid.scope and record_key = p_key and decode(f2, l_v, 0, 1) = 1;
                else
                    update iga_files set f3 = l_v where workspace_id = g_workspace and application_id = g_app
                       and scope_name = g_grid.scope and record_key = p_key and decode(f3, l_v, 0, 1) = 1;
                end if;
            end if;
        end loop;
    end;

    procedure finalize_edit(p_edit_token in out varchar2, p_record_key varchar2,
                            p_raise boolean default false, p_column varchar2 default null) is
        l_edit iga_edits%rowtype; l_version number; l_count number; l_bytes number;
        l_cur integer; l_rows integer;
        l_cfg t_cfg;
        p_scope varchar2(255);
        l_status varchar2(10) := v('APEX$ROW_STATUS');   -- C / U in the grid's row processing
        l_mime_len number; l_mime_char boolean;
    begin
        begin_request;
        savepoint iga_finalize;
        l_cfg := settings;
        -- no edit (also: the column holds a file count from the query, not a token)
        if not is_token(p_edit_token) then
            load_grid(to_number(v('APP_PAGE_ID')), p_column);
            if p_record_key is not null then
                -- Minimum Files per Row only where the user may add files to the row: a row whose files
                -- are read only (Read Only condition for each row, Authorization Function, Allowed Row
                -- Operations ...) still saves - its files cannot be completed there
                if nvl(to_number(regexp_substr(json_value(g_grid.attrs, '$.attribute_40'), '^\d+$')), 0) > 0
                   and allowed(g_grid.scope, p_record_key, case when l_status = 'C' then 'CREATE' else 'WRITE' end) then
                    check_minimum(g_grid.scope, p_record_key, null);
                end if;
                g_store := column_store;
                sync_grid_values(p_record_key);
            end if;
            return;
        end if;
        if p_record_key is null then fail('Save the parent record before linking attachments.'); end if;
        -- New rows have a NULL key in staging; existing rows must match exactly.
        select * into l_edit from iga_edits where edit_token = p_edit_token
          and workspace_id = g_workspace and application_id = g_app
          and session_id = g_session and user_name = g_user and expires_at > systimestamp for update;
        -- the column saving now, not the one the token names: a token works only for its own column
        load_grid(to_number(v('APP_PAGE_ID')), p_column);
        if nvl(l_edit.page_id, -1) <> g_grid.page_id or nvl(upper(l_edit.column_name), '-') <> upper(g_grid.column_name)
           or l_edit.scope_name <> g_grid.scope then
            fail('These attachments belong to another column. Reopen the cell.');
        end if;
        p_scope := l_edit.scope_name;
        -- A token of a new row is only for the row being inserted (CREATE); on a saved row, WRITE.
        if l_edit.record_key is null then
            if l_status = 'U' then fail('These attachments were added to a new row. Reopen the cell.'); end if;
            authorize(p_scope, p_record_key, 'CREATE');
            -- outside the grid's row processing the operation is unknown: the row must be writable too
            if l_status is null then authorize(p_scope, p_record_key, 'WRITE'); end if;
        else
            -- the grid updates the row: SAVE (see authorize); outside the grid's row processing: WRITE
            authorize(p_scope, p_record_key, case when l_status = 'U' then 'SAVE' else 'WRITE' end);
        end if;
        if l_edit.record_key is not null and l_edit.record_key <> p_record_key then fail('Attachment record mismatch.'); end if;
        if l_edit.status = 'S' then
            if l_edit.record_key <> p_record_key then fail('Attachment token was already consumed.'); end if;
            g_store := store_from(l_edit.storage);
            p_edit_token := to_char(saved_count(p_scope, p_record_key, null));
            return;
        end if;
        g_store := store_from(l_edit.storage);
        select count(*) into l_count from iga_uploads where edit_token = p_edit_token and status <> 'R';
        if l_count > 0 then fail('Finish or remove incomplete attachment uploads before saving.'); end if;
        ensure_version(p_scope, p_record_key);
        select attachment_version into l_version from iga_record_versions
         where workspace_id = g_workspace and application_id = g_app and scope_name = p_scope
           and record_key = p_record_key for update;
        if l_version <> l_edit.base_version then
            -- Somebody saved this row's files in between. Files only added here go in as well (the limits
            -- below are checked on the result); removals and field changes were made on files as this
            -- editor saw them, so they are refused.
            select count(*) into l_count from (
                select 1 from iga_removals where edit_token = p_edit_token
                union all
                select 1 from iga_changes where edit_token = p_edit_token);
            if l_count > 0 then fail('Attachments changed in another editor. Revert this row and reopen attachments.'); end if;
        end if;
        -- Required Extra Fields of new and changed files (only spaces counts as empty)
        for i in 1 .. 3 loop
            if substr(g_store.freq, i, 1) = 'Y' then
                for m in (select file_name n from iga_uploads
                           where edit_token = p_edit_token and trim(decode(i, 1, f1, 2, f2, f3)) is null
                          union all
                          select nvl(file_name, file_id) from iga_changes
                           where edit_token = p_edit_token and trim(decode(i, 1, f1, 2, f2, f3)) is null
                             and file_id not in (select file_id from iga_removals where edit_token = p_edit_token)) loop
                    fail('Fill in ' || g_store.flabel(i) || ' for ' || m.n || '.');
                end loop;
            end if;
        end loop;
        -- changed Extra Fields of saved files
        for ch in (select file_id, f1, f2, f3 from iga_changes where edit_token = p_edit_token) loop
            if own then
                if g_store.fcol(1) is not null or g_store.fcol(2) is not null or g_store.fcol(3) is not null then
                    -- only the used fields have columns: DBMS_SQL binds them by name
                    l_cur := dbms_sql.open_cursor;
                    dbms_sql.parse(l_cur, 'update ' || g_store.tab || ' t set ' ||
                        rtrim(case when g_store.fcol(1) is not null then 't.' || g_store.fcol(1) || ' = :v1, ' end ||
                              case when g_store.fcol(2) is not null then 't.' || g_store.fcol(2) || ' = :v2, ' end ||
                              case when g_store.fcol(3) is not null then 't.' || g_store.fcol(3) || ' = :v3, ' end, ', ') ||
                        ' where t.' || g_store.fk || ' = :k and to_char(t.' || g_store.pk || ') = :id', dbms_sql.native);
                    if g_store.fcol(1) is not null then dbms_sql.bind_variable(l_cur, ':v1', ch.f1); end if;
                    if g_store.fcol(2) is not null then dbms_sql.bind_variable(l_cur, ':v2', ch.f2); end if;
                    if g_store.fcol(3) is not null then dbms_sql.bind_variable(l_cur, ':v3', ch.f3); end if;
                    dbms_sql.bind_variable(l_cur, ':k', p_record_key);
                    dbms_sql.bind_variable(l_cur, ':id', ch.file_id);
                    l_rows := dbms_sql.execute(l_cur);
                    dbms_sql.close_cursor(l_cur);
                end if;
            else
                update iga_files set f1 = ch.f1, f2 = ch.f2, f3 = ch.f3
                 where file_id = ch.file_id and workspace_id = g_workspace and application_id = g_app
                   and scope_name = p_scope and record_key = p_record_key;
            end if;
        end loop;
        delete from iga_changes where edit_token = p_edit_token;
        if own then
            execute immediate 'delete from ' || g_store.tab || ' t where t.' || g_store.fk || ' = :k and to_char(t.' || g_store.pk ||
                ') in (select file_id from iga_removals where edit_token = :t)' using p_record_key, p_edit_token;
        else
            delete from iga_files where file_id in (select file_id from iga_removals where edit_token = p_edit_token)
              and workspace_id = g_workspace and application_id = g_app and scope_name = p_scope and record_key = p_record_key;
        end if;
        delete from iga_removals where edit_token = p_edit_token;
        select count(*), nvl(sum(expected_bytes), 0) into l_count, l_bytes from iga_uploads where edit_token = p_edit_token;
        if l_count + saved_count(p_scope, p_record_key, p_edit_token) > nvl(l_edit.max_file_count, l_cfg.max_file_count) then
            fail('Attachment count limit exceeded.');
        end if;
        if l_edit.max_total_bytes is not null and l_bytes + saved_bytes(p_scope, p_record_key, p_edit_token) > l_edit.max_total_bytes then
            fail('The files of this row are larger than ' || round(l_edit.max_total_bytes / 1024) || ' KB together.');
        end if;
        if own then
            -- a MIME type longer than the developer's column (e.g. a 73 character Office type in a
            -- varchar2(50)) is saved as application/octet-stream instead of failing the save
            col_len(g_store.tab, g_store.mime, l_mime_len, l_mime_char);
            -- the developer's table: its key comes from an identity column, a sequence default or a trigger
            execute immediate 'insert into ' || g_store.tab || ' (' || g_store.fk || ', ' || g_store.fname || ', ' || g_store.mime ||
                ', ' || g_store.content || case when g_store.fsize is not null then ', ' || g_store.fsize end ||
                case when g_store.fcol(1) is not null then ', ' || g_store.fcol(1) end ||
                case when g_store.fcol(2) is not null then ', ' || g_store.fcol(2) end ||
                case when g_store.fcol(3) is not null then ', ' || g_store.fcol(3) end ||
                ') select :k, file_name, ' ||
                case when l_mime_len is not null
                     then 'case when lengthb(mime_type) > ' || to_char(trunc(l_mime_len)) ||
                          ' then ''application/octet-stream'' else mime_type end'
                     else 'mime_type' end ||
                ', file_blob' || case when g_store.fsize is not null then ', expected_bytes' end ||
                case when g_store.fcol(1) is not null then ', f1' end ||
                case when g_store.fcol(2) is not null then ', f2' end ||
                case when g_store.fcol(3) is not null then ', f3' end ||
                ' from iga_uploads where edit_token = :t order by created_at, upload_id' using p_record_key, p_edit_token;
        else
            -- created_at = when the upload started, so the files list in the order they were added
            insert into iga_files(file_id, workspace_id, application_id, scope_name, record_key,
                                 file_name, mime_type, file_bytes, file_blob, f1, f2, f3, created_by, created_at)
            select upload_id, g_workspace, g_app, p_scope, p_record_key, file_name, mime_type,
                   expected_bytes, file_blob, f1, f2, f3, g_user, created_at from iga_uploads where edit_token = p_edit_token;
        end if;
        delete from iga_uploads where edit_token = p_edit_token;
        sync_grid_values(p_record_key, p_authorized => true);
        check_minimum(p_scope, p_record_key, p_edit_token);
        update iga_record_versions set attachment_version = attachment_version + 1
         where workspace_id = g_workspace and application_id = g_app and scope_name = p_scope and record_key = p_record_key;
        -- a saved token stays a day, so the same save repeated (e.g. a refreshed row) is a no-op
        update iga_edits set status = 'S', record_key = p_record_key, expires_at = systimestamp + interval '1' day
         where edit_token = p_edit_token;
        -- the column gets the row's new file count: the grid shows it in the cell after the save
        p_edit_token := to_char(saved_count(p_scope, p_record_key, null));
    exception
        when others then
            if l_cur is not null and dbms_sql.is_open(l_cur) then dbms_sql.close_cursor(l_cur); end if;
            rollback to iga_finalize;
            if sqlcode = 100 then
                row_error(-20001, 'ORA-20001: Attachment edit expired or is not owned by this session.', p_raise);
            elsif sqlcode = -20001 then
                row_error(sqlcode, sqlerrm, p_raise);
            else
                raise;
            end if;
    end;

    procedure delete_record_files(p_record_key varchar2, p_raise boolean default false,
                                  p_column varchar2 default null) is
        l_cfg t_cfg;
        l_attrs clob;
        function a(p_no pls_integer) return varchar2 is
        begin return json_value(l_attrs, '$.attribute_' || to_char(p_no, 'FM00')); end;
    begin
        begin_request;
        savepoint iga_delete;
        l_cfg := settings;
        load_grid(to_number(v('APP_PAGE_ID')), p_column);
        -- Call while the row is still there: the grid's query and the Authorization Function may read it.
        authorize(g_grid.scope, p_record_key, 'DELETE');
        ensure_version(g_grid.scope, p_record_key);
        update iga_record_versions set attachment_version = attachment_version + 1
         where workspace_id = g_workspace and application_id = g_app and scope_name = g_grid.scope and record_key = p_record_key;
        l_attrs := g_grid.attrs;
        g_store := checked(a(11), a(12), a(13), a(14), a(15), a(16), a(17), a(18));
        if own then
            execute immediate 'delete from ' || g_store.tab || ' t where t.' || g_store.fk || ' = :k' using p_record_key;
        else
            delete from iga_files where workspace_id = g_workspace and application_id = g_app
              and scope_name = g_grid.scope and record_key = p_record_key;
        end if;
        -- Leave other editors' staging until expiry. Their next finalization is denied
        -- by the grid (the row is gone), or by the version tombstone if a key is reused.
    exception when others then
        rollback to iga_delete;
        if sqlcode = -20001 then row_error(sqlcode, sqlerrm, p_raise); else raise; end if;
    end;

    procedure purge_expired is
    begin
        -- staged files, removals and field changes go with their edit (ON DELETE CASCADE)
        delete from iga_edits where expires_at < systimestamp;
        delete from iga_stage_locks where touched_at < systimestamp - interval '2' day;
    end;

    procedure move_files(p_from_scope varchar2, p_to_scope varchar2,
                         p_from_application_id number, p_to_application_id number default null) is
        l_to_app number := nvl(p_to_application_id, p_from_application_id);
        l_to_scope varchar2(64) := substr(trim(p_to_scope), 1, 64);
        l_to_ws number;
        l_n number;
    begin
        if trim(p_from_scope) is null or l_to_scope is null or p_from_application_id is null then
            fail('Pass the old and the new Storage Name and the application ID.');
        end if;
        -- the workspace of the (new) application; else the files keep theirs
        begin
            select workspace_id into l_to_ws from apex_applications where application_id = l_to_app;
        exception when no_data_found then l_to_ws := null;
        end;
        update iga_files set workspace_id = nvl(l_to_ws, workspace_id), application_id = l_to_app, scope_name = l_to_scope
         where application_id = p_from_application_id and scope_name = trim(p_from_scope);
        l_n := sql%rowcount;
        -- the attachment versions go along (a row that already has one under the new name keeps it)
        update iga_record_versions v set workspace_id = nvl(l_to_ws, workspace_id), application_id = l_to_app,
               scope_name = l_to_scope
         where application_id = p_from_application_id and scope_name = trim(p_from_scope)
           and not exists (select 1 from iga_record_versions t where t.application_id = l_to_app
                              and t.workspace_id = nvl(l_to_ws, v.workspace_id)
                              and t.scope_name = l_to_scope and t.record_key = v.record_key);
        delete from iga_record_versions where application_id = p_from_application_id and scope_name = trim(p_from_scope)
           and not (application_id = l_to_app and scope_name = l_to_scope);
        dbms_output.put_line('IG Attachments: ' || l_n || ' file(s) moved to ' || l_to_scope ||
                             ' (application ' || l_to_app || '). COMMIT to keep the change.');
    end;

    procedure send_file(p_scope varchar2, p_key varchar2, p_token varchar2) is
        l_blob blob; l_name varchar2(1000); l_mime varchar2(255); l_edit iga_edits%rowtype;
    begin
        authorize(p_scope, p_key, case when p_key is null then 'CREATE' else 'READ' end);
        -- a saved file needs READ only (an old token sent along does not matter); a staged file needs
        -- this session's valid edit token
        begin
            if p_key is null then raise no_data_found; end if;
            saved_file(p_scope, p_key, apex_application.g_x04, l_blob, l_name, l_mime);
        exception when no_data_found then
            if not is_token(p_token) then fail('Attachment not found.'); end if;
            l_edit := get_edit(p_scope, p_token, p_key);
            begin
                select file_blob, file_name, mime_type into l_blob, l_name, l_mime from iga_uploads
                 where upload_id = apex_application.g_x04 and edit_token = p_token and status = 'R';
            exception when no_data_found then fail('Attachment not found.');
            end;
        end;
        sys.owa_util.mime_header(nvl(l_mime, 'application/octet-stream'), false);
        sys.htp.p('Content-Length: ' || dbms_lob.getlength(l_blob));
        -- the real name (also non-ASCII) in filename*, a plain ASCII copy for old clients;
        -- brackets and other punctuation are kept, only quotes, backslashes and controls go
        sys.htp.p('Content-Disposition: attachment; filename="' ||
            regexp_replace(asciistr(l_name), '\\[0-9A-F]{4}|["\\]|[[:cntrl:]]', '_') ||
            '"; filename*=UTF-8''''' || utl_url.escape(l_name, true, 'AL32UTF8'));
        sys.htp.p('X-Content-Type-Options: nosniff');
        sys.htp.p('Cache-Control: no-store');
        sys.owa_util.http_header_close;
        sys.wpg_docload.download_file(l_blob);
        apex_application.stop_apex_engine;
    end;

    -- The grid's save, as Page Designer has it: without a row process that calls finalize_edit the files
    -- would never be linked (the row would keep "Pending"). Null when it looks right.
    function setup_warning return varchar2 is
        l_target varchar2(100);
        l_code clob;
        l_n number := 0;
        l_name varchar2(255) := upper(g_grid.column_name);
    begin
        for p in (select json_value(attributes, '$.target_type') target,
                         json_value(attributes, '$.dml_plsql_code' returning clob) code
                    from apex_application_page_proc
                   where application_id = g_app and page_id = g_grid.page_id and region_id = g_grid.region_id
                     and process_type_code = 'NATIVE_IG_DML') loop
            l_n := l_n + 1;
            l_target := p.target;
            l_code := p.code;
        end loop;
        if l_n = 0 then
            return 'the grid has no "Interactive Grid - Automatic Row Processing (DML)" process: files of column ' ||
                   l_name || ' are never saved.';
        end if;
        if nvl(l_target, '-') <> 'PLSQL_CODE' then
            return 'set Target Type "PL/SQL Code" in the grid''s row processing and call iga_api.finalize_edit(:' ||
                   l_name || ', <primary key>) there (see the plug-in help).';
        end if;
        if instr(upper(l_code), 'FINALIZE_EDIT') = 0 then
            return 'the grid''s row processing does not call iga_api.finalize_edit(:' || l_name ||
                   ', <primary key>): files of this column are never saved.';
        end if;
        return null;
    exception when others then return null;
    end;

    procedure render(
        p_item in apex_plugin.t_item, p_plugin in apex_plugin.t_plugin,
        p_param in apex_plugin.t_item_render_param,
        p_result in out nocopy apex_plugin.t_item_render_result) is
        l_scope varchar2(255);
        l_cfg t_cfg;
        l_json clob;
        l_id varchar2(255) := p_item.name;
        l_ro boolean := p_param.is_readonly or p_param.is_printer_friendly;
        l_pos integer := 1;
        l_warning varchar2(4000);
    begin
        begin_request;
        l_cfg := settings;
        load_grid(to_number(v('APP_PAGE_ID')), p_item.name, p_item.id);
        l_scope := g_grid.scope;
        l_cfg := limits(p_item, l_scope);
        apex_json.initialize_clob_output;
        apex_json.open_object;
        apex_json.write('item', l_id);
        -- the column's name: igaAttachments.get() also finds the column by it (without a Static ID
        -- the DOM id is C<column id>)
        apex_json.write('column', g_grid.column_name);
        -- the grid, its key and this column's field are found by the JavaScript
        apex_json.write('display', nvl(attr(p_item, 8), 'ICON_TEXT'));
        apex_json.write('label', nvl(attr(p_item, 9), 'Attachments'));
        apex_json.write('icon', nvl(attr(p_item, 10), 'fa-paperclip'));
        apex_json.write('ajax', apex_plugin.get_ajax_identifier);
        apex_json.write('maxBytes', l_cfg.max_file_bytes);
        apex_json.write('maxCount', l_cfg.max_file_count);
        apex_json.write('maxTotal', max_total_bytes(p_item));
        apex_json.write('minCount', nvl(to_number(regexp_substr(attr(p_item, 40), '^\d+$')), 0));
        apex_json.write('accept', '.' || replace(l_cfg.allowed_extensions, ',', ',.'));
        apex_json.write('readOnly', l_ro);
        -- Extra Fields (with the lengths of the developer's columns; storage set up wrong: the panel's
        -- requests say so, the page still renders)
        begin
            g_store := store_of(p_item);
        exception when others then
            g_fields := fields_of(p_item);
        end;
        apex_json.open_array('fields');
        for i in 1 .. 3 loop
            if g_fields(i).kind <> 'NONE' then
                apex_json.open_object;
                apex_json.write('n', i);
                apex_json.write('kind', g_fields(i).kind);
                apex_json.write('label', g_fields(i).label);
                apex_json.write('required', g_fields(i).req);
                apex_json.write('dkind', g_fields(i).dkind);
                if g_fields(i).dkind <> 'NONE' then apex_json.write('dval', g_fields(i).dval); end if;
                if g_fields(i).maxlen is not null then apex_json.write('max', least(g_fields(i).maxlen, 4000)); end if;
                apex_json.close_object;
            end if;
        end loop;
        apex_json.close_array;
        -- for developers (App Builder session): the grid's row processing must call finalize_edit
        l_warning := setup_warning;
        if l_warning is not null then
            apex_debug.warn('IG Attachments: %s', l_warning);
            if v('APP_BUILDER_SESSION') is not null then apex_json.write('setupWarning', l_warning); end if;
        end if;
        apex_json.close_object;
        l_json := apex_json.get_clob_output;
        apex_json.free_output;
        sys.htp.p('<span class="iga-editor"><input type="hidden" id="' ||
          apex_escape.html_attribute(l_id) || '" name="' ||
          apex_escape.html_attribute(apex_plugin.get_input_name_for_item) ||
          '" value="' || apex_escape.html_attribute(p_param.value) ||
          '"><button type="button" class="iga-open" id="' || apex_escape.html_attribute(l_id) ||
          '_OPEN"></button></span>');
        -- The settings as JSON data in the page, of any length (long lists, Arabic text): apex_json writes
        -- "/" as "\/", so the data cannot close the script element.
        sys.htp.prn('<script type="application/json" id="' || apex_escape.html_attribute(l_id) || '_CFG">');
        while l_pos <= dbms_lob.getlength(l_json) loop
            sys.htp.prn(dbms_lob.substr(l_json, 4000, l_pos));
            l_pos := l_pos + 4000;
        end loop;
        sys.htp.p('</script>');
        dbms_lob.freetemporary(l_json);
        apex_javascript.add_onload_code('igaAttachments.init(JSON.parse(document.getElementById(' ||
            apex_javascript.add_value(l_id || '_CFG', false) || ').textContent));');
        p_result.is_navigable := true;
        p_result.navigable_dom_id := l_id || '_OPEN';
    end;

    procedure ajax(
        p_item in apex_plugin.t_item, p_plugin in apex_plugin.t_plugin,
        p_param in apex_plugin.t_item_ajax_param,
        p_result in out nocopy apex_plugin.t_item_ajax_result) is
        l_scope varchar2(255);
        l_op varchar2(20) := apex_application.g_x01;
        l_token varchar2(32) := apex_application.g_x02;
        l_key varchar2(512) := apex_application.g_x03;
        l_edit iga_edits%rowtype;
        l_message varchar2(4000);
        l_cfg t_cfg;
        l_id varchar2(32);
        l_received number;
        l_writable boolean := true;
    begin
        begin_request;
        savepoint iga_request;
        l_cfg := settings;
        load_grid(to_number(v('APP_PAGE_ID')), p_item.name, p_item.id);
        l_scope := g_grid.scope;
        l_cfg := limits(p_item, l_scope);
        -- staging limits: the plug-in's Component Settings (MB); none until they are saved once
        if p_plugin.attributes is not null then
            if num(p_plugin.attributes.get_varchar2('attribute_01')) > 0 then
                l_cfg.session_quota_bytes := round(num(p_plugin.attributes.get_varchar2('attribute_01')) * 1048576); end if;
            if num(p_plugin.attributes.get_varchar2('attribute_02')) > 0 then
                l_cfg.user_quota_bytes := round(num(p_plugin.attributes.get_varchar2('attribute_02')) * 1048576); end if;
            if num(p_plugin.attributes.get_varchar2('attribute_03')) > 0 then
                l_cfg.total_quota_bytes := round(num(p_plugin.attributes.get_varchar2('attribute_03')) * 1048576); end if;
        end if;
        g_store := store_of(p_item);
        if l_op = 'DOWNLOAD' then send_file(l_scope, l_key, l_token); return; end if;
        -- Read Only = Always on the column is kept by the server too
        if l_op in ('START', 'CHUNK', 'FINISH', 'PUT', 'REMOVE', 'FIELDS') and read_only then
            fail('These attachments are read only.');
        end if;
        apex_json.initialize_clob_output;
        apex_json.open_object;
        if l_op = 'OPEN' then
            -- a user who may only read gets the files read only (no edit)
            begin
                if read_only then fail('Attachment access denied.'); end if;
                authorize(l_scope, l_key, case when l_key is null then 'CREATE' else 'WRITE' end);
            exception when others then
                if sqlcode <> -20001 or l_key is null then raise; end if;
                authorize(l_scope, l_key, 'READ');
                l_writable := false;
            end;
            if l_writable then
                -- A finalized, expired or foreign token can remain in the client (refresh, copy,
                -- new session): start a new edit instead of locking the cell out.
                if is_token(l_token) then
                    begin
                        l_edit := get_edit(l_scope, l_token, l_key);
                        -- a saved edit, or one of another page or column: a new edit
                        if l_edit.status = 'S' or nvl(l_edit.page_id, -1) <> g_grid.page_id
                           or nvl(upper(l_edit.column_name), '-') <> upper(g_grid.column_name) then
                            l_token := null;
                        else
                            refresh_empty_edit(l_scope, l_key, l_token, l_cfg.max_file_count, max_total_bytes(p_item),
                                               keep_of(p_item), store_text(g_store));
                        end if;
                    exception when others then
                        l_token := null;
                    end;
                else
                    l_token := null;
                end if;
                if l_token is null then
                    l_token := new_edit(l_scope, l_key, l_cfg.max_file_count, max_total_bytes(p_item),
                                        keep_of(p_item), store_text(g_store));
                end if;
                active_edit(l_scope, l_token, l_key);
                apex_json.write('token', l_token);
            else
                l_token := null;
                apex_json.write('readOnly', true);
            end if;
            list_files(l_scope, l_key, l_token);
        elsif l_op = 'LIST' then list_files(l_scope, l_key, case when is_token(l_token) then l_token end);
        elsif l_op = 'START' then apex_json.write('uploadId', start_upload(l_scope, l_key, l_token, l_cfg));
        elsif l_op = 'CHUNK' then
            apex_json.write('received', upload_chunk(l_scope, l_key, l_token, apex_application.g_x04, to_number(apex_application.g_x06)));
        elsif l_op = 'FINISH' then
            finish_upload(l_scope, l_key, l_token, apex_application.g_x04, attr(p_item, 49));
            list_files(l_scope, l_key, l_token);
        elsif l_op = 'PUT' then
            -- a file of one chunk in one round trip: start, bytes, finish, new list.
            -- The reservation is committed at once: the staging locks are released before the bytes are
            -- decoded and the File Check Function runs (a slow virus scan holds up no other upload).
            -- A file refused after that is removed again.
            l_id := start_upload(l_scope, l_key, l_token, l_cfg);
            commit;
            savepoint iga_request;
            begin
                l_received := upload_chunk(l_scope, l_key, l_token, l_id, 0);
                finish_upload(l_scope, l_key, l_token, l_id, attr(p_item, 49));
            exception when others then
                rollback to iga_request;
                delete from iga_uploads where upload_id = l_id and edit_token = l_token;
                commit;
                savepoint iga_request;
                raise;
            end;
            list_files(l_scope, l_key, l_token);
        elsif l_op = 'REMOVE' then
            remove_file(l_scope, l_key, l_token);
            list_files(l_scope, l_key, l_token);
        elsif l_op = 'FIELDS' then
            set_fields(l_scope, l_key, l_token);
            list_files(l_scope, l_key, l_token);
        elsif l_op = 'DISCARD' then
            -- the row was reverted in the grid: its unsaved edit (staged files, removals, field changes)
            -- goes at once instead of holding the staging limits until it expires. Only this session's own.
            if is_token(l_token) then
                delete from iga_edits where edit_token = l_token and workspace_id = g_workspace and application_id = g_app
                   and scope_name = l_scope and session_id = g_session and user_name = g_user and status = 'A'
                   and nvl(record_key, chr(1)) = nvl(l_key, chr(1));
            end if;
        else fail('Unknown attachment operation.'); end if;
        apex_json.write('ok', true);
        apex_json.close_object;
        -- AJAX staging commits separately; finalize_edit never commits parent DML.
        commit;
        sys.owa_util.mime_header('application/json', false);
        sys.htp.p('Cache-Control: no-store'); sys.owa_util.http_header_close;
        apex_util.prn(apex_json.get_clob_output, false); apex_json.free_output;
    exception
        when apex_application.e_stop_apex_engine then raise;
        when others then
            rollback to iga_request;
            -- refusals (type, size, access ...) go to the user only; real faults to the debug log
            if sqlcode between -20999 and -20000 then
                l_message := substr(sqlerrm, 12);
            else
                apex_debug.error('IG Attachments: %s', sqlerrm);
                l_message := 'The attachment request failed. Check the APEX debug log.';
            end if;
            apex_json.free_output;
            -- a failed download answers 403, so the browser never saves the message as the file
            if l_op = 'DOWNLOAD' then sys.owa_util.status_line(403, 'Forbidden', false); end if;
            sys.owa_util.mime_header('application/json', false);
            sys.htp.p('Cache-Control: no-store'); sys.owa_util.http_header_close;
            -- free_output leaves apex_json without an output: write the reply directly
            -- "reason", not "error": apex.server would also show an "error" key as a page error
            sys.htp.prn('{"ok":false,"reason":' || apex_json.stringify(l_message) || '}');
    end;
end iga_api;
/
