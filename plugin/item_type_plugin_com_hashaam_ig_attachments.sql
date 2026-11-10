prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX export file
--
-- You should run this script using a SQL client connected to the database as
-- the owner (parsing schema) of the application or as a database user with the
-- APEX_ADMINISTRATOR_ROLE role.
--
-- This export file has been automatically generated. Modifying this file is not
-- supported by Oracle and can lead to unexpected application and/or instance
-- behavior now or in the future.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2026.03.30'
,p_release=>'26.1.0'
,p_default_workspace_id=>6375939148427884
,p_default_application_id=>1530
,p_default_id_offset=>0
,p_default_owner=>'WKSP_MRS'
);
end;
/
 
prompt APPLICATION 1530 - APEX Plugins By Hashaam
--
-- Application Export:
--   Application:     1530
--   Name:            APEX Plugins By Hashaam
--   Date and Time:   14:41 Tuesday November 10, 2026
--   Exported By:     WKSP_MRS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 13045247398558757
--   Manifest End
--   Version:         26.1.0
--   Instance ID:     743364309778592
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/item_type/com_hashaam_ig_attachments
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(13045247398558757)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'COM.HASHAAM.IG_ATTACHMENTS'
,p_display_name=>'IG Attachments'
,p_apexlang_name=>'igAttachments'
,p_supported_component_types=>'APEX_APPL_PAGE_IG_COLUMNS'
,p_javascript_file_urls=>'#PLUGIN_FILES#js/igAttachments#MIN#.js?v=1.1.0-30dda230'
,p_css_file_urls=>'#PLUGIN_FILES#css/igAttachments#MIN#.css?v=1.1.0-30dda230'
,p_api_version=>3
,p_render_function=>'iga_api.render'
,p_ajax_function=>'iga_api.ajax'
,p_item_session_state_data_type=>'VARCHAR2'
,p_standard_attributes=>'VISIBLE:FORM_ELEMENT:SESSION_STATE:READONLY:SOURCE'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'IG Attachments adds files to the rows of an editable Interactive Grid - also to new rows that are not saved yet. Users click the button in the row''s cell, add, download, preview and remove files, fill in the files'' extra fields, press Done and save t'
||'he grid.',
'',
'Add a query column for it and make it this type - its value is the file count shown in the button, e.g.',
'to_char((select count(*) from expense_files f where f.expense_id = e.id)) as attachment_edit',
'(or cast(null as varchar2(32)) without a count). The grid, its primary key (one column) and the column itself are found automatically. While files change, the column holds an edit token; opening and closing the panel without changes leaves the row un'
||'touched.',
'',
'Row process (Interactive Grid - Automatic Row Processing, Target Type PL/SQL Code), in the row''s transaction:',
'iga_api.finalize_edit(:ATTACHMENT_EDIT, :ID);   -- after the insert / update of the row',
'iga_api.delete_record_files(:ID);               -- before deleting the row',
'A refusal (e.g. "Add an attachment to this row.") is shown as a plain message and APEX rolls the row back; pass p_raise => true to get an exception instead.',
'',
'Who may do what comes from the grid: users see the files of the rows in their grid, add files where the grid can add rows, and change or remove them where it can update or delete rows (its authorization schemes and Allowed Row Operations Column inclu'
||'ded). A true Read Only condition of the page, the grid or the column makes the files read only; a column condition evaluated for each row applies to each saved row (e.g. Category = Fuel), in the panel and on the server. For more rules (e.g. closed pe'
||'riods) name an Authorization Function on the column: function my_rule(p_key varchar2, p_operation varchar2) return boolean, operation READ, CREATE (key null), WRITE or DELETE.',
'',
'Needs IGA_API and the IGA_ tables (install.sql) in the parsing schema. Component Settings: how much unsaved files may use per session, per user and in total.',
'',
'File Limits: Maximum File Size (KB), Maximum Files per Row, Minimum Files per Row (attachments mandatory), Allowed File Types, Maximum Total Size per Row (KB), Keep Unsaved Files (minutes) and an optional File Check Function (e.g. a virus scan). Cell'
||': icon, label or both.',
'',
'Storage: Plug-in Table keeps saved files in IGA_FILES. My Table keeps them in your own table - Table, Primary Key Column (filled by an identity, sequence default or trigger), Row Key Column (the foreign key to the grid row: index it and give it ON DE'
||'LETE CASCADE), File Name, MIME Type, File Content (BLOB), optionally File Size.',
'',
'Extra Fields 1-3: Text Field (an input per file; it can start with a grid column or page item value; Value Required) or Hidden (no input; the grid column or page item value when the row is saved, on all the row''s files).',
'',
'JavaScript: igaAttachments.get("ATTACHMENT_EDIT").open() / isBusy().'))
,p_version_identifier=>'1.1.0'
,p_files_version=>2461355092424
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(13083919447893523)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_title=>'Cell'
,p_apexlang_name=>'igaCell'
,p_static_id=>'igaCell'
,p_display_sequence=>20
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(13157878634493648)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_title=>'Extra Field 1'
,p_apexlang_name=>'igaField1'
,p_static_id=>'igaField1'
,p_display_sequence=>40
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(13157917687493648)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_title=>'Extra Field 2'
,p_apexlang_name=>'igaField2'
,p_static_id=>'igaField2'
,p_display_sequence=>50
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(13158040938493648)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_title=>'Extra Field 3'
,p_apexlang_name=>'igaField3'
,p_static_id=>'igaField3'
,p_display_sequence=>60
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(13068496792704793)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_title=>'File Limits'
,p_apexlang_name=>'igaLimits'
,p_static_id=>'igaLimits'
,p_display_sequence=>10
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(13225652657403695)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_title=>'Security'
,p_apexlang_name=>'igaSecurity'
,p_static_id=>'igaSecurity'
,p_display_sequence=>70
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(13144020089326312)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_title=>'Storage'
,p_apexlang_name=>'igaStorage'
,p_static_id=>'igaStorage'
,p_display_sequence=>30
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13045339724558757)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>105
,p_static_id=>'attribute_01'
,p_prompt=>'Storage Name'
,p_apexlang_name=>'storageName'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_max_length=>64
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13144124335326312)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'PLUGIN'
,p_attribute_group_id=>wwv_flow_imp.id(13144020089326312)
,p_text_case=>'UPPER'
,p_help_text=>'Optional. The plug-in table keeps this column''s files under page and column (e.g. P300.ATTACHMENT_EDIT). Give a name such as EXPENSES to keep them when the grid moves to another page, or to share them between two grids of the same table.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13068541117704793)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_static_id=>'attribute_05'
,p_prompt=>'Maximum File Size'
,p_apexlang_name=>'maxFileSize'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_unit=>'KB'
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(13068496792704793)
,p_help_text=>'The largest file allowed, in KB (1024 KB = 1 MB, at most 51200). Empty = 10240 KB (10 MB). Checked in the browser and again on the server.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13068688011704793)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_static_id=>'attribute_06'
,p_prompt=>'Maximum Files per Row'
,p_apexlang_name=>'maxFiles'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(13068496792704793)
,p_help_text=>'How many files one row can have (at most 50). Empty = 10. Checked again when the row is saved.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13068793983704793)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_static_id=>'attribute_07'
,p_prompt=>'Allowed File Types'
,p_apexlang_name=>'allowedFileTypes'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_max_length=>1000
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(13068496792704793)
,p_help_text=>'File extensions users may add, separated by commas, for example pdf,png,jpg,jpeg,txt,docx,xlsx. Empty = pdf,png,jpg,jpeg,txt. PDF, PNG and JPEG files must also really be what their extension says.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13084087524893523)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_static_id=>'attribute_08'
,p_prompt=>'Cell Display'
,p_apexlang_name=>'cellDisplay'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'ICON_TEXT'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(13083919447893523)
,p_help_text=>'What the grid cell shows. Rows with unsaved attachment changes also show Pending (a dot with Icon).'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13084267108893523)
,p_plugin_attribute_id=>wwv_flow_imp.id(13084087524893523)
,p_display_sequence=>20
,p_display_value=>'Icon'
,p_return_value=>'ICON'
,p_apexlang_name=>'icon'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13084103987893523)
,p_plugin_attribute_id=>wwv_flow_imp.id(13084087524893523)
,p_display_sequence=>10
,p_display_value=>'Icon and Label'
,p_return_value=>'ICON_TEXT'
,p_apexlang_name=>'iconAndText'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13084383594893523)
,p_plugin_attribute_id=>wwv_flow_imp.id(13084087524893523)
,p_display_sequence=>30
,p_display_value=>'Label'
,p_return_value=>'TEXT'
,p_apexlang_name=>'text'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13084488426893523)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_static_id=>'attribute_09'
,p_prompt=>'Label'
,p_apexlang_name=>'label'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'Attachments'
,p_max_length=>100
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(13083919447893523)
,p_help_text=>'The text in the cell. With Cell Display = Icon it is read out by screen readers only.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13084522645893523)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>10
,p_display_sequence=>100
,p_static_id=>'attribute_10'
,p_prompt=>'Icon'
,p_apexlang_name=>'icon'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'fa-paperclip'
,p_max_length=>100
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(13083919447893523)
,p_help_text=>'A Font APEX icon class for the cell, for example fa-paperclip, fa-file-o or fa-folder-open-o.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13144124335326312)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>110
,p_static_id=>'attribute_11'
,p_prompt=>'Storage'
,p_apexlang_name=>'storage'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'PLUGIN'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(13144020089326312)
,p_help_text=>'Where saved files are kept. Plug-in Table - IGA_FILES, nothing to set up. My Table - your own attachments table, named with its columns below. Either way files wait in the plug-in staging tables until the grid is saved, and IGA_API.FINALIZE_EDIT in t'
||'he row process moves them in the same transaction as the row.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13144321839326312)
,p_plugin_attribute_id=>wwv_flow_imp.id(13144124335326312)
,p_display_sequence=>20
,p_display_value=>'My Table'
,p_return_value=>'TABLE'
,p_apexlang_name=>'myTable'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13144287333326312)
,p_plugin_attribute_id=>wwv_flow_imp.id(13144124335326312)
,p_display_sequence=>10
,p_display_value=>'Plug-in Table (IGA_FILES)'
,p_return_value=>'PLUGIN'
,p_apexlang_name=>'pluginTable'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13144446115326312)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>120
,p_static_id=>'attribute_12'
,p_prompt=>'Table'
,p_apexlang_name=>'tableName'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_max_length=>261
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13144124335326312)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'TABLE'
,p_attribute_group_id=>wwv_flow_imp.id(13144020089326312)
,p_text_case=>'UPPER'
,p_help_text=>'Your attachments table, e.g. EXPENSE_FILES (or OWNER.EXPENSE_FILES). Its primary key must fill itself (identity column, sequence default or trigger); other NOT NULL columns need defaults or a trigger.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13144514025326312)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>13
,p_display_sequence=>130
,p_static_id=>'attribute_13'
,p_prompt=>'Primary Key Column'
,p_apexlang_name=>'primaryKeyColumn'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_max_length=>128
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13144124335326312)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'TABLE'
,p_attribute_group_id=>wwv_flow_imp.id(13144020089326312)
,p_text_case=>'UPPER'
,p_help_text=>'The primary key column of the table, e.g. FILE_ID.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13144631527326312)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>14
,p_display_sequence=>140
,p_static_id=>'attribute_14'
,p_prompt=>'Row Key Column'
,p_apexlang_name=>'rowKeyColumn'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_max_length=>128
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13144124335326312)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'TABLE'
,p_attribute_group_id=>wwv_flow_imp.id(13144020089326312)
,p_text_case=>'UPPER'
,p_help_text=>'The column holding the grid row primary key (the foreign key to the parent table), e.g. EXPENSE_ID. When a row is deleted its files must go too - give this foreign key ON DELETE CASCADE, or delete them in the row process.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13144745931326312)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>150
,p_static_id=>'attribute_15'
,p_prompt=>'File Name Column'
,p_apexlang_name=>'fileNameColumn'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_max_length=>128
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13144124335326312)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'TABLE'
,p_attribute_group_id=>wwv_flow_imp.id(13144020089326312)
,p_text_case=>'UPPER'
,p_help_text=>'Column for the file name, e.g. FILE_NAME (VARCHAR2 of 255 characters or more).'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13144894777326312)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>16
,p_display_sequence=>160
,p_static_id=>'attribute_16'
,p_prompt=>'MIME Type Column'
,p_apexlang_name=>'mimeTypeColumn'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_max_length=>128
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13144124335326312)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'TABLE'
,p_attribute_group_id=>wwv_flow_imp.id(13144020089326312)
,p_text_case=>'UPPER'
,p_help_text=>'Column for the MIME type, e.g. MIME_TYPE (VARCHAR2(100)). The plug-in fills it from the checked file content, not from what the browser says.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13144980834326312)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>17
,p_display_sequence=>170
,p_static_id=>'attribute_17'
,p_prompt=>'File Content Column'
,p_apexlang_name=>'contentColumn'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_max_length=>128
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13144124335326312)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'TABLE'
,p_attribute_group_id=>wwv_flow_imp.id(13144020089326312)
,p_text_case=>'UPPER'
,p_help_text=>'The BLOB column holding the file, e.g. CONTENT.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13145006292326312)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>18
,p_display_sequence=>180
,p_static_id=>'attribute_18'
,p_prompt=>'File Size Column'
,p_apexlang_name=>'fileSizeColumn'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_max_length=>128
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13144124335326312)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'TABLE'
,p_attribute_group_id=>wwv_flow_imp.id(13144020089326312)
,p_text_case=>'UPPER'
,p_help_text=>'Optional column for the size in bytes, e.g. FILE_SIZE. Without it the size is read from the BLOB.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13158105291493648)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>19
,p_display_sequence=>1100
,p_static_id=>'attribute_19'
,p_prompt=>'Type'
,p_apexlang_name=>'field1Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'NONE'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(13157878634493648)
,p_help_text=>'An extra value kept with each file, e.g. Remarks or the expense category. Text Field shows an input for every file in the panel (also for saved files - changes are applied when the grid is saved); it can start with the value of a grid column or page '
||'item. Hidden has no input: the files get the value of the grid column or page item when the row is saved.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13158658977493648)
,p_plugin_attribute_id=>wwv_flow_imp.id(13158105291493648)
,p_display_sequence=>50
,p_display_value=>'Hidden'
,p_return_value=>'HIDDEN'
,p_apexlang_name=>'hidden'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13158219689493648)
,p_plugin_attribute_id=>wwv_flow_imp.id(13158105291493648)
,p_display_sequence=>10
,p_display_value=>'Not Used'
,p_return_value=>'NONE'
,p_apexlang_name=>'none'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13158379462493648)
,p_plugin_attribute_id=>wwv_flow_imp.id(13158105291493648)
,p_display_sequence=>20
,p_display_value=>'Text Field'
,p_return_value=>'TEXT'
,p_apexlang_name=>'textField'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13158700179493648)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>20
,p_display_sequence=>1110
,p_static_id=>'attribute_20'
,p_prompt=>'Label'
,p_apexlang_name=>'field1Label'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_max_length=>200
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13158105291493648)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'TEXT,HIDDEN'
,p_attribute_group_id=>wwv_flow_imp.id(13157878634493648)
,p_help_text=>'The label of the input, e.g. Document Type. It is also used in messages such as "Fill in Document Type for receipt.pdf".'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13158836782493648)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>21
,p_display_sequence=>1120
,p_static_id=>'attribute_21'
,p_prompt=>'Column'
,p_apexlang_name=>'field1Column'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_max_length=>128
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13158105291493648)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'TEXT,HIDDEN'
,p_attribute_group_id=>wwv_flow_imp.id(13157878634493648)
,p_text_case=>'UPPER'
,p_help_text=>'Storage = My Table - the column of your attachments table for this value, e.g. DOCUMENT_TYPE (VARCHAR2). With the Plug-in Table the value is kept in IGA_FILES.F1; leave this empty.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13159047722493648)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>23
,p_display_sequence=>1140
,p_static_id=>'attribute_23'
,p_prompt=>'Value From'
,p_apexlang_name=>'field1ValueFrom'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'NONE'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13158105291493648)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'TEXT,HIDDEN'
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(13157878634493648)
,p_help_text=>'Where the value comes from - Grid Column (a column of the same grid row, e.g. CATEGORY) or Page Item (e.g. P300_DEPARTMENT). Text Field - the starting value of a new file, taken in the browser when the file is added; the user can change it. Hidden - '
||'the value when the row is saved, set on all the row''s files (also when it changes later); the server reads it, so users cannot change it. A page item that changes on the page must be in the grid''s Page Items to Submit.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13159379911493648)
,p_plugin_attribute_id=>wwv_flow_imp.id(13159047722493648)
,p_display_sequence=>30
,p_display_value=>'Grid Column'
,p_return_value=>'COLUMN'
,p_apexlang_name=>'gridColumn'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13159173170493648)
,p_plugin_attribute_id=>wwv_flow_imp.id(13159047722493648)
,p_display_sequence=>10
,p_display_value=>'Nothing'
,p_return_value=>'NONE'
,p_apexlang_name=>'none'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13159462562493648)
,p_plugin_attribute_id=>wwv_flow_imp.id(13159047722493648)
,p_display_sequence=>40
,p_display_value=>'Page Item'
,p_return_value=>'ITEM'
,p_apexlang_name=>'pageItem'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13159605623493648)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>24
,p_display_sequence=>1150
,p_static_id=>'attribute_24'
,p_prompt=>'Column or Item'
,p_apexlang_name=>'field1ColumnOrItem'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_max_length=>128
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13159047722493648)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'COLUMN,ITEM'
,p_attribute_group_id=>wwv_flow_imp.id(13157878634493648)
,p_text_case=>'UPPER'
,p_help_text=>'The name of the grid column (e.g. CATEGORY) or the page item (e.g. P300_DEPARTMENT).'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13159793161493648)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>25
,p_display_sequence=>1160
,p_static_id=>'attribute_25'
,p_prompt=>'Value Required'
,p_apexlang_name=>'field1Required'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13158105291493648)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'TEXT'
,p_attribute_group_id=>wwv_flow_imp.id(13157878634493648)
,p_help_text=>'New and changed files need a value before the panel closes; the server checks it again when the grid is saved.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13159835806493648)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>26
,p_display_sequence=>1200
,p_static_id=>'attribute_26'
,p_prompt=>'Type'
,p_apexlang_name=>'field2Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'NONE'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(13157917687493648)
,p_help_text=>'An extra value kept with each file, e.g. Remarks or the expense category. Text Field shows an input for every file in the panel (also for saved files - changes are applied when the grid is saved); it can start with the value of a grid column or page '
||'item. Hidden has no input: the files get the value of the grid column or page item when the row is saved.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13160346835493648)
,p_plugin_attribute_id=>wwv_flow_imp.id(13159835806493648)
,p_display_sequence=>50
,p_display_value=>'Hidden'
,p_return_value=>'HIDDEN'
,p_apexlang_name=>'hidden'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13159918257493648)
,p_plugin_attribute_id=>wwv_flow_imp.id(13159835806493648)
,p_display_sequence=>10
,p_display_value=>'Not Used'
,p_return_value=>'NONE'
,p_apexlang_name=>'none'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13160029353493648)
,p_plugin_attribute_id=>wwv_flow_imp.id(13159835806493648)
,p_display_sequence=>20
,p_display_value=>'Text Field'
,p_return_value=>'TEXT'
,p_apexlang_name=>'textField'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13160431798493649)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>27
,p_display_sequence=>1210
,p_static_id=>'attribute_27'
,p_prompt=>'Label'
,p_apexlang_name=>'field2Label'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_max_length=>200
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13159835806493648)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'TEXT,HIDDEN'
,p_attribute_group_id=>wwv_flow_imp.id(13157917687493648)
,p_help_text=>'The label of the input, e.g. Document Type. It is also used in messages such as "Fill in Document Type for receipt.pdf".'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13160533751493649)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>28
,p_display_sequence=>1220
,p_static_id=>'attribute_28'
,p_prompt=>'Column'
,p_apexlang_name=>'field2Column'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_max_length=>128
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13159835806493648)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'TEXT,HIDDEN'
,p_attribute_group_id=>wwv_flow_imp.id(13157917687493648)
,p_text_case=>'UPPER'
,p_help_text=>'Storage = My Table - the column of your attachments table for this value, e.g. DOCUMENT_TYPE (VARCHAR2). With the Plug-in Table the value is kept in IGA_FILES.F2; leave this empty.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13160731397493649)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>30
,p_display_sequence=>1240
,p_static_id=>'attribute_30'
,p_prompt=>'Value From'
,p_apexlang_name=>'field2ValueFrom'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'NONE'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13159835806493648)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'TEXT,HIDDEN'
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(13157917687493648)
,p_help_text=>'Where the value comes from - Grid Column (a column of the same grid row, e.g. CATEGORY) or Page Item (e.g. P300_DEPARTMENT). Text Field - the starting value of a new file, taken in the browser when the file is added; the user can change it. Hidden - '
||'the value when the row is saved, set on all the row''s files (also when it changes later); the server reads it, so users cannot change it. A page item that changes on the page must be in the grid''s Page Items to Submit.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13161075921493649)
,p_plugin_attribute_id=>wwv_flow_imp.id(13160731397493649)
,p_display_sequence=>30
,p_display_value=>'Grid Column'
,p_return_value=>'COLUMN'
,p_apexlang_name=>'gridColumn'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13160894777493649)
,p_plugin_attribute_id=>wwv_flow_imp.id(13160731397493649)
,p_display_sequence=>10
,p_display_value=>'Nothing'
,p_return_value=>'NONE'
,p_apexlang_name=>'none'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13161180259493649)
,p_plugin_attribute_id=>wwv_flow_imp.id(13160731397493649)
,p_display_sequence=>40
,p_display_value=>'Page Item'
,p_return_value=>'ITEM'
,p_apexlang_name=>'pageItem'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13161398871493649)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>31
,p_display_sequence=>1250
,p_static_id=>'attribute_31'
,p_prompt=>'Column or Item'
,p_apexlang_name=>'field2ColumnOrItem'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_max_length=>128
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13160731397493649)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'COLUMN,ITEM'
,p_attribute_group_id=>wwv_flow_imp.id(13157917687493648)
,p_text_case=>'UPPER'
,p_help_text=>'The name of the grid column (e.g. CATEGORY) or the page item (e.g. P300_DEPARTMENT).'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13161410967493649)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>32
,p_display_sequence=>1260
,p_static_id=>'attribute_32'
,p_prompt=>'Value Required'
,p_apexlang_name=>'field2Required'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13159835806493648)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'TEXT'
,p_attribute_group_id=>wwv_flow_imp.id(13157917687493648)
,p_help_text=>'New and changed files need a value before the panel closes; the server checks it again when the grid is saved.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13161526058493649)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>33
,p_display_sequence=>1300
,p_static_id=>'attribute_33'
,p_prompt=>'Type'
,p_apexlang_name=>'field3Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'NONE'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(13158040938493648)
,p_help_text=>'An extra value kept with each file, e.g. Remarks or the expense category. Text Field shows an input for every file in the panel (also for saved files - changes are applied when the grid is saved); it can start with the value of a grid column or page '
||'item. Hidden has no input: the files get the value of the grid column or page item when the row is saved.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13162082080493649)
,p_plugin_attribute_id=>wwv_flow_imp.id(13161526058493649)
,p_display_sequence=>50
,p_display_value=>'Hidden'
,p_return_value=>'HIDDEN'
,p_apexlang_name=>'hidden'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13161602494493649)
,p_plugin_attribute_id=>wwv_flow_imp.id(13161526058493649)
,p_display_sequence=>10
,p_display_value=>'Not Used'
,p_return_value=>'NONE'
,p_apexlang_name=>'none'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13161763940493649)
,p_plugin_attribute_id=>wwv_flow_imp.id(13161526058493649)
,p_display_sequence=>20
,p_display_value=>'Text Field'
,p_return_value=>'TEXT'
,p_apexlang_name=>'textField'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13162116314493649)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>34
,p_display_sequence=>1310
,p_static_id=>'attribute_34'
,p_prompt=>'Label'
,p_apexlang_name=>'field3Label'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_max_length=>200
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13161526058493649)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'TEXT,HIDDEN'
,p_attribute_group_id=>wwv_flow_imp.id(13158040938493648)
,p_help_text=>'The label of the input, e.g. Document Type. It is also used in messages such as "Fill in Document Type for receipt.pdf".'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13162231999493649)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>35
,p_display_sequence=>1320
,p_static_id=>'attribute_35'
,p_prompt=>'Column'
,p_apexlang_name=>'field3Column'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_max_length=>128
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13161526058493649)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'TEXT,HIDDEN'
,p_attribute_group_id=>wwv_flow_imp.id(13158040938493648)
,p_text_case=>'UPPER'
,p_help_text=>'Storage = My Table - the column of your attachments table for this value, e.g. DOCUMENT_TYPE (VARCHAR2). With the Plug-in Table the value is kept in IGA_FILES.F3; leave this empty.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13162441877493649)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>37
,p_display_sequence=>1340
,p_static_id=>'attribute_37'
,p_prompt=>'Value From'
,p_apexlang_name=>'field3ValueFrom'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'NONE'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13161526058493649)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'TEXT,HIDDEN'
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(13158040938493648)
,p_help_text=>'Where the value comes from - Grid Column (a column of the same grid row, e.g. CATEGORY) or Page Item (e.g. P300_DEPARTMENT). Text Field - the starting value of a new file, taken in the browser when the file is added; the user can change it. Hidden - '
||'the value when the row is saved, set on all the row''s files (also when it changes later); the server reads it, so users cannot change it. A page item that changes on the page must be in the grid''s Page Items to Submit.'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13162767083493649)
,p_plugin_attribute_id=>wwv_flow_imp.id(13162441877493649)
,p_display_sequence=>30
,p_display_value=>'Grid Column'
,p_return_value=>'COLUMN'
,p_apexlang_name=>'gridColumn'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13162552384493649)
,p_plugin_attribute_id=>wwv_flow_imp.id(13162441877493649)
,p_display_sequence=>10
,p_display_value=>'Nothing'
,p_return_value=>'NONE'
,p_apexlang_name=>'none'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(13162806549493649)
,p_plugin_attribute_id=>wwv_flow_imp.id(13162441877493649)
,p_display_sequence=>40
,p_display_value=>'Page Item'
,p_return_value=>'ITEM'
,p_apexlang_name=>'pageItem'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13163070317493649)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>38
,p_display_sequence=>1350
,p_static_id=>'attribute_38'
,p_prompt=>'Column or Item'
,p_apexlang_name=>'field3ColumnOrItem'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_max_length=>128
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13162441877493649)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'COLUMN,ITEM'
,p_attribute_group_id=>wwv_flow_imp.id(13158040938493648)
,p_text_case=>'UPPER'
,p_help_text=>'The name of the grid column (e.g. CATEGORY) or the page item (e.g. P300_DEPARTMENT).'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13163152446493649)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>39
,p_display_sequence=>1360
,p_static_id=>'attribute_39'
,p_prompt=>'Value Required'
,p_apexlang_name=>'field3Required'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(13161526058493649)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'TEXT'
,p_attribute_group_id=>wwv_flow_imp.id(13158040938493648)
,p_help_text=>'New and changed files need a value before the panel closes; the server checks it again when the grid is saved.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13172352047714740)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>40
,p_display_sequence=>65
,p_static_id=>'attribute_40'
,p_prompt=>'Minimum Files per Row'
,p_apexlang_name=>'minFiles'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(13068496792704793)
,p_help_text=>'Makes attachments mandatory - 1 means every row needs at least one file. Checked by IGA_API.FINALIZE_EDIT when a row is inserted or updated (also when its attachments were never opened); the grid then shows the message on the row. Leave it empty for '
||'optional attachments.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13196512189084709)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>47
,p_display_sequence=>66
,p_static_id=>'attribute_47'
,p_prompt=>'Keep Unsaved Files'
,p_apexlang_name=>'keepMinutes'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_default_value=>'120'
,p_unit=>'minutes'
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(13068496792704793)
,p_help_text=>'How long files that were added but not saved with the grid are kept, counted from the last action in the panel (5 to 10080 minutes). After that the job IGA_PURGE_EXPIRED removes them and the panel starts a new edit.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13196634404084709)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>48
,p_display_sequence=>67
,p_static_id=>'attribute_48'
,p_prompt=>'Maximum Total Size per Row'
,p_apexlang_name=>'maxTotalSize'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_unit=>'KB'
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(13068496792704793)
,p_help_text=>'The largest size of all files of one row together, in KB. Checked when a file is added and again when the row is saved. Leave it empty for no limit.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13196772473084709)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>49
,p_display_sequence=>68
,p_static_id=>'attribute_49'
,p_prompt=>'File Check Function'
,p_apexlang_name=>'fileCheckFunction'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_max_length=>261
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(13068496792704793)
,p_help_text=>'Optional PL/SQL function that checks every added file, e.g. a virus scan - function my_check(p_file_name varchar2, p_mime_type varchar2, p_content blob) return varchar2. Return an error message to refuse the file, or null to accept it. Called after t'
||'he plug-in''s own type and content checks.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13225774967403695)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>59
,p_display_sequence=>10
,p_static_id=>'attribute_59'
,p_prompt=>'Authorization Function'
,p_apexlang_name=>'authorizationFunction'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_max_length=>261
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(13225652657403695)
,p_help_text=>'Optional. The grid already decides who may do what - users see the files of the rows in their grid, add files where the grid can add rows and change or remove them where it can update or delete rows (its authorization schemes included). Name a functi'
||'on for more rules, e.g. closed periods - function my_rule(p_key varchar2, p_operation varchar2) return boolean, operation READ, CREATE (key null), WRITE or DELETE. Return false to refuse.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13225865289403695)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_static_id=>'session_quota'
,p_prompt=>'Unsaved Files per Session'
,p_apexlang_name=>'sessionQuota'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_default_value=>'100'
,p_unit=>'MB'
,p_is_translatable=>false
,p_help_text=>'Files added but not saved yet may use at most this much per APEX session (all grids of the application).'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13226081443403695)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_static_id=>'total_quota'
,p_prompt=>'Unsaved Files in Total'
,p_apexlang_name=>'totalQuota'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_default_value=>'256'
,p_unit=>'MB'
,p_is_translatable=>false
,p_help_text=>'Files added but not saved yet may use at most this much for everybody together (the staging tables of the installation). Keep it below the free space of the schema''s tablespace, so users get this limit''s message instead of a database error when it fi'
||'lls up.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(13225912061403695)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_static_id=>'user_quota'
,p_prompt=>'Unsaved Files per User'
,p_apexlang_name=>'userQuota'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_default_value=>'200'
,p_unit=>'MB'
,p_is_translatable=>false
,p_help_text=>'Files added but not saved yet may use at most this much per user, over all the user''s sessions.'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2A204947204174746163686D656E747320312E302E30207C204D49540A202020436F6C6F75727320636F6D652066726F6D20746865206170706C69636174696F6E2773207468656D652028556E6976657273616C205468656D65207661726961626C65';
wwv_flow_imp.g_varchar2_table(2) := '732C20616C736F20696E206461726B206D6F6465293B0A2020207468652066616C6C6261636B73206172652075736564206F75747369646520415045582E202A2F0A2E6967612D656469746F722C2E6967612D70616E656C7B0A20202D2D6967612D6163';
wwv_flow_imp.g_varchar2_table(3) := '63656E743A766172282D2D75742D70616C657474652D7072696D6172792C23313736623538293B0A20202D2D6967612D616363656E742D746578743A766172282D2D75742D70616C657474652D7072696D6172792D636F6E74726173742C23666666293B';
wwv_flow_imp.g_varchar2_table(4) := '0A20202D2D6967612D62673A766172282D2D75742D636F6D706F6E656E742D6261636B67726F756E642D636F6C6F722C23666666293B0A20202D2D6967612D746578743A766172282D2D75742D636F6D706F6E656E742D746578742D64656661756C742D';
wwv_flow_imp.g_varchar2_table(5) := '636F6C6F722C23323033353265293B0A20202D2D6967612D6D757465643A766172282D2D75742D636F6D706F6E656E742D746578742D6D757465642D636F6C6F722C23356637313638293B0A20202D2D6967612D626F726465723A766172282D2D75742D';
wwv_flow_imp.g_varchar2_table(6) := '636F6D706F6E656E742D626F726465722D636F6C6F722C23643564646438293B0A20202D2D6967612D736F66743A766172282D2D75742D636F6D706F6E656E742D686967686C696768742D6261636B67726F756E642D636F6C6F722C7267626128313237';
wwv_flow_imp.g_varchar2_table(7) := '2C3132372C3132372C2E303829293B0A20202D2D6967612D64616E6765723A766172282D2D75742D70616C657474652D64616E6765722C23623332363165293B0A20202D2D6967612D7761726E696E673A766172282D2D75742D70616C657474652D7761';
wwv_flow_imp.g_varchar2_table(8) := '726E696E672C23623538313030293B0A7D0A2E6967612D656469746F727B646973706C61793A666C65783B616C69676E2D6974656D733A63656E7465723B77696474683A313030257D0A0A2F2A207468652063656C6C3A206120736D616C6C2062757474';
wwv_flow_imp.g_varchar2_table(9) := '6F6E2028616C736F2074686520656469746F722C20736F20746865206163746976652063656C6C206C6F6F6B73207468652073616D6520617320746865206F746865727329202A2F0A2E6967612D6F70656E7B666F6E743A696E68657269743B63757273';
wwv_flow_imp.g_varchar2_table(10) := '6F723A706F696E7465723B626F726465723A303B70616464696E673A303B6261636B67726F756E643A7472616E73706172656E743B636F6C6F723A696E68657269743B666F6E742D7765696768743A696E68657269743B626F726465722D726164697573';
wwv_flow_imp.g_varchar2_table(11) := '3A3670783B746578742D616C69676E3A696E68657269743B77696474683A313030257D0A2E6967612D6F70656E3A666F6375737B6F75746C696E653A6E6F6E653B626F782D736861646F773A6E6F6E657D0A2E6967612D6F70656E3A666F6375732D7669';
wwv_flow_imp.g_varchar2_table(12) := '7369626C65202E6967612D63656C6C7B6F75746C696E653A32707820736F6C696420766172282D2D6967612D616363656E74293B6F75746C696E652D6F66667365743A3170787D0A2E6967612D63656C6C7B646973706C61793A696E6C696E652D666C65';
wwv_flow_imp.g_varchar2_table(13) := '783B616C69676E2D6974656D733A63656E7465723B6A7573746966792D636F6E74656E743A63656E7465723B6761703A3670783B77686974652D73706163653A6E6F777261703B6D696E2D6865696768743A323670783B70616464696E673A3370782031';
wwv_flow_imp.g_varchar2_table(14) := '3070783B626F726465723A31707820736F6C696420766172282D2D6967612D626F726465722C23643564646438293B626F726465722D7261646975733A3670783B6261636B67726F756E643A766172282D2D6967612D62672C23666666293B636F6C6F72';
wwv_flow_imp.g_varchar2_table(15) := '3A766172282D2D6967612D746578742C696E6865726974293B666F6E742D73697A653A313270783B6C696E652D6865696768743A312E323B637572736F723A706F696E7465723B626F782D736861646F773A302031707820317078207267626128302C30';
wwv_flow_imp.g_varchar2_table(16) := '2C302C2E3034293B7472616E736974696F6E3A6261636B67726F756E64202E3132732C626F726465722D636F6C6F72202E3132737D0A2E6967612D63656C6C3A686F7665727B6261636B67726F756E643A766172282D2D6967612D736F66742C72676261';
wwv_flow_imp.g_varchar2_table(17) := '283132372C3132372C3132372C2E303829293B626F726465722D636F6C6F723A766172282D2D6967612D616363656E742C23313736623538297D0A2E6967612D63656C6C2E69732D70656E64696E677B626F726465722D636F6C6F723A766172282D2D69';
wwv_flow_imp.g_varchar2_table(18) := '67612D7761726E696E672C23623538313030297D0A2E6967612D63656C6C2D69636F6E2E66617B666F6E742D73697A653A313470783B636F6C6F723A766172282D2D6967612D616363656E742C23313736623538297D0A2E6967612D63656C6C2D636F75';
wwv_flow_imp.g_varchar2_table(19) := '6E747B6D696E2D77696474683A313870783B70616464696E673A30203570783B626F726465722D7261646975733A3970783B6261636B67726F756E643A766172282D2D6967612D616363656E742C23313736623538293B636F6C6F723A766172282D2D69';
wwv_flow_imp.g_varchar2_table(20) := '67612D616363656E742D746578742C23666666293B666F6E742D73697A653A313170783B666F6E742D7765696768743A3630303B6C696E652D6865696768743A313870783B746578742D616C69676E3A63656E7465727D0A2E6967612D63656C6C2D7065';
wwv_flow_imp.g_varchar2_table(21) := '6E64696E677B666F6E742D73697A653A313170783B70616464696E673A317078203670783B626F726465722D7261646975733A3470783B6261636B67726F756E643A72676261283138312C3132392C302C2E3134293B636F6C6F723A766172282D2D6967';
wwv_flow_imp.g_varchar2_table(22) := '612D7761726E696E672C23623538313030297D0A2E6967612D63656C6C2D646F747B77696474683A3770783B6865696768743A3770783B626F726465722D7261646975733A3530253B6261636B67726F756E643A766172282D2D6967612D7761726E696E';
wwv_flow_imp.g_varchar2_table(23) := '672C23623538313030293B6D617267696E2D696E6C696E652D73746172743A2D3270787D0A0A2F2A207468652070616E656C202A2F0A2E6967612D70616E656C7B666F6E743A313470782F312E3520766172282D2D612D626173652D666F6E742D66616D';
wwv_flow_imp.g_varchar2_table(24) := '696C792C73797374656D2D75692C2D6170706C652D73797374656D2C225365676F65205549222C73616E732D7365726966293B636F6C6F723A766172282D2D6967612D74657874293B6261636B67726F756E643A766172282D2D6967612D6267293B626F';
wwv_flow_imp.g_varchar2_table(25) := '726465723A31707820736F6C696420766172282D2D6967612D626F72646572293B626F726465722D7261646975733A313670783B626F782D736861646F773A3020323470782038307078207267626128302C302C302C2E3238293B70616464696E673A30';
wwv_flow_imp.g_varchar2_table(26) := '3B77696474683A6D696E2836383070782C63616C63283130307677202D203332707829293B6D61782D6865696768743A63616C6328313030647668202D2034387078293B6F766572666C6F773A6175746F7D0A2E6967612D70616E656C3A3A6261636B64';
wwv_flow_imp.g_varchar2_table(27) := '726F707B6261636B67726F756E643A726762612831302C32302C31362C2E3435293B6261636B64726F702D66696C7465723A626C757228337078297D0A2E6967612D70616E656C202A7B626F782D73697A696E673A626F726465722D626F787D0A2E6967';
wwv_flow_imp.g_varchar2_table(28) := '612D6865616465727B646973706C61793A666C65783B616C69676E2D6974656D733A63656E7465723B6A7573746966792D636F6E74656E743A73706163652D6265747765656E3B6761703A313270783B70616464696E673A323470782032387078203132';
wwv_flow_imp.g_varchar2_table(29) := '70787D0A2E6967612D65796562726F777B666F6E742D73697A653A313270783B666F6E742D7765696768743A3730303B6C65747465722D73706163696E673A2E3132656D3B636F6C6F723A766172282D2D6967612D6D75746564297D0A2E6967612D6865';
wwv_flow_imp.g_varchar2_table(30) := '616465722068327B666F6E742D73697A653A323270783B6D617267696E3A367078203020303B6C65747465722D73706163696E673A2D2E3032656D3B6C696E652D6865696768743A312E333B636F6C6F723A766172282D2D6967612D74657874297D0A2E';
wwv_flow_imp.g_varchar2_table(31) := '6967612D636C6F73657B626F726465723A303B6261636B67726F756E643A766172282D2D6967612D736F6674293B626F726465722D7261646975733A3530253B77696474683A333670783B6865696768743A333670783B70616464696E673A303B666C65';
wwv_flow_imp.g_varchar2_table(32) := '782D736872696E6B3A303B616C69676E2D73656C663A666C65782D73746172743B646973706C61793A696E6C696E652D666C65783B616C69676E2D6974656D733A63656E7465723B6A7573746966792D636F6E74656E743A63656E7465723B636F6C6F72';
wwv_flow_imp.g_varchar2_table(33) := '3A766172282D2D6967612D6D75746564293B637572736F723A706F696E7465727D0A2E6967612D636C6F7365202E66617B6C696E652D6865696768743A313B666F6E742D73697A653A313670787D0A2E6967612D636F6E746578747B6D617267696E3A30';
wwv_flow_imp.g_varchar2_table(34) := '3B70616464696E673A30203238707820313670783B636F6C6F723A766172282D2D6967612D6D75746564293B666F6E742D73697A653A313370787D0A2E6967612D64726F707B6D617267696E3A30203238707820313270783B6261636B67726F756E643A';
wwv_flow_imp.g_varchar2_table(35) := '766172282D2D6967612D736F6674293B626F726465723A312E3570782064617368656420766172282D2D6967612D626F72646572293B626F726465722D7261646975733A313270783B646973706C61793A666C65783B616C69676E2D6974656D733A6365';
wwv_flow_imp.g_varchar2_table(36) := '6E7465723B666C65782D646972656374696F6E3A636F6C756D6E3B6761703A3770783B70616464696E673A3232707820313670783B746578742D616C69676E3A63656E7465727D0A2E6967612D64726F702E69732D6F7665727B626F726465722D636F6C';
wwv_flow_imp.g_varchar2_table(37) := '6F723A766172282D2D6967612D616363656E74293B6261636B67726F756E643A766172282D2D6967612D6267297D0A2E6967612D64726F702D69636F6E7B636F6C6F723A766172282D2D6967612D616363656E74297D0A2E6967612D64726F702D69636F';
wwv_flow_imp.g_varchar2_table(38) := '6E202E66617B666F6E742D73697A653A333070787D0A2E6967612D64726F70207374726F6E677B666F6E742D73697A653A313670787D0A2E6967612D64726F70207370616E7B636F6C6F723A766172282D2D6967612D6D75746564293B666F6E742D7369';
wwv_flow_imp.g_varchar2_table(39) := '7A653A313370787D0A2E6967612D64726F7020736D616C6C7B666F6E742D73697A653A313270783B636F6C6F723A766172282D2D6967612D6D75746564293B6D617267696E2D746F703A3570787D0A2E6967612D62726F7773652C2E6967612D646F6E65';
wwv_flow_imp.g_varchar2_table(40) := '7B666F6E743A696E68657269743B637572736F723A706F696E7465723B626F726465723A303B626F726465722D7261646975733A3870783B70616464696E673A3130707820313670783B6261636B67726F756E643A766172282D2D6967612D616363656E';
wwv_flow_imp.g_varchar2_table(41) := '74293B636F6C6F723A766172282D2D6967612D616363656E742D74657874293B666F6E742D7765696768743A3630307D0A2E6967612D62726F7773657B6D617267696E2D746F703A3570783B666F6E742D73697A653A313370787D0A2E6967612D737461';
wwv_flow_imp.g_varchar2_table(42) := '7475737B70616464696E673A38707820323870783B636F6C6F723A766172282D2D6967612D6D75746564293B666F6E742D73697A653A313370783B6D696E2D6865696768743A333470787D0A2E6967612D6D6573736167653A656D7074797B646973706C';
wwv_flow_imp.g_varchar2_table(43) := '61793A6E6F6E657D0A2E6967612D6D6573736167657B6D617267696E3A38707820323870783B626F726465722D7261646975733A3870783B70616464696E673A313270783B6261636B67726F756E643A72676261283137392C33382C33302C2E31293B63';
wwv_flow_imp.g_varchar2_table(44) := '6F6C6F723A766172282D2D6967612D64616E676572297D0A2E6967612D66696C65737B70616464696E673A30203238707820323070783B646973706C61793A677269643B6761703A313070787D0A2E6967612D66696C657B646973706C61793A666C6578';
wwv_flow_imp.g_varchar2_table(45) := '3B616C69676E2D6974656D733A63656E7465723B6761703A313370783B626F726465723A31707820736F6C696420766172282D2D6967612D626F72646572293B626F726465722D7261646975733A313070783B70616464696E673A313470787D0A2E6967';
wwv_flow_imp.g_varchar2_table(46) := '612D66696C652E69732D75706C6F6164696E677B626F726465722D7374796C653A6461736865647D0A2E6967612D66696C652D69636F6E7B77696474683A343870783B6865696768743A353270783B626F726465722D7261646975733A3870783B626163';
wwv_flow_imp.g_varchar2_table(47) := '6B67726F756E643A766172282D2D6967612D736F6674293B636F6C6F723A766172282D2D6967612D616363656E74293B646973706C61793A666C65783B616C69676E2D6974656D733A63656E7465723B6A7573746966792D636F6E74656E743A63656E74';
wwv_flow_imp.g_varchar2_table(48) := '65723B666C65782D736872696E6B3A303B6F766572666C6F773A68696464656E7D0A2E6967612D66696C652D69636F6E202E66617B666F6E742D73697A653A323270787D0A2E6967612D707265766965777B77696474683A313030253B6865696768743A';
wwv_flow_imp.g_varchar2_table(49) := '313030253B6F626A6563742D6669743A636F7665727D0A2E6967612D66696C652D696E666F7B666C65783A313B6D696E2D77696474683A303B646973706C61793A666C65783B616C69676E2D6974656D733A666C65782D73746172743B666C65782D6469';
wwv_flow_imp.g_varchar2_table(50) := '72656374696F6E3A636F6C756D6E3B6761703A3370787D0A2E6967612D66696C652D696E666F207374726F6E677B666F6E742D73697A653A313370783B6D61782D77696474683A313030253B6F766572666C6F772D777261703A616E7977686572657D0A';
wwv_flow_imp.g_varchar2_table(51) := '2E6967612D66696C652D696E666F3E7370616E7B666F6E742D73697A653A313270783B636F6C6F723A766172282D2D6967612D6D75746564297D0A2E6967612D66696C652D696E666F202E6967612D62616467657B666F6E742D73697A653A313270783B';
wwv_flow_imp.g_varchar2_table(52) := '6261636B67726F756E643A766172282D2D6967612D736F6674293B636F6C6F723A766172282D2D6967612D74657874293B70616464696E673A317078203770783B626F726465722D7261646975733A3470787D0A2E6967612D66696C652E69732D72656D';
wwv_flow_imp.g_varchar2_table(53) := '6F7665647B626F726465722D636F6C6F723A766172282D2D6967612D64616E676572297D0A2E6967612D66696C652E69732D72656D6F766564202E6967612D62616467657B636F6C6F723A766172282D2D6967612D64616E676572297D0A2E6967612D62';
wwv_flow_imp.g_varchar2_table(54) := '61727B77696474683A31363070783B6D61782D77696474683A313030253B6865696768743A3470783B626F726465722D7261646975733A3270783B6261636B67726F756E643A766172282D2D6967612D736F6674293B6F766572666C6F773A6869646465';
wwv_flow_imp.g_varchar2_table(55) := '6E3B6D617267696E2D746F703A3270787D0A2E6967612D626172207370616E7B646973706C61793A626C6F636B3B6865696768743A313030253B77696474683A303B6261636B67726F756E643A766172282D2D6967612D616363656E74293B7472616E73';
wwv_flow_imp.g_varchar2_table(56) := '6974696F6E3A7769647468202E32737D0A2E6967612D66696C652D616374696F6E737B646973706C61793A666C65783B6761703A3670783B616C69676E2D6974656D733A63656E7465723B666C65782D777261703A777261703B6A7573746966792D636F';
wwv_flow_imp.g_varchar2_table(57) := '6E74656E743A666C65782D656E647D0A2E6967612D69636F6E2D627574746F6E7B646973706C61793A696E6C696E652D666C65783B616C69676E2D6974656D733A63656E7465723B6A7573746966792D636F6E74656E743A63656E7465723B7769647468';
wwv_flow_imp.g_varchar2_table(58) := '3A333470783B6865696768743A333470783B70616464696E673A303B626F726465723A31707820736F6C696420766172282D2D6967612D626F72646572293B626F726465722D7261646975733A3870783B6261636B67726F756E643A766172282D2D6967';
wwv_flow_imp.g_varchar2_table(59) := '612D6267293B636F6C6F723A766172282D2D6967612D616363656E74293B637572736F723A706F696E7465723B7472616E736974696F6E3A6261636B67726F756E64202E3132732C626F726465722D636F6C6F72202E3132737D0A2E6967612D69636F6E';
wwv_flow_imp.g_varchar2_table(60) := '2D627574746F6E3A686F7665727B6261636B67726F756E643A766172282D2D6967612D736F6674293B626F726465722D636F6C6F723A766172282D2D6967612D616363656E74297D0A2E6967612D69636F6E2D627574746F6E202E66617B666F6E742D73';
wwv_flow_imp.g_varchar2_table(61) := '697A653A313570783B6C696E652D6865696768743A317D0A2E6967612D64616E6765727B636F6C6F723A766172282D2D6967612D64616E676572297D0A2E6967612D69636F6E2D627574746F6E2E6967612D64616E6765723A686F7665727B626F726465';
wwv_flow_imp.g_varchar2_table(62) := '722D636F6C6F723A766172282D2D6967612D64616E676572297D0A2E6967612D76687B706F736974696F6E3A6162736F6C75746521696D706F7274616E743B77696474683A3170783B6865696768743A3170783B70616464696E673A303B6D617267696E';
wwv_flow_imp.g_varchar2_table(63) := '3A2D3170783B6F766572666C6F773A68696464656E3B636C69703A7265637428302C302C302C30293B77686974652D73706163653A6E6F777261703B626F726465723A307D0A2E6967612D656D7074797B70616464696E673A323070783B746578742D61';
wwv_flow_imp.g_varchar2_table(64) := '6C69676E3A63656E7465723B6261636B67726F756E643A766172282D2D6967612D736F6674293B626F726465722D7261646975733A313070783B636F6C6F723A766172282D2D6967612D6D75746564297D0A2E6967612D666F6F7465727B706F73697469';
wwv_flow_imp.g_varchar2_table(65) := '6F6E3A737469636B793B626F74746F6D3A303B6261636B67726F756E643A766172282D2D6967612D6267293B626F726465722D746F703A31707820736F6C696420766172282D2D6967612D626F72646572293B70616464696E673A313670782032387078';
wwv_flow_imp.g_varchar2_table(66) := '3B646973706C61793A666C65783B616C69676E2D6974656D733A63656E7465723B6A7573746966792D636F6E74656E743A73706163652D6265747765656E3B6761703A313670787D0A2E6967612D666F6F74657220707B6D617267696E3A303B636F6C6F';
wwv_flow_imp.g_varchar2_table(67) := '723A766172282D2D6967612D6D75746564293B666F6E742D73697A653A313270783B6D61782D77696474683A33333070787D0A2E6967612D70616E656C20627574746F6E3A666F6375732D76697369626C657B6F75746C696E653A33707820736F6C6964';
wwv_flow_imp.g_varchar2_table(68) := '20766172282D2D6967612D616363656E74293B6F75746C696E652D6F66667365743A3370787D0A2E6967612D70616E656C20627574746F6E3A64697361626C65647B6F7061636974793A2E353B637572736F723A776169747D0A2E6967612D70616E656C';
wwv_flow_imp.g_varchar2_table(69) := '205B68696464656E5D7B646973706C61793A6E6F6E6521696D706F7274616E747D0A0A2F2A204578747261204669656C6473206F6620612066696C65202A2F0A2E6967612D6669656C64737B646973706C61793A677269643B677269642D74656D706C61';
wwv_flow_imp.g_varchar2_table(70) := '74652D636F6C756D6E733A726570656174286175746F2D6669742C6D696E6D61782831353070782C31667229293B6761703A38707820313070783B77696474683A313030253B6D617267696E2D746F703A3670787D0A2E6967612D6669656C647B646973';
wwv_flow_imp.g_varchar2_table(71) := '706C61793A666C65783B666C65782D646972656374696F6E3A636F6C756D6E3B6761703A3370783B6D696E2D77696474683A307D0A2E6967612D6669656C64206C6162656C7B666F6E742D73697A653A313270783B666F6E742D7765696768743A363030';
wwv_flow_imp.g_varchar2_table(72) := '3B636F6C6F723A766172282D2D6967612D6D75746564297D0A2E6967612D6669656C642E69732D7265717569726564206C6162656C3A3A61667465727B636F6E74656E743A22202A223B636F6C6F723A766172282D2D6967612D64616E676572297D0A2E';
wwv_flow_imp.g_varchar2_table(73) := '6967612D6669656C6420696E7075742C2E6967612D6669656C642073656C6563742C2E6967612D6669656C642074657874617265617B666F6E743A696E68657269743B666F6E742D73697A653A313370783B70616464696E673A367078203870783B626F';
wwv_flow_imp.g_varchar2_table(74) := '726465723A31707820736F6C696420766172282D2D6967612D626F72646572293B626F726465722D7261646975733A3670783B6261636B67726F756E643A766172282D2D6967612D6267293B636F6C6F723A766172282D2D6967612D74657874293B7769';
wwv_flow_imp.g_varchar2_table(75) := '6474683A313030253B6D696E2D77696474683A307D0A2E6967612D6669656C642074657874617265617B726573697A653A766572746963616C7D0A2E6967612D6669656C64203A666F6375737B6F75746C696E653A32707820736F6C696420766172282D';
wwv_flow_imp.g_varchar2_table(76) := '2D6967612D616363656E74293B6F75746C696E652D6F66667365743A307D0A2E6967612D6669656C64203A64697361626C65647B6F7061636974793A2E377D0A0A406D65646961286D61782D77696474683A3532307078297B2E6967612D686561646572';
wwv_flow_imp.g_varchar2_table(77) := '7B70616464696E673A323070787D2E6967612D636F6E746578747B70616464696E673A30203230707820313670787D2E6967612D64726F707B6D617267696E2D696E6C696E653A323070787D2E6967612D66696C65737B70616464696E672D696E6C696E';
wwv_flow_imp.g_varchar2_table(78) := '653A323070787D2E6967612D66696C657B666C65782D777261703A777261707D2E6967612D66696C652D616374696F6E737B6D61782D77696474683A6E6F6E653B77696474683A313030253B6A7573746966792D636F6E74656E743A666C65782D737461';
wwv_flow_imp.g_varchar2_table(79) := '72743B70616464696E672D696E6C696E652D73746172743A363070787D2E6967612D666F6F7465727B70616464696E673A3136707820323070787D2E6967612D7374617475737B70616464696E672D696E6C696E653A323070787D7D0A406D6564696128';
wwv_flow_imp.g_varchar2_table(80) := '707265666572732D726564756365642D6D6F74696F6E3A726564756365297B2E6967612D70616E656C3A3A6261636B64726F707B6261636B64726F702D66696C7465723A6E6F6E657D7D0A2F2A206F757473696465204150455820286E6F207468656D65';
wwv_flow_imp.g_varchar2_table(81) := '207661726961626C657329207468652066616C6C6261636B7320666F6C6C6F77207468652073797374656D2773206461726B206D6F64653B0A202020696E73696465204150455820746865207468656D652773206F776E207661726961626C6573207769';
wwv_flow_imp.g_varchar2_table(82) := '6E2C206C69676874206F72206461726B202A2F0A406D6564696128707265666572732D636F6C6F722D736368656D653A6461726B297B2E6967612D656469746F722C2E6967612D70616E656C7B2D2D6967612D62673A766172282D2D75742D636F6D706F';
wwv_flow_imp.g_varchar2_table(83) := '6E656E742D6261636B67726F756E642D636F6C6F722C23316632363233293B2D2D6967612D746578743A766172282D2D75742D636F6D706F6E656E742D746578742D64656661756C742D636F6C6F722C23653665636539293B2D2D6967612D6D75746564';
wwv_flow_imp.g_varchar2_table(84) := '3A766172282D2D75742D636F6D706F6E656E742D746578742D6D757465642D636F6C6F722C23613762346164293B2D2D6967612D626F726465723A766172282D2D75742D636F6D706F6E656E742D626F726465722D636F6C6F722C23336134343430297D';
wwv_flow_imp.g_varchar2_table(85) := '7D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(13045711757558757)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_file_name=>'css/igAttachments.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2E6967612D656469746F722C2E6967612D70616E656C7B2D2D6967612D616363656E743A766172282D2D75742D70616C657474652D7072696D6172792C23313736623538293B2D2D6967612D616363656E742D746578743A766172282D2D75742D70616C';
wwv_flow_imp.g_varchar2_table(2) := '657474652D7072696D6172792D636F6E74726173742C23666666293B2D2D6967612D62673A766172282D2D75742D636F6D706F6E656E742D6261636B67726F756E642D636F6C6F722C23666666293B2D2D6967612D746578743A766172282D2D75742D63';
wwv_flow_imp.g_varchar2_table(3) := '6F6D706F6E656E742D746578742D64656661756C742D636F6C6F722C23323033353265293B2D2D6967612D6D757465643A766172282D2D75742D636F6D706F6E656E742D746578742D6D757465642D636F6C6F722C23356637313638293B2D2D6967612D';
wwv_flow_imp.g_varchar2_table(4) := '626F726465723A766172282D2D75742D636F6D706F6E656E742D626F726465722D636F6C6F722C23643564646438293B2D2D6967612D736F66743A766172282D2D75742D636F6D706F6E656E742D686967686C696768742D6261636B67726F756E642D63';
wwv_flow_imp.g_varchar2_table(5) := '6F6C6F722C72676261283132372C3132372C3132372C2E303829293B2D2D6967612D64616E6765723A766172282D2D75742D70616C657474652D64616E6765722C23623332363165293B2D2D6967612D7761726E696E673A766172282D2D75742D70616C';
wwv_flow_imp.g_varchar2_table(6) := '657474652D7761726E696E672C23623538313030297D2E6967612D656469746F727B646973706C61793A666C65783B616C69676E2D6974656D733A63656E7465723B77696474683A313030257D2E6967612D6F70656E7B666F6E743A696E68657269743B';
wwv_flow_imp.g_varchar2_table(7) := '637572736F723A706F696E7465723B626F726465723A303B70616464696E673A303B6261636B67726F756E643A7472616E73706172656E743B636F6C6F723A696E68657269743B666F6E742D7765696768743A696E68657269743B626F726465722D7261';
wwv_flow_imp.g_varchar2_table(8) := '646975733A3670783B746578742D616C69676E3A696E68657269743B77696474683A313030257D2E6967612D6F70656E3A666F6375737B6F75746C696E653A6E6F6E653B626F782D736861646F773A6E6F6E657D2E6967612D6F70656E3A666F6375732D';
wwv_flow_imp.g_varchar2_table(9) := '76697369626C65202E6967612D63656C6C7B6F75746C696E653A32707820736F6C696420766172282D2D6967612D616363656E74293B6F75746C696E652D6F66667365743A3170787D2E6967612D63656C6C7B646973706C61793A696E6C696E652D666C';
wwv_flow_imp.g_varchar2_table(10) := '65783B616C69676E2D6974656D733A63656E7465723B6A7573746966792D636F6E74656E743A63656E7465723B6761703A3670783B77686974652D73706163653A6E6F777261703B6D696E2D6865696768743A323670783B70616464696E673A33707820';
wwv_flow_imp.g_varchar2_table(11) := '313070783B626F726465723A31707820736F6C696420766172282D2D6967612D626F726465722C23643564646438293B626F726465722D7261646975733A3670783B6261636B67726F756E643A766172282D2D6967612D62672C23666666293B636F6C6F';
wwv_flow_imp.g_varchar2_table(12) := '723A766172282D2D6967612D746578742C696E6865726974293B666F6E742D73697A653A313270783B6C696E652D6865696768743A312E323B637572736F723A706F696E7465723B626F782D736861646F773A3020317078203170782023303030303030';
wwv_flow_imp.g_varchar2_table(13) := '30613B7472616E736974696F6E3A6261636B67726F756E64202E3132732C626F726465722D636F6C6F72202E3132737D2E6967612D63656C6C3A686F7665727B6261636B67726F756E643A766172282D2D6967612D736F66742C72676261283132372C31';
wwv_flow_imp.g_varchar2_table(14) := '32372C3132372C2E303829293B626F726465722D636F6C6F723A766172282D2D6967612D616363656E742C23313736623538297D2E6967612D63656C6C2E69732D70656E64696E677B626F726465722D636F6C6F723A766172282D2D6967612D7761726E';
wwv_flow_imp.g_varchar2_table(15) := '696E672C23623538313030297D2E6967612D63656C6C2D69636F6E2E66617B666F6E742D73697A653A313470783B636F6C6F723A766172282D2D6967612D616363656E742C23313736623538297D2E6967612D63656C6C2D636F756E747B6D696E2D7769';
wwv_flow_imp.g_varchar2_table(16) := '6474683A313870783B70616464696E673A30203570783B626F726465722D7261646975733A3970783B6261636B67726F756E643A766172282D2D6967612D616363656E742C23313736623538293B636F6C6F723A766172282D2D6967612D616363656E74';
wwv_flow_imp.g_varchar2_table(17) := '2D746578742C23666666293B666F6E742D73697A653A313170783B666F6E742D7765696768743A3630303B6C696E652D6865696768743A313870783B746578742D616C69676E3A63656E7465727D2E6967612D63656C6C2D70656E64696E677B666F6E74';
wwv_flow_imp.g_varchar2_table(18) := '2D73697A653A313170783B70616464696E673A317078203670783B626F726465722D7261646975733A3470783B6261636B67726F756E643A2362353831303032343B636F6C6F723A766172282D2D6967612D7761726E696E672C23623538313030297D2E';
wwv_flow_imp.g_varchar2_table(19) := '6967612D63656C6C2D646F747B77696474683A3770783B6865696768743A3770783B626F726465722D7261646975733A3530253B6261636B67726F756E643A766172282D2D6967612D7761726E696E672C23623538313030293B6D617267696E2D696E6C';
wwv_flow_imp.g_varchar2_table(20) := '696E652D73746172743A2D3270787D2E6967612D70616E656C7B666F6E743A313470782F312E3520766172282D2D612D626173652D666F6E742D66616D696C792C73797374656D2D75692C2D6170706C652D73797374656D2C225365676F65205549222C';
wwv_flow_imp.g_varchar2_table(21) := '73616E732D7365726966293B636F6C6F723A766172282D2D6967612D74657874293B6261636B67726F756E643A766172282D2D6967612D6267293B626F726465723A31707820736F6C696420766172282D2D6967612D626F72646572293B626F72646572';
wwv_flow_imp.g_varchar2_table(22) := '2D7261646975733A313670783B626F782D736861646F773A3020323470782038307078202330303030303034373B70616464696E673A303B77696474683A6D696E2836383070782C63616C63283130307677202D203332707829293B6D61782D68656967';
wwv_flow_imp.g_varchar2_table(23) := '68743A63616C6328313030647668202D2034387078293B6F766572666C6F773A6175746F7D2E6967612D70616E656C3A3A6261636B64726F707B6261636B67726F756E643A2330613134313037333B2D7765626B69742D6261636B64726F702D66696C74';
wwv_flow_imp.g_varchar2_table(24) := '65723A626C757228337078293B6261636B64726F702D66696C7465723A626C757228337078297D2E6967612D70616E656C202A7B626F782D73697A696E673A626F726465722D626F787D2E6967612D6865616465727B646973706C61793A666C65783B61';
wwv_flow_imp.g_varchar2_table(25) := '6C69676E2D6974656D733A63656E7465723B6A7573746966792D636F6E74656E743A73706163652D6265747765656E3B6761703A313270783B70616464696E673A32347078203238707820313270787D2E6967612D65796562726F777B666F6E742D7369';
wwv_flow_imp.g_varchar2_table(26) := '7A653A313270783B666F6E742D7765696768743A3730303B6C65747465722D73706163696E673A2E3132656D3B636F6C6F723A766172282D2D6967612D6D75746564297D2E6967612D6865616465722068327B666F6E742D73697A653A323270783B6D61';
wwv_flow_imp.g_varchar2_table(27) := '7267696E3A367078203020303B6C65747465722D73706163696E673A2D2E3032656D3B6C696E652D6865696768743A312E333B636F6C6F723A766172282D2D6967612D74657874297D2E6967612D636C6F73657B626F726465723A303B6261636B67726F';
wwv_flow_imp.g_varchar2_table(28) := '756E643A766172282D2D6967612D736F6674293B626F726465722D7261646975733A3530253B77696474683A333670783B6865696768743A333670783B70616464696E673A303B666C65782D736872696E6B3A303B616C69676E2D73656C663A666C6578';
wwv_flow_imp.g_varchar2_table(29) := '2D73746172743B646973706C61793A696E6C696E652D666C65783B616C69676E2D6974656D733A63656E7465723B6A7573746966792D636F6E74656E743A63656E7465723B636F6C6F723A766172282D2D6967612D6D75746564293B637572736F723A70';
wwv_flow_imp.g_varchar2_table(30) := '6F696E7465727D2E6967612D636C6F7365202E66617B6C696E652D6865696768743A313B666F6E742D73697A653A313670787D2E6967612D636F6E746578747B6D617267696E3A303B70616464696E673A30203238707820313670783B636F6C6F723A76';
wwv_flow_imp.g_varchar2_table(31) := '6172282D2D6967612D6D75746564293B666F6E742D73697A653A313370787D2E6967612D64726F707B6D617267696E3A30203238707820313270783B6261636B67726F756E643A766172282D2D6967612D736F6674293B626F726465723A312E35707820';
wwv_flow_imp.g_varchar2_table(32) := '64617368656420766172282D2D6967612D626F72646572293B626F726465722D7261646975733A313270783B646973706C61793A666C65783B616C69676E2D6974656D733A63656E7465723B666C65782D646972656374696F6E3A636F6C756D6E3B6761';
wwv_flow_imp.g_varchar2_table(33) := '703A3770783B70616464696E673A3232707820313670783B746578742D616C69676E3A63656E7465727D2E6967612D64726F702E69732D6F7665727B626F726465722D636F6C6F723A766172282D2D6967612D616363656E74293B6261636B67726F756E';
wwv_flow_imp.g_varchar2_table(34) := '643A766172282D2D6967612D6267297D2E6967612D64726F702D69636F6E7B636F6C6F723A766172282D2D6967612D616363656E74297D2E6967612D64726F702D69636F6E202E66617B666F6E742D73697A653A333070787D2E6967612D64726F702073';
wwv_flow_imp.g_varchar2_table(35) := '74726F6E677B666F6E742D73697A653A313670787D2E6967612D64726F70207370616E7B636F6C6F723A766172282D2D6967612D6D75746564293B666F6E742D73697A653A313370787D2E6967612D64726F7020736D616C6C7B666F6E742D73697A653A';
wwv_flow_imp.g_varchar2_table(36) := '313270783B636F6C6F723A766172282D2D6967612D6D75746564293B6D617267696E2D746F703A3570787D2E6967612D62726F7773652C2E6967612D646F6E657B666F6E743A696E68657269743B637572736F723A706F696E7465723B626F726465723A';
wwv_flow_imp.g_varchar2_table(37) := '303B626F726465722D7261646975733A3870783B70616464696E673A3130707820313670783B6261636B67726F756E643A766172282D2D6967612D616363656E74293B636F6C6F723A766172282D2D6967612D616363656E742D74657874293B666F6E74';
wwv_flow_imp.g_varchar2_table(38) := '2D7765696768743A3630307D2E6967612D62726F7773657B6D617267696E2D746F703A3570783B666F6E742D73697A653A313370787D2E6967612D7374617475737B70616464696E673A38707820323870783B636F6C6F723A766172282D2D6967612D6D';
wwv_flow_imp.g_varchar2_table(39) := '75746564293B666F6E742D73697A653A313370783B6D696E2D6865696768743A333470787D2E6967612D6D6573736167653A656D7074797B646973706C61793A6E6F6E657D2E6967612D6D6573736167657B6D617267696E3A38707820323870783B626F';
wwv_flow_imp.g_varchar2_table(40) := '726465722D7261646975733A3870783B70616464696E673A313270783B6261636B67726F756E643A2362333236316531613B636F6C6F723A766172282D2D6967612D64616E676572297D2E6967612D66696C65737B70616464696E673A30203238707820';
wwv_flow_imp.g_varchar2_table(41) := '323070783B646973706C61793A677269643B6761703A313070787D2E6967612D66696C657B646973706C61793A666C65783B616C69676E2D6974656D733A63656E7465723B6761703A313370783B626F726465723A31707820736F6C696420766172282D';
wwv_flow_imp.g_varchar2_table(42) := '2D6967612D626F72646572293B626F726465722D7261646975733A313070783B70616464696E673A313470787D2E6967612D66696C652E69732D75706C6F6164696E677B626F726465722D7374796C653A6461736865647D2E6967612D66696C652D6963';
wwv_flow_imp.g_varchar2_table(43) := '6F6E7B77696474683A343870783B6865696768743A353270783B626F726465722D7261646975733A3870783B6261636B67726F756E643A766172282D2D6967612D736F6674293B636F6C6F723A766172282D2D6967612D616363656E74293B646973706C';
wwv_flow_imp.g_varchar2_table(44) := '61793A666C65783B616C69676E2D6974656D733A63656E7465723B6A7573746966792D636F6E74656E743A63656E7465723B666C65782D736872696E6B3A303B6F766572666C6F773A68696464656E7D2E6967612D66696C652D69636F6E202E66617B66';
wwv_flow_imp.g_varchar2_table(45) := '6F6E742D73697A653A323270787D2E6967612D707265766965777B77696474683A313030253B6865696768743A313030253B6F626A6563742D6669743A636F7665727D2E6967612D66696C652D696E666F7B666C65783A313B6D696E2D77696474683A30';
wwv_flow_imp.g_varchar2_table(46) := '3B646973706C61793A666C65783B616C69676E2D6974656D733A666C65782D73746172743B666C65782D646972656374696F6E3A636F6C756D6E3B6761703A3370787D2E6967612D66696C652D696E666F207374726F6E677B666F6E742D73697A653A31';
wwv_flow_imp.g_varchar2_table(47) := '3370783B6D61782D77696474683A313030253B6F766572666C6F772D777261703A616E7977686572657D2E6967612D66696C652D696E666F3E7370616E7B666F6E742D73697A653A313270783B636F6C6F723A766172282D2D6967612D6D75746564297D';
wwv_flow_imp.g_varchar2_table(48) := '2E6967612D66696C652D696E666F202E6967612D62616467657B666F6E742D73697A653A313270783B6261636B67726F756E643A766172282D2D6967612D736F6674293B636F6C6F723A766172282D2D6967612D74657874293B70616464696E673A3170';
wwv_flow_imp.g_varchar2_table(49) := '78203770783B626F726465722D7261646975733A3470787D2E6967612D66696C652E69732D72656D6F7665647B626F726465722D636F6C6F723A766172282D2D6967612D64616E676572297D2E6967612D66696C652E69732D72656D6F766564202E6967';
wwv_flow_imp.g_varchar2_table(50) := '612D62616467657B636F6C6F723A766172282D2D6967612D64616E676572297D2E6967612D6261727B77696474683A31363070783B6D61782D77696474683A313030253B6865696768743A3470783B626F726465722D7261646975733A3270783B626163';
wwv_flow_imp.g_varchar2_table(51) := '6B67726F756E643A766172282D2D6967612D736F6674293B6F766572666C6F773A68696464656E3B6D617267696E2D746F703A3270787D2E6967612D626172207370616E7B646973706C61793A626C6F636B3B6865696768743A313030253B7769647468';
wwv_flow_imp.g_varchar2_table(52) := '3A303B6261636B67726F756E643A766172282D2D6967612D616363656E74293B7472616E736974696F6E3A7769647468202E32737D2E6967612D66696C652D616374696F6E737B646973706C61793A666C65783B6761703A3670783B616C69676E2D6974';
wwv_flow_imp.g_varchar2_table(53) := '656D733A63656E7465723B666C65782D777261703A777261703B6A7573746966792D636F6E74656E743A666C65782D656E647D2E6967612D69636F6E2D627574746F6E7B646973706C61793A696E6C696E652D666C65783B616C69676E2D6974656D733A';
wwv_flow_imp.g_varchar2_table(54) := '63656E7465723B6A7573746966792D636F6E74656E743A63656E7465723B77696474683A333470783B6865696768743A333470783B70616464696E673A303B626F726465723A31707820736F6C696420766172282D2D6967612D626F72646572293B626F';
wwv_flow_imp.g_varchar2_table(55) := '726465722D7261646975733A3870783B6261636B67726F756E643A766172282D2D6967612D6267293B636F6C6F723A766172282D2D6967612D616363656E74293B637572736F723A706F696E7465723B7472616E736974696F6E3A6261636B67726F756E';
wwv_flow_imp.g_varchar2_table(56) := '64202E3132732C626F726465722D636F6C6F72202E3132737D2E6967612D69636F6E2D627574746F6E3A686F7665727B6261636B67726F756E643A766172282D2D6967612D736F6674293B626F726465722D636F6C6F723A766172282D2D6967612D6163';
wwv_flow_imp.g_varchar2_table(57) := '63656E74297D2E6967612D69636F6E2D627574746F6E202E66617B666F6E742D73697A653A313570783B6C696E652D6865696768743A317D2E6967612D64616E6765727B636F6C6F723A766172282D2D6967612D64616E676572297D2E6967612D69636F';
wwv_flow_imp.g_varchar2_table(58) := '6E2D627574746F6E2E6967612D64616E6765723A686F7665727B626F726465722D636F6C6F723A766172282D2D6967612D64616E676572297D2E6967612D76687B706F736974696F6E3A6162736F6C75746521696D706F7274616E743B77696474683A31';
wwv_flow_imp.g_varchar2_table(59) := '70783B6865696768743A3170783B70616464696E673A303B6D617267696E3A2D3170783B6F766572666C6F773A68696464656E3B636C69703A7265637428302C302C302C30293B77686974652D73706163653A6E6F777261703B626F726465723A307D2E';
wwv_flow_imp.g_varchar2_table(60) := '6967612D656D7074797B70616464696E673A323070783B746578742D616C69676E3A63656E7465723B6261636B67726F756E643A766172282D2D6967612D736F6674293B626F726465722D7261646975733A313070783B636F6C6F723A766172282D2D69';
wwv_flow_imp.g_varchar2_table(61) := '67612D6D75746564297D2E6967612D666F6F7465727B706F736974696F6E3A737469636B793B626F74746F6D3A303B6261636B67726F756E643A766172282D2D6967612D6267293B626F726465722D746F703A31707820736F6C696420766172282D2D69';
wwv_flow_imp.g_varchar2_table(62) := '67612D626F72646572293B70616464696E673A3136707820323870783B646973706C61793A666C65783B616C69676E2D6974656D733A63656E7465723B6A7573746966792D636F6E74656E743A73706163652D6265747765656E3B6761703A313670787D';
wwv_flow_imp.g_varchar2_table(63) := '2E6967612D666F6F74657220707B6D617267696E3A303B636F6C6F723A766172282D2D6967612D6D75746564293B666F6E742D73697A653A313270783B6D61782D77696474683A33333070787D2E6967612D70616E656C20627574746F6E3A666F637573';
wwv_flow_imp.g_varchar2_table(64) := '2D76697369626C657B6F75746C696E653A33707820736F6C696420766172282D2D6967612D616363656E74293B6F75746C696E652D6F66667365743A3370787D2E6967612D70616E656C20627574746F6E3A64697361626C65647B6F7061636974793A2E';
wwv_flow_imp.g_varchar2_table(65) := '353B637572736F723A776169747D2E6967612D70616E656C205B68696464656E5D7B646973706C61793A6E6F6E6521696D706F7274616E747D2E6967612D6669656C64737B646973706C61793A677269643B677269642D74656D706C6174652D636F6C75';
wwv_flow_imp.g_varchar2_table(66) := '6D6E733A726570656174286175746F2D6669742C6D696E6D61782831353070782C31667229293B6761703A38707820313070783B77696474683A313030253B6D617267696E2D746F703A3670787D2E6967612D6669656C647B646973706C61793A666C65';
wwv_flow_imp.g_varchar2_table(67) := '783B666C65782D646972656374696F6E3A636F6C756D6E3B6761703A3370783B6D696E2D77696474683A307D2E6967612D6669656C64206C6162656C7B666F6E742D73697A653A313270783B666F6E742D7765696768743A3630303B636F6C6F723A7661';
wwv_flow_imp.g_varchar2_table(68) := '72282D2D6967612D6D75746564297D2E6967612D6669656C642E69732D7265717569726564206C6162656C3A61667465727B636F6E74656E743A22202A223B636F6C6F723A766172282D2D6967612D64616E676572297D2E6967612D6669656C6420696E';
wwv_flow_imp.g_varchar2_table(69) := '7075742C2E6967612D6669656C642073656C6563742C2E6967612D6669656C642074657874617265617B666F6E743A696E68657269743B666F6E742D73697A653A313370783B70616464696E673A367078203870783B626F726465723A31707820736F6C';
wwv_flow_imp.g_varchar2_table(70) := '696420766172282D2D6967612D626F72646572293B626F726465722D7261646975733A3670783B6261636B67726F756E643A766172282D2D6967612D6267293B636F6C6F723A766172282D2D6967612D74657874293B77696474683A313030253B6D696E';
wwv_flow_imp.g_varchar2_table(71) := '2D77696474683A307D2E6967612D6669656C642074657874617265617B726573697A653A766572746963616C7D2E6967612D6669656C64203A666F6375737B6F75746C696E653A32707820736F6C696420766172282D2D6967612D616363656E74293B6F';
wwv_flow_imp.g_varchar2_table(72) := '75746C696E652D6F66667365743A307D2E6967612D6669656C64203A64697361626C65647B6F7061636974793A2E377D406D6564696120286D61782D77696474683A3532307078297B2E6967612D6865616465727B70616464696E673A323070787D2E69';
wwv_flow_imp.g_varchar2_table(73) := '67612D636F6E746578747B70616464696E673A30203230707820313670787D2E6967612D64726F707B6D617267696E2D696E6C696E653A323070787D2E6967612D66696C65737B70616464696E672D696E6C696E653A323070787D2E6967612D66696C65';
wwv_flow_imp.g_varchar2_table(74) := '7B666C65782D777261703A777261707D2E6967612D66696C652D616374696F6E737B6D61782D77696474683A6E6F6E653B77696474683A313030253B6A7573746966792D636F6E74656E743A666C65782D73746172743B70616464696E672D696E6C696E';
wwv_flow_imp.g_varchar2_table(75) := '652D73746172743A363070787D2E6967612D666F6F7465727B70616464696E673A3136707820323070787D2E6967612D7374617475737B70616464696E672D696E6C696E653A323070787D7D406D656469612028707265666572732D726564756365642D';
wwv_flow_imp.g_varchar2_table(76) := '6D6F74696F6E3A726564756365297B2E6967612D70616E656C3A3A6261636B64726F707B2D7765626B69742D6261636B64726F702D66696C7465723A6E6F6E653B6261636B64726F702D66696C7465723A6E6F6E657D7D406D6564696120287072656665';
wwv_flow_imp.g_varchar2_table(77) := '72732D636F6C6F722D736368656D653A6461726B297B2E6967612D656469746F722C2E6967612D70616E656C7B2D2D6967612D62673A766172282D2D75742D636F6D706F6E656E742D6261636B67726F756E642D636F6C6F722C23316632363233293B2D';
wwv_flow_imp.g_varchar2_table(78) := '2D6967612D746578743A766172282D2D75742D636F6D706F6E656E742D746578742D64656661756C742D636F6C6F722C23653665636539293B2D2D6967612D6D757465643A766172282D2D75742D636F6D706F6E656E742D746578742D6D757465642D63';
wwv_flow_imp.g_varchar2_table(79) := '6F6C6F722C23613762346164293B2D2D6967612D626F726465723A766172282D2D75742D636F6D706F6E656E742D626F726465722D636F6C6F722C23336134343430297D7D0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(13763332547159729)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_file_name=>'css/igAttachments.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2A204947204174746163686D656E747320312E312E30207C204D4954202A2F0A2866756E6374696F6E2028726F6F742C20666163746F727929207B0A202020202275736520737472696374223B0A20202020636F6E737420617069203D20666163746F';
wwv_flow_imp.g_varchar2_table(2) := '727928293B0A2020202069662028747970656F66206D6F64756C65203D3D3D20226F626A65637422202626206D6F64756C652E6578706F72747329206D6F64756C652E6578706F727473203D206170693B0A20202020656C736520726F6F742E69676141';
wwv_flow_imp.g_varchar2_table(3) := '74746163686D656E7473203D206170693B0A7D28747970656F6620676C6F62616C5468697320213D3D2022756E646566696E656422203F20676C6F62616C54686973203A20746869732C2066756E6374696F6E202829207B0A2020202022757365207374';
wwv_flow_imp.g_varchar2_table(4) := '72696374223B0A20202020636F6E737420696E7374616E636573203D206E6577204D617028293B0A20202020636F6E737420616C6961736573203D206E6577204D617028293B2020202F2F20696E7374616E6365202D3E2069747320636F6C756D6E206E';
wwv_flow_imp.g_varchar2_table(5) := '616D652C207768656E207468617420646966666572732066726F6D20746865206974656D2069640A202020202F2F2074686520677269647327205361766520616374696F6E732077726170706564206279206174746163686D656E7420636F6C756D6E73';
wwv_flow_imp.g_varchar2_table(6) := '3A20616374696F6E73202D3E207B206F726967696E616C2C20677561726465642C20636865636B73207D0A20202020636F6E73742073617665477561726473203D206E6577204D617028293B0A20202020636F6E737420756E77726170203D2076616C75';
wwv_flow_imp.g_varchar2_table(7) := '65203D3E2076616C756520262620747970656F662076616C7565203D3D3D20226F626A656374222026262022762220696E2076616C7565203F2076616C75652E76203A2076616C75653B0A2020202066756E6374696F6E2062797465732876616C756529';
wwv_flow_imp.g_varchar2_table(8) := '207B0A20202020202020202F2F2035204D422C20322E35204D422C20343530204B423A206E6F20222E3022206F6E2077686F6C65206E756D626572730A2020202020202020636F6E737420666D74203D206E203D3E20537472696E67284D6174682E726F';
wwv_flow_imp.g_varchar2_table(9) := '756E64286E202A20313029202F203130293B0A202020202020202072657475726E2076616C7565203C2031303234203F2076616C7565202B2022204222203A2076616C7565203C20313034383537360A2020202020202020202020203F20666D74287661';
wwv_flow_imp.g_varchar2_table(10) := '6C7565202F203130323429202B2022204B4222203A20666D742876616C7565202F203130343835373629202B2022204D42223B0A202020207D0A2020202066756E6374696F6E2076616C696461746546696C652866696C652C2063666729207B0A202020';
wwv_flow_imp.g_varchar2_table(11) := '2020202020636F6E737420657874203D2066696C652E6E616D652E696E636C7564657328222E2229203F2066696C652E6E616D652E73706C697428222E22292E706F7028292E746F4C6F776572436173652829203A2022223B0A2020202020202020636F';
wwv_flow_imp.g_varchar2_table(12) := '6E737420616C6C6F776564203D206366672E6163636570742E73706C697428222C22292E6D61702878203D3E20782E7472696D28292E7265706C616365282F5E5C2E2F2C202222292E746F4C6F776572436173652829293B0A2020202020202020696620';
wwv_flow_imp.g_varchar2_table(13) := '2821616C6C6F7765642E696E636C75646573286578742929207468726F77206E6577204572726F722866696C652E6E616D65202B20223A20746869732066696C652074797065206973206E6F7420616C6C6F7765642E22293B0A20202020202020206966';
wwv_flow_imp.g_varchar2_table(14) := '20282166696C652E73697A6529207468726F77206E6577204572726F722866696C652E6E616D65202B202220697320656D7074792E22293B0A20202020202020206966202866696C652E73697A65203E206366672E6D6178427974657329207468726F77';
wwv_flow_imp.g_varchar2_table(15) := '206E6577204572726F722866696C652E6E616D65202B2022202822202B2062797465732866696C652E73697A6529202B202229206973206C6172676572207468616E207468652022202B206279746573286366672E6D6178427974657329202B2022206C';
wwv_flow_imp.g_varchar2_table(16) := '696D69742E22293B0A202020207D0A2020202066756E6374696F6E20746F4261736536342862756666657229207B0A20202020202020206C65742062696E617279203D2022223B0A20202020202020206E65772055696E74384172726179286275666665';
wwv_flow_imp.g_varchar2_table(17) := '72292E666F7245616368286E203D3E207B2062696E617279202B3D20537472696E672E66726F6D43686172436F6465286E293B207D293B0A202020202020202072657475726E2062746F612862696E617279293B0A202020207D0A20202020636F6E7374';
wwv_flow_imp.g_varchar2_table(18) := '204348554E4B203D203139363630383B202F2F20313932204B42206F662066696C652062797465732070657220726571756573740A20202020636F6E7374204449524543545F444F574E4C4F41445F4259544553203D2032363231343430303B202F2F20';
wwv_flow_imp.g_varchar2_table(19) := '6C617267657220646F776E6C6F61647320676F20737472616967687420746F207468652062726F7773657220283235204D42290A202020202F2F20616E206564697420746F6B656E3B2074686520636F6C756D6E2063616E20616C736F20686F6C642061';
wwv_flow_imp.g_varchar2_table(20) := '2066696C6520636F756E74202861206E756D626572292066726F6D2074686520677269642071756572790A20202020636F6E737420544F4B454E203D202F5E5B412D46302D395D7B33327D242F3B0A20202020636F6E7374206973546F6B656E203D2076';
wwv_flow_imp.g_varchar2_table(21) := '203D3E20544F4B454E2E746573742876203D3D206E756C6C203F202222203A20537472696E67287629293B0A20202020636C6173732053657373696F6E207B0A2020202020202020636F6E7374727563746F72286366672C206164617074657229207B0A';
wwv_flow_imp.g_varchar2_table(22) := '202020202020202020202020746869732E636667203D206366673B20746869732E61646170746572203D20616461707465723B20746869732E746F6B656E203D2022223B0A202020202020202020202020746869732E66696C6573203D205B5D3B207468';
wwv_flow_imp.g_varchar2_table(23) := '69732E62757379203D2066616C73653B20746869732E636F6E74657874203D206E756C6C3B0A202020202020202020202020746869732E7265616479203D2066616C73653B20746869732E70726F6772657373203D206E756C6C3B20746869732E6F6E63';
wwv_flow_imp.g_varchar2_table(24) := '68616E6765203D202829203D3E207B7D3B0A202020202020202020202020746869732E636C61696D6564203D2066616C73653B0A2020202020202020202020202F2F204578747261204669656C642076616C75657320747970656420627574206E6F7420';
wwv_flow_imp.g_varchar2_table(25) := '636F6E6669726D65642062792074686520736572766572207965743A2066696C65206964202D3E207B20696E6465783A2076616C7565207D2E0A2020202020202020202020202F2F20412072656675736564206F72206C6F7374204649454C4453207265';
wwv_flow_imp.g_varchar2_table(26) := '7175657374206B65657073207468656D202874686520696E7075742073686F7773207468656D20616761696E2C20636C6F73696E672072657472696573292E0A202020202020202020202020746869732E647261667473203D206E6577204D617028293B';
wwv_flow_imp.g_varchar2_table(27) := '0A2020202020202020202020202F2F204649454C4453207265717565737473207761697420666F722065616368206F7468657220616E6420666F722072756E6E696E6720776F726B20286E657665722022506C65617365207761697422290A2020202020';
wwv_flow_imp.g_varchar2_table(28) := '20202020202020746869732E6669656C645175657565203D2050726F6D6973652E7265736F6C766528293B0A20202020202020207D0A20202020202020202F2F2054686520726F7720686F6C64732074686520746F6B656E206F6E6C79207768696C6520';
wwv_flow_imp.g_varchar2_table(29) := '736F6D657468696E67206973207265616C6C792070656E64696E673A2061206E65772066696C652028616C736F206F6E650A20202020202020202F2F2077686F73652075706C6F616420646964206E6F742066696E697368202D20746865207361766520';
wwv_flow_imp.g_varchar2_table(30) := '7265667573657320697420756E74696C2069742069732072656D6F766564292C20612073617665642066696C65206D61726B65640A20202020202020202F2F20666F722072656D6F76616C206F722077697468206368616E676564206669656C64732E20';
wwv_flow_imp.g_varchar2_table(31) := '4F70656E696E6720616E6420636C6F73696E67202D206F7220616464696E6720612066696C6520616E642072656D6F76696E672069740A20202020202020202F2F20616761696E202D206C65617665732074686520726F77206173206974207761732E20';
wwv_flow_imp.g_varchar2_table(32) := '54686520726F772069732075706461746564207768656E207468652070616E656C20636C6F7365732C206E65766572207768696C650A20202020202020202F2F2066696C657320617265206265696E67207069636B656420286E6F206772696420776F72';
wwv_flow_imp.g_varchar2_table(33) := '6B20626568696E6420746865206469616C6F67292E0A2020202020202020736574746C652829207B0A202020202020202020202020636F6E73742070656E64696E67203D20746869732E66696C65732E736F6D652866203D3E20662E737461676564203F';
wwv_flow_imp.g_varchar2_table(34) := '2021662E72656D6F766564203A20662E72656D6F766564207C7C20662E6368616E676564293B0A2020202020202020202020206966202870656E64696E672026262021746869732E636C61696D656420262620746869732E746F6B656E29207B0A202020';
wwv_flow_imp.g_varchar2_table(35) := '20202020202020202020202020746869732E616461707465722E736574546F6B656E28746869732E636F6E746578742C20746869732E746F6B656E293B0A20202020202020202020202020202020746869732E636C61696D6564203D20747275653B0A20';
wwv_flow_imp.g_varchar2_table(36) := '20202020202020202020207D20656C736520696620282170656E64696E6720262620746869732E636C61696D656420262620746869732E616461707465722E636C656172546F6B656E29207B0A20202020202020202020202020202020746869732E6164';
wwv_flow_imp.g_varchar2_table(37) := '61707465722E636C656172546F6B656E28746869732E636F6E74657874293B0A20202020202020202020202020202020746869732E636C61696D6564203D2066616C73653B0A2020202020202020202020207D0A20202020202020207D0A202020202020';
wwv_flow_imp.g_varchar2_table(38) := '20206173796E632072657175657374286F702C206578747261203D207B7D29207B0A202020202020202020202020636F6E737420726573706F6E7365203D20617761697420746869732E616461707465722E72657175657374286F702C207B0A20202020';
wwv_flow_imp.g_varchar2_table(39) := '202020202020202020202020746F6B656E3A20746869732E746F6B656E2C206B65793A20746869732E636F6E746578742E6B65792C202E2E2E65787472610A2020202020202020202020207D293B0A202020202020202020202020696620282172657370';
wwv_flow_imp.g_varchar2_table(40) := '6F6E7365207C7C20726573706F6E73652E6F6B203D3D3D2066616C736529207468726F77206E6577204572726F7228726573706F6E73653F2E726561736F6E207C7C20726573706F6E73653F2E6572726F72207C7C20224174746163686D656E74207265';
wwv_flow_imp.g_varchar2_table(41) := '7175657374206661696C65642E22293B0A20202020202020202020202072657475726E20726573706F6E73653B0A20202020202020207D0A20202020202020206173796E63206F70656E28636F6E7465787429207B0A2020202020202020202020206966';
wwv_flow_imp.g_varchar2_table(42) := '2028746869732E6275737929207468726F77206E6577204572726F722822416E206174746163686D656E74206F7065726174696F6E206973207374696C6C2072756E6E696E672E22293B0A202020202020202020202020746869732E7265616479203D20';
wwv_flow_imp.g_varchar2_table(43) := '66616C73653B20746869732E66696C6573203D205B5D3B20746869732E647261667473203D206E6577204D617028293B0A2020202020202020202020202F2F20636F6E746578742E746F6B656E3A2074686520746F6B656E2074686520726F7720686F6C';
wwv_flow_imp.g_varchar2_table(44) := '64733B20636F6E746578742E72657573653A20746869732070616E656C2773206F776E20656D7074792065646974206F66207468650A2020202020202020202020202F2F20726F772066726F6D20616E206561726C696572206F70656E696E6720287468';
wwv_flow_imp.g_varchar2_table(45) := '6520726F7720646F6573206E6F7420686F6C64206974292C2073656E7420736F2074686520736572766572207265757365732069740A202020202020202020202020746869732E636F6E74657874203D204F626A6563742E667265657A65287B202E2E2E';
wwv_flow_imp.g_varchar2_table(46) := '636F6E74657874207D293B0A202020202020202020202020746869732E746F6B656E203D206973546F6B656E28636F6E746578742E746F6B656E29203F20636F6E746578742E746F6B656E203A206973546F6B656E28636F6E746578742E726575736529';
wwv_flow_imp.g_varchar2_table(47) := '203F20636F6E746578742E7265757365203A2022223B0A202020202020202020202020746869732E636C61696D6564203D2066616C73653B0A202020202020202020202020617761697420746869732E72756E286173796E63202829203D3E207B0A2020';
wwv_flow_imp.g_varchar2_table(48) := '2020202020202020202020202020636F6E737420726573706F6E7365203D20617761697420746869732E7265717565737428746869732E636F6E746578742E726561644F6E6C79203F20224C49535422203A20224F50454E22293B0A2020202020202020';
wwv_flow_imp.g_varchar2_table(49) := '202020202020202069662028726573706F6E73652E726561644F6E6C7929207B0A20202020202020202020202020202020202020202F2F2072656164206F6E6C793A206E6F2065646974202D20616E206F6C6420746F6B656E206F662074686520726F77';
wwv_flow_imp.g_varchar2_table(50) := '206D757374206E6F7420676F20776974682074686520646F776E6C6F6164730A2020202020202020202020202020202020202020746869732E636F6E74657874203D204F626A6563742E667265657A65287B202E2E2E746869732E636F6E746578742C20';
wwv_flow_imp.g_varchar2_table(51) := '726561644F6E6C793A2074727565207D293B0A2020202020202020202020202020202020202020746869732E746F6B656E203D2022223B0A202020202020202020202020202020207D0A2020202020202020202020202020202069662028726573706F6E';
wwv_flow_imp.g_varchar2_table(52) := '73652E746F6B656E29207B0A20202020202020202020202020202020202020202F2F2074686520726F7720616C726561647920686F6C6473207468697320746F6B656E3A206E6F7468696E6720746F20636C61696D0A2020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(53) := '202020202020746869732E636C61696D6564203D20726573706F6E73652E746F6B656E203D3D3D20636F6E746578742E746F6B656E3B0A2020202020202020202020202020202020202020746869732E746F6B656E203D20726573706F6E73652E746F6B';
wwv_flow_imp.g_varchar2_table(54) := '656E3B0A202020202020202020202020202020207D0A202020202020202020202020202020202F2F2076616C756573206F66206E65772066696C65732066726F6D20746865204772696420436F6C756D6E202F2050616765204974656D206F6620656163';
wwv_flow_imp.g_varchar2_table(55) := '68206669656C640A20202020202020202020202020202020746869732E64656661756C7473203D205B302C20312C20325D2E6D61702869203D3E2028636F6E746578742E64656661756C7473207C7C205B5D295B695D203F3F202222293B0A2020202020';
wwv_flow_imp.g_varchar2_table(56) := '2020202020202020202020746869732E66696C6573203D20726573706F6E73652E66696C6573207C7C205B5D3B0A20202020202020202020202020202020746869732E7265616479203D20747275653B0A2020202020202020202020207D293B0A202020';
wwv_flow_imp.g_varchar2_table(57) := '20202020207D0A20202020202020206173796E632072756E28666E29207B0A20202020202020202020202069662028746869732E6275737929207468726F77206E6577204572726F722822506C65617365207761697420666F7220746865206375727265';
wwv_flow_imp.g_varchar2_table(58) := '6E74206174746163686D656E74206F7065726174696F6E2E22293B0A202020202020202020202020746869732E62757379203D20747275653B20746869732E6F6E6368616E676528293B0A202020202020202020202020636F6E737420776F726B203D20';
wwv_flow_imp.g_varchar2_table(59) := '286173796E63202829203D3E207B0A20202020202020202020202020202020747279207B2072657475726E20617761697420666E28293B207D0A2020202020202020202020202020202066696E616C6C79207B20746869732E62757379203D2066616C73';
wwv_flow_imp.g_varchar2_table(60) := '653B20746869732E70726F6772657373203D206E756C6C3B20746869732E72756E6E696E67203D206E756C6C3B20746869732E6F6E6368616E676528293B207D0A2020202020202020202020207D2928293B0A202020202020202020202020746869732E';
wwv_flow_imp.g_varchar2_table(61) := '72756E6E696E67203D20776F726B3B0A20202020202020202020202072657475726E20776F726B3B0A20202020202020207D0A20202020202020202F2F207265736F6C766573207768656E206E6F20726571756573742069732072756E6E696E6720616E';
wwv_flow_imp.g_varchar2_table(62) := '64206E6F206669656C64206368616E67652069732077616974696E6720287468656972206572726F7273206172650A20202020202020202F2F207265706F727465642062792074686569722063616C6C657273290A20202020202020206173796E632069';
wwv_flow_imp.g_varchar2_table(63) := '646C652829207B0A202020202020202020202020666F7220283B3B29207B0A20202020202020202020202020202020636F6E7374207175657565203D20746869732E6669656C6451756575653B0A20202020202020202020202020202020617761697420';
wwv_flow_imp.g_varchar2_table(64) := '71756575653B0A202020202020202020202020202020207768696C652028746869732E72756E6E696E6729207B20747279207B20617761697420746869732E72756E6E696E673B207D20636174636820285F29207B202F2A207265706F7274656420656C';
wwv_flow_imp.g_varchar2_table(65) := '73657768657265202A2F207D207D0A20202020202020202020202020202020696620287175657565203D3D3D20746869732E6669656C6451756575652026262021746869732E72756E6E696E67292072657475726E3B0A2020202020202020202020207D';
wwv_flow_imp.g_varchar2_table(66) := '0A20202020202020207D0A20202020202020206173796E6320726566726573682829207B0A202020202020202020202020746869732E66696C6573203D2028617761697420746869732E7265717565737428224C4953542229292E66696C6573207C7C20';
wwv_flow_imp.g_varchar2_table(67) := '5B5D3B0A202020202020202020202020746869732E6F6E6368616E676528293B0A20202020202020207D0A20202020202020206173796E632075706C6F61642866696C657329207B0A2020202020202020202020206966202821746869732E7265616479';
wwv_flow_imp.g_varchar2_table(68) := '29207468726F77206E6577204572726F72282252656F70656E206174746163686D656E7473206265666F7265206D616B696E67206368616E6765732E22293B0A20202020202020202020202069662028746869732E636F6E746578742E726561644F6E6C';
wwv_flow_imp.g_varchar2_table(69) := '7929207468726F77206E6577204572726F7228225468697320726F772069732072656164206F6E6C792E22293B0A20202020202020202020202072657475726E20746869732E72756E286173796E63202829203D3E207B0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(70) := '20202020636F6E73742070726F626C656D73203D205B5D3B0A202020202020202020202020202020206C657420696E746572727570746564203D2066616C73653B0A20202020202020202020202020202020746869732E63616E63656C6C6564203D2066';
wwv_flow_imp.g_varchar2_table(71) := '616C73653B0A20202020202020202020202020202020666F722028636F6E73742066696C65206F662066696C657329207B0A20202020202020202020202020202020202020202F2F2043616E63656C3A206E6F20667572746865722066696C653B206120';
wwv_flow_imp.g_varchar2_table(72) := '6C61726765206F6E652073746F7073206265747765656E2069747320706172747320287365652062656C6F77290A202020202020202020202020202020202020202069662028746869732E63616E63656C6C65642920627265616B3B0A20202020202020';
wwv_flow_imp.g_varchar2_table(73) := '202020202020202020202020206C65742073656E74203D2066616C73653B2020202F2F206120726571756573742077656E74206F75743A2074686520736572766572206D617920686176652073746F726564207468652066696C650A2020202020202020';
wwv_flow_imp.g_varchar2_table(74) := '202020202020202020202020747279207B0A20202020202020202020202020202020202020202020202076616C696461746546696C652866696C652C20746869732E636667293B0A20202020202020202020202020202020202020202020202069662028';
wwv_flow_imp.g_varchar2_table(75) := '746869732E66696C65732E66696C7465722866203D3E2021662E72656D6F766564292E6C656E677468203E3D20746869732E6366672E6D6178436F756E74290A202020202020202020202020202020202020202020202020202020207468726F77206E65';
wwv_flow_imp.g_varchar2_table(76) := '77204572726F7228224D6178696D756D2022202B20746869732E6366672E6D6178436F756E74202B2028746869732E6366672E6D6178436F756E74203D3D3D2031203F20222066696C6522203A20222066696C65732229202B20222070657220726F772E';
wwv_flow_imp.g_varchar2_table(77) := '22293B0A202020202020202020202020202020202020202020202020746869732E70726F6772657373203D207B206E616D653A2066696C652E6E616D652C2072656365697665643A20302C2073697A653A2066696C652E73697A65207D3B0A2020202020';
wwv_flow_imp.g_varchar2_table(78) := '20202020202020202020202020202020202020746869732E6F6E6368616E676528293B0A2020202020202020202020202020202020202020202020206966202866696C652E73697A65203C3D204348554E4B29207B0A2020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(79) := '20202020202020202020202020202F2F206F6E6520726F756E6420747269703A2073746172742C20627974657320616E642066696E69736820746F6765746865723B20746865207265706C7920697320746865206E6577206C6973742E0A202020202020';
wwv_flow_imp.g_varchar2_table(80) := '202020202020202020202020202020202020202020202F2F204E6F7420726574726965643A2061206C6F7374207265706C79206166746572207375636365737320776F756C6420616464207468652066696C652074776963652E0A202020202020202020';
wwv_flow_imp.g_varchar2_table(81) := '20202020202020202020202020202020202020636F6E7374206368756E6B73203D20746F4261736536342861776169742066696C652E61727261794275666665722829292E6D61746368282F2E7B312C383030307D2F67293B0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(82) := '20202020202020202020202020202020202073656E74203D20747275653B0A20202020202020202020202020202020202020202020202020202020746869732E66696C6573203D2028617761697420746869732E726571756573742822505554222C207B';
wwv_flow_imp.g_varchar2_table(83) := '206E616D653A2066696C652E6E616D652C2073697A653A2066696C652E73697A652C206368756E6B732C2076616C7565733A20746869732E64656661756C7473207D29292E66696C6573207C7C205B5D3B0A202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(84) := '2020202020207D20656C7365207B0A2020202020202020202020202020202020202020202020202020202073656E74203D20747275653B0A20202020202020202020202020202020202020202020202020202020636F6E73742073746172746564203D20';
wwv_flow_imp.g_varchar2_table(85) := '617761697420746869732E7265717565737428225354415254222C207B206E616D653A2066696C652E6E616D652C2073697A653A2066696C652E73697A652C2076616C7565733A20746869732E64656661756C7473207D293B0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(86) := '2020202020202020202020202020202020206C6574206F6666736574203D20303B0A202020202020202020202020202020202020202020202020202020207768696C6520286F6666736574203C2066696C652E73697A6529207B0A202020202020202020';
wwv_flow_imp.g_varchar2_table(87) := '202020202020202020202020202020202020202020202069662028746869732E63616E63656C6C656429207B0A2020202020202020202020202020202020202020202020202020202020202020202020202F2F2074686520706172747320616C72656164';
wwv_flow_imp.g_varchar2_table(88) := '792073746F726564206172652072656D6F7665642028746865206C6973742062656C6F77206E6F206C6F6E6765722073686F7773207468652066696C65290A20202020202020202020202020202020202020202020202020202020202020202020202074';
wwv_flow_imp.g_varchar2_table(89) := '7279207B20617761697420746869732E72657175657374282252454D4F5645222C207B2069643A20737461727465642E75706C6F61644964207D293B207D20636174636820285F29207B202F2A20746865206C6973742073686F7773206974202A2F207D';
wwv_flow_imp.g_varchar2_table(90) := '0A2020202020202020202020202020202020202020202020202020202020202020202020207468726F77206E6577204572726F722866696C652E6E616D65202B20223A2075706C6F61642063616E63656C6C65642E22293B0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(91) := '2020202020202020202020202020202020202020207D0A2020202020202020202020202020202020202020202020202020202020202020636F6E737420627566666572203D2061776169742066696C652E736C696365286F66667365742C206F66667365';
wwv_flow_imp.g_varchar2_table(92) := '74202B204348554E4B292E617272617942756666657228293B0A20202020202020202020202020202020202020202020202020202020202020202F2F203830303020697320646976697369626C6520627920343A20656163682066303120656C656D656E';
wwv_flow_imp.g_varchar2_table(93) := '74206465636F64657320696E646570656E64656E746C792E0A2020202020202020202020202020202020202020202020202020202020202020636F6E7374206368756E6B73203D20746F42617365363428627566666572292E6D61746368282F2E7B312C';
wwv_flow_imp.g_varchar2_table(94) := '383030307D2F67293B0A20202020202020202020202020202020202020202020202020202020202020206C657420726573706F6E73653B0A2020202020202020202020202020202020202020202020202020202020202020666F7220286C657420617474';
wwv_flow_imp.g_varchar2_table(95) := '656D7074203D20303B20617474656D7074203C20323B20617474656D70742B2B29207B0A202020202020202020202020202020202020202020202020202020202020202020202020747279207B0A20202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(96) := '202020202020202020202020202020202020726573706F6E7365203D20617761697420746869732E7265717565737428224348554E4B222C207B2069643A20737461727465642E75706C6F616449642C206F66667365742C206368756E6B73207D293B0A';
wwv_flow_imp.g_varchar2_table(97) := '20202020202020202020202020202020202020202020202020202020202020202020202020202020627265616B3B0A2020202020202020202020202020202020202020202020202020202020202020202020207D20636174636820286572726F7229207B';
wwv_flow_imp.g_varchar2_table(98) := '2069662028617474656D7074203D3D3D203129207468726F77206572726F723B207D0A20202020202020202020202020202020202020202020202020202020202020207D0A20202020202020202020202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(99) := '2069662028214E756D6265722E6973496E746567657228726573706F6E73652E726563656976656429207C7C20726573706F6E73652E7265636569766564203C206F6666736574202B206275666665722E627974654C656E677468207C7C0A2020202020';
wwv_flow_imp.g_varchar2_table(100) := '20202020202020202020202020202020202020202020202020202020202020726573706F6E73652E7265636569766564203E2066696C652E73697A6529207468726F77206E6577204572726F7228225365727665722072657475726E656420616E20696E';
wwv_flow_imp.g_varchar2_table(101) := '76616C69642075706C6F6164206F66667365742E22293B0A20202020202020202020202020202020202020202020202020202020202020206F6666736574203D20726573706F6E73652E72656365697665643B0A20202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(102) := '20202020202020202020202020202020746869732E70726F6772657373203D207B206E616D653A2066696C652E6E616D652C2072656365697665643A206F66667365742C2073697A653A2066696C652E73697A65207D3B0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(103) := '2020202020202020202020202020202020202020746869732E6F6E6368616E676528293B0A202020202020202020202020202020202020202020202020202020207D0A20202020202020202020202020202020202020202020202020202020636F6E7374';
wwv_flow_imp.g_varchar2_table(104) := '2066696E6973686564203D20617761697420746869732E72657175657374282246494E495348222C207B2069643A20737461727465642E75706C6F61644964207D293B0A2020202020202020202020202020202020202020202020202020202074686973';
wwv_flow_imp.g_varchar2_table(105) := '2E66696C6573203D2066696E69736865642E66696C6573207C7C2028617761697420746869732E7265717565737428224C4953542229292E66696C6573207C7C205B5D3B0A2020202020202020202020202020202020202020202020207D0A2020202020';
wwv_flow_imp.g_varchar2_table(106) := '2020202020202020202020202020207D20636174636820286572726F7229207B0A2020202020202020202020202020202020202020202020202F2F206F6E652066696C6520726566757365642028747970652C2073697A652C20636F6E74656E74202E2E';
wwv_flow_imp.g_varchar2_table(107) := '2E293A20746865206F746865727320617265207374696C6C2073656E740A20202020202020202020202020202020202020202020202070726F626C656D732E70757368286572726F722E6D657373616765207C7C20537472696E67286572726F7229293B';
wwv_flow_imp.g_varchar2_table(108) := '0A2020202020202020202020202020202020202020202020202F2F2061206C6F7374207265706C7920616674657220746865207365727665722073746F726564207468652066696C653A20746865206C6973742062656C6F772073686F77732069740A20';
wwv_flow_imp.g_varchar2_table(109) := '20202020202020202020202020202020202020202020206966202873656E742920696E746572727570746564203D20747275653B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D0A20202020202020';
wwv_flow_imp.g_varchar2_table(110) := '2020202020202020202F2F20416E20696E7465727275707465642075706C6F61642072656D61696E732076697369626C6520616E642072656D6F7661626C652028616E20696E636F6D706C657465206F6E6520626C6F636B730A20202020202020202020';
wwv_flow_imp.g_varchar2_table(111) := '2020202020202F2F2066696E616C697A6174696F6E293B20612072656675736564206F6E65206973206E6F7420696E20746865206C6973742E0A2020202020202020202020202020202069662028696E74657272757074656429207B20747279207B2074';
wwv_flow_imp.g_varchar2_table(112) := '6869732E66696C6573203D2028617761697420746869732E7265717565737428224C4953542229292E66696C6573207C7C205B5D3B207D20636174636820285F29207B202F2A206B656570206C697374202A2F207D207D0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(113) := '2020202069662028746869732E63616E63656C6C6564202626202170726F626C656D732E736F6D652870203D3E202F63616E63656C6C65642F2E7465737428702929292070726F626C656D732E70757368282255706C6F61642063616E63656C6C65642E';
wwv_flow_imp.g_varchar2_table(114) := '22293B0A20202020202020202020202020202020746869732E63616E63656C6C6564203D2066616C73653B0A202020202020202020202020202020206966202870726F626C656D732E6C656E67746829207468726F77206E6577204572726F722870726F';
wwv_flow_imp.g_varchar2_table(115) := '626C656D732E6A6F696E2822202229293B0A2020202020202020202020207D293B0A20202020202020207D0A20202020202020202F2F2073746F707320612072756E6E696E672075706C6F61643A206E6F20667572746865722066696C652C20616E6420';
wwv_flow_imp.g_varchar2_table(116) := '61206C617267652066696C65206265747765656E2074776F206F6620697473207061727473202869747320706172740A20202020202020202F2F20616C72656164792073746F7265642069732072656D6F766564293B206120736D616C6C2066696C6520';
wwv_flow_imp.g_varchar2_table(117) := '6973206F6E65207265717565737420616E642066696E69736865730A202020202020202063616E63656C2829207B2069662028746869732E627573792920746869732E63616E63656C6C6564203D20747275653B207D0A20202020202020206173796E63';
wwv_flow_imp.g_varchar2_table(118) := '2072656D6F76652866696C6529207B0A2020202020202020202020206966202821746869732E726561647929207468726F77206E6577204572726F72282252656F70656E206174746163686D656E7473206265666F7265206D616B696E67206368616E67';
wwv_flow_imp.g_varchar2_table(119) := '65732E22293B0A20202020202020202020202069662028746869732E636F6E746578742E726561644F6E6C7929207468726F77206E6577204572726F7228225468697320726F772069732072656164206F6E6C792E22293B0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(120) := '2072657475726E20746869732E72756E286173796E63202829203D3E207B0A20202020202020202020202020202020636F6E737420726573706F6E7365203D20617761697420746869732E72657175657374282252454D4F5645222C207B2069643A2066';
wwv_flow_imp.g_varchar2_table(121) := '696C652E69642C20726573746F72653A2066696C652E72656D6F766564207D293B0A20202020202020202020202020202020746869732E66696C6573203D20726573706F6E73652E66696C6573207C7C2028617761697420746869732E72657175657374';
wwv_flow_imp.g_varchar2_table(122) := '28224C4953542229292E66696C6573207C7C205B5D3B0A2020202020202020202020207D293B0A20202020202020207D0A20202020202020202F2F20746865204578747261204669656C6473206F6620612066696C6520286E6577206F72207361766564';
wwv_flow_imp.g_varchar2_table(123) := '293B2073617665642066696C6573206B65657020746865206368616E676520756E74696C2074686520677269642069732073617665640A20202020202020206173796E63207365744669656C64732866696C652C2076616C75657329207B0A2020202020';
wwv_flow_imp.g_varchar2_table(124) := '202020202020206966202821746869732E726561647929207468726F77206E6577204572726F72282252656F70656E206174746163686D656E7473206265666F7265206D616B696E67206368616E6765732E22293B0A2020202020202020202020206966';
wwv_flow_imp.g_varchar2_table(125) := '2028746869732E636F6E746578742E726561644F6E6C7929207468726F77206E6577204572726F7228225468697320726F772069732072656164206F6E6C792E22293B0A20202020202020202020202072657475726E20746869732E72756E286173796E';
wwv_flow_imp.g_varchar2_table(126) := '63202829203D3E207B0A20202020202020202020202020202020636F6E737420726573706F6E7365203D20617761697420746869732E7265717565737428224649454C4453222C207B2069643A2066696C652E69642C2076616C756573207D293B0A2020';
wwv_flow_imp.g_varchar2_table(127) := '2020202020202020202020202020746869732E66696C6573203D20726573706F6E73652E66696C6573207C7C2028617761697420746869732E7265717565737428224C4953542229292E66696C6573207C7C205B5D3B0A2020202020202020202020207D';
wwv_flow_imp.g_varchar2_table(128) := '293B0A20202020202020207D0A20202020202020202F2F207468652076616C756520616E204578747261204669656C642073686F77733A207468652075736572277320756E636F6E6669726D65642064726166742C20656C736520746865207365727665';
wwv_flow_imp.g_varchar2_table(129) := '7227732076616C75650A20202020202020206669656C6456616C75652866696C652C20696E64657829207B0A202020202020202020202020636F6E7374206964203D20537472696E672866696C652E6964293B0A202020202020202020202020636F6E73';
wwv_flow_imp.g_varchar2_table(130) := '74206472616674203D20746869732E6472616674732E676574286964293B0A20202020202020202020202069662028647261667420262620696E64657820696E206472616674292072657475726E2064726166745B696E6465785D3B0A20202020202020';
wwv_flow_imp.g_varchar2_table(131) := '2020202020636F6E73742063757272656E74203D20746869732E66696C65732E66696E642866203D3E20537472696E6728662E696429203D3D3D20696429207C7C2066696C653B0A20202020202020202020202072657475726E202863757272656E742E';
wwv_flow_imp.g_varchar2_table(132) := '76616C756573207C7C205B5D295B696E6465785D203F3F2022223B0A20202020202020207D0A20202020202020202F2F204F6E65204578747261204669656C64206F6620612066696C65206368616E6765642E205468652076616C7565206973206B6570';
wwv_flow_imp.g_varchar2_table(133) := '742061732061206472616674206174206F6E63653B2074686520726571756573742077616974730A20202020202020202F2F20666F722072756E6E696E6720776F726B2028616E2075706C6F61642C20616E6F74686572206669656C642920616E642074';
wwv_flow_imp.g_varchar2_table(134) := '68656E2073656E6473207468652066696C652773206E65776573742076616C7565732C20736F0A20202020202020202F2F20717569636B206368616E676573206F66207365766572616C206669656C6473206E65766572206F7665727772697465206561';
wwv_flow_imp.g_varchar2_table(135) := '6368206F746865722E0A20202020202020207365744669656C642866696C652C20696E6465782C2076616C756529207B0A2020202020202020202020206966202821746869732E7265616479292072657475726E2050726F6D6973652E72656A65637428';
wwv_flow_imp.g_varchar2_table(136) := '6E6577204572726F72282252656F70656E206174746163686D656E7473206265666F7265206D616B696E67206368616E6765732E2229293B0A20202020202020202020202069662028746869732E636F6E746578742E726561644F6E6C79292072657475';
wwv_flow_imp.g_varchar2_table(137) := '726E2050726F6D6973652E72656A656374286E6577204572726F7228225468697320726F772069732072656164206F6E6C792E2229293B0A202020202020202020202020636F6E7374206964203D20537472696E672866696C652E6964293B0A20202020';
wwv_flow_imp.g_varchar2_table(138) := '2020202020202020636F6E7374206472616674203D20746869732E6472616674732E67657428696429207C7C207B7D3B0A20202020202020202020202064726166745B696E6465785D203D2076616C75653B0A202020202020202020202020746869732E';
wwv_flow_imp.g_varchar2_table(139) := '6472616674732E7365742869642C206472616674293B0A20202020202020202020202072657475726E20746869732E71756575654669656C6473286964293B0A20202020202020207D0A202020202020202071756575654669656C647328696429207B0A';
wwv_flow_imp.g_varchar2_table(140) := '202020202020202020202020636F6E7374206A6F62203D20746869732E6669656C6451756575652E7468656E282829203D3E20746869732E73656E644669656C647328696429293B0A202020202020202020202020746869732E6669656C645175657565';
wwv_flow_imp.g_varchar2_table(141) := '203D206A6F622E6361746368282829203D3E207B202F2A207265706F72746564206279207468652063616C6C6572202A2F207D293B0A20202020202020202020202072657475726E206A6F623B0A20202020202020207D0A20202020202020206173796E';
wwv_flow_imp.g_varchar2_table(142) := '632073656E644669656C647328696429207B0A2020202020202020202020202F2F207265736F6C7665732074727565207768656E20612072657175657374207761732073656E7420616E642061636365707465640A202020202020202020202020696620';
wwv_flow_imp.g_varchar2_table(143) := '2821746869732E6472616674732E68617328696429292072657475726E2066616C73653B2020202F2F2073656E7420746F676574686572207769746820616E206561726C696572206368616E67650A2020202020202020202020207768696C6520287468';
wwv_flow_imp.g_varchar2_table(144) := '69732E6275737929207B0A20202020202020202020202020202020747279207B2061776169742028746869732E72756E6E696E67207C7C206E65772050726F6D6973652872203D3E2073657454696D656F757428722C2035302929293B207D2063617463';
wwv_flow_imp.g_varchar2_table(145) := '6820285F29207B202F2A206974732063616C6C6572207265706F727473206974202A2F207D0A2020202020202020202020207D0A202020202020202020202020636F6E73742066696C65203D20746869732E66696C65732E66696E642866203D3E205374';
wwv_flow_imp.g_varchar2_table(146) := '72696E6728662E696429203D3D3D206964293B0A202020202020202020202020636F6E7374206472616674203D20746869732E6472616674732E676574286964293B0A202020202020202020202020696620282166696C65207C7C2066696C652E72656D';
wwv_flow_imp.g_varchar2_table(147) := '6F766564207C7C2021647261667429207B20746869732E6472616674732E64656C657465286964293B2072657475726E2066616C73653B207D0A202020202020202020202020636F6E73742076616C756573203D205B302C20312C20325D2E6D61702869';
wwv_flow_imp.g_varchar2_table(148) := '203D3E206920696E206472616674203F2064726166745B695D203A202866696C652E76616C756573207C7C205B5D295B695D203F3F202222293B0A2020202020202020202020202F2F20746865206F6C642076616C756520707574206261636B2028652E';
wwv_flow_imp.g_varchar2_table(149) := '672E2061667465722061207265667573616C293A20746865207365727665722068617320697420616C72656164792C206E6F7468696E6720746F2073656E640A2020202020202020202020206966202876616C7565732E65766572792828762C20692920';
wwv_flow_imp.g_varchar2_table(150) := '3D3E2076203D3D3D20282866696C652E76616C756573207C7C205B5D295B695D203F3F202222292929207B20746869732E6472616674732E64656C657465286964293B2072657475726E2066616C73653B207D0A20202020202020202020202061776169';
wwv_flow_imp.g_varchar2_table(151) := '7420746869732E72756E286173796E63202829203D3E207B0A20202020202020202020202020202020636F6E737420726573706F6E7365203D20617761697420746869732E7265717565737428224649454C4453222C207B2069643A2066696C652E6964';
wwv_flow_imp.g_varchar2_table(152) := '2C2076616C756573207D293B0A20202020202020202020202020202020746869732E66696C6573203D20726573706F6E73652E66696C6573207C7C2028617761697420746869732E7265717565737428224C4953542229292E66696C6573207C7C205B5D';
wwv_flow_imp.g_varchar2_table(153) := '3B0A2020202020202020202020207D293B0A2020202020202020202020202F2F20636F6E6669726D65643A2064726F702077686174207761732073656E743B20612076616C7565207479706564206D65616E7768696C6520737461797320612064726166';
wwv_flow_imp.g_varchar2_table(154) := '742028697473206F776E207265717565737420666F6C6C6F7773290A202020202020202020202020636F6E73742063757272656E74203D20746869732E6472616674732E676574286964293B0A2020202020202020202020206966202863757272656E74';
wwv_flow_imp.g_varchar2_table(155) := '29207B0A20202020202020202020202020202020666F722028636F6E73742069206F66204F626A6563742E6B6579732863757272656E742929206966202863757272656E745B695D203D3D3D2076616C7565735B695D292064656C657465206375727265';
wwv_flow_imp.g_varchar2_table(156) := '6E745B695D3B0A2020202020202020202020202020202069662028214F626A6563742E6B6579732863757272656E74292E6C656E6774682920746869732E6472616674732E64656C657465286964293B0A2020202020202020202020207D0A2020202020';
wwv_flow_imp.g_varchar2_table(157) := '2020202020202072657475726E20747275653B0A20202020202020207D0A20202020202020202F2F20647261667473206F662066696C6573207468617420617265207374696C6C2074686572652028612072656D6F7665642066696C6527732064726166';
wwv_flow_imp.g_varchar2_table(158) := '74206E6F206C6F6E676572206D617474657273290A20202020202020206861734472616674732829207B0A20202020202020202020202072657475726E205B2E2E2E746869732E6472616674732E6B65797328295D2E736F6D65286964203D3E20746869';
wwv_flow_imp.g_varchar2_table(159) := '732E66696C65732E736F6D652866203D3E20537472696E6728662E696429203D3D3D2069642026262021662E72656D6F76656429293B0A20202020202020207D0A20202020202020202F2F2073656E647320657665727920647261667420616761696E20';
wwv_flow_imp.g_varchar2_table(160) := '28636C6F73696E67207468652070616E656C20616674657220612072656675736564206F72206C6F7374206669656C64206368616E6765290A20202020202020206173796E6320666C7573684669656C64732829207B0A20202020202020202020202066';
wwv_flow_imp.g_varchar2_table(161) := '6F722028636F6E7374206964206F66205B2E2E2E746869732E6472616674732E6B65797328295D2920617761697420746869732E71756575654669656C6473286964293B0A20202020202020207D0A20202020202020202F2F2072657175697265642066';
wwv_flow_imp.g_varchar2_table(162) := '69656C6473207374696C6C20656D707479206F6E2066696C6573207468617420617265206E6577206F72206368616E67656420696E207468697320656469740A20202020202020206D697373696E672829207B0A202020202020202020202020636F6E73';
wwv_flow_imp.g_varchar2_table(163) := '74206F7574203D205B5D3B0A202020202020202020202020666F722028636F6E7374206669656C64206F6620746869732E6366672E6669656C6473207C7C205B5D29207B0A2020202020202020202020202020202069662028216669656C642E72657175';
wwv_flow_imp.g_varchar2_table(164) := '69726564207C7C206669656C642E6B696E64203D3D3D202248494444454E222920636F6E74696E75653B0A20202020202020202020202020202020666F722028636F6E73742066696C65206F6620746869732E66696C657329207B0A2020202020202020';
wwv_flow_imp.g_varchar2_table(165) := '202020202020202020202020636F6E737420746F7563686564203D2066696C652E737461676564203F2066696C652E7265616479202626202166696C652E72656D6F766564203A2066696C652E6368616E676564202626202166696C652E72656D6F7665';
wwv_flow_imp.g_varchar2_table(166) := '643B0A20202020202020202020202020202020202020202F2F20612076616C7565206F66206F6E6C792073706163657320697320656D70747920287468652073657276657220636865636B73206974207468652073616D6520776179290A202020202020';
wwv_flow_imp.g_varchar2_table(167) := '202020202020202020202020202069662028746F75636865642026262021537472696E67282866696C652E76616C756573207C7C205B5D295B6669656C642E6E202D20315D203F3F202222292E7472696D282929206F75742E70757368286669656C642E';
wwv_flow_imp.g_varchar2_table(168) := '6C6162656C202B202220666F722022202B2066696C652E6E616D65293B0A202020202020202020202020202020207D0A2020202020202020202020207D0A20202020202020202020202072657475726E206F75743B0A20202020202020207D0A20202020';
wwv_flow_imp.g_varchar2_table(169) := '2020202063616E536176652829207B2072657475726E20746869732E72656164792026262021746869732E6275737920262620746869732E66696C65732E65766572792866203D3E20662E7265616479207C7C20662E72656D6F766564293B207D0A2020';
wwv_flow_imp.g_varchar2_table(170) := '20207D0A0A20202020636F6E737420444F54203D2022205C753030623720223B0A20202020636F6E737420636F756E74203D206E203D3E206E202B20286E203D3D3D2031203F2022206174746163686D656E7422203A2022206174746163686D656E7473';
wwv_flow_imp.g_varchar2_table(171) := '22293B0A202020202F2F20466F6E742041504558202F20466F6E7420417765736F6D652069636F6E202841504558207061676573206C6F6164206974290A2020202066756E6374696F6E2069636F6E286E616D6529207B0A2020202020202020636F6E73';
wwv_flow_imp.g_varchar2_table(172) := '74206E6F6465203D20656C28227370616E222C202266612022202B206E616D65293B0A20202020202020206E6F64652E7365744174747269627574652822617269612D68696464656E222C20227472756522293B0A202020202020202072657475726E20';
wwv_flow_imp.g_varchar2_table(173) := '6E6F64653B0A202020207D0A2020202066756E6374696F6E2069636F6E466F722866696C6529207B0A2020202020202020636F6E737420657874203D2066696C652E6E616D652E696E636C7564657328222E2229203F2066696C652E6E616D652E73706C';
wwv_flow_imp.g_varchar2_table(174) := '697428222E22292E706F7028292E746F4C6F776572436173652829203A2022223B0A202020202020202072657475726E2066696C652E6D696D652E737461727473576974682822696D6167652F2229207C7C205B22706E67222C20226A7067222C20226A';
wwv_flow_imp.g_varchar2_table(175) := '706567222C2022676966222C202277656270225D2E696E636C756465732865787429203F202266612D66696C652D696D6167652D6F220A2020202020202020202020203A20657874203D3D3D202270646622203F202266612D66696C652D7064662D6F22';
wwv_flow_imp.g_varchar2_table(176) := '203A205B22747874222C2022637376222C20226C6F67225D2E696E636C756465732865787429203F202266612D66696C652D746578742D6F220A2020202020202020202020203A205B22646F63222C2022646F6378225D2E696E636C7564657328657874';
wwv_flow_imp.g_varchar2_table(177) := '29203F202266612D66696C652D776F72642D6F22203A205B22786C73222C2022786C7378225D2E696E636C756465732865787429203F202266612D66696C652D657863656C2D6F22203A202266612D66696C652D6F223B0A202020207D0A202020206675';
wwv_flow_imp.g_varchar2_table(178) := '6E6374696F6E20656C287461672C20636C732C207465787429207B0A2020202020202020636F6E7374206E6F6465203D20646F63756D656E742E637265617465456C656D656E7428746167293B0A202020202020202069662028636C7329206E6F64652E';
wwv_flow_imp.g_varchar2_table(179) := '636C6173734E616D65203D20636C733B0A2020202020202020696620287465787420213D3D20756E646566696E656429206E6F64652E74657874436F6E74656E74203D20746578743B0A202020202020202072657475726E206E6F64653B0A202020207D';
wwv_flow_imp.g_varchar2_table(180) := '0A202020202F2F20612066696C6520616374696F6E3A20616E2069636F6E2C20697473206C6162656C2061732074686520746F6F6C74697020616E64202868696464656E2920666F722073637265656E20726561646572730A2020202066756E6374696F';
wwv_flow_imp.g_varchar2_table(181) := '6E2069636F6E427574746F6E286C6162656C2C2069636F6E4E616D652C20636C732C206F6E636C69636B29207B0A2020202020202020636F6E737420627574746F6E203D20656C2822627574746F6E222C20226967612D69636F6E2D627574746F6E2220';
wwv_flow_imp.g_varchar2_table(182) := '2B2028636C73203F20222022202B20636C73203A20222229293B0A2020202020202020627574746F6E2E74797065203D2022627574746F6E223B20627574746F6E2E7469746C65203D206C6162656C3B0A2020202020202020627574746F6E2E61707065';
wwv_flow_imp.g_varchar2_table(183) := '6E642869636F6E2869636F6E4E616D65292C20656C28227370616E222C20226967612D7668222C206C6162656C29293B0A2020202020202020627574746F6E2E6F6E636C69636B203D206F6E636C69636B3B0A202020202020202072657475726E206275';
wwv_flow_imp.g_varchar2_table(184) := '74746F6E3B0A202020207D0A2020202066756E6374696F6E2063726561746550616E656C286366672C2073657373696F6E2C206F7074696F6E73203D207B7D29207B0A2020202020202020636F6E7374206469616C6F67203D20656C28226469616C6F67';
wwv_flow_imp.g_varchar2_table(185) := '222C20226967612D70616E656C22293B0A20202020202020206469616C6F672E6964203D206366672E6974656D202B20225F50414E454C223B0A20202020202020206469616C6F672E746162496E646578203D202D313B0A2020202020202020636F6E73';
wwv_flow_imp.g_varchar2_table(186) := '74207469746C654964203D206469616C6F672E6964202B20225F5449544C45223B0A20202020202020206469616C6F672E7365744174747269627574652822617269612D6C6162656C6C65646279222C207469746C654964293B0A202020202020202063';
wwv_flow_imp.g_varchar2_table(187) := '6F6E737420686561646572203D20656C2822686561646572222C20226967612D68656164657222293B0A2020202020202020636F6E73742068656164696E67203D20656C282264697622293B0A202020202020202068656164696E672E617070656E6428';
wwv_flow_imp.g_varchar2_table(188) := '656C28227370616E222C20226967612D65796562726F77222C2022524F57204154544143484D454E54532229293B0A2020202020202020636F6E7374207469746C65203D20656C28226832222C2022222C20224D616E616765206174746163686D656E74';
wwv_flow_imp.g_varchar2_table(189) := '7322293B207469746C652E6964203D207469746C6549643B2068656164696E672E617070656E64287469746C65293B0A2020202020202020636F6E737420636C6F7365203D20656C2822627574746F6E222C20226967612D636C6F736522293B20636C6F';
wwv_flow_imp.g_varchar2_table(190) := '73652E617070656E642869636F6E282266612D74696D65732229293B0A2020202020202020636C6F73652E74797065203D2022627574746F6E223B20636C6F73652E7365744174747269627574652822617269612D6C6162656C222C2022436C6F736520';
wwv_flow_imp.g_varchar2_table(191) := '6174746163686D656E747322293B0A20202020202020206865616465722E617070656E642868656164696E672C20636C6F7365293B0A2020202020202020636F6E737420636F6E74657874203D20656C282270222C20226967612D636F6E746578742229';
wwv_flow_imp.g_varchar2_table(192) := '3B0A2020202020202020636F6E73742064726F70203D20656C2822646976222C20226967612D64726F7022293B0A2020202020202020636F6E73742064726F7049636F6E203D20656C2822646976222C20226967612D64726F702D69636F6E22293B2064';
wwv_flow_imp.g_varchar2_table(193) := '726F7049636F6E2E617070656E642869636F6E282266612D636C6F75642D75706C6F61642229293B0A202020202020202064726F702E617070656E642864726F7049636F6E2C20656C28227374726F6E67222C2022222C202244726F702066696C657320';
wwv_flow_imp.g_varchar2_table(194) := '6865726522292C0A202020202020202020202020656C28227370616E222C2022222C20226F722063686F6F73652066696C65732066726F6D20796F7572206465766963652229293B0A2020202020202020636F6E73742062726F777365203D20656C2822';
wwv_flow_imp.g_varchar2_table(195) := '627574746F6E222C20226967612D62726F777365222C202243686F6F73652066696C657322293B2062726F7773652E74797065203D2022627574746F6E223B0A2020202020202020636F6E737420696E707574203D20656C2822696E70757422293B2069';
wwv_flow_imp.g_varchar2_table(196) := '6E7075742E74797065203D202266696C65223B20696E7075742E6D756C7469706C65203D20747275653B20696E7075742E616363657074203D206366672E6163636570743B20696E7075742E68696464656E203D20747275653B0A20202020202020202F';
wwv_flow_imp.g_varchar2_table(197) := '2F204153434949206F6E6C7920696E20746869732066696C653A2041504558206D617920736572766520697420776974686F7574206120636861727365740A2020202020202020636F6E7374207479706573203D206366672E6163636570742E73706C69';
wwv_flow_imp.g_varchar2_table(198) := '7428222C22292E6D61702878203D3E20782E7472696D28292E7265706C616365282F5E5C2E2F2C202222292E746F5570706572436173652829292E6A6F696E28222C2022293B0A202020202020202064726F702E617070656E642862726F7773652C2069';
wwv_flow_imp.g_varchar2_table(199) := '6E7075742C20656C2822736D616C6C222C2022222C207479706573202B20444F54202B206279746573286366672E6D6178427974657329202B2022207065722066696C6522202B20444F54202B0A20202020202020202020202022557020746F2022202B';
wwv_flow_imp.g_varchar2_table(200) := '206366672E6D6178436F756E74202B20286366672E6D6178436F756E74203D3D3D2031203F20222066696C6522203A20222066696C65732229202B0A202020202020202020202020286366672E6D6178546F74616C203F20444F54202B20627974657328';
wwv_flow_imp.g_varchar2_table(201) := '6366672E6D6178546F74616C29202B202220746F67657468657222203A20222229202B0A202020202020202020202020286366672E6D696E436F756E74203F20444F54202B206366672E6D696E436F756E74202B20286366672E6D696E436F756E74203D';
wwv_flow_imp.g_varchar2_table(202) := '3D3D2031203F20222066696C6522203A20222066696C65732229202B202220726571756972656422203A2022222929293B0A2020202020202020636F6E7374206D657373616765203D20656C2822646976222C20226967612D6D65737361676522293B20';
wwv_flow_imp.g_varchar2_table(203) := '6D6573736167652E7365744174747269627574652822726F6C65222C2022616C65727422293B0A2020202020202020636F6E737420737461747573203D20656C2822646976222C20226967612D73746174757322293B207374617475732E736574417474';
wwv_flow_imp.g_varchar2_table(204) := '7269627574652822726F6C65222C202273746174757322293B207374617475732E7365744174747269627574652822617269612D6C697665222C2022706F6C69746522293B0A2020202020202020636F6E7374206C697374203D20656C2822646976222C';
wwv_flow_imp.g_varchar2_table(205) := '20226967612D66696C657322293B0A2020202020202020636F6E737420666F6F746572203D20656C2822666F6F746572222C20226967612D666F6F74657222293B0A2020202020202020666F6F7465722E617070656E6428656C282270222C2022222C20';
wwv_flow_imp.g_varchar2_table(206) := '224174746163686D656E74206368616E67657320617265206170706C696564207768656E20796F7520736176652074686520677269642E2229293B0A2020202020202020636F6E737420646F6E65203D20656C2822627574746F6E222C20226967612D64';
wwv_flow_imp.g_varchar2_table(207) := '6F6E65222C2022446F6E6522293B20646F6E652E74797065203D2022627574746F6E223B20666F6F7465722E617070656E6428646F6E65293B0A20202020202020206469616C6F672E617070656E64286865616465722C20636F6E746578742C2064726F';
wwv_flow_imp.g_varchar2_table(208) := '702C206D6573736167652C207374617475732C206C6973742C20666F6F746572293B0A2020202020202020646F63756D656E742E626F64792E617070656E64286469616C6F67293B0A20202020202020206C6574206F626A65637455726C73203D205B5D';
wwv_flow_imp.g_varchar2_table(209) := '3B0A202020202020202066756E6374696F6E20636C65617255726C732829207B206F626A65637455726C732E666F72456163682855524C2E7265766F6B654F626A65637455524C293B206F626A65637455726C73203D205B5D3B207D0A20202020202020';
wwv_flow_imp.g_varchar2_table(210) := '2066756E6374696F6E206572726F722865727229207B206D6573736167652E74657874436F6E74656E74203D206572722E6D657373616765207C7C20537472696E6728657272293B207D0A20202020202020206173796E632066756E6374696F6E206174';
wwv_flow_imp.g_varchar2_table(211) := '74656D707428666E29207B206D6573736167652E74657874436F6E74656E74203D2022223B20747279207B20617761697420666E28293B2072657475726E20747275653B207D206361746368202865727229207B206572726F7228657272293B20726574';
wwv_flow_imp.g_varchar2_table(212) := '75726E2066616C73653B207D207D0A20202020202020202F2F2041206669656C64206368616E6765202873656E74207768656E20746865206669656C64206C6F7365732074686520666F637573293A20616E206561726C696572206D6573736167652073';
wwv_flow_imp.g_varchar2_table(213) := '7461797320756E74696C206120726571756573740A20202020202020202F2F207265616C6C79207375636365656473202D20636C6561726564206174206F6E63652C207468652070616E656C20776F756C6420736872696E6B20756E6465722074686520';
wwv_flow_imp.g_varchar2_table(214) := '706F696E74657220616E64206120636C69636B206F6E0A20202020202020202F2F20446F6E6520776F756C64206C616E64206265736964652069742E0A20202020202020206173796E632066756E6374696F6E20617474656D70744669656C6428666E29';
wwv_flow_imp.g_varchar2_table(215) := '207B0A202020202020202020202020747279207B2069662028617761697420666E282929206D6573736167652E74657874436F6E74656E74203D2022223B2072657475726E20747275653B207D206361746368202865727229207B206572726F72286572';
wwv_flow_imp.g_varchar2_table(216) := '72293B2072657475726E2066616C73653B207D0A20202020202020207D0A20202020202020202F2F20446F6E652C2074686520636C6F736520627574746F6E20616E64204573636170653A2061206669656C642076616C7565206E6F742073656E742079';
wwv_flow_imp.g_varchar2_table(217) := '657420287374696C6C20666F6375736564202D2045736361706520646F6573206E6F740A20202020202020202F2F20626C75722069742920697320736176656420666972737420616E642072756E6E696E67207265717565737473206172652061776169';
wwv_flow_imp.g_varchar2_table(218) := '7465643B207468652070616E656C207374617973206F70656E207768656E20746861740A20202020202020202F2F206661696C732E204F6E6C79207468656E20746865206469616C6F6720636C6F73657320616E642074686520726F7720697320736574';
wwv_flow_imp.g_varchar2_table(219) := '746C656420286F6E636C6F7365292E0A20202020202020206C657420636C6F73696E67203D2066616C73653B0A20202020202020206173796E632066756E6374696F6E20636C6F736550616E656C2829207B0A2020202020202020202020206966202863';
wwv_flow_imp.g_varchar2_table(220) := '6C6F73696E67292072657475726E3B0A202020202020202020202020636C6F73696E67203D20747275653B0A202020202020202020202020747279207B0A2020202020202020202020202020202061776169742073657373696F6E2E69646C6528293B0A';
wwv_flow_imp.g_varchar2_table(221) := '20202020202020202020202020202020666F722028636F6E7374206669656C64206F66206C6973742E717565727953656C6563746F72416C6C28222E6967612D6669656C6420696E707574222929207B0A20202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(222) := '20696620286669656C642E636F6D6D69742026262021286177616974206669656C642E636F6D6D6974282929292072657475726E3B0A202020202020202020202020202020207D0A2020202020202020202020202020202061776169742073657373696F';
wwv_flow_imp.g_varchar2_table(223) := '6E2E69646C6528293B0A202020202020202020202020202020202F2F2061206669656C642076616C75652074686520736572766572207265667573656420286F7220646964206E6F7420616E7377657229206973207374696C6C20696E2069747320696E';
wwv_flow_imp.g_varchar2_table(224) := '7075743A2073656E642069740A202020202020202020202020202020202F2F20616761696E3B207768656E2074686174206661696C73207468652070616E656C207374617973206F70656E202D20636F7272656374207468652076616C7565206F722070';
wwv_flow_imp.g_varchar2_table(225) := '757420746865206F6C64206F6E65206261636B0A202020202020202020202020202020206966202873657373696F6E2E6861734472616674732829202626202128617761697420617474656D7074282829203D3E2073657373696F6E2E666C7573684669';
wwv_flow_imp.g_varchar2_table(226) := '656C647328292929292072657475726E3B0A20202020202020202020202020202020636F6E7374206D697373696E67203D2073657373696F6E2E6D697373696E6728293B0A20202020202020202020202020202020696620286D697373696E672E6C656E';
wwv_flow_imp.g_varchar2_table(227) := '67746829207B206572726F72286E6577204572726F72282246696C6C20696E2022202B206D697373696E672E6A6F696E28222C202229202B20222E2229293B2072657475726E3B207D0A202020202020202020202020202020206469616C6F672E636C6F';
wwv_flow_imp.g_varchar2_table(228) := '736528293B0A2020202020202020202020207D2066696E616C6C79207B20636C6F73696E67203D2066616C73653B207D0A20202020202020207D0A20202020202020202F2F20746865204578747261204669656C6473206F66206F6E652066696C653A20';
wwv_flow_imp.g_varchar2_table(229) := '612054657874204669656C642065616368202848696464656E206669656C64732068617665206E6F20696E707574290A202020202020202066756E6374696F6E206669656C64496E707574732866696C652C20726561644F6E6C7929207B0A2020202020';
wwv_flow_imp.g_varchar2_table(230) := '20202020202020636F6E7374206669656C6473203D20286366672E6669656C6473207C7C205B5D292E66696C7465722878203D3E20782E6B696E6420213D3D202248494444454E22293B0A20202020202020202020202069662028216669656C64732E6C';
wwv_flow_imp.g_varchar2_table(231) := '656E677468292072657475726E206E756C6C3B0A202020202020202020202020636F6E737420626F78203D20656C2822646976222C20226967612D6669656C647322293B0A2020202020202020202020206669656C64732E666F7245616368286669656C';
wwv_flow_imp.g_varchar2_table(232) := '64203D3E207B0A20202020202020202020202020202020636F6E7374206964203D206469616C6F672E6964202B20225F4622202B206669656C642E6E202B20225F22202B20537472696E672866696C652E6964292E7265706C616365282F5B5E412D5A61';
wwv_flow_imp.g_varchar2_table(233) := '2D7A302D395D2F672C202222293B0A20202020202020202020202020202020636F6E73742077726170203D20656C2822646976222C20226967612D6669656C6422202B20286669656C642E7265717569726564203F20222069732D726571756972656422';
wwv_flow_imp.g_varchar2_table(234) := '203A20222229293B0A20202020202020202020202020202020636F6E7374206C6162656C203D20656C28226C6162656C222C2022222C206669656C642E6C6162656C293B206C6162656C2E68746D6C466F72203D2069643B0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(235) := '2020202020636F6E737420696E707574203D20656C2822696E70757422293B20696E7075742E74797065203D202274657874223B0A20202020202020202020202020202020696E7075742E6964203D2069643B20696E7075742E646174617365742E6B65';
wwv_flow_imp.g_varchar2_table(236) := '79203D2069643B0A202020202020202020202020202020202F2F207468652073657276657227732076616C75652C206F72207768617420746865207573657220747970656420616E64207468652073657276657220686173206E6F7420636F6E6669726D';
wwv_flow_imp.g_varchar2_table(237) := '6564207965740A20202020202020202020202020202020696E7075742E76616C7565203D2073657373696F6E2E6669656C6456616C75652866696C652C206669656C642E6E202D2031293B0A20202020202020202020202020202020696E7075742E7368';
wwv_flow_imp.g_varchar2_table(238) := '6F776E203D20696E7075742E76616C75653B2020202F2F206120726564726177206B6565707320746578742074797065642073696E6365207468656E0A202020202020202020202020202020202F2F20746865206C656E6774682074686520646576656C';
wwv_flow_imp.g_varchar2_table(239) := '6F706572277320636F6C756D6E20686F6C6473202853746F72616765203D204D79205461626C65292C20656C7365207468652073746167696E67206C696D69740A20202020202020202020202020202020696E7075742E6D61784C656E677468203D204D';
wwv_flow_imp.g_varchar2_table(240) := '6174682E6D696E286669656C642E6D6178207C7C20343030302C2034303030293B0A20202020202020202020202020202020696E7075742E64697361626C6564203D20726561644F6E6C79207C7C2066696C652E72656D6F766564207C7C202166696C65';
wwv_flow_imp.g_varchar2_table(241) := '2E72656164793B0A20202020202020202020202020202020696620286669656C642E72657175697265642920696E7075742E7265717569726564203D20747275653B0A202020202020202020202020202020202F2F2073656E64732061206368616E6765';
wwv_flow_imp.g_varchar2_table(242) := '642076616C7565206F6E636520286368616E6765206576656E742C206F7220636C6F736550616E656C20666F722061206669656C64207374696C6C206265696E672074797065640A202020202020202020202020202020202F2F20696E293B2069742077';
wwv_flow_imp.g_varchar2_table(243) := '6169747320666F722072756E6E696E6720776F726B20696E7374656164206F66206265696E6720726566757365640A20202020202020202020202020202020696E7075742E636F6D6D6974203D206173796E63202829203D3E207B0A2020202020202020';
wwv_flow_imp.g_varchar2_table(244) := '20202020202020202020202069662028696E7075742E64697361626C6564207C7C20696E7075742E76616C7565203D3D3D2073657373696F6E2E6669656C6456616C75652866696C652C206669656C642E6E202D203129292072657475726E2074727565';
wwv_flow_imp.g_varchar2_table(245) := '3B0A202020202020202020202020202020202020202072657475726E20617474656D70744669656C64282829203D3E2073657373696F6E2E7365744669656C642866696C652C206669656C642E6E202D20312C20696E7075742E76616C756529293B0A20';
wwv_flow_imp.g_varchar2_table(246) := '2020202020202020202020202020207D3B0A20202020202020202020202020202020696E7075742E6F6E6368616E6765203D202829203D3E207B20696E7075742E636F6D6D697428293B207D3B0A202020202020202020202020202020202F2F20616C73';
wwv_flow_imp.g_varchar2_table(247) := '6F206F6E206C656176696E6720746865206669656C643A2074657874206B657074206163726F737320612072656472617720686173206E6F206368616E6765206576656E74206F6620697473206F776E0A20202020202020202020202020202020696E70';
wwv_flow_imp.g_varchar2_table(248) := '75742E6F6E626C7572203D202829203D3E207B20696E7075742E636F6D6D697428293B207D3B0A20202020202020202020202020202020777261702E617070656E64286C6162656C2C20696E707574293B20626F782E617070656E642877726170293B0A';
wwv_flow_imp.g_varchar2_table(249) := '2020202020202020202020207D293B0A20202020202020202020202072657475726E20626F783B0A20202020202020207D0A2020202020202020636C6F73652E6F6E636C69636B203D20646F6E652E6F6E636C69636B203D20636C6F736550616E656C3B';
wwv_flow_imp.g_varchar2_table(250) := '0A20202020202020202F2F204573636170652069732068616E646C656420686572653A204368726F6D652069676E6F72657320612070726576656E746564202263616E63656C22207768656E20697420636F6D657320747769636520776974686F757420';
wwv_flow_imp.g_varchar2_table(251) := '610A20202020202020202F2F20636C69636B20696E206265747765656E20616E6420636C6F73657320746865206469616C6F672C20776869636820776F756C642064726F7020612072656675736564206669656C642076616C75650A2020202020202020';
wwv_flow_imp.g_varchar2_table(252) := '6469616C6F672E6164644576656E744C697374656E657228226B6579646F776E222C206576656E74203D3E207B0A202020202020202020202020696620286576656E742E6B6579203D3D3D20224573636170652220262620216576656E742E6465666175';
wwv_flow_imp.g_varchar2_table(253) := '6C7450726576656E74656429207B206576656E742E70726576656E7444656661756C7428293B20636C6F736550616E656C28293B207D0A20202020202020207D293B0A20202020202020206469616C6F672E6164644576656E744C697374656E65722822';
wwv_flow_imp.g_varchar2_table(254) := '63616E63656C222C206576656E74203D3E207B206576656E742E70726576656E7444656661756C7428293B20636C6F736550616E656C28293B207D293B0A20202020202020206469616C6F672E6164644576656E744C697374656E65722822636C6F7365';
wwv_flow_imp.g_varchar2_table(255) := '222C202829203D3E207B20636C65617255726C7328293B206F7074696F6E732E6F6E636C6F73653F2E28293B207D293B0A202020202020202062726F7773652E6F6E636C69636B203D202829203D3E20696E7075742E636C69636B28293B0A2020202020';
wwv_flow_imp.g_varchar2_table(256) := '202020696E7075742E6F6E6368616E6765203D202829203D3E207B20636F6E73742066696C6573203D205B2E2E2E696E7075742E66696C65735D3B20696E7075742E76616C7565203D2022223B20617474656D7074282829203D3E2073657373696F6E2E';
wwv_flow_imp.g_varchar2_table(257) := '75706C6F61642866696C657329293B207D3B0A2020202020202020666F722028636F6E73742074797065206F66205B2264726167656E746572222C2022647261676F766572222C2022647261676C65617665222C202264726F70225D292064726F702E61';
wwv_flow_imp.g_varchar2_table(258) := '64644576656E744C697374656E657228747970652C206576656E74203D3E207B0A2020202020202020202020206576656E742E70726576656E7444656661756C7428293B206576656E742E73746F7050726F7061676174696F6E28293B0A202020202020';
wwv_flow_imp.g_varchar2_table(259) := '20202020202064726F702E636C6173734C6973742E746F67676C65282269732D6F766572222C2074797065203D3D3D202264726167656E74657222207C7C2074797065203D3D3D2022647261676F76657222293B0A202020202020202020202020696620';
wwv_flow_imp.g_varchar2_table(260) := '2874797065203D3D3D202264726F7022202626202173657373696F6E2E62757379202626202173657373696F6E2E636F6E746578742E726561644F6E6C79290A20202020202020202020202020202020617474656D7074282829203D3E2073657373696F';
wwv_flow_imp.g_varchar2_table(261) := '6E2E75706C6F6164285B2E2E2E6576656E742E646174615472616E736665722E66696C65735D29293B0A20202020202020207D293B0A202020202020202073657373696F6E2E6F6E6368616E6765203D202829203D3E207B0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(262) := '20636F6E737420726561644F6E6C79203D2073657373696F6E2E636F6E746578743F2E726561644F6E6C793B0A20202020202020202020202062726F7773652E64697361626C6564203D2073657373696F6E2E62757379207C7C20726561644F6E6C7920';
wwv_flow_imp.g_varchar2_table(263) := '7C7C202173657373696F6E2E72656164793B0A202020202020202020202020636C6F73652E64697361626C6564203D20646F6E652E64697361626C6564203D2073657373696F6E2E627573793B0A20202020202020202020202064726F702E6869646465';
wwv_flow_imp.g_varchar2_table(264) := '6E203D20426F6F6C65616E28726561644F6E6C79293B0A202020202020202020202020636F6E746578742E74657874436F6E74656E74203D2073657373696F6E2E636F6E74657874203F2073657373696F6E2E636F6E746578742E6C6162656C203A2022';
wwv_flow_imp.g_varchar2_table(265) := '223B0A202020202020202020202020636F6E746578742E68696464656E203D2021636F6E746578742E74657874436F6E74656E743B0A2020202020202020202020202F2F20746865207374617475732069732061206C69766520726567696F6E3A206475';
wwv_flow_imp.g_varchar2_table(266) := '72696E6720616E2075706C6F6164206974206368616E67657320696E207374657073206F6620323520252C20736F2073637265656E20726561646572730A2020202020202020202020202F2F20617265206E6F742068616E646564206576657279207065';
wwv_flow_imp.g_varchar2_table(267) := '7263656E742028746865206261722062656C6F77207374696C6C206D6F76657320736D6F6F74686C79290A202020202020202020202020636F6E73742073746174757354657874203D2073657373696F6E2E70726F67726573730A202020202020202020';
wwv_flow_imp.g_varchar2_table(268) := '202020202020203F202255706C6F6164696E672022202B2073657373696F6E2E70726F67726573732E6E616D65202B20444F54202B0A2020202020202020202020202020202020204D6174682E666C6F6F722873657373696F6E2E70726F67726573732E';
wwv_flow_imp.g_varchar2_table(269) := '7265636569766564202F2073657373696F6E2E70726F67726573732E73697A65202A203429202A203235202B202225220A202020202020202020202020202020203A2073657373696F6E2E62757379203F2022576F726B696E672E2E2E22203A20636F75';
wwv_flow_imp.g_varchar2_table(270) := '6E742873657373696F6E2E66696C65732E66696C7465722866203D3E2021662E72656D6F766564292E6C656E677468293B0A202020202020202020202020696620287374617475732E74657874436F6E74656E7420213D3D207374617475735465787429';
wwv_flow_imp.g_varchar2_table(271) := '207374617475732E74657874436F6E74656E74203D20737461747573546578743B0A2020202020202020202020206966202873657373696F6E2E6275737929207B0A202020202020202020202020202020202F2F20507265736572766520657869737469';
wwv_flow_imp.g_varchar2_table(272) := '6E67207072657669657773207768696C652075706C6F6164696E673B207468652066696C65206265696E672073656E742073686F7773206174206F6E63652077697468206974732070726F67726573732E0A202020202020202020202020202020206C65';
wwv_flow_imp.g_varchar2_table(273) := '7420726F77203D206C6973742E717565727953656C6563746F7228222E6967612D66696C652E69732D75706C6F6164696E6722293B0A202020202020202020202020202020206966202873657373696F6E2E70726F677265737329207B0A202020202020';
wwv_flow_imp.g_varchar2_table(274) := '20202020202020202020202020206966202821726F77207C7C20726F772E646174617365742E6E616D6520213D3D2073657373696F6E2E70726F67726573732E6E616D6529207B0A202020202020202020202020202020202020202020202020726F773F';
wwv_flow_imp.g_varchar2_table(275) := '2E72656D6F766528293B0A2020202020202020202020202020202020202020202020206C6973742E717565727953656C6563746F7228222E6967612D656D70747922293F2E72656D6F766528293B0A202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(276) := '202020726F77203D20656C282261727469636C65222C20226967612D66696C652069732D75706C6F6164696E6722293B20726F772E646174617365742E6E616D65203D2073657373696F6E2E70726F67726573732E6E616D653B0A202020202020202020';
wwv_flow_imp.g_varchar2_table(277) := '202020202020202020202020202020636F6E737420726F7749636F6E203D20656C2822646976222C20226967612D66696C652D69636F6E22293B20726F7749636F6E2E617070656E642869636F6E282266612D636972636C652D6F2D6E6F746368206661';
wwv_flow_imp.g_varchar2_table(278) := '2D7370696E2229293B0A202020202020202020202020202020202020202020202020636F6E737420696E666F203D20656C2822646976222C20226967612D66696C652D696E666F22293B0A20202020202020202020202020202020202020202020202069';
wwv_flow_imp.g_varchar2_table(279) := '6E666F2E617070656E6428656C28227374726F6E67222C2022222C2073657373696F6E2E70726F67726573732E6E616D65292C20656C28227370616E222C2022222C2062797465732873657373696F6E2E70726F67726573732E73697A6529292C0A2020';
wwv_flow_imp.g_varchar2_table(280) := '2020202020202020202020202020202020202020202020202020656C28227370616E222C20226967612D6261646765222C202255706C6F6164696E672229293B0A202020202020202020202020202020202020202020202020636F6E737420626172203D';
wwv_flow_imp.g_varchar2_table(281) := '20656C2822646976222C20226967612D62617222293B206261722E617070656E6428656C28227370616E2229293B0A202020202020202020202020202020202020202020202020696E666F2E617070656E6428626172293B0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(282) := '20202020202020202020202020636F6E737420616374696F6E73203D20656C2822646976222C20226967612D66696C652D616374696F6E7322293B0A202020202020202020202020202020202020202020202020616374696F6E732E617070656E642869';
wwv_flow_imp.g_varchar2_table(283) := '636F6E427574746F6E282243616E63656C2075706C6F6164222C202266612D74696D6573222C20226967612D64616E676572206967612D63616E63656C222C202829203D3E2073657373696F6E2E63616E63656C282929293B0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(284) := '2020202020202020202020202020726F772E617070656E6428726F7749636F6E2C20696E666F2C20616374696F6E73293B206C6973742E617070656E6428726F77293B0A20202020202020202020202020202020202020207D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(285) := '20202020202020202020726F772E717565727953656C6563746F7228222E6967612D626172207370616E22292E7374796C652E7769647468203D0A2020202020202020202020202020202020202020202020204D6174682E726F756E642873657373696F';
wwv_flow_imp.g_varchar2_table(286) := '6E2E70726F67726573732E7265636569766564202F2073657373696F6E2E70726F67726573732E73697A65202A2031303029202B202225223B0A202020202020202020202020202020207D0A2020202020202020202020202020202072657475726E3B0A';
wwv_flow_imp.g_varchar2_table(287) := '2020202020202020202020207D0A2020202020202020202020202F2F206B6565702074686520666F63757320696E20746865206669656C64206265696E6720656469746564206163726F737320746865207265647261770A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(288) := '636F6E737420666F6375734B6579203D20646F63756D656E742E616374697665456C656D656E74202626206C6973742E636F6E7461696E7328646F63756D656E742E616374697665456C656D656E7429203F20646F63756D656E742E616374697665456C';
wwv_flow_imp.g_varchar2_table(289) := '656D656E742E646174617365742E6B6579203A206E756C6C3B0A2020202020202020202020202F2F207465787420747970656420696E2061206669656C6420616E64206E6F742073656E742079657420286E6F206368616E6765206576656E7420736F20';
wwv_flow_imp.g_varchar2_table(290) := '6661722920737572766976657320746865207265647261770A202020202020202020202020636F6E737420747970696E67203D206E6577204D617028293B0A202020202020202020202020666F722028636F6E7374206E6F6465206F66206C6973742E71';
wwv_flow_imp.g_varchar2_table(291) := '7565727953656C6563746F72416C6C28222E6967612D6669656C6420696E707574222929207B0A20202020202020202020202020202020696620286E6F64652E76616C756520213D3D206E6F64652E73686F776E2920747970696E672E736574286E6F64';
wwv_flow_imp.g_varchar2_table(292) := '652E646174617365742E6B65792C206E6F64652E76616C7565293B0A2020202020202020202020207D0A202020202020202020202020636C65617255726C7328293B206C6973742E7265706C6163654368696C6472656E28293B0A202020202020202020';
wwv_flow_imp.g_varchar2_table(293) := '202020696620282173657373696F6E2E66696C65732E6C656E67746829207B0A202020202020202020202020202020206C6973742E617070656E6428656C2822646976222C20226967612D656D707479222C20224E6F206174746163686D656E74732079';
wwv_flow_imp.g_varchar2_table(294) := '65742E20416464207468652066696C6573207468617420737570706F7274207468697320726F772E2229293B0A2020202020202020202020202020202072657475726E3B0A2020202020202020202020207D0A2020202020202020202020207365737369';
wwv_flow_imp.g_varchar2_table(295) := '6F6E2E66696C65732E666F72456163682866696C65203D3E207B0A20202020202020202020202020202020636F6E737420726F77203D20656C282261727469636C65222C20226967612D66696C6522202B202866696C652E72656D6F766564203F202220';
wwv_flow_imp.g_varchar2_table(296) := '69732D72656D6F76656422203A20222229293B0A20202020202020202020202020202020636F6E73742066696C6549636F6E203D20656C2822646976222C20226967612D66696C652D69636F6E22293B2066696C6549636F6E2E617070656E642869636F';
wwv_flow_imp.g_varchar2_table(297) := '6E2869636F6E466F722866696C652929293B0A20202020202020202020202020202020636F6E737420696E666F203D20656C2822646976222C20226967612D66696C652D696E666F22293B0A20202020202020202020202020202020696E666F2E617070';
wwv_flow_imp.g_varchar2_table(298) := '656E6428656C28227374726F6E67222C2022222C2066696C652E6E616D65292C20656C28227370616E222C2022222C2062797465732866696C652E73697A652929293B0A20202020202020202020202020202020636F6E7374206261646765203D20656C';
wwv_flow_imp.g_varchar2_table(299) := '28227370616E222C20226967612D6261646765222C2066696C652E72656D6F766564203F202252656D6F76616C2070656E64696E6722203A202166696C652E72656164790A20202020202020202020202020202020202020203F2022496E636F6D706C65';
wwv_flow_imp.g_varchar2_table(300) := '7465202D2072656D6F766520746F207361766522203A2066696C652E737461676564203F202250656E64696E67207361766522203A2066696C652E6368616E676564203F20224368616E6765732070656E64696E6722203A2022536176656422293B0A20';
wwv_flow_imp.g_varchar2_table(301) := '202020202020202020202020202020696E666F2E617070656E64286261646765293B0A20202020202020202020202020202020636F6E737420696E70757473203D206669656C64496E707574732866696C652C20726561644F6E6C79293B0A2020202020';
wwv_flow_imp.g_varchar2_table(302) := '202020202020202020202069662028696E707574732920696E666F2E617070656E6428696E70757473293B0A20202020202020202020202020202020636F6E737420616374696F6E73203D20656C2822646976222C20226967612D66696C652D61637469';
wwv_flow_imp.g_varchar2_table(303) := '6F6E7322293B0A202020202020202020202020202020206966202866696C652E7265616479202626202166696C652E72656D6F76656429207B0A2020202020202020202020202020202020202020616374696F6E732E617070656E642869636F6E427574';
wwv_flow_imp.g_varchar2_table(304) := '746F6E2822446F776E6C6F6164222C202266612D646F776E6C6F6164222C2022222C202829203D3E20617474656D7074282829203D3E206F7074696F6E732E646F776E6C6F61642866696C652C2073657373696F6E292929293B0A202020202020202020';
wwv_flow_imp.g_varchar2_table(305) := '2020202020202020202020696620285B22696D6167652F706E67222C2022696D6167652F6A706567225D2E696E636C756465732866696C652E6D696D6529202626206F7074696F6E732E7072657669657729207B0A202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(306) := '202020202020202020636F6E73742070726576696577203D2069636F6E427574746F6E282250726576696577222C202266612D657965222C2022222C202829203D3E20617474656D7074286173796E63202829203D3E207B0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(307) := '2020202020202020202020202020202020636F6E737420626C6F62203D206177616974206F7074696F6E732E707265766965772866696C652C2073657373696F6E293B0A2020202020202020202020202020202020202020202020202020202069662028';
wwv_flow_imp.g_varchar2_table(308) := '215B22696D6167652F706E67222C2022696D6167652F6A706567225D2E696E636C7564657328626C6F622E747970652929207468726F77206E6577204572726F7228225072657669657720756E617661696C61626C652E22293B0A202020202020202020';
wwv_flow_imp.g_varchar2_table(309) := '20202020202020202020202020202020202020636F6E73742075726C203D2055524C2E6372656174654F626A65637455524C28626C6F62293B206F626A65637455726C732E707573682875726C293B0A2020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(310) := '2020202020202020636F6E737420696D616765203D20656C2822696D67222C20226967612D7072657669657722293B20696D6167652E737263203D2075726C3B20696D6167652E616C74203D2066696C652E6E616D653B0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(311) := '2020202020202020202020202020202066696C6549636F6E2E7265706C6163654368696C6472656E28696D616765293B0A2020202020202020202020202020202020202020202020207D29293B0A20202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(312) := '2020616374696F6E732E617070656E642870726576696577293B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D0A202020202020202020202020202020206966202821726561644F6E6C7929207B0A';
wwv_flow_imp.g_varchar2_table(313) := '2020202020202020202020202020202020202020616374696F6E732E617070656E642866696C652E72656D6F7665640A2020202020202020202020202020202020202020202020203F2069636F6E427574746F6E2822526573746F7265222C202266612D';
wwv_flow_imp.g_varchar2_table(314) := '756E646F222C2022222C202829203D3E20617474656D7074282829203D3E2073657373696F6E2E72656D6F76652866696C652929290A2020202020202020202020202020202020202020202020203A2069636F6E427574746F6E282252656D6F7665222C';
wwv_flow_imp.g_varchar2_table(315) := '202266612D74726173682D6F222C20226967612D64616E676572222C202829203D3E20617474656D7074282829203D3E2073657373696F6E2E72656D6F76652866696C65292929293B0A202020202020202020202020202020207D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(316) := '2020202020202020726F772E617070656E642866696C6549636F6E2C20696E666F2C20616374696F6E73293B206C6973742E617070656E6428726F77293B0A2020202020202020202020207D293B0A202020202020202020202020666F722028636F6E73';
wwv_flow_imp.g_varchar2_table(317) := '74205B6B65792C2076616C75655D206F6620747970696E6729207B0A20202020202020202020202020202020636F6E7374206E6F6465203D206C6973742E717565727953656C6563746F7228275B646174612D6B65793D2227202B206B6579202B202722';
wwv_flow_imp.g_varchar2_table(318) := '5D27293B0A20202020202020202020202020202020696620286E6F646520262620216E6F64652E64697361626C656429206E6F64652E76616C7565203D2076616C75653B0A2020202020202020202020207D0A2020202020202020202020206966202866';
wwv_flow_imp.g_varchar2_table(319) := '6F6375734B657929206C6973742E717565727953656C6563746F7228275B646174612D6B65793D2227202B20666F6375734B6579202B2027225D27293F2E666F63757328293B0A20202020202020207D3B0A202020202020202072657475726E207B0A20';
wwv_flow_imp.g_varchar2_table(320) := '20202020202020202020206469616C6F672C2073657373696F6E2C0A2020202020202020202020206173796E63206F70656E2863747829207B0A20202020202020202020202020202020696620286469616C6F672E6F70656E292072657475726E3B0A20';
wwv_flow_imp.g_varchar2_table(321) := '2020202020202020202020202020206D6573736167652E74657874436F6E74656E74203D2022223B206C6973742E7265706C6163654368696C6472656E28293B0A202020202020202020202020202020206469616C6F672E73686F774D6F64616C28293B';
wwv_flow_imp.g_varchar2_table(322) := '0A20202020202020202020202020202020617761697420617474656D7074282829203D3E2073657373696F6E2E6F70656E2863747829293B0A2020202020202020202020202020202062726F7773652E666F63757328293B0A2020202020202020202020';
wwv_flow_imp.g_varchar2_table(323) := '207D2C0A20202020202020202020202064657374726F792829207B20636C65617255726C7328293B206469616C6F672E72656D6F766528293B207D0A20202020202020207D3B0A202020207D0A0A202020202F2F2043656C6C206D61726B75702028616C';
wwv_flow_imp.g_varchar2_table(324) := '736F2074686520656469746F72277320636F6E74656E742C20736F20746865206163746976652063656C6C206C6F6F6B73207468652073616D6520617320746865206F7468657273292E0A202020202F2F20546865206772696420657363617065732063';
wwv_flow_imp.g_varchar2_table(325) := '656C6C732062792064656661756C743B207468697320636F6C756D6E2773206573636170696E67206973207377697463686564206F666620616E6420746865206D61726B75702069730A202020202F2F206275696C7420686572652C2077697468207468';
wwv_flow_imp.g_varchar2_table(326) := '65206C6162656C20657363617065643A207468652076616C756520697473656C66206973206F6E6C79206576657220616E206564697420746F6B656E2E0A2020202066756E6374696F6E2063656C6C48746D6C286366672C2076616C75652C2065736329';
wwv_flow_imp.g_varchar2_table(327) := '207B0A2020202020202020636F6E73742070656E64696E67203D206973546F6B656E2876616C7565293B0A2020202020202020636F6E73742066696C6573203D202F5E5C642B242F2E746573742876616C7565203D3D206E756C6C203F202222203A2053';
wwv_flow_imp.g_varchar2_table(328) := '7472696E672876616C75652929203F204E756D6265722876616C756529203A20303B0A2020202020202020636F6E73742074657874203D206366672E6C6162656C207C7C20224174746163686D656E7473223B0A2020202020202020636F6E7374206963';
wwv_flow_imp.g_varchar2_table(329) := '6F6E50617274203D206366672E646973706C6179203D3D3D20225445585422203F202222203A0A202020202020202020202020273C7370616E20636C6173733D226967612D63656C6C2D69636F6E2066612027202B20657363286366672E69636F6E207C';
wwv_flow_imp.g_varchar2_table(330) := '7C202266612D7061706572636C69702229202B20272220617269612D68696464656E3D2274727565223E3C2F7370616E3E273B0A2020202020202020636F6E7374207465787450617274203D206366672E646973706C6179203D3D3D202249434F4E2220';
wwv_flow_imp.g_varchar2_table(331) := '3F20273C7370616E20636C6173733D22752D56697375616C6C7948696464656E223E27202B20657363287465787429202B20223C2F7370616E3E22203A0A202020202020202020202020273C7370616E20636C6173733D226967612D63656C6C2D6C6162';
wwv_flow_imp.g_varchar2_table(332) := '656C223E27202B20657363287465787429202B20223C2F7370616E3E223B0A2020202020202020636F6E73742070656E64696E6750617274203D2070656E64696E67203F20286366672E646973706C6179203D3D3D202249434F4E220A20202020202020';
wwv_flow_imp.g_varchar2_table(333) := '20202020203F20273C7370616E20636C6173733D226967612D63656C6C2D646F7422207469746C653D224368616E676573206E6F7420736176656420796574223E3C2F7370616E3E3C7370616E20636C6173733D22752D56697375616C6C794869646465';
wwv_flow_imp.g_varchar2_table(334) := '6E223E50656E64696E673C2F7370616E3E270A2020202020202020202020203A20273C7370616E20636C6173733D226967612D63656C6C2D70656E64696E67223E50656E64696E673C2F7370616E3E2729203A2022223B0A2020202020202020636F6E73';
wwv_flow_imp.g_varchar2_table(335) := '7420636F756E7450617274203D2066696C6573203E2030202626202170656E64696E67203F20273C7370616E20636C6173733D226967612D63656C6C2D636F756E74223E27202B2066696C6573202B20223C2F7370616E3E22203A2022223B0A20202020';
wwv_flow_imp.g_varchar2_table(336) := '2020202072657475726E20273C7370616E20636C6173733D226967612D63656C6C27202B202870656E64696E67203F20222069732D70656E64696E6722203A20222229202B20272220646174612D6967612D6974656D3D2227202B20657363286366672E';
wwv_flow_imp.g_varchar2_table(337) := '6974656D29202B2027223E27202B0A20202020202020202020202069636F6E50617274202B207465787450617274202B20636F756E7450617274202B2070656E64696E6750617274202B20223C2F7370616E3E223B0A202020207D0A0A2020202066756E';
wwv_flow_imp.g_varchar2_table(338) := '6374696F6E20696E69742863666729207B0A20202020202020206966202821726F6F7441706578282929207468726F77206E6577204572726F7228224947204174746163686D656E7473206E65656473204F7261636C6520415045582E22293B0A202020';
wwv_flow_imp.g_varchar2_table(339) := '2020202020636F6E73742061706578203D20726F6F744170657828292C2024203D20617065782E6A51756572793B0A2020202020202020636F6E737420657363203D20617065782E7574696C3F2E65736361706548544D4C207C7C202876203D3E205374';
wwv_flow_imp.g_varchar2_table(340) := '72696E672876292E7265706C616365282F5B263C3E22275D2F672C2063203D3E2022262322202B20632E63686172436F64654174283029202B20223B2229293B0A2020202020202020696E7374616E6365732E676574286366672E6974656D293F2E6465';
wwv_flow_imp.g_varchar2_table(341) := '7374726F7928293B0A2020202020202020636F6E737420696E707574203D20646F63756D656E742E676574456C656D656E7442794964286366672E6974656D292C20627574746F6E203D20646F63756D656E742E676574456C656D656E74427949642863';
wwv_flow_imp.g_varchar2_table(342) := '66672E6974656D202B20225F4F50454E22293B0A20202020202020206C65742064697361626C6564203D20426F6F6C65616E286366672E726561644F6E6C79292C206C6F636B656456696577203D206E756C6C2C2061637469766550616E656C203D206E';
wwv_flow_imp.g_varchar2_table(343) := '756C6C3B0A20202020202020202F2F2054686520677269642C20697473206B657920616E64207468697320636F6C756D6E2773206669656C642061726520726561642066726F6D20746865206772696420697473656C662E2054686520677269640A2020';
wwv_flow_imp.g_varchar2_table(344) := '2020202020202F2F207265676973746572732061667465722069747320636F6C756D6E7320696E697469616C697A652C20736F206974206973206C6F6F6B6564207570207768656E206669727374206E65656465642E0A20202020202020206C65742072';
wwv_flow_imp.g_varchar2_table(345) := '6567696F6E4964203D206366672E726567696F6E207C7C206E756C6C3B0A202020202020202066756E6374696F6E20726567696F6E2829207B0A2020202020202020202020206966202821726567696F6E496429207B0A20202020202020202020202020';
wwv_flow_imp.g_varchar2_table(346) := '202020636F6E737420666F756E64203D20617065782E726567696F6E2E66696E64436C6F7365737428696E70757429207C7C20617065782E726567696F6E2E66696E64436C6F7365737428627574746F6E293B0A20202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(347) := '6966202821666F756E6429207468726F77206E6577204572726F7228224947204174746163686D656E74733A2022202B206366672E6974656D202B2022206973206E6F7420696E7369646520616E20496E74657261637469766520477269642E22293B0A';
wwv_flow_imp.g_varchar2_table(348) := '20202020202020202020202020202020726567696F6E4964203D20666F756E642E656C656D656E742E617474722822696422293B0A2020202020202020202020207D0A20202020202020202020202072657475726E20617065782E726567696F6E287265';
wwv_flow_imp.g_varchar2_table(349) := '67696F6E4964293B0A20202020202020207D0A202020202020202066756E6374696F6E20766965772829207B2072657475726E20726567696F6E28292E63616C6C28226765745669657773222C20226772696422293B207D0A2020202020202020636F6E';
wwv_flow_imp.g_varchar2_table(350) := '7374206D696E65203D20746172676574203D3E20746172676574202626207461726765742E636F6E7461696E7320262620287461726765742E636F6E7461696E7328696E70757429207C7C207461726765742E636F6E7461696E7328627574746F6E2929';
wwv_flow_imp.g_varchar2_table(351) := '3B0A202020202020202066756E6374696F6E206669656C644F66286D6F64656C29207B0A202020202020202020202020636F6E7374206669656C6473203D206D6F64656C2E6765744F7074696F6E28226669656C64732229207C7C207B7D3B0A20202020';
wwv_flow_imp.g_varchar2_table(352) := '202020202020202072657475726E204F626A6563742E6B657973286669656C6473292E66696E64286E616D65203D3E206669656C64735B6E616D655D2E656C656D656E744964203D3D3D206366672E6974656D29207C7C206366672E6974656D3B0A2020';
wwv_flow_imp.g_varchar2_table(353) := '2020202020207D0A202020202020202066756E6374696F6E206B65794F66286D6F64656C29207B0A202020202020202020202020636F6E7374206964203D206D6F64656C2E6765744F7074696F6E28226964656E746974794669656C6422293B0A202020';
wwv_flow_imp.g_varchar2_table(354) := '202020202020202020636F6E7374206B6579203D2041727261792E6973417272617928696429203F206964203A206964203F205B69645D203A205B5D3B0A202020202020202020202020696620286B65792E6C656E67746820213D3D203129207468726F';
wwv_flow_imp.g_varchar2_table(355) := '77206E6577204572726F7228224947204174746163686D656E7473206E65656473206120677269642077697468206F6E65207072696D617279206B657920636F6C756D6E2E22293B0A20202020202020202020202072657475726E206B65795B305D3B0A';
wwv_flow_imp.g_varchar2_table(356) := '20202020202020207D0A202020202020202066756E6374696F6E207061696E742829207B0A202020202020202020202020627574746F6E2E696E6E657248544D4C203D2063656C6C48746D6C286366672C20696E7075742E76616C75652C20657363293B';
wwv_flow_imp.g_varchar2_table(357) := '0A202020202020202020202020627574746F6E2E7365744174747269627574652822617269612D6C6162656C222C20286366672E6C6162656C207C7C20224174746163686D656E74732229202B20286973546F6B656E28696E7075742E76616C75652920';
wwv_flow_imp.g_varchar2_table(358) := '3F20222C2070656E64696E6722203A20222229293B0A20202020202020207D0A20202020202020202F2F20746F6B656E73207468697320636F6C756D6E20707574206F6E20726F777320287265636F7264206964202D3E20746F6B656E293A20616E7920';
wwv_flow_imp.g_varchar2_table(359) := '6F7468657220746F6B656E20696E207468652063656C6C20287061737465642C0A20202020202020202F2F2066696C6C656420646F776E292069732074616B656E206F666620616761696E202D2069742062656C6F6E677320746F20616E6F7468657220';
wwv_flow_imp.g_varchar2_table(360) := '726F7727732066696C65730A2020202020202020636F6E7374206F776E546F6B656E73203D206E6577204D617028293B0A20202020202020202F2F207265636F7264206B6579202D3E2074686520746F6B656E206F6620616E2065646974206F70656E65';
wwv_flow_imp.g_varchar2_table(361) := '6420616E6420636C6F73656420776974686F7574206368616E676573202874686520726F7720646F6573206E6F7420686F6C640A20202020202020202F2F206974293A2073656E7420616761696E206F6E20746865206E657874206F70656E696E672C20';
wwv_flow_imp.g_varchar2_table(362) := '736F20746869732070616E656C2072657573657320697420616E64206F74686572207461627320676574207468656972206F776E0A2020202020202020636F6E737420656D7074794564697473203D206E6577204D617028293B0A202020202020202063';
wwv_flow_imp.g_varchar2_table(363) := '6F6E73742061646170746572203D207B0A2020202020202020202020206173796E632072657175657374286F702C206461746129207B0A20202020202020202020202020202020747279207B0A2020202020202020202020202020202020202020726574';
wwv_flow_imp.g_varchar2_table(364) := '75726E20617761697420617065782E7365727665722E706C7567696E286366672E616A61782C207B0A2020202020202020202020202020202020202020202020207830313A206F702C207830323A20646174612E746F6B656E2C207830333A2064617461';
wwv_flow_imp.g_varchar2_table(365) := '2E6B65792C207830343A20646174612E69642C0A2020202020202020202020202020202020202020202020207830353A20646174612E726573746F7265203F2022524553544F524522203A20646174612E6E616D652C0A20202020202020202020202020';
wwv_flow_imp.g_varchar2_table(366) := '20202020202020202020207830363A20646174612E6F6666736574203F3F20646174612E73697A652C206630313A20646174612E6368756E6B732C206630323A20646174612E76616C7565730A20202020202020202020202020202020202020207D2C20';
wwv_flow_imp.g_varchar2_table(367) := '7B2064617461547970653A20226A736F6E22207D293B0A202020202020202020202020202020207D206361746368202878687229207B0A20202020202020202020202020202020202020202F2F20617065782E7365727665722072656A65637473207769';
wwv_flow_imp.g_varchar2_table(368) := '746820746865206A715848523A207375726661636520746865207365727665722773206D6573736167652E0A2020202020202020202020202020202020202020636F6E7374206A736F6E203D20786872202626207868722E726573706F6E73654A534F4E';
wwv_flow_imp.g_varchar2_table(369) := '3B0A20202020202020202020202020202020202020207468726F77206E6577204572726F7228286A736F6E20262620286A736F6E2E726561736F6E207C7C206A736F6E2E6572726F72207C7C206A736F6E2E6D6573736167652929207C7C0A2020202020';
wwv_flow_imp.g_varchar2_table(370) := '2020202020202020202020202020202020202028786872202626207868722E737461747573203F20224174746163686D656E742072657175657374206661696C65642028485454502022202B207868722E737461747573202B2022292E22203A20224174';
wwv_flow_imp.g_varchar2_table(371) := '746163686D656E742072657175657374206661696C65642E2229293B0A202020202020202020202020202020207D0A2020202020202020202020207D2C0A202020202020202020202020736574546F6B656E286374782C20746F6B656E29207B0A202020';
wwv_flow_imp.g_varchar2_table(372) := '202020202020202020202020206F776E546F6B656E732E736574286374782E6D6F64656C2E6765745265636F72644964286374782E7265636F7264292C20746F6B656E293B0A20202020202020202020202020202020636F6E737420726573756C74203D';
wwv_flow_imp.g_varchar2_table(373) := '206374782E6D6F64656C2E73657456616C7565286374782E7265636F72642C206669656C644F66286374782E6D6F64656C292C20746F6B656E293B0A2020202020202020202020202020202069662028726573756C74203D3D3D20224455502229207468';
wwv_flow_imp.g_varchar2_table(374) := '726F77206E6577204572726F7228224475706C6963617465206174746163686D656E7420746F6B656E2E22293B0A20202020202020202020202020202020696E7075742E76616C7565203D20746F6B656E3B0A2020202020202020202020202020202070';
wwv_flow_imp.g_varchar2_table(375) := '61696E7428293B0A20202020202020202020202020202020617065782E6576656E742E7472696767657228696E7075742C20226368616E676522293B0A2020202020202020202020207D2C0A2020202020202020202020202F2F204E6F7468696E672070';
wwv_flow_imp.g_varchar2_table(376) := '656E64696E6720616E79206D6F72653A2074616B652074686520746F6B656E206F66662074686520726F7720616761696E2C20616E64207768656E206E6F7468696E6720656C73650A2020202020202020202020202F2F206F6E20616E20657869737469';
wwv_flow_imp.g_varchar2_table(377) := '6E6720726F7720776173206368616E6765642C20756E646F2074686520726F77206368616E676520636F6D706C6574656C792E0A202020202020202020202020636C656172546F6B656E2863747829207B0A20202020202020202020202020202020636F';
wwv_flow_imp.g_varchar2_table(378) := '6E7374206669656C64203D206669656C644F66286374782E6D6F64656C293B0A202020202020202020202020202020206F776E546F6B656E732E64656C657465286374782E6D6F64656C2E6765745265636F72644964286374782E7265636F726429293B';
wwv_flow_imp.g_varchar2_table(379) := '0A20202020202020202020202020202020636F6E7374206F726967696E616C203D206374782E6F726967696E616C203D3D206E756C6C207C7C206973546F6B656E286374782E6F726967696E616C29203F202222203A20537472696E67286374782E6F72';
wwv_flow_imp.g_varchar2_table(380) := '6967696E616C293B0A202020202020202020202020202020206374782E6D6F64656C2E73657456616C7565286374782E7265636F72642C206669656C642C206F726967696E616C293B0A20202020202020202020202020202020696E7075742E76616C75';
wwv_flow_imp.g_varchar2_table(381) := '65203D206F726967696E616C3B0A202020202020202020202020202020207061696E7428293B0A20202020202020202020202020202020636F6E7374206D657461203D206374782E6D6F64656C2E6765745265636F72644D65746164617461286374782E';
wwv_flow_imp.g_varchar2_table(382) := '6D6F64656C2E6765745265636F72644964286374782E7265636F72642929207C7C207B7D3B0A20202020202020202020202020202020636F6E7374206F7468657273203D204F626A6563742E6B657973286D6574612E6669656C6473207C7C207B7D292E';
wwv_flow_imp.g_varchar2_table(383) := '736F6D65286E616D65203D3E206E616D6520213D3D206669656C64202626206D6574612E6669656C64735B6E616D655D2E6368616E676564293B0A20202020202020202020202020202020696620286D6574612E7570646174656420262620216D657461';
wwv_flow_imp.g_varchar2_table(384) := '2E696E73657274656420262620216F746865727329206374782E6D6F64656C2E7265766572745265636F726473285B6374782E7265636F72645D293B0A2020202020202020202020207D0A20202020202020207D3B0A2020202020202020636F6E737420';
wwv_flow_imp.g_varchar2_table(385) := '73657373696F6E203D206E65772053657373696F6E286366672C2061646170746572293B0A20202020202020206173796E632066756E6374696F6E20666574636846696C652866696C6529207B0A202020202020202020202020636F6E73742072657370';
wwv_flow_imp.g_varchar2_table(386) := '6F6E7365203D2061776169742066657463682866696C6555726C2866696C65292C207B2063726564656E7469616C733A202273616D652D6F726967696E22207D293B0A2020202020202020202020206966202821726573706F6E73652E6F6B207C7C2028';
wwv_flow_imp.g_varchar2_table(387) := '726573706F6E73652E686561646572732E6765742822636F6E74656E742D747970652229207C7C202222292E696E636C7564657328226170706C69636174696F6E2F6A736F6E222929207B0A202020202020202020202020202020206C65742072656173';
wwv_flow_imp.g_varchar2_table(388) := '6F6E203D2022223B0A20202020202020202020202020202020747279207B20726561736F6E203D2028617761697420726573706F6E73652E6A736F6E2829292E726561736F6E207C7C2022223B207D20636174636820285F29207B202F2A206E6F74204A';
wwv_flow_imp.g_varchar2_table(389) := '534F4E202A2F207D0A202020202020202020202020202020207468726F77206E6577204572726F7228726561736F6E207C7C20225468652066696C6520636F756C64206E6F7420626520646F776E6C6F616465642028485454502022202B20726573706F';
wwv_flow_imp.g_varchar2_table(390) := '6E73652E737461747573202B2022292E22293B0A2020202020202020202020207D0A20202020202020202020202072657475726E20726573706F6E73652E626C6F6228293B0A20202020202020207D0A202020202020202066756E6374696F6E2066696C';
wwv_flow_imp.g_varchar2_table(391) := '6555726C2866696C6529207B0A20202020202020202020202072657475726E20617065782E7365727665722E706C7567696E55726C286366672E616A61782C207B207830313A2022444F574E4C4F4144222C207830323A2073657373696F6E2E746F6B65';
wwv_flow_imp.g_varchar2_table(392) := '6E2C0A202020202020202020202020202020207830333A2073657373696F6E2E636F6E746578742E6B65792C207830343A2066696C652E6964207D293B0A20202020202020207D0A202020202020202061637469766550616E656C203D20637265617465';
wwv_flow_imp.g_varchar2_table(393) := '50616E656C286366672C2073657373696F6E2C207B0A2020202020202020202020206F6E636C6F73652829207B0A20202020202020202020202020202020747279207B2073657373696F6E2E736574746C6528293B207D20636174636820286529207B20';
wwv_flow_imp.g_varchar2_table(394) := '617065782E6D6573736167652E616C65727428652E6D657373616765293B207D0A20202020202020202020202020202020636F6E7374206B6579203D2073657373696F6E2E636F6E746578742026262073657373696F6E2E636F6E746578742E6B65793B';
wwv_flow_imp.g_varchar2_table(395) := '0A20202020202020202020202020202020696620286B657929207B0A20202020202020202020202020202020202020206966202873657373696F6E2E746F6B656E202626202173657373696F6E2E636C61696D6564202626202173657373696F6E2E636F';
wwv_flow_imp.g_varchar2_table(396) := '6E746578742E726561644F6E6C792920656D70747945646974732E736574286B65792C2073657373696F6E2E746F6B656E293B0A2020202020202020202020202020202020202020656C736520656D70747945646974732E64656C657465286B6579293B';
wwv_flow_imp.g_varchar2_table(397) := '0A202020202020202020202020202020207D0A20202020202020202020202020202020696620286C6F636B65645669657729207B206C6F636B6564566965772E76696577242E677269642822756E6C6F636B41637469766522293B206C6F636B65645669';
wwv_flow_imp.g_varchar2_table(398) := '6577203D206E756C6C3B207D0A202020202020202020202020202020202872657475726E466F63757320262620646F63756D656E742E636F6E7461696E732872657475726E466F63757329203F2072657475726E466F637573203A20627574746F6E292E';
wwv_flow_imp.g_varchar2_table(399) := '666F63757328293B0A2020202020202020202020207D2C0A2020202020202020202020206173796E6320646F776E6C6F61642866696C6529207B0A202020202020202020202020202020202F2F2061206C617267652066696C6520676F65732073747261';
wwv_flow_imp.g_varchar2_table(400) := '6967687420746F207468652062726F77736572277320646F776E6C6F6164732028736176656420746F206469736B20617320697420617272697665732C206E6F742068656C6420696E0A202020202020202020202020202020202F2F206D656D6F727929';
wwv_flow_imp.g_varchar2_table(401) := '3B20736D616C6C6572206F6E65732061726520666574636865642066697273742C20736F2061207265667573616C2073686F77732074686520736572766572277320726561736F6E0A20202020202020202020202020202020696620284E756D62657228';
wwv_flow_imp.g_varchar2_table(402) := '66696C652E73697A6529203E204449524543545F444F574E4C4F41445F425954455329207B0A2020202020202020202020202020202020202020636F6E7374206C696E6B203D20656C28226122293B206C696E6B2E68726566203D2066696C6555726C28';
wwv_flow_imp.g_varchar2_table(403) := '66696C65293B206C696E6B2E646F776E6C6F6164203D2066696C652E6E616D653B0A2020202020202020202020202020202020202020646F63756D656E742E626F64792E617070656E64286C696E6B293B206C696E6B2E636C69636B28293B206C696E6B';
wwv_flow_imp.g_varchar2_table(404) := '2E72656D6F766528293B0A202020202020202020202020202020202020202072657475726E3B0A202020202020202020202020202020207D0A20202020202020202020202020202020636F6E737420626C6F62203D20617761697420666574636846696C';
wwv_flow_imp.g_varchar2_table(405) := '652866696C65293B0A20202020202020202020202020202020636F6E73742075726C203D2055524C2E6372656174654F626A65637455524C28626C6F62293B0A20202020202020202020202020202020636F6E737420616E63686F72203D20656C282261';
wwv_flow_imp.g_varchar2_table(406) := '22293B20616E63686F722E68726566203D2075726C3B20616E63686F722E646F776E6C6F6164203D2066696C652E6E616D653B0A20202020202020202020202020202020646F63756D656E742E626F64792E617070656E6428616E63686F72293B20616E';
wwv_flow_imp.g_varchar2_table(407) := '63686F722E636C69636B28293B20616E63686F722E72656D6F766528293B0A2020202020202020202020202020202073657454696D656F7574282829203D3E2055524C2E7265766F6B654F626A65637455524C2875726C292C203630303030293B0A2020';
wwv_flow_imp.g_varchar2_table(408) := '202020202020202020207D2C0A202020202020202020202020707265766965773A20666574636846696C650A20202020202020207D293B0A20202020202020202F2F207265636F72643A2074686520636C69636B656420726F773B20656C736520746865';
wwv_flow_imp.g_varchar2_table(409) := '2061637469766520726F77202845646974206D6F6465290A20202020202020206C65742072657475726E466F637573203D206E756C6C3B0A20202020202020206173796E632066756E6374696F6E206F70656E28636C69636B65642C2066726F6D29207B';
wwv_flow_imp.g_varchar2_table(410) := '0A2020202020202020202020206966202861637469766550616E656C2E6469616C6F672E6F70656E292072657475726E3B0A20202020202020202020202072657475726E466F637573203D2066726F6D207C7C206E756C6C3B0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(411) := '2020636F6E7374206772696456696577203D207669657728292C206D6F64656C203D2067726964566965772E6D6F64656C3B0A202020202020202020202020636F6E7374207265636F7264203D20636C69636B6564207C7C2067726964566965772E7669';
wwv_flow_imp.g_varchar2_table(412) := '6577242E6772696428226765744163746976655265636F726422293B0A20202020202020202020202069662028217265636F726429207B20617065782E6D6573736167652E616C6572742822436C69636B20746865206174746163686D656E7473206275';
wwv_flow_imp.g_varchar2_table(413) := '74746F6E206F66206120726F772E22293B2072657475726E3B207D0A202020202020202020202020636F6E7374206D65746164617461203D206D6F64656C2E6765745265636F72644D65746164617461286D6F64656C2E6765745265636F726449642872';
wwv_flow_imp.g_varchar2_table(414) := '65636F72642929207C7C207B7D3B0A202020202020202020202020636F6E73742069734E6577203D20426F6F6C65616E286D657461646174612E696E736572746564293B0A2020202020202020202020202F2F2074686520726F77206D6179206E6F7420';
wwv_flow_imp.g_varchar2_table(415) := '6265206368616E6765642C206F722041504558206D61646520746869732063656C6C2072656164206F6E6C7920286120636865636B73756D206D61726B7320726561642D6F6E6C792063656C6C73290A202020202020202020202020636F6E7374206365';
wwv_flow_imp.g_varchar2_table(416) := '6C6C4D657461203D20286D657461646174612E6669656C6473207C7C207B7D295B6669656C644F66286D6F64656C295D207C7C207B7D3B0A202020202020202020202020636F6E737420726561644F6E6C79203D2064697361626C6564207C7C20216D6F';
wwv_flow_imp.g_varchar2_table(417) := '64656C2E616C6C6F7745646974287265636F726429207C7C20426F6F6C65616E2863656C6C4D6574612E636B207C7C2063656C6C4D6574612E64697361626C6564293B0A202020202020202020202020636F6E7374206B6579203D2069734E6577203F20';
wwv_flow_imp.g_varchar2_table(418) := '6E756C6C203A20537472696E6728756E77726170286D6F64656C2E67657456616C7565287265636F72642C206B65794F66286D6F64656C292929203F3F202222293B0A202020202020202020202020696620282169734E657720262620216B657929207B';
wwv_flow_imp.g_varchar2_table(419) := '20617065782E6D6573736167652E616C65727428225468697320726F7720686173206E6F207265636F7264206B65792E22293B2072657475726E3B207D0A2020202020202020202020202F2F20696E2045646974206D6F64652074686520616374697665';
wwv_flow_imp.g_varchar2_table(420) := '2063656C6C206D757374206E6F74206D6F7665207768696C65207468652070616E656C206973206F70656E0A2020202020202020202020206966202867726964566965772E76696577242E677269642822696E456469744D6F6465222920262620677269';
wwv_flow_imp.g_varchar2_table(421) := '64566965772E76696577242E6772696428226765744163746976655265636F72642229203D3D3D207265636F726429207B0A2020202020202020202020202020202067726964566965772E76696577242E6772696428226C6F636B41637469766522293B';
wwv_flow_imp.g_varchar2_table(422) := '206C6F636B656456696577203D2067726964566965773B0A2020202020202020202020207D0A202020202020202020202020747279207B0A202020202020202020202020202020202F2F204578747261204669656C642076616C756573206F66206E6577';
wwv_flow_imp.g_varchar2_table(423) := '2066696C65733A2066726F6D206120636F6C756D6E206F662074686520726F77206F7220612070616765206974656D0A20202020202020202020202020202020636F6E73742064656661756C7473203D205B302C20312C20325D2E6D61702869203D3E20';
wwv_flow_imp.g_varchar2_table(424) := '7B0A2020202020202020202020202020202020202020636F6E7374206669656C64203D20286366672E6669656C6473207C7C205B5D292E66696E642878203D3E20782E6E203D3D3D2069202B2031293B0A20202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(425) := '2069662028216669656C64292072657475726E2022223B0A2020202020202020202020202020202020202020696620286669656C642E646B696E64203D3D3D2022434F4C554D4E2229207B20747279207B2072657475726E20537472696E6728756E7772';
wwv_flow_imp.g_varchar2_table(426) := '6170286D6F64656C2E67657456616C7565287265636F72642C206669656C642E6476616C2929203F3F202222293B207D20636174636820285F29207B2072657475726E2022223B207D207D0A202020202020202020202020202020202020202069662028';
wwv_flow_imp.g_varchar2_table(427) := '6669656C642E646B696E64203D3D3D20224954454D22292072657475726E20617065782E6974656D286669656C642E6476616C292E67657456616C75652829207C7C2022223B0A202020202020202020202020202020202020202072657475726E202222';
wwv_flow_imp.g_varchar2_table(428) := '3B0A202020202020202020202020202020207D293B0A20202020202020202020202020202020636F6E73742063757272656E74203D20756E77726170286D6F64656C2E67657456616C7565287265636F72642C206669656C644F66286D6F64656C292929';
wwv_flow_imp.g_varchar2_table(429) := '3B0A2020202020202020202020202020202061776169742061637469766550616E656C2E6F70656E287B0A20202020202020202020202020202020202020206B65792C20746F6B656E3A206973546F6B656E2863757272656E7429203F2063757272656E';
wwv_flow_imp.g_varchar2_table(430) := '74203A2022222C206F726967696E616C3A2063757272656E742C0A202020202020202020202020202020202020202072657573653A20216973546F6B656E2863757272656E7429202626206B6579203F20656D70747945646974732E676574286B657929';
wwv_flow_imp.g_varchar2_table(431) := '207C7C202222203A2022222C0A20202020202020202020202020202020202020207265636F72642C206D6F64656C2C20726561644F6E6C792C2064656661756C74732C0A20202020202020202020202020202020202020206C6162656C3A2069734E6577';
wwv_flow_imp.g_varchar2_table(432) := '203F20224E657720726F77202D207468652066696C657320617265206C696E6B656420746F206974207768656E20796F7520736176652074686520677269642E22203A2022220A202020202020202020202020202020207D293B0A202020202020202020';
wwv_flow_imp.g_varchar2_table(433) := '2020207D206361746368202865727229207B0A20202020202020202020202020202020696620286C6F636B65645669657729207B206C6F636B6564566965772E76696577242E677269642822756E6C6F636B41637469766522293B206C6F636B65645669';
wwv_flow_imp.g_varchar2_table(434) := '6577203D206E756C6C3B207D0A202020202020202020202020202020207468726F77206572723B0A2020202020202020202020207D0A20202020202020207D0A2020202020202020627574746F6E2E6F6E636C69636B203D202829203D3E207B206F7065';
wwv_flow_imp.g_varchar2_table(435) := '6E28292E63617463682865203D3E20617065782E6D6573736167652E616C65727428652E6D65737361676529293B207D3B0A2020202020202020617065782E6974656D2E637265617465286366672E6974656D2C207B0A20202020202020202020202069';
wwv_flow_imp.g_varchar2_table(436) := '74656D5F747970653A202249475F4154544143484D454E5453222C0A2020202020202020202020202F2F205468652067726964207772697465732074686520656469746F7227732076616C756520696E746F207468652061637469766520726F77207768';
wwv_flow_imp.g_varchar2_table(437) := '656E65766572206974206C6561766573207468652063656C6C2E20416E20656469740A2020202020202020202020202F2F20746F6B656E20696E2074686520656469746F722074686174206973206E6F74207468652061637469766520726F7727732076';
wwv_flow_imp.g_varchar2_table(438) := '616C7565206973207374616C65202D2074686520726F7720776173207361766564206D65616E7768696C650A2020202020202020202020202F2F2028697420686F6C6473206974732066696C6520636F756E74206E6F7729206F72207468652070616E65';
wwv_flow_imp.g_varchar2_table(439) := '6C206F6620616E6F7468657220726F7720736574206974202D20736F2074686520726F772773206F776E2076616C75652069730A2020202020202020202020202F2F207265706F727465643A2077726974696E67206974206261636B206368616E676573';
wwv_flow_imp.g_varchar2_table(440) := '206E6F7468696E672E20416E79206F746865722076616C75652069732074686520656469746F722773206F776E2C206173207365742E0A20202020202020202020202067657456616C75652829207B0A2020202020202020202020202020202069662028';
wwv_flow_imp.g_varchar2_table(441) := '6973546F6B656E28696E7075742E76616C75652929207B0A2020202020202020202020202020202020202020747279207B0A202020202020202020202020202020202020202020202020636F6E7374206772696456696577203D207669657728292C2072';
wwv_flow_imp.g_varchar2_table(442) := '65636F7264203D2067726964566965772E76696577242E6772696428226765744163746976655265636F726422293B0A202020202020202020202020202020202020202020202020696620287265636F726429207B0A2020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(443) := '2020202020202020202020202020636F6E73742076616C7565203D20756E777261702867726964566965772E6D6F64656C2E67657456616C7565287265636F72642C206669656C644F662867726964566965772E6D6F64656C2929293B0A202020202020';
wwv_flow_imp.g_varchar2_table(444) := '20202020202020202020202020202020202020202020636F6E73742074657874203D2076616C7565203D3D206E756C6C203F202222203A20537472696E672876616C7565293B0A2020202020202020202020202020202020202020202020202020202069';
wwv_flow_imp.g_varchar2_table(445) := '6620287465787420213D3D20696E7075742E76616C756529207B20696E7075742E76616C7565203D20746578743B207061696E7428293B207D0A2020202020202020202020202020202020202020202020207D0A20202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(446) := '202020207D20636174636820285F29207B202F2A207468652067726964206973206E6F7420746865726520796574202A2F207D0A202020202020202020202020202020207D0A2020202020202020202020202020202072657475726E20696E7075742E76';
wwv_flow_imp.g_varchar2_table(447) := '616C75653B0A2020202020202020202020207D2C0A20202020202020202020202073657456616C75652876616C756529207B20696E7075742E76616C7565203D20756E777261702876616C756529207C7C2022223B207061696E7428293B207D2C0A2020';
wwv_flow_imp.g_varchar2_table(448) := '20202020202020202020646973706C617956616C7565466F722876616C756529207B2072657475726E2063656C6C48746D6C286366672C20756E777261702876616C7565292C20657363293B207D2C0A202020202020202020202020676574506F707570';
wwv_flow_imp.g_varchar2_table(449) := '53656C6563746F722829207B2072657475726E20222322202B2061637469766550616E656C2E6469616C6F672E69643B207D2C0A202020202020202020202020736574466F6375732829207B20627574746F6E2E666F63757328293B207D2C0A20202020';
wwv_flow_imp.g_varchar2_table(450) := '202020202020202064697361626C652829207B2064697361626C6564203D20747275653B207D2C0A202020202020202020202020656E61626C652829207B2064697361626C6564203D2066616C73653B207D2C0A20202020202020202020202069734469';
wwv_flow_imp.g_varchar2_table(451) := '7361626C65642829207B2072657475726E2064697361626C65643B207D2C0A2020202020202020202020202F2F20416C776179732076616C69643A2074686520677269642076616C696461746573206F6E206368616E67652C2077686963682068617070';
wwv_flow_imp.g_varchar2_table(452) := '656E73207768696C65204F50454E206973207374696C6C2072756E6E696E672C0A2020202020202020202020202F2F20616E6420612063656C6C206572726F7220776F756C64207374617920616E6420626C6F636B20536176652E204275737920736176';
wwv_flow_imp.g_varchar2_table(453) := '6573206172652073746F707065642062792074686520736176652067756172642C0A2020202020202020202020202F2F20616E642066696E616C697A655F656469742072656A6563747320696E636F6D706C6574652075706C6F6164732E0A2020202020';
wwv_flow_imp.g_varchar2_table(454) := '2020202020202067657456616C69646974792829207B2072657475726E207B2076616C69643A2074727565207D3B207D2C0A20202020202020202020202067657456616C69646174696F6E4D6573736167652829207B2072657475726E2022223B207D0A';
wwv_flow_imp.g_varchar2_table(455) := '20202020202020207D293B0A20202020202020207061696E7428293B0A20202020202020202F2F20666F7220646576656C6F70657273206F6E6C792028417070204275696C6465722073657373696F6E293A207468652067726964277320726F77207072';
wwv_flow_imp.g_varchar2_table(456) := '6F63657373696E6720646F6573206E6F742073617665207468652066696C65730A2020202020202020696620286366672E73657475705761726E696E6729207B0A202020202020202020202020636F6E73742074657874203D2022494720417474616368';
wwv_flow_imp.g_varchar2_table(457) := '6D656E7473202822202B206366672E6974656D202B2022293A2022202B206366672E73657475705761726E696E673B0A20202020202020202020202069662028747970656F6620636F6E736F6C6520213D3D2022756E646566696E6564222920636F6E73';
wwv_flow_imp.g_varchar2_table(458) := '6F6C652E7761726E2874657874293B0A202020202020202020202020747279207B20617065782E6D6573736167652E73686F774572726F7273285B7B20747970653A20226572726F72222C206C6F636174696F6E3A202270616765222C206D6573736167';
wwv_flow_imp.g_varchar2_table(459) := '653A20746578742C20756E736166653A2066616C7365207D5D293B207D20636174636820285F29207B202F2A20636F6E736F6C65206F6E6C79202A2F207D0A20202020202020207D0A2020202020202020636F6E737420737562736372697074696F6E73';
wwv_flow_imp.g_varchar2_table(460) := '203D206E6577204D617028293B0A202020202020202066756E6374696F6E207761746368286D6F64656C29207B0A20202020202020202020202069662028737562736372697074696F6E732E686173286D6F64656C29292072657475726E3B0A20202020';
wwv_flow_imp.g_varchar2_table(461) := '2020202020202020636F6E7374206964203D206D6F64656C2E737562736372696265287B0A202020202020202020202020202020206F6E4368616E676528747970652C206368616E676529207B0A20202020202020202020202020202020202020206966';
wwv_flow_imp.g_varchar2_table(462) := '202874797065203D3D3D2022636F7079222920286368616E67652E7265636F726473207C7C205B5D292E666F7245616368287265636F7264203D3E206D6F64656C2E73657456616C7565287265636F72642C206669656C644F66286D6F64656C292C2022';
wwv_flow_imp.g_varchar2_table(463) := '2229293B0A20202020202020202020202020202020202020202F2F206120726F7720726576657274656420696E2074686520677269643A2069747320756E7361766564206174746163686D656E74206368616E67657320676F206F6E2074686520736572';
wwv_flow_imp.g_varchar2_table(464) := '766572206174206F6E63650A20202020202020202020202020202020202020202F2F20287468657920776F756C6420686F6C64207468652073746167696E67206C696D69747320756E74696C207468657920657870697265292E205468652070616E656C';
wwv_flow_imp.g_varchar2_table(465) := '2773206F776E20726576657274207768656E0A20202020202020202020202020202020202020202F2F206E6F7468696E672069732070656E64696E672028636C656172546F6B656E29206861732074616B656E2069747320746F6B656E206F6666206669';
wwv_flow_imp.g_varchar2_table(466) := '72737420616E64206973206E6F742061666665637465642E0A20202020202020202020202020202020202020206966202874797065203D3D3D2022726576657274222920286368616E67652E7265636F726473207C7C205B5D292E666F72456163682872';
wwv_flow_imp.g_varchar2_table(467) := '65636F7264203D3E207B0A202020202020202020202020202020202020202020202020636F6E7374206964203D206D6F64656C2E6765745265636F72644964287265636F7264292C20746F6B656E203D206F776E546F6B656E732E676574286964293B0A';
wwv_flow_imp.g_varchar2_table(468) := '2020202020202020202020202020202020202020202020206966202821746F6B656E292072657475726E3B0A2020202020202020202020202020202020202020202020206F776E546F6B656E732E64656C657465286964293B0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(469) := '2020202020202020202020202020636F6E7374206D657461203D206D6F64656C2E6765745265636F72644D6574616461746128696429207C7C207B7D3B0A2020202020202020202020202020202020202020202020206C6574206B6579203D206E756C6C';
wwv_flow_imp.g_varchar2_table(470) := '3B0A202020202020202020202020202020202020202020202020747279207B206B6579203D206D6574612E696E736572746564203F206E756C6C203A20537472696E6728756E77726170286D6F64656C2E67657456616C7565287265636F72642C206B65';
wwv_flow_imp.g_varchar2_table(471) := '794F66286D6F64656C292929203F3F20222229207C7C206E756C6C3B207D20636174636820285F29207B2072657475726E3B207D0A202020202020202020202020202020202020202020202020616461707465722E726571756573742822444953434152';
wwv_flow_imp.g_varchar2_table(472) := '44222C207B20746F6B656E2C206B6579207D292E6361746368282829203D3E207B202F2A206974206578706972657320616E79776179202A2F207D293B0A20202020202020202020202020202020202020207D293B0A2020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(473) := '2020202020202F2F206120746F6B656E20706173746564206F722066696C6C656420696E746F207468697320636F6C756D6E20286E6F74206F6E65207468697320636F6C756D6E207075742074686572652920697320756E646F6E650A20202020202020';
wwv_flow_imp.g_varchar2_table(474) := '202020202020202020202020206966202874797065203D3D3D202273657422202626206368616E6765202626206368616E67652E7265636F7264202626206368616E67652E6669656C64203D3D3D206669656C644F66286D6F64656C2929207B0A202020';
wwv_flow_imp.g_varchar2_table(475) := '202020202020202020202020202020202020202020636F6E73742076616C7565203D20756E77726170286D6F64656C2E67657456616C7565286368616E67652E7265636F72642C206368616E67652E6669656C6429293B0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(476) := '202020202020202020202020636F6E7374206F776E203D206F776E546F6B656E732E676574286D6F64656C2E6765745265636F72644964286368616E67652E7265636F726429293B0A202020202020202020202020202020202020202020202020696620';
wwv_flow_imp.g_varchar2_table(477) := '286973546F6B656E2876616C7565292026262076616C756520213D3D206F776E29207B0A20202020202020202020202020202020202020202020202020202020636F6E7374206F6C64203D20756E77726170286368616E67652E6F6C6456616C7565293B';
wwv_flow_imp.g_varchar2_table(478) := '0A202020202020202020202020202020202020202020202020202020206D6F64656C2E73657456616C7565286368616E67652E7265636F72642C206368616E67652E6669656C642C20216973546F6B656E286F6C6429207C7C206F6C64203D3D3D206F77';
wwv_flow_imp.g_varchar2_table(479) := '6E203F20537472696E67286F6C64203F3F20222229203A202222293B0A2020202020202020202020202020202020202020202020207D0A20202020202020202020202020202020202020207D0A2020202020202020202020202020202020202020696620';
wwv_flow_imp.g_varchar2_table(480) := '2874797065203D3D3D202264657374726F79222920737562736372697074696F6E732E64656C657465286D6F64656C293B0A202020202020202020202020202020207D0A2020202020202020202020207D293B0A20202020202020202020202073756273';
wwv_flow_imp.g_varchar2_table(481) := '6372697074696F6E732E736574286D6F64656C2C206964293B0A20202020202020207D0A20202020202020202F2F205468697320636F6C756D6E2072656E6465727320697473206F776E206D61726B757020287365652063656C6C48746D6C293A207475';
wwv_flow_imp.g_varchar2_table(482) := '726E2074686520677269642773206573636170696E67206F666620666F72206974206F6E6C792E0A202020202020202066756E6374696F6E20756E657363617065436F6C756D6E2829207B0A2020202020202020202020206C6574206772696456696577';
wwv_flow_imp.g_varchar2_table(483) := '3B0A202020202020202020202020747279207B206772696456696577203D207669657728293B207D20636174636820285F29207B2072657475726E3B207D0A202020202020202020202020636F6E737420636F6C756D6E203D202867726964566965772E';
wwv_flow_imp.g_varchar2_table(484) := '76696577242E677269642822676574436F6C756D6E732229207C7C205B5D292E66696E642863203D3E20632E656C656D656E744964203D3D3D206366672E6974656D207C7C20632E70726F7065727479203D3D3D206669656C644F662867726964566965';
wwv_flow_imp.g_varchar2_table(485) := '772E6D6F64656C29293B0A20202020202020202020202069662028636F6C756D6E20262620636F6C756D6E2E65736361706520213D3D2066616C736529207B0A20202020202020202020202020202020636F6C756D6E2E657363617065203D2066616C73';
wwv_flow_imp.g_varchar2_table(486) := '653B0A20202020202020202020202020202020747279207B2067726964566965772E76696577242E67726964282272656672657368436F6C756D6E7322293B207D20636174636820285F29207B202F2A206F6C64657220677269643A2072656672657368';
wwv_flow_imp.g_varchar2_table(487) := '20697320656E6F756768202A2F207D0A2020202020202020202020202020202067726964566965772E76696577242E6772696428227265667265736822293B0A2020202020202020202020207D0A20202020202020207D0A202020202020202074727920';
wwv_flow_imp.g_varchar2_table(488) := '7B207761746368287669657728292E6D6F64656C293B20756E657363617065436F6C756D6E28293B207D20636174636820285F29207B202F2A2047726964206D617920696E697469616C697A652061667465722074686520636F6C756D6E20656469746F';
wwv_flow_imp.g_varchar2_table(489) := '722E202A2F207D0A2020202020202020636F6E737420646F6324203D202428646F63756D656E74293B0A2020202020202020636F6E7374206E616D657370616365203D20222E6967615F22202B206366672E6974656D2E7265706C616365282F5B5E612D';
wwv_flow_imp.g_varchar2_table(490) := '7A412D5A302D395D2F672C20225F22293B0A2020202020202020646F63242E6F6666286E616D657370616365292E6F6E2822696E74657261637469766567726964766965776D6F64656C63726561746522202B206E616D6573706163652C20286576656E';
wwv_flow_imp.g_varchar2_table(491) := '742C206461746129203D3E207B0A20202020202020202020202069662028216D696E65286576656E742E74617267657429292072657475726E3B0A202020202020202020202020776174636828646174612E6D6F64656C293B2067756172645361766528';
wwv_flow_imp.g_varchar2_table(492) := '293B2073657454696D656F757428756E657363617065436F6C756D6E293B0A20202020202020207D293B0A20202020202020202F2F2054686520627574746F6E20696E20612063656C6C206F70656E73207468652070616E656C20666F72207468617420';
wwv_flow_imp.g_varchar2_table(493) := '726F7720287468652067726964206D616B65732069747320726F7720616374697665206F6E206D6F757365646F776E292E0A2020202020202020646F63242E6F6E2822636C69636B22202B206E616D6573706163652C20222E6967612D63656C6C222C20';
wwv_flow_imp.g_varchar2_table(494) := '6576656E74203D3E207B0A20202020202020202020202069662028627574746F6E2E636F6E7461696E73286576656E742E74617267657429207C7C2061637469766550616E656C2E6469616C6F672E6F70656E292072657475726E3B0A20202020202020';
wwv_flow_imp.g_varchar2_table(495) := '20202020202F2F20616E6F74686572206174746163686D656E7420636F6C756D6E206F66207468652073616D6520677269642068616E646C657320697473206F776E2063656C6C730A202020202020202020202020696620286576656E742E7461726765';
wwv_flow_imp.g_varchar2_table(496) := '742E636C6F7365737428222E6967612D63656C6C22293F2E6765744174747269627574652822646174612D6967612D6974656D222920213D3D206366672E6974656D292072657475726E3B0A2020202020202020202020206C6574206772696456696577';
wwv_flow_imp.g_varchar2_table(497) := '3B0A202020202020202020202020747279207B206772696456696577203D207669657728293B207D20636174636820285F29207B2072657475726E3B207D0A202020202020202020202020696620282167726964566965772E76696577245B305D2E636F';
wwv_flow_imp.g_varchar2_table(498) := '6E7461696E73286576656E742E74617267657429292072657475726E3B0A202020202020202020202020636F6E737420726F77203D206576656E742E7461726765742E636C6F736573742822747222293B0A2020202020202020202020202F2F20612067';
wwv_flow_imp.g_varchar2_table(499) := '72696420726F77206361727269657320697473207265636F726420696420696E20646174612D69640A202020202020202020202020636F6E7374207265636F7264203D20726F7720262620726F772E6861734174747269627574652822646174612D6964';
wwv_flow_imp.g_varchar2_table(500) := '2229203F2067726964566965772E6D6F64656C2E6765745265636F726428726F772E6765744174747269627574652822646174612D6964222929203A206E756C6C3B0A202020202020202020202020636F6E73742063656C6C203D206576656E742E7461';
wwv_flow_imp.g_varchar2_table(501) := '726765742E636C6F736573742822746422293B0A20202020202020202020202073657454696D656F7574282829203D3E206F70656E287265636F72642C20627574746F6E2E636C6F73657374282274642229203D3D3D2063656C6C203F206E756C6C203A';
wwv_flow_imp.g_varchar2_table(502) := '2063656C6C292E63617463682865203D3E20617065782E6D6573736167652E616C65727428652E6D6573736167652929293B0A20202020202020207D293B0A20202020202020202F2F204D6F64656C2066696E616C697A6174696F6E20616C736F207265';
wwv_flow_imp.g_varchar2_table(503) := '6A6563747320696E636F6D706C6574652075706C6F6164733A206120646972656374206D6F64656C2E736176652063616E6E6F74206279706173732069742E0A20202020202020202F2F2054686520677269642773205361766520616374696F6E206973';
wwv_flow_imp.g_varchar2_table(504) := '2077726170706564206F6E63653B206576657279206174746163686D656E7420636F6C756D6E206F6620746865206772696420616464732069747320636865636B2E0A2020202020202020636F6E737420697342757379203D202829203D3E2073657373';
wwv_flow_imp.g_varchar2_table(505) := '696F6E2E62757379207C7C2061637469766550616E656C2E6469616C6F672E6F70656E3B0A20202020202020202F2F205468697320636F6C756D6E27732063656C6C207374696C6C206265696E6720656469746564207768656E20746865206772696420';
wwv_flow_imp.g_varchar2_table(506) := '73617665733A2065646974206D6F6465206973206C6566742066697273742C207768696C65207468650A20202020202020202F2F2063656C6C2063616E207374696C6C206265207772697474656E2E204120736176652063616E206D616B652074686520';
wwv_flow_imp.g_varchar2_table(507) := '63656C6C2072656164206F6E6C792028612052656164204F6E6C7920636F6E646974696F6E20666F7220656163680A20202020202020202F2F20726F772C20652E672E2073617665642061732061204675656C20636C61696D293B206C656176696E6720';
wwv_flow_imp.g_varchar2_table(508) := '69742061667465727761726473206661696C7320696E2074686520677269642028225365742076616C7565206E6F7420616C6C6F7765640A20202020202020202F2F20666F72206669656C6422202D207468652067726964207772697465732061206365';
wwv_flow_imp.g_varchar2_table(509) := '6C6C206261636B207768656E65766572206974206C6561766573206974292E0A202020202020202066756E6374696F6E206C6561766541637469766543656C6C2829207B0A202020202020202020202020747279207B0A20202020202020202020202020';
wwv_flow_imp.g_varchar2_table(510) := '202020636F6E7374206772696456696577203D207669657728293B0A20202020202020202020202020202020696620282167726964566965772E76696577242E677269642822696E456469744D6F64652229292072657475726E3B0A2020202020202020';
wwv_flow_imp.g_varchar2_table(511) := '2020202020202020636F6E73742063656C6C24203D2067726964566965772E76696577242E67726964282267657441637469766543656C6C46726F6D436F6C756D6E4974656D222C20696E707574293B0A20202020202020202020202020202020696620';
wwv_flow_imp.g_varchar2_table(512) := '2863656C6C242026262063656C6C242E686173436C6173732026262063656C6C242E686173436C617373282269732D6163746976652229292067726964566965772E76696577242E677269642822736574456469744D6F6465222C2066616C7365293B0A';
wwv_flow_imp.g_varchar2_table(513) := '2020202020202020202020207D20636174636820285F29207B202F2A206E6F7468696E6720746F206C65617665202A2F207D0A20202020202020207D0A2020202020202020636F6E7374206D79477561726473203D206E65772053657428293B0A202020';
wwv_flow_imp.g_varchar2_table(514) := '202020202066756E6374696F6E206775617264536176652829207B0A2020202020202020202020206C657420616374696F6E733B0A202020202020202020202020747279207B20616374696F6E73203D20726567696F6E28292E63616C6C282267657441';
wwv_flow_imp.g_varchar2_table(515) := '6374696F6E7322293B207D20636174636820285F29207B2072657475726E3B207D0A202020202020202020202020636F6E737420616374696F6E203D20616374696F6E732E6C6F6F6B757028227361766522293B0A202020202020202020202020696620';
wwv_flow_imp.g_varchar2_table(516) := '2821616374696F6E292072657475726E3B0A2020202020202020202020206C6574206775617264203D20736176654775617264732E67657428616374696F6E73293B0A20202020202020202020202069662028216775617264207C7C20616374696F6E2E';
wwv_flow_imp.g_varchar2_table(517) := '616374696F6E20213D3D2067756172642E6775617264656429207B0A20202020202020202020202020202020636F6E7374206F726967696E616C203D20616374696F6E2E616374696F6E3B0A202020202020202020202020202020206966202874797065';
wwv_flow_imp.g_varchar2_table(518) := '6F66206F726967696E616C20213D3D202266756E6374696F6E22292072657475726E3B0A20202020202020202020202020202020636F6E737420636865636B73203D206E65772053657428292C206C6561766573203D206E65772053657428293B0A2020';
wwv_flow_imp.g_varchar2_table(519) := '2020202020202020202020202020636F6E73742067756172646564203D2066756E6374696F6E20282E2E2E6172677329207B0A2020202020202020202020202020202020202020666F722028636F6E73742062757379206F6620636865636B7329207B0A';
wwv_flow_imp.g_varchar2_table(520) := '2020202020202020202020202020202020202020202020206966202862757379282929207B20617065782E6D6573736167652E616C6572742822436C6F736520746865206174746163686D656E742070616E656C206265666F726520736176696E672074';
wwv_flow_imp.g_varchar2_table(521) := '686520677269642E22293B2072657475726E3B207D0A20202020202020202020202020202020202020207D0A2020202020202020202020202020202020202020666F722028636F6E7374206C65617665206F66206C656176657329206C6561766528293B';
wwv_flow_imp.g_varchar2_table(522) := '0A202020202020202020202020202020202020202072657475726E206F726967696E616C2E6170706C7928746869732C2061726773293B0A202020202020202020202020202020207D3B0A202020202020202020202020202020206775617264203D207B';
wwv_flow_imp.g_varchar2_table(523) := '206F726967696E616C2C20677561726465642C20636865636B732C206C6561766573207D3B0A20202020202020202020202020202020736176654775617264732E73657428616374696F6E732C206775617264293B20616374696F6E2E616374696F6E20';
wwv_flow_imp.g_varchar2_table(524) := '3D20677561726465643B0A2020202020202020202020207D0A20202020202020202020202067756172642E636865636B732E61646428697342757379293B2067756172642E6C65617665732E616464286C6561766541637469766543656C6C293B206D79';
wwv_flow_imp.g_varchar2_table(525) := '4775617264732E61646428616374696F6E73293B0A20202020202020207D0A202020202020202067756172645361766528293B0A2020202020202020646F63242E6F6E2822696E74657261637469766567726964766965776368616E676522202B206E61';
wwv_flow_imp.g_varchar2_table(526) := '6D6573706163652C206576656E74203D3E207B20696620286D696E65286576656E742E7461726765742929207B2067756172645361766528293B2073657454696D656F757428756E657363617065436F6C756D6E293B207D207D293B0A20202020202020';
wwv_flow_imp.g_varchar2_table(527) := '20636F6E7374207375626D6974203D206576656E74203D3E207B0A2020202020202020202020206966202873657373696F6E2E62757379207C7C2061637469766550616E656C2E6469616C6F672E6F70656E29207B0A2020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(528) := '20206576656E742E70726576656E7444656661756C7428293B20617065782E6576656E742E6743616E63656C466C6167203D20747275653B0A20202020202020202020202020202020617065782E6D6573736167652E616C6572742822436C6F73652074';
wwv_flow_imp.g_varchar2_table(529) := '6865206174746163686D656E742070616E656C206265666F7265207375626D697474696E672E22293B0A2020202020202020202020207D0A20202020202020207D3B0A2020202020202020646F63242E6F6E2822617065786265666F7265706167657375';
wwv_flow_imp.g_varchar2_table(530) := '626D697422202B206E616D6573706163652C207375626D6974293B0A2020202020202020636F6E737420696E7374616E6365203D207B0A2020202020202020202020206F70656E2C0A2020202020202020202020206973427573792C0A20202020202020';
wwv_flow_imp.g_varchar2_table(531) := '202020202064657374726F792829207B0A20202020202020202020202020202020696620286C6F636B65645669657729206C6F636B6564566965772E76696577242E677269642822756E6C6F636B41637469766522293B0A202020202020202020202020';
wwv_flow_imp.g_varchar2_table(532) := '20202020666F722028636F6E7374205B6D6F64656C2C2069645D206F6620737562736372697074696F6E7329206D6F64656C2E756E537562736372696265286964293B0A20202020202020202020202020202020666F722028636F6E737420616374696F';
wwv_flow_imp.g_varchar2_table(533) := '6E73206F66206D7947756172647329207B0A2020202020202020202020202020202020202020636F6E7374206775617264203D20736176654775617264732E67657428616374696F6E73293B0A2020202020202020202020202020202020202020696620';
wwv_flow_imp.g_varchar2_table(534) := '282167756172642920636F6E74696E75653B0A202020202020202020202020202020202020202067756172642E636865636B732E64656C65746528697342757379293B2067756172642E6C65617665732E64656C657465286C6561766541637469766543';
wwv_flow_imp.g_varchar2_table(535) := '656C6C293B0A2020202020202020202020202020202020202020696620282167756172642E636865636B732E73697A6529207B0A20202020202020202020202020202020202020202020202069662028616374696F6E732E6C6F6F6B7570282273617665';
wwv_flow_imp.g_varchar2_table(536) := '22293F2E616374696F6E203D3D3D2067756172642E677561726465642920616374696F6E732E6C6F6F6B757028227361766522292E616374696F6E203D2067756172642E6F726967696E616C3B0A20202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(537) := '2020736176654775617264732E64656C65746528616374696F6E73293B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D0A20202020202020202020202020202020646F63242E6F6666286E616D6573';
wwv_flow_imp.g_varchar2_table(538) := '70616365293B0A2020202020202020202020202020202061637469766550616E656C2E64657374726F7928293B20627574746F6E2E6F6E636C69636B203D206E756C6C3B0A20202020202020202020202020202020636F6E737420616C696173203D2061';
wwv_flow_imp.g_varchar2_table(539) := '6C69617365732E67657428696E7374616E6365293B0A2020202020202020202020202020202069662028616C69617320262620696E7374616E6365732E67657428616C69617329203D3D3D20696E7374616E63652920696E7374616E6365732E64656C65';
wwv_flow_imp.g_varchar2_table(540) := '746528616C696173293B0A20202020202020202020202020202020616C69617365732E64656C65746528696E7374616E6365293B0A2020202020202020202020207D0A20202020202020207D3B0A2020202020202020696E7374616E6365732E73657428';
wwv_flow_imp.g_varchar2_table(541) := '6366672E6974656D2C20696E7374616E6365293B0A20202020202020202F2F20616C736F2062792074686520636F6C756D6E2773206E616D6520286120636F6C756D6E20776974686F7574206120537461746963204944206861732074686520444F4D20';
wwv_flow_imp.g_varchar2_table(542) := '696420433C636F6C756D6E2069643E290A2020202020202020696620286366672E636F6C756D6E202626206366672E636F6C756D6E20213D3D206366672E6974656D2026262021696E7374616E6365732E686173286366672E636F6C756D6E2929207B0A';
wwv_flow_imp.g_varchar2_table(543) := '202020202020202020202020696E7374616E6365732E736574286366672E636F6C756D6E2C20696E7374616E6365293B0A202020202020202020202020616C69617365732E73657428696E7374616E63652C206366672E636F6C756D6E293B0A20202020';
wwv_flow_imp.g_varchar2_table(544) := '202020207D0A202020202020202072657475726E20696E7374616E63653B0A202020207D0A2020202066756E6374696F6E20726F6F74417065782829207B2072657475726E20747970656F66206170657820213D3D2022756E646566696E656422203F20';
wwv_flow_imp.g_varchar2_table(545) := '61706578203A206E756C6C3B207D0A2020202072657475726E207B20696E69742C206765743A206964203D3E20696E7374616E6365732E676574286964292C2053657373696F6E2C2063726561746550616E656C2C2076616C696461746546696C652C20';
wwv_flow_imp.g_varchar2_table(546) := '62797465732C20756E777261702C20746F426173653634207D3B0A7D29293B0A0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(13045826843558757)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_file_name=>'js/igAttachments.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2866756E6374696F6E28502C5A297B2275736520737472696374223B636F6E737420553D5A28293B747970656F66206D6F64756C653D3D226F626A6563742226266D6F64756C652E6578706F7274733F6D6F64756C652E6578706F7274733D553A502E69';
wwv_flow_imp.g_varchar2_table(2) := '67614174746163686D656E74733D557D2928747970656F6620676C6F62616C546869733C2275223F676C6F62616C546869733A746869732C66756E6374696F6E28297B2275736520737472696374223B636F6E737420503D6E6577204D61702C5A3D6E65';
wwv_flow_imp.g_varchar2_table(3) := '77204D61702C553D6E6577204D61702C563D6E3D3E6E2626747970656F66206E3D3D226F626A656374222626227622696E206E3F6E2E763A6E3B66756E6374696F6E2024286E297B636F6E737420653D693D3E537472696E67284D6174682E726F756E64';
wwv_flow_imp.g_varchar2_table(4) := '28692A3130292F3130293B72657475726E206E3C313032343F6E2B222042223A6E3C313034383537363F65286E2F31303234292B22204B42223A65286E2F31303438353736292B22204D42227D66756E6374696F6E206F65286E2C65297B636F6E737420';
wwv_flow_imp.g_varchar2_table(5) := '693D6E2E6E616D652E696E636C7564657328222E22293F6E2E6E616D652E73706C697428222E22292E706F7028292E746F4C6F7765724361736528293A22223B69662821652E6163636570742E73706C697428222C22292E6D6170286C3D3E6C2E747269';
wwv_flow_imp.g_varchar2_table(6) := '6D28292E7265706C616365282F5E5C2E2F2C2222292E746F4C6F776572436173652829292E696E636C75646573286929297468726F77206E6577204572726F72286E2E6E616D652B223A20746869732066696C652074797065206973206E6F7420616C6C';
wwv_flow_imp.g_varchar2_table(7) := '6F7765642E22293B696628216E2E73697A65297468726F77206E6577204572726F72286E2E6E616D652B2220697320656D7074792E22293B6966286E2E73697A653E652E6D61784279746573297468726F77206E6577204572726F72286E2E6E616D652B';
wwv_flow_imp.g_varchar2_table(8) := '222028222B24286E2E73697A65292B2229206973206C6172676572207468616E2074686520222B2428652E6D61784279746573292B22206C696D69742E22297D66756E6374696F6E206165286E297B6C657420653D22223B72657475726E206E65772055';
wwv_flow_imp.g_varchar2_table(9) := '696E74384172726179286E292E666F724561636828693D3E7B652B3D537472696E672E66726F6D43686172436F64652869297D292C62746F612865297D636F6E7374206C653D3139363630382C70653D32363231343430302C67653D2F5E5B412D46302D';
wwv_flow_imp.g_varchar2_table(10) := '395D7B33327D242F2C6A3D6E3D3E67652E74657374286E3D3D6E756C6C3F22223A537472696E67286E29293B636C6173732063657B636F6E7374727563746F7228652C69297B746869732E6366673D652C746869732E616461707465723D692C74686973';
wwv_flow_imp.g_varchar2_table(11) := '2E746F6B656E3D22222C746869732E66696C65733D5B5D2C746869732E627573793D21312C746869732E636F6E746578743D6E756C6C2C746869732E72656164793D21312C746869732E70726F67726573733D6E756C6C2C746869732E6F6E6368616E67';
wwv_flow_imp.g_varchar2_table(12) := '653D28293D3E7B7D2C746869732E636C61696D65643D21312C746869732E6472616674733D6E6577204D61702C746869732E6669656C6451756575653D50726F6D6973652E7265736F6C766528297D736574746C6528297B636F6E737420653D74686973';
wwv_flow_imp.g_varchar2_table(13) := '2E66696C65732E736F6D6528693D3E692E7374616765643F21692E72656D6F7665643A692E72656D6F7665647C7C692E6368616E676564293B65262621746869732E636C61696D65642626746869732E746F6B656E3F28746869732E616461707465722E';
wwv_flow_imp.g_varchar2_table(14) := '736574546F6B656E28746869732E636F6E746578742C746869732E746F6B656E292C746869732E636C61696D65643D2130293A21652626746869732E636C61696D65642626746869732E616461707465722E636C656172546F6B656E262628746869732E';
wwv_flow_imp.g_varchar2_table(15) := '616461707465722E636C656172546F6B656E28746869732E636F6E74657874292C746869732E636C61696D65643D2131297D6173796E63207265717565737428652C693D7B7D297B636F6E737420613D617761697420746869732E616461707465722E72';
wwv_flow_imp.g_varchar2_table(16) := '65717565737428652C7B746F6B656E3A746869732E746F6B656E2C6B65793A746869732E636F6E746578742E6B65792C2E2E2E697D293B69662821617C7C612E6F6B3D3D3D2131297468726F77206E6577204572726F722828613D3D6E756C6C3F766F69';
wwv_flow_imp.g_varchar2_table(17) := '6420303A612E726561736F6E297C7C28613D3D6E756C6C3F766F696420303A612E6572726F72297C7C224174746163686D656E742072657175657374206661696C65642E22293B72657475726E20617D6173796E63206F70656E2865297B696628746869';
wwv_flow_imp.g_varchar2_table(18) := '732E62757379297468726F77206E6577204572726F722822416E206174746163686D656E74206F7065726174696F6E206973207374696C6C2072756E6E696E672E22293B746869732E72656164793D21312C746869732E66696C65733D5B5D2C74686973';
wwv_flow_imp.g_varchar2_table(19) := '2E6472616674733D6E6577204D61702C746869732E636F6E746578743D4F626A6563742E667265657A65287B2E2E2E657D292C746869732E746F6B656E3D6A28652E746F6B656E293F652E746F6B656E3A6A28652E7265757365293F652E72657573653A';
wwv_flow_imp.g_varchar2_table(20) := '22222C746869732E636C61696D65643D21312C617761697420746869732E72756E286173796E6328293D3E7B636F6E737420693D617761697420746869732E7265717565737428746869732E636F6E746578742E726561644F6E6C793F224C495354223A';
wwv_flow_imp.g_varchar2_table(21) := '224F50454E22293B692E726561644F6E6C79262628746869732E636F6E746578743D4F626A6563742E667265657A65287B2E2E2E746869732E636F6E746578742C726561644F6E6C793A21307D292C746869732E746F6B656E3D2222292C692E746F6B65';
wwv_flow_imp.g_varchar2_table(22) := '6E262628746869732E636C61696D65643D692E746F6B656E3D3D3D652E746F6B656E2C746869732E746F6B656E3D692E746F6B656E292C746869732E64656661756C74733D5B302C312C325D2E6D617028613D3E28652E64656661756C74737C7C5B5D29';
wwv_flow_imp.g_varchar2_table(23) := '5B615D3F3F2222292C746869732E66696C65733D692E66696C65737C7C5B5D2C746869732E72656164793D21307D297D6173796E632072756E2865297B696628746869732E62757379297468726F77206E6577204572726F722822506C65617365207761';
wwv_flow_imp.g_varchar2_table(24) := '697420666F72207468652063757272656E74206174746163686D656E74206F7065726174696F6E2E22293B746869732E627573793D21302C746869732E6F6E6368616E676528293B636F6E737420693D286173796E6328293D3E7B7472797B7265747572';
wwv_flow_imp.g_varchar2_table(25) := '6E206177616974206528297D66696E616C6C797B746869732E627573793D21312C746869732E70726F67726573733D6E756C6C2C746869732E72756E6E696E673D6E756C6C2C746869732E6F6E6368616E676528297D7D2928293B72657475726E207468';
wwv_flow_imp.g_varchar2_table(26) := '69732E72756E6E696E673D692C697D6173796E632069646C6528297B666F72283B3B297B636F6E737420653D746869732E6669656C6451756575653B666F7228617761697420653B746869732E72756E6E696E673B297472797B61776169742074686973';
wwv_flow_imp.g_varchar2_table(27) := '2E72756E6E696E677D63617463687B7D696628653D3D3D746869732E6669656C645175657565262621746869732E72756E6E696E672972657475726E7D7D6173796E63207265667265736828297B746869732E66696C65733D2861776169742074686973';
wwv_flow_imp.g_varchar2_table(28) := '2E7265717565737428224C4953542229292E66696C65737C7C5B5D2C746869732E6F6E6368616E676528297D6173796E632075706C6F61642865297B69662821746869732E7265616479297468726F77206E6577204572726F72282252656F70656E2061';
wwv_flow_imp.g_varchar2_table(29) := '74746163686D656E7473206265666F7265206D616B696E67206368616E6765732E22293B696628746869732E636F6E746578742E726561644F6E6C79297468726F77206E6577204572726F7228225468697320726F772069732072656164206F6E6C792E';
wwv_flow_imp.g_varchar2_table(30) := '22293B72657475726E20746869732E72756E286173796E6328293D3E7B636F6E737420693D5B5D3B6C657420613D21313B746869732E63616E63656C6C65643D21313B666F7228636F6E7374206C206F662065297B696628746869732E63616E63656C6C';
wwv_flow_imp.g_varchar2_table(31) := '656429627265616B3B6C657420703D21313B7472797B6966286F65286C2C746869732E636667292C746869732E66696C65732E66696C74657228663D3E21662E72656D6F766564292E6C656E6774683E3D746869732E6366672E6D6178436F756E742974';
wwv_flow_imp.g_varchar2_table(32) := '68726F77206E6577204572726F7228224D6178696D756D20222B746869732E6366672E6D6178436F756E742B28746869732E6366672E6D6178436F756E743D3D3D313F222066696C65223A222066696C657322292B222070657220726F772E22293B6966';
wwv_flow_imp.g_varchar2_table(33) := '28746869732E70726F67726573733D7B6E616D653A6C2E6E616D652C72656365697665643A302C73697A653A6C2E73697A657D2C746869732E6F6E6368616E676528292C6C2E73697A653C3D6C65297B636F6E737420663D6165286177616974206C2E61';
wwv_flow_imp.g_varchar2_table(34) := '727261794275666665722829292E6D61746368282F2E7B312C383030307D2F67293B703D21302C746869732E66696C65733D28617761697420746869732E726571756573742822505554222C7B6E616D653A6C2E6E616D652C73697A653A6C2E73697A65';
wwv_flow_imp.g_varchar2_table(35) := '2C6368756E6B733A662C76616C7565733A746869732E64656661756C74737D29292E66696C65737C7C5B5D7D656C73657B703D21303B636F6E737420663D617761697420746869732E7265717565737428225354415254222C7B6E616D653A6C2E6E616D';
wwv_flow_imp.g_varchar2_table(36) := '652C73697A653A6C2E73697A652C76616C7565733A746869732E64656661756C74737D293B6C6574206D3D303B666F72283B6D3C6C2E73697A653B297B696628746869732E63616E63656C6C6564297B7472797B617761697420746869732E7265717565';
wwv_flow_imp.g_varchar2_table(37) := '7374282252454D4F5645222C7B69643A662E75706C6F616449647D297D63617463687B7D7468726F77206E6577204572726F72286C2E6E616D652B223A2075706C6F61642063616E63656C6C65642E22297D636F6E737420533D6177616974206C2E736C';
wwv_flow_imp.g_varchar2_table(38) := '696365286D2C6D2B6C65292E617272617942756666657228292C4C3D61652853292E6D61746368282F2E7B312C383030307D2F67293B6C657420433B666F72286C657420413D303B413C323B412B2B297472797B433D617761697420746869732E726571';
wwv_flow_imp.g_varchar2_table(39) := '7565737428224348554E4B222C7B69643A662E75706C6F616449642C6F66667365743A6D2C6368756E6B733A4C7D293B627265616B7D63617463682879297B696628413D3D3D31297468726F7720797D696628214E756D6265722E6973496E7465676572';
wwv_flow_imp.g_varchar2_table(40) := '28432E7265636569766564297C7C432E72656365697665643C6D2B532E627974654C656E6774687C7C432E72656365697665643E6C2E73697A65297468726F77206E6577204572726F7228225365727665722072657475726E656420616E20696E76616C';
wwv_flow_imp.g_varchar2_table(41) := '69642075706C6F6164206F66667365742E22293B6D3D432E72656365697665642C746869732E70726F67726573733D7B6E616D653A6C2E6E616D652C72656365697665643A6D2C73697A653A6C2E73697A657D2C746869732E6F6E6368616E676528297D';
wwv_flow_imp.g_varchar2_table(42) := '636F6E737420763D617761697420746869732E72657175657374282246494E495348222C7B69643A662E75706C6F616449647D293B746869732E66696C65733D762E66696C65737C7C28617761697420746869732E7265717565737428224C4953542229';
wwv_flow_imp.g_varchar2_table(43) := '292E66696C65737C7C5B5D7D7D63617463682866297B692E7075736828662E6D6573736167657C7C537472696E67286629292C70262628613D2130297D7D69662861297472797B746869732E66696C65733D28617761697420746869732E726571756573';
wwv_flow_imp.g_varchar2_table(44) := '7428224C4953542229292E66696C65737C7C5B5D7D63617463687B7D696628746869732E63616E63656C6C6564262621692E736F6D65286C3D3E2F63616E63656C6C65642F2E74657374286C29292626692E70757368282255706C6F61642063616E6365';
wwv_flow_imp.g_varchar2_table(45) := '6C6C65642E22292C746869732E63616E63656C6C65643D21312C692E6C656E677468297468726F77206E6577204572726F7228692E6A6F696E2822202229297D297D63616E63656C28297B746869732E62757379262628746869732E63616E63656C6C65';
wwv_flow_imp.g_varchar2_table(46) := '643D2130297D6173796E632072656D6F76652865297B69662821746869732E7265616479297468726F77206E6577204572726F72282252656F70656E206174746163686D656E7473206265666F7265206D616B696E67206368616E6765732E22293B6966';
wwv_flow_imp.g_varchar2_table(47) := '28746869732E636F6E746578742E726561644F6E6C79297468726F77206E6577204572726F7228225468697320726F772069732072656164206F6E6C792E22293B72657475726E20746869732E72756E286173796E6328293D3E7B636F6E737420693D61';
wwv_flow_imp.g_varchar2_table(48) := '7761697420746869732E72657175657374282252454D4F5645222C7B69643A652E69642C726573746F72653A652E72656D6F7665647D293B746869732E66696C65733D692E66696C65737C7C28617761697420746869732E7265717565737428224C4953';
wwv_flow_imp.g_varchar2_table(49) := '542229292E66696C65737C7C5B5D7D297D6173796E63207365744669656C647328652C69297B69662821746869732E7265616479297468726F77206E6577204572726F72282252656F70656E206174746163686D656E7473206265666F7265206D616B69';
wwv_flow_imp.g_varchar2_table(50) := '6E67206368616E6765732E22293B696628746869732E636F6E746578742E726561644F6E6C79297468726F77206E6577204572726F7228225468697320726F772069732072656164206F6E6C792E22293B72657475726E20746869732E72756E28617379';
wwv_flow_imp.g_varchar2_table(51) := '6E6328293D3E7B636F6E737420613D617761697420746869732E7265717565737428224649454C4453222C7B69643A652E69642C76616C7565733A697D293B746869732E66696C65733D612E66696C65737C7C28617761697420746869732E7265717565';
wwv_flow_imp.g_varchar2_table(52) := '737428224C4953542229292E66696C65737C7C5B5D7D297D6669656C6456616C756528652C69297B636F6E737420613D537472696E6728652E6964292C6C3D746869732E6472616674732E6765742861293B72657475726E206C26266920696E206C3F6C';
wwv_flow_imp.g_varchar2_table(53) := '5B695D3A2828746869732E66696C65732E66696E6428663D3E537472696E6728662E6964293D3D3D61297C7C65292E76616C7565737C7C5B5D295B695D3F3F22227D7365744669656C6428652C692C61297B69662821746869732E726561647929726574';
wwv_flow_imp.g_varchar2_table(54) := '75726E2050726F6D6973652E72656A656374286E6577204572726F72282252656F70656E206174746163686D656E7473206265666F7265206D616B696E67206368616E6765732E2229293B696628746869732E636F6E746578742E726561644F6E6C7929';
wwv_flow_imp.g_varchar2_table(55) := '72657475726E2050726F6D6973652E72656A656374286E6577204572726F7228225468697320726F772069732072656164206F6E6C792E2229293B636F6E7374206C3D537472696E6728652E6964292C703D746869732E6472616674732E676574286C29';
wwv_flow_imp.g_varchar2_table(56) := '7C7C7B7D3B72657475726E20705B695D3D612C746869732E6472616674732E736574286C2C70292C746869732E71756575654669656C6473286C297D71756575654669656C64732865297B636F6E737420693D746869732E6669656C6451756575652E74';
wwv_flow_imp.g_varchar2_table(57) := '68656E2828293D3E746869732E73656E644669656C6473286529293B72657475726E20746869732E6669656C6451756575653D692E63617463682828293D3E7B7D292C697D6173796E632073656E644669656C64732865297B69662821746869732E6472';
wwv_flow_imp.g_varchar2_table(58) := '616674732E6861732865292972657475726E21313B666F72283B746869732E627573793B297472797B617761697428746869732E72756E6E696E677C7C6E65772050726F6D69736528663D3E73657454696D656F757428662C35302929297D6361746368';
wwv_flow_imp.g_varchar2_table(59) := '7B7D636F6E737420693D746869732E66696C65732E66696E6428663D3E537472696E6728662E6964293D3D3D65292C613D746869732E6472616674732E6765742865293B69662821697C7C692E72656D6F7665647C7C21612972657475726E2074686973';
wwv_flow_imp.g_varchar2_table(60) := '2E6472616674732E64656C6574652865292C21313B636F6E7374206C3D5B302C312C325D2E6D617028663D3E6620696E20613F615B665D3A28692E76616C7565737C7C5B5D295B665D3F3F2222293B6966286C2E65766572792828662C6D293D3E663D3D';
wwv_flow_imp.g_varchar2_table(61) := '3D2828692E76616C7565737C7C5B5D295B6D5D3F3F222229292972657475726E20746869732E6472616674732E64656C6574652865292C21313B617761697420746869732E72756E286173796E6328293D3E7B636F6E737420663D617761697420746869';
wwv_flow_imp.g_varchar2_table(62) := '732E7265717565737428224649454C4453222C7B69643A692E69642C76616C7565733A6C7D293B746869732E66696C65733D662E66696C65737C7C28617761697420746869732E7265717565737428224C4953542229292E66696C65737C7C5B5D7D293B';
wwv_flow_imp.g_varchar2_table(63) := '636F6E737420703D746869732E6472616674732E6765742865293B69662870297B666F7228636F6E73742066206F66204F626A6563742E6B65797328702929705B665D3D3D3D6C5B665D262664656C65746520705B665D3B4F626A6563742E6B65797328';
wwv_flow_imp.g_varchar2_table(64) := '70292E6C656E6774687C7C746869732E6472616674732E64656C6574652865297D72657475726E21307D68617344726166747328297B72657475726E5B2E2E2E746869732E6472616674732E6B65797328295D2E736F6D6528653D3E746869732E66696C';
wwv_flow_imp.g_varchar2_table(65) := '65732E736F6D6528693D3E537472696E6728692E6964293D3D3D65262621692E72656D6F76656429297D6173796E6320666C7573684669656C647328297B666F7228636F6E73742065206F665B2E2E2E746869732E6472616674732E6B65797328295D29';
wwv_flow_imp.g_varchar2_table(66) := '617761697420746869732E71756575654669656C64732865297D6D697373696E6728297B636F6E737420653D5B5D3B666F7228636F6E73742069206F6620746869732E6366672E6669656C64737C7C5B5D29696628212821692E72657175697265647C7C';
wwv_flow_imp.g_varchar2_table(67) := '692E6B696E643D3D3D2248494444454E222929666F7228636F6E73742061206F6620746869732E66696C65732928612E7374616765643F612E7265616479262621612E72656D6F7665643A612E6368616E676564262621612E72656D6F76656429262621';
wwv_flow_imp.g_varchar2_table(68) := '537472696E672828612E76616C7565737C7C5B5D295B692E6E2D315D3F3F2222292E7472696D28292626652E7075736828692E6C6162656C2B2220666F7220222B612E6E616D65293B72657475726E20657D63616E5361766528297B72657475726E2074';
wwv_flow_imp.g_varchar2_table(69) := '6869732E7265616479262621746869732E627573792626746869732E66696C65732E657665727928653D3E652E72656164797C7C652E72656D6F766564297D7D636F6E7374204A3D22205C78423720222C6D653D6E3D3E6E2B286E3D3D3D313F22206174';
wwv_flow_imp.g_varchar2_table(70) := '746163686D656E74223A22206174746163686D656E747322293B66756E6374696F6E2059286E297B636F6E737420653D6428227370616E222C22666120222B6E293B72657475726E20652E7365744174747269627574652822617269612D68696464656E';
wwv_flow_imp.g_varchar2_table(71) := '222C227472756522292C657D66756E6374696F6E207965286E297B636F6E737420653D6E2E6E616D652E696E636C7564657328222E22293F6E2E6E616D652E73706C697428222E22292E706F7028292E746F4C6F7765724361736528293A22223B726574';
wwv_flow_imp.g_varchar2_table(72) := '75726E206E2E6D696D652E737461727473576974682822696D6167652F22297C7C5B22706E67222C226A7067222C226A706567222C22676966222C2277656270225D2E696E636C756465732865293F2266612D66696C652D696D6167652D6F223A653D3D';
wwv_flow_imp.g_varchar2_table(73) := '3D22706466223F2266612D66696C652D7064662D6F223A5B22747874222C22637376222C226C6F67225D2E696E636C756465732865293F2266612D66696C652D746578742D6F223A5B22646F63222C22646F6378225D2E696E636C756465732865293F22';
wwv_flow_imp.g_varchar2_table(74) := '66612D66696C652D776F72642D6F223A5B22786C73222C22786C7378225D2E696E636C756465732865293F2266612D66696C652D657863656C2D6F223A2266612D66696C652D6F227D66756E6374696F6E2064286E2C652C69297B636F6E737420613D64';
wwv_flow_imp.g_varchar2_table(75) := '6F63756D656E742E637265617465456C656D656E74286E293B72657475726E2065262628612E636C6173734E616D653D65292C69213D3D766F69642030262628612E74657874436F6E74656E743D69292C617D66756E6374696F6E206565286E2C652C69';
wwv_flow_imp.g_varchar2_table(76) := '2C61297B636F6E7374206C3D642822627574746F6E222C226967612D69636F6E2D627574746F6E222B28693F2220222B693A222229293B72657475726E206C2E747970653D22627574746F6E222C6C2E7469746C653D6E2C6C2E617070656E6428592865';
wwv_flow_imp.g_varchar2_table(77) := '292C6428227370616E222C226967612D7668222C6E29292C6C2E6F6E636C69636B3D612C6C7D66756E6374696F6E206465286E2C652C693D7B7D297B636F6E737420613D6428226469616C6F67222C226967612D70616E656C22293B612E69643D6E2E69';
wwv_flow_imp.g_varchar2_table(78) := '74656D2B225F50414E454C222C612E746162496E6465783D2D313B636F6E7374206C3D612E69642B225F5449544C45223B612E7365744174747269627574652822617269612D6C6162656C6C65646279222C6C293B636F6E737420703D64282268656164';
wwv_flow_imp.g_varchar2_table(79) := '6572222C226967612D68656164657222292C663D64282264697622293B662E617070656E64286428227370616E222C226967612D65796562726F77222C22524F57204154544143484D454E54532229293B636F6E7374206D3D6428226832222C22222C22';
wwv_flow_imp.g_varchar2_table(80) := '4D616E616765206174746163686D656E747322293B6D2E69643D6C2C662E617070656E64286D293B636F6E737420763D642822627574746F6E222C226967612D636C6F736522293B762E617070656E642859282266612D74696D65732229292C762E7479';
wwv_flow_imp.g_varchar2_table(81) := '70653D22627574746F6E222C762E7365744174747269627574652822617269612D6C6162656C222C22436C6F7365206174746163686D656E747322292C702E617070656E6428662C76293B636F6E737420533D64282270222C226967612D636F6E746578';
wwv_flow_imp.g_varchar2_table(82) := '7422292C4C3D642822646976222C226967612D64726F7022292C433D642822646976222C226967612D64726F702D69636F6E22293B432E617070656E642859282266612D636C6F75642D75706C6F61642229292C4C2E617070656E6428432C6428227374';
wwv_flow_imp.g_varchar2_table(83) := '726F6E67222C22222C2244726F702066696C6573206865726522292C6428227370616E222C22222C226F722063686F6F73652066696C65732066726F6D20796F7572206465766963652229293B636F6E737420413D642822627574746F6E222C22696761';
wwv_flow_imp.g_varchar2_table(84) := '2D62726F777365222C2243686F6F73652066696C657322293B412E747970653D22627574746F6E223B636F6E737420793D642822696E70757422293B792E747970653D2266696C65222C792E6D756C7469706C653D21302C792E6163636570743D6E2E61';
wwv_flow_imp.g_varchar2_table(85) := '63636570742C792E68696464656E3D21303B636F6E73742069653D6E2E6163636570742E73706C697428222C22292E6D617028633D3E632E7472696D28292E7265706C616365282F5E5C2E2F2C2222292E746F5570706572436173652829292E6A6F696E';
wwv_flow_imp.g_varchar2_table(86) := '28222C2022293B4C2E617070656E6428412C792C642822736D616C6C222C22222C69652B4A2B24286E2E6D61784279746573292B22207065722066696C65222B4A2B22557020746F20222B6E2E6D6178436F756E742B286E2E6D6178436F756E743D3D3D';
wwv_flow_imp.g_varchar2_table(87) := '313F222066696C65223A222066696C657322292B286E2E6D6178546F74616C3F4A2B24286E2E6D6178546F74616C292B2220746F676574686572223A2222292B286E2E6D696E436F756E743F4A2B6E2E6D696E436F756E742B286E2E6D696E436F756E74';
wwv_flow_imp.g_varchar2_table(88) := '3D3D3D313F222066696C65223A222066696C657322292B22207265717569726564223A22222929293B636F6E7374204F3D642822646976222C226967612D6D65737361676522293B4F2E7365744174747269627574652822726F6C65222C22616C657274';
wwv_flow_imp.g_varchar2_table(89) := '22293B636F6E7374204D3D642822646976222C226967612D73746174757322293B4D2E7365744174747269627574652822726F6C65222C2273746174757322292C4D2E7365744174747269627574652822617269612D6C697665222C22706F6C69746522';
wwv_flow_imp.g_varchar2_table(90) := '293B636F6E737420453D642822646976222C226967612D66696C657322292C473D642822666F6F746572222C226967612D666F6F74657222293B472E617070656E642864282270222C22222C224174746163686D656E74206368616E6765732061726520';
wwv_flow_imp.g_varchar2_table(91) := '6170706C696564207768656E20796F7520736176652074686520677269642E2229293B636F6E737420543D642822627574746F6E222C226967612D646F6E65222C22446F6E6522293B542E747970653D22627574746F6E222C472E617070656E64285429';
wwv_flow_imp.g_varchar2_table(92) := '2C612E617070656E6428702C532C4C2C4F2C4D2C452C47292C646F63756D656E742E626F64792E617070656E642861293B6C657420573D5B5D3B66756E6374696F6E205128297B572E666F72456163682855524C2E7265766F6B654F626A65637455524C';
wwv_flow_imp.g_varchar2_table(93) := '292C573D5B5D7D66756E6374696F6E20442863297B4F2E74657874436F6E74656E743D632E6D6573736167657C7C537472696E672863297D6173796E632066756E6374696F6E20712863297B4F2E74657874436F6E74656E743D22223B7472797B726574';
wwv_flow_imp.g_varchar2_table(94) := '75726E206177616974206328292C21307D63617463682862297B72657475726E20442862292C21317D7D6173796E632066756E6374696F6E204B2863297B7472797B72657475726E206177616974206328292626284F2E74657874436F6E74656E743D22';
wwv_flow_imp.g_varchar2_table(95) := '22292C21307D63617463682862297B72657475726E20442862292C21317D7D6C657420583D21313B6173796E632066756E6374696F6E204228297B6966282158297B583D21303B7472797B617761697420652E69646C6528293B666F7228636F6E737420';
wwv_flow_imp.g_varchar2_table(96) := '62206F6620452E717565727953656C6563746F72416C6C28222E6967612D6669656C6420696E707574222929696628622E636F6D6D6974262621617761697420622E636F6D6D697428292972657475726E3B696628617761697420652E69646C6528292C';
wwv_flow_imp.g_varchar2_table(97) := '652E6861734472616674732829262621617761697420712828293D3E652E666C7573684669656C64732829292972657475726E3B636F6E737420633D652E6D697373696E6728293B696628632E6C656E677468297B44286E6577204572726F7228224669';
wwv_flow_imp.g_varchar2_table(98) := '6C6C20696E20222B632E6A6F696E28222C2022292B222E2229293B72657475726E7D612E636C6F736528297D66696E616C6C797B583D21317D7D7D66756E6374696F6E204828632C62297B636F6E7374205F3D286E2E6669656C64737C7C5B5D292E6669';
wwv_flow_imp.g_varchar2_table(99) := '6C74657228783D3E782E6B696E64213D3D2248494444454E22293B696628215F2E6C656E6774682972657475726E206E756C6C3B636F6E7374207A3D642822646976222C226967612D6669656C647322293B72657475726E205F2E666F72456163682878';
wwv_flow_imp.g_varchar2_table(100) := '3D3E7B636F6E7374204E3D612E69642B225F46222B782E6E2B225F222B537472696E6728632E6964292E7265706C616365282F5B5E412D5A612D7A302D395D2F672C2222292C493D642822646976222C226967612D6669656C64222B28782E7265717569';
wwv_flow_imp.g_varchar2_table(101) := '7265643F222069732D7265717569726564223A222229292C753D6428226C6162656C222C22222C782E6C6162656C293B752E68746D6C466F723D4E3B636F6E737420673D642822696E70757422293B672E747970653D2274657874222C672E69643D4E2C';
wwv_flow_imp.g_varchar2_table(102) := '672E646174617365742E6B65793D4E2C672E76616C75653D652E6669656C6456616C756528632C782E6E2D31292C672E73686F776E3D672E76616C75652C672E6D61784C656E6774683D4D6174682E6D696E28782E6D61787C7C3465332C346533292C67';
wwv_flow_imp.g_varchar2_table(103) := '2E64697361626C65643D627C7C632E72656D6F7665647C7C21632E72656164792C782E7265717569726564262628672E72657175697265643D2130292C672E636F6D6D69743D6173796E6328293D3E672E64697361626C65647C7C672E76616C75653D3D';
wwv_flow_imp.g_varchar2_table(104) := '3D652E6669656C6456616C756528632C782E6E2D31293F21303A4B2828293D3E652E7365744669656C6428632C782E6E2D312C672E76616C756529292C672E6F6E6368616E67653D28293D3E7B672E636F6D6D697428297D2C672E6F6E626C75723D2829';
wwv_flow_imp.g_varchar2_table(105) := '3D3E7B672E636F6D6D697428297D2C492E617070656E6428752C67292C7A2E617070656E642849297D292C7A7D762E6F6E636C69636B3D542E6F6E636C69636B3D422C612E6164644576656E744C697374656E657228226B6579646F776E222C633D3E7B';
wwv_flow_imp.g_varchar2_table(106) := '632E6B65793D3D3D2245736361706522262621632E64656661756C7450726576656E746564262628632E70726576656E7444656661756C7428292C422829297D292C612E6164644576656E744C697374656E6572282263616E63656C222C633D3E7B632E';
wwv_flow_imp.g_varchar2_table(107) := '70726576656E7444656661756C7428292C4228297D292C612E6164644576656E744C697374656E65722822636C6F7365222C28293D3E7B76617220633B5128292C28633D692E6F6E636C6F7365293D3D6E756C6C7C7C632E63616C6C2869297D292C412E';
wwv_flow_imp.g_varchar2_table(108) := '6F6E636C69636B3D28293D3E792E636C69636B28292C792E6F6E6368616E67653D28293D3E7B636F6E737420633D5B2E2E2E792E66696C65735D3B792E76616C75653D22222C712828293D3E652E75706C6F6164286329297D3B666F7228636F6E737420';
wwv_flow_imp.g_varchar2_table(109) := '63206F665B2264726167656E746572222C22647261676F766572222C22647261676C65617665222C2264726F70225D294C2E6164644576656E744C697374656E657228632C623D3E7B622E70726576656E7444656661756C7428292C622E73746F705072';
wwv_flow_imp.g_varchar2_table(110) := '6F7061676174696F6E28292C4C2E636C6173734C6973742E746F67676C65282269732D6F766572222C633D3D3D2264726167656E746572227C7C633D3D3D22647261676F76657222292C633D3D3D2264726F7022262621652E62757379262621652E636F';
wwv_flow_imp.g_varchar2_table(111) := '6E746578742E726561644F6E6C792626712828293D3E652E75706C6F6164285B2E2E2E622E646174615472616E736665722E66696C65735D29297D293B72657475726E20652E6F6E6368616E67653D28293D3E7B76617220782C4E2C493B636F6E737420';
wwv_flow_imp.g_varchar2_table(112) := '633D28783D652E636F6E74657874293D3D6E756C6C3F766F696420303A782E726561644F6E6C793B412E64697361626C65643D652E627573797C7C637C7C21652E72656164792C762E64697361626C65643D542E64697361626C65643D652E627573792C';
wwv_flow_imp.g_varchar2_table(113) := '4C2E68696464656E3D2121632C532E74657874436F6E74656E743D652E636F6E746578743F652E636F6E746578742E6C6162656C3A22222C532E68696464656E3D21532E74657874436F6E74656E743B636F6E737420623D652E70726F67726573733F22';
wwv_flow_imp.g_varchar2_table(114) := '55706C6F6164696E6720222B652E70726F67726573732E6E616D652B4A2B4D6174682E666C6F6F7228652E70726F67726573732E72656365697665642F652E70726F67726573732E73697A652A34292A32352B2225223A652E627573793F22576F726B69';
wwv_flow_imp.g_varchar2_table(115) := '6E672E2E2E223A6D6528652E66696C65732E66696C74657228753D3E21752E72656D6F766564292E6C656E677468293B6966284D2E74657874436F6E74656E74213D3D622626284D2E74657874436F6E74656E743D62292C652E62757379297B6C657420';
wwv_flow_imp.g_varchar2_table(116) := '753D452E717565727953656C6563746F7228222E6967612D66696C652E69732D75706C6F6164696E6722293B696628652E70726F6772657373297B69662821757C7C752E646174617365742E6E616D65213D3D652E70726F67726573732E6E616D65297B';
wwv_flow_imp.g_varchar2_table(117) := '753D3D6E756C6C7C7C752E72656D6F766528292C284E3D452E717565727953656C6563746F7228222E6967612D656D7074792229293D3D6E756C6C7C7C4E2E72656D6F766528292C753D64282261727469636C65222C226967612D66696C652069732D75';
wwv_flow_imp.g_varchar2_table(118) := '706C6F6164696E6722292C752E646174617365742E6E616D653D652E70726F67726573732E6E616D653B636F6E737420673D642822646976222C226967612D66696C652D69636F6E22293B672E617070656E642859282266612D636972636C652D6F2D6E';
wwv_flow_imp.g_varchar2_table(119) := '6F7463682066612D7370696E2229293B636F6E737420743D642822646976222C226967612D66696C652D696E666F22293B742E617070656E64286428227374726F6E67222C22222C652E70726F67726573732E6E616D65292C6428227370616E222C2222';
wwv_flow_imp.g_varchar2_table(120) := '2C2428652E70726F67726573732E73697A6529292C6428227370616E222C226967612D6261646765222C2255706C6F6164696E672229293B636F6E737420723D642822646976222C226967612D62617222293B722E617070656E64286428227370616E22';
wwv_flow_imp.g_varchar2_table(121) := '29292C742E617070656E642872293B636F6E737420733D642822646976222C226967612D66696C652D616374696F6E7322293B732E617070656E64286565282243616E63656C2075706C6F6164222C2266612D74696D6573222C226967612D64616E6765';
wwv_flow_imp.g_varchar2_table(122) := '72206967612D63616E63656C222C28293D3E652E63616E63656C282929292C752E617070656E6428672C742C73292C452E617070656E642875297D752E717565727953656C6563746F7228222E6967612D626172207370616E22292E7374796C652E7769';
wwv_flow_imp.g_varchar2_table(123) := '6474683D4D6174682E726F756E6428652E70726F67726573732E72656365697665642F652E70726F67726573732E73697A652A313030292B2225227D72657475726E7D636F6E7374205F3D646F63756D656E742E616374697665456C656D656E74262645';
wwv_flow_imp.g_varchar2_table(124) := '2E636F6E7461696E7328646F63756D656E742E616374697665456C656D656E74293F646F63756D656E742E616374697665456C656D656E742E646174617365742E6B65793A6E756C6C2C7A3D6E6577204D61703B666F7228636F6E73742075206F662045';
wwv_flow_imp.g_varchar2_table(125) := '2E717565727953656C6563746F72416C6C28222E6967612D6669656C6420696E707574222929752E76616C7565213D3D752E73686F776E26267A2E73657428752E646174617365742E6B65792C752E76616C7565293B6966285128292C452E7265706C61';
wwv_flow_imp.g_varchar2_table(126) := '63654368696C6472656E28292C21652E66696C65732E6C656E677468297B452E617070656E6428642822646976222C226967612D656D707479222C224E6F206174746163686D656E7473207965742E20416464207468652066696C657320746861742073';
wwv_flow_imp.g_varchar2_table(127) := '7570706F7274207468697320726F772E2229293B72657475726E7D652E66696C65732E666F724561636828753D3E7B636F6E737420673D64282261727469636C65222C226967612D66696C65222B28752E72656D6F7665643F222069732D72656D6F7665';
wwv_flow_imp.g_varchar2_table(128) := '64223A222229292C743D642822646976222C226967612D66696C652D69636F6E22293B742E617070656E64285928796528752929293B636F6E737420723D642822646976222C226967612D66696C652D696E666F22293B722E617070656E642864282273';
wwv_flow_imp.g_varchar2_table(129) := '74726F6E67222C22222C752E6E616D65292C6428227370616E222C22222C2428752E73697A652929293B636F6E737420733D6428227370616E222C226967612D6261646765222C752E72656D6F7665643F2252656D6F76616C2070656E64696E67223A75';
wwv_flow_imp.g_varchar2_table(130) := '2E72656164793F752E7374616765643F2250656E64696E672073617665223A752E6368616E6765643F224368616E6765732070656E64696E67223A225361766564223A22496E636F6D706C657465202D2072656D6F766520746F207361766522293B722E';
wwv_flow_imp.g_varchar2_table(131) := '617070656E642873293B636F6E7374206F3D4828752C63293B6F2626722E617070656E64286F293B636F6E737420683D642822646976222C226967612D66696C652D616374696F6E7322293B696628752E7265616479262621752E72656D6F7665642626';
wwv_flow_imp.g_varchar2_table(132) := '28682E617070656E642865652822446F776E6C6F6164222C2266612D646F776E6C6F6164222C22222C28293D3E712828293D3E692E646F776E6C6F616428752C65292929292C5B22696D6167652F706E67222C22696D6167652F6A706567225D2E696E63';
wwv_flow_imp.g_varchar2_table(133) := '6C7564657328752E6D696D65292626692E7072657669657729297B636F6E737420773D6565282250726576696577222C2266612D657965222C22222C28293D3E71286173796E6328293D3E7B636F6E7374206B3D617761697420692E7072657669657728';
wwv_flow_imp.g_varchar2_table(134) := '752C65293B696628215B22696D6167652F706E67222C22696D6167652F6A706567225D2E696E636C75646573286B2E7479706529297468726F77206E6577204572726F7228225072657669657720756E617661696C61626C652E22293B636F6E73742046';
wwv_flow_imp.g_varchar2_table(135) := '3D55524C2E6372656174654F626A65637455524C286B293B572E707573682846293B636F6E737420523D642822696D67222C226967612D7072657669657722293B522E7372633D462C522E616C743D752E6E616D652C742E7265706C6163654368696C64';
wwv_flow_imp.g_varchar2_table(136) := '72656E2852297D29293B682E617070656E642877297D637C7C682E617070656E6428752E72656D6F7665643F65652822526573746F7265222C2266612D756E646F222C22222C28293D3E712828293D3E652E72656D6F766528752929293A656528225265';
wwv_flow_imp.g_varchar2_table(137) := '6D6F7665222C2266612D74726173682D6F222C226967612D64616E676572222C28293D3E712828293D3E652E72656D6F76652875292929292C672E617070656E6428742C722C68292C452E617070656E642867297D293B666F7228636F6E73745B752C67';
wwv_flow_imp.g_varchar2_table(138) := '5D6F66207A297B636F6E737420743D452E717565727953656C6563746F7228275B646174612D6B65793D22272B752B27225D27293B74262621742E64697361626C6564262628742E76616C75653D67297D5F26262828493D452E717565727953656C6563';
wwv_flow_imp.g_varchar2_table(139) := '746F7228275B646174612D6B65793D22272B5F2B27225D2729293D3D6E756C6C7C7C492E666F6375732829297D2C7B6469616C6F673A612C73657373696F6E3A652C6173796E63206F70656E2863297B612E6F70656E7C7C284F2E74657874436F6E7465';
wwv_flow_imp.g_varchar2_table(140) := '6E743D22222C452E7265706C6163654368696C6472656E28292C612E73686F774D6F64616C28292C617761697420712828293D3E652E6F70656E286329292C412E666F6375732829297D2C64657374726F7928297B5128292C612E72656D6F766528297D';
wwv_flow_imp.g_varchar2_table(141) := '7D7D66756E6374696F6E207565286E2C652C69297B636F6E737420613D6A2865292C6C3D2F5E5C642B242F2E7465737428653D3D6E756C6C3F22223A537472696E67286529293F4E756D6265722865293A302C703D6E2E6C6162656C7C7C224174746163';
wwv_flow_imp.g_varchar2_table(142) := '686D656E7473222C663D6E2E646973706C61793D3D3D2254455854223F22223A273C7370616E20636C6173733D226967612D63656C6C2D69636F6E20666120272B69286E2E69636F6E7C7C2266612D7061706572636C697022292B272220617269612D68';
wwv_flow_imp.g_varchar2_table(143) := '696464656E3D2274727565223E3C2F7370616E3E272C6D3D6E2E646973706C61793D3D3D2249434F4E223F273C7370616E20636C6173733D22752D56697375616C6C7948696464656E223E272B692870292B223C2F7370616E3E223A273C7370616E2063';
wwv_flow_imp.g_varchar2_table(144) := '6C6173733D226967612D63656C6C2D6C6162656C223E272B692870292B223C2F7370616E3E222C763D613F6E2E646973706C61793D3D3D2249434F4E223F273C7370616E20636C6173733D226967612D63656C6C2D646F7422207469746C653D22436861';
wwv_flow_imp.g_varchar2_table(145) := '6E676573206E6F7420736176656420796574223E3C2F7370616E3E3C7370616E20636C6173733D22752D56697375616C6C7948696464656E223E50656E64696E673C2F7370616E3E273A273C7370616E20636C6173733D226967612D63656C6C2D70656E';
wwv_flow_imp.g_varchar2_table(146) := '64696E67223E50656E64696E673C2F7370616E3E273A22222C533D6C3E30262621613F273C7370616E20636C6173733D226967612D63656C6C2D636F756E74223E272B6C2B223C2F7370616E3E223A22223B72657475726E273C7370616E20636C617373';
wwv_flow_imp.g_varchar2_table(147) := '3D226967612D63656C6C272B28613F222069732D70656E64696E67223A2222292B272220646174612D6967612D6974656D3D22272B69286E2E6974656D292B27223E272B662B6D2B532B762B223C2F7370616E3E227D66756E6374696F6E207765286E29';
wwv_flow_imp.g_varchar2_table(148) := '7B76617220752C673B6966282166652829297468726F77206E6577204572726F7228224947204174746163686D656E7473206E65656473204F7261636C6520415045582E22293B636F6E737420653D666528292C693D652E6A51756572792C613D282875';
wwv_flow_imp.g_varchar2_table(149) := '3D652E7574696C293D3D6E756C6C3F766F696420303A752E65736361706548544D4C297C7C28743D3E537472696E672874292E7265706C616365282F5B263C3E22275D2F672C723D3E222623222B722E63686172436F646541742830292B223B2229293B';
wwv_flow_imp.g_varchar2_table(150) := '28673D502E676574286E2E6974656D29293D3D6E756C6C7C7C672E64657374726F7928293B636F6E7374206C3D646F63756D656E742E676574456C656D656E7442794964286E2E6974656D292C703D646F63756D656E742E676574456C656D656E744279';
wwv_flow_imp.g_varchar2_table(151) := '4964286E2E6974656D2B225F4F50454E22293B6C657420663D21216E2E726561644F6E6C792C6D3D6E756C6C2C763D6E756C6C2C533D6E2E726567696F6E7C7C6E756C6C3B66756E6374696F6E204C28297B6966282153297B636F6E737420743D652E72';
wwv_flow_imp.g_varchar2_table(152) := '6567696F6E2E66696E64436C6F73657374286C297C7C652E726567696F6E2E66696E64436C6F736573742870293B6966282174297468726F77206E6577204572726F7228224947204174746163686D656E74733A20222B6E2E6974656D2B22206973206E';
wwv_flow_imp.g_varchar2_table(153) := '6F7420696E7369646520616E20496E74657261637469766520477269642E22293B533D742E656C656D656E742E617474722822696422297D72657475726E20652E726567696F6E2853297D66756E6374696F6E204328297B72657475726E204C28292E63';
wwv_flow_imp.g_varchar2_table(154) := '616C6C28226765745669657773222C226772696422297D636F6E737420413D743D3E742626742E636F6E7461696E73262628742E636F6E7461696E73286C297C7C742E636F6E7461696E73287029293B66756E6374696F6E20792874297B636F6E737420';
wwv_flow_imp.g_varchar2_table(155) := '723D742E6765744F7074696F6E28226669656C647322297C7C7B7D3B72657475726E204F626A6563742E6B6579732872292E66696E6428733D3E725B735D2E656C656D656E7449643D3D3D6E2E6974656D297C7C6E2E6974656D7D66756E6374696F6E20';
wwv_flow_imp.g_varchar2_table(156) := '69652874297B636F6E737420723D742E6765744F7074696F6E28226964656E746974794669656C6422292C733D41727261792E697341727261792872293F723A723F5B725D3A5B5D3B696628732E6C656E677468213D3D31297468726F77206E65772045';
wwv_flow_imp.g_varchar2_table(157) := '72726F7228224947204174746163686D656E7473206E65656473206120677269642077697468206F6E65207072696D617279206B657920636F6C756D6E2E22293B72657475726E20735B305D7D66756E6374696F6E204F28297B702E696E6E657248544D';
wwv_flow_imp.g_varchar2_table(158) := '4C3D7565286E2C6C2E76616C75652C61292C702E7365744174747269627574652822617269612D6C6162656C222C286E2E6C6162656C7C7C224174746163686D656E747322292B286A286C2E76616C7565293F222C2070656E64696E67223A222229297D';
wwv_flow_imp.g_varchar2_table(159) := '636F6E7374204D3D6E6577204D61702C453D6E6577204D61702C473D7B6173796E63207265717565737428742C72297B7472797B72657475726E20617761697420652E7365727665722E706C7567696E286E2E616A61782C7B7830313A742C7830323A72';
wwv_flow_imp.g_varchar2_table(160) := '2E746F6B656E2C7830333A722E6B65792C7830343A722E69642C7830353A722E726573746F72653F22524553544F5245223A722E6E616D652C7830363A722E6F66667365743F3F722E73697A652C6630313A722E6368756E6B732C6630323A722E76616C';
wwv_flow_imp.g_varchar2_table(161) := '7565737D2C7B64617461547970653A226A736F6E227D297D63617463682873297B636F6E7374206F3D732626732E726573706F6E73654A534F4E3B7468726F77206E6577204572726F72286F2626286F2E726561736F6E7C7C6F2E6572726F727C7C6F2E';
wwv_flow_imp.g_varchar2_table(162) := '6D657373616765297C7C28732626732E7374617475733F224174746163686D656E742072657175657374206661696C656420284854545020222B732E7374617475732B22292E223A224174746163686D656E742072657175657374206661696C65642E22';
wwv_flow_imp.g_varchar2_table(163) := '29297D7D2C736574546F6B656E28742C72297B6966284D2E73657428742E6D6F64656C2E6765745265636F7264496428742E7265636F7264292C72292C742E6D6F64656C2E73657456616C756528742E7265636F72642C7928742E6D6F64656C292C7229';
wwv_flow_imp.g_varchar2_table(164) := '3D3D3D2244555022297468726F77206E6577204572726F7228224475706C6963617465206174746163686D656E7420746F6B656E2E22293B6C2E76616C75653D722C4F28292C652E6576656E742E74726967676572286C2C226368616E676522297D2C63';
wwv_flow_imp.g_varchar2_table(165) := '6C656172546F6B656E2874297B636F6E737420723D7928742E6D6F64656C293B4D2E64656C65746528742E6D6F64656C2E6765745265636F7264496428742E7265636F726429293B636F6E737420733D742E6F726967696E616C3D3D6E756C6C7C7C6A28';
wwv_flow_imp.g_varchar2_table(166) := '742E6F726967696E616C293F22223A537472696E6728742E6F726967696E616C293B742E6D6F64656C2E73657456616C756528742E7265636F72642C722C73292C6C2E76616C75653D732C4F28293B636F6E7374206F3D742E6D6F64656C2E6765745265';
wwv_flow_imp.g_varchar2_table(167) := '636F72644D6574616461746128742E6D6F64656C2E6765745265636F7264496428742E7265636F726429297C7C7B7D2C683D4F626A6563742E6B657973286F2E6669656C64737C7C7B7D292E736F6D6528773D3E77213D3D7226266F2E6669656C64735B';
wwv_flow_imp.g_varchar2_table(168) := '775D2E6368616E676564293B6F2E757064617465642626216F2E696E736572746564262621682626742E6D6F64656C2E7265766572745265636F726473285B742E7265636F72645D297D7D2C543D6E6577206365286E2C47293B6173796E632066756E63';
wwv_flow_imp.g_varchar2_table(169) := '74696F6E20572874297B636F6E737420723D617761697420666574636828512874292C7B63726564656E7469616C733A2273616D652D6F726967696E227D293B69662821722E6F6B7C7C28722E686561646572732E6765742822636F6E74656E742D7479';
wwv_flow_imp.g_varchar2_table(170) := '706522297C7C2222292E696E636C7564657328226170706C69636174696F6E2F6A736F6E2229297B6C657420733D22223B7472797B733D28617761697420722E6A736F6E2829292E726561736F6E7C7C22227D63617463687B7D7468726F77206E657720';
wwv_flow_imp.g_varchar2_table(171) := '4572726F7228737C7C225468652066696C6520636F756C64206E6F7420626520646F776E6C6F6164656420284854545020222B722E7374617475732B22292E22297D72657475726E20722E626C6F6228297D66756E6374696F6E20512874297B72657475';
wwv_flow_imp.g_varchar2_table(172) := '726E20652E7365727665722E706C7567696E55726C286E2E616A61782C7B7830313A22444F574E4C4F4144222C7830323A542E746F6B656E2C7830333A542E636F6E746578742E6B65792C7830343A742E69647D297D763D6465286E2C542C7B6F6E636C';
wwv_flow_imp.g_varchar2_table(173) := '6F736528297B7472797B542E736574746C6528297D63617463682872297B652E6D6573736167652E616C65727428722E6D657373616765297D636F6E737420743D542E636F6E746578742626542E636F6E746578742E6B65793B74262628542E746F6B65';
wwv_flow_imp.g_varchar2_table(174) := '6E262621542E636C61696D6564262621542E636F6E746578742E726561644F6E6C793F452E73657428742C542E746F6B656E293A452E64656C657465287429292C6D2626286D2E76696577242E677269642822756E6C6F636B41637469766522292C6D3D';
wwv_flow_imp.g_varchar2_table(175) := '6E756C6C292C28442626646F63756D656E742E636F6E7461696E732844293F443A70292E666F63757328297D2C6173796E6320646F776E6C6F61642874297B6966284E756D62657228742E73697A65293E7065297B636F6E737420683D6428226122293B';
wwv_flow_imp.g_varchar2_table(176) := '682E687265663D512874292C682E646F776E6C6F61643D742E6E616D652C646F63756D656E742E626F64792E617070656E642868292C682E636C69636B28292C682E72656D6F766528293B72657475726E7D636F6E737420723D61776169742057287429';
wwv_flow_imp.g_varchar2_table(177) := '2C733D55524C2E6372656174654F626A65637455524C2872292C6F3D6428226122293B6F2E687265663D732C6F2E646F776E6C6F61643D742E6E616D652C646F63756D656E742E626F64792E617070656E64286F292C6F2E636C69636B28292C6F2E7265';
wwv_flow_imp.g_varchar2_table(178) := '6D6F766528292C73657454696D656F75742828293D3E55524C2E7265766F6B654F626A65637455524C2873292C366534297D2C707265766965773A577D293B6C657420443D6E756C6C3B6173796E632066756E6374696F6E207128742C72297B69662876';
wwv_flow_imp.g_varchar2_table(179) := '2E6469616C6F672E6F70656E2972657475726E3B443D727C7C6E756C6C3B636F6E737420733D4328292C6F3D732E6D6F64656C2C683D747C7C732E76696577242E6772696428226765744163746976655265636F726422293B6966282168297B652E6D65';
wwv_flow_imp.g_varchar2_table(180) := '73736167652E616C6572742822436C69636B20746865206174746163686D656E747320627574746F6E206F66206120726F772E22293B72657475726E7D636F6E737420773D6F2E6765745265636F72644D65746164617461286F2E6765745265636F7264';
wwv_flow_imp.g_varchar2_table(181) := '4964286829297C7C7B7D2C6B3D2121772E696E7365727465642C463D28772E6669656C64737C7C7B7D295B79286F295D7C7C7B7D2C523D667C7C216F2E616C6C6F77456469742868297C7C212128462E636B7C7C462E64697361626C6564292C74653D6B';
wwv_flow_imp.g_varchar2_table(182) := '3F6E756C6C3A537472696E672856286F2E67657456616C756528682C6965286F2929293F3F2222293B696628216B2626217465297B652E6D6573736167652E616C65727428225468697320726F7720686173206E6F207265636F7264206B65792E22293B';
wwv_flow_imp.g_varchar2_table(183) := '72657475726E7D732E76696577242E677269642822696E456469744D6F646522292626732E76696577242E6772696428226765744163746976655265636F726422293D3D3D68262628732E76696577242E6772696428226C6F636B41637469766522292C';
wwv_flow_imp.g_varchar2_table(184) := '6D3D73293B7472797B636F6E73742073653D5B302C312C325D2E6D61702876653D3E7B636F6E7374206E653D286E2E6669656C64737C7C5B5D292E66696E642868653D3E68652E6E3D3D3D76652B31293B696628216E652972657475726E22223B696628';
wwv_flow_imp.g_varchar2_table(185) := '6E652E646B696E643D3D3D22434F4C554D4E22297472797B72657475726E20537472696E672856286F2E67657456616C756528682C6E652E6476616C29293F3F2222297D63617463687B72657475726E22227D72657475726E206E652E646B696E643D3D';
wwv_flow_imp.g_varchar2_table(186) := '3D224954454D222626652E6974656D286E652E6476616C292E67657456616C756528297C7C22227D292C72653D56286F2E67657456616C756528682C79286F2929293B617761697420762E6F70656E287B6B65793A74652C746F6B656E3A6A287265293F';
wwv_flow_imp.g_varchar2_table(187) := '72653A22222C6F726967696E616C3A72652C72657573653A216A28726529262674652626452E676574287465297C7C22222C7265636F72643A682C6D6F64656C3A6F2C726561644F6E6C793A522C64656661756C74733A73652C6C6162656C3A6B3F224E';
wwv_flow_imp.g_varchar2_table(188) := '657720726F77202D207468652066696C657320617265206C696E6B656420746F206974207768656E20796F7520736176652074686520677269642E223A22227D297D6361746368287365297B7468726F77206D2626286D2E76696577242E677269642822';
wwv_flow_imp.g_varchar2_table(189) := '756E6C6F636B41637469766522292C6D3D6E756C6C292C73657D7D696628702E6F6E636C69636B3D28293D3E7B7128292E636174636828743D3E652E6D6573736167652E616C65727428742E6D65737361676529297D2C652E6974656D2E637265617465';
wwv_flow_imp.g_varchar2_table(190) := '286E2E6974656D2C7B6974656D5F747970653A2249475F4154544143484D454E5453222C67657456616C756528297B6966286A286C2E76616C756529297472797B636F6E737420743D4328292C723D742E76696577242E67726964282267657441637469';
wwv_flow_imp.g_varchar2_table(191) := '76655265636F726422293B69662872297B636F6E737420733D5628742E6D6F64656C2E67657456616C756528722C7928742E6D6F64656C2929292C6F3D733D3D6E756C6C3F22223A537472696E672873293B6F213D3D6C2E76616C75652626286C2E7661';
wwv_flow_imp.g_varchar2_table(192) := '6C75653D6F2C4F2829297D7D63617463687B7D72657475726E206C2E76616C75657D2C73657456616C75652874297B6C2E76616C75653D562874297C7C22222C4F28297D2C646973706C617956616C7565466F722874297B72657475726E207565286E2C';
wwv_flow_imp.g_varchar2_table(193) := '562874292C61297D2C676574506F70757053656C6563746F7228297B72657475726E2223222B762E6469616C6F672E69647D2C736574466F63757328297B702E666F63757328297D2C64697361626C6528297B663D21307D2C656E61626C6528297B663D';
wwv_flow_imp.g_varchar2_table(194) := '21317D2C697344697361626C656428297B72657475726E20667D2C67657456616C696469747928297B72657475726E7B76616C69643A21307D7D2C67657456616C69646174696F6E4D65737361676528297B72657475726E22227D7D292C4F28292C6E2E';
wwv_flow_imp.g_varchar2_table(195) := '73657475705761726E696E67297B636F6E737420743D224947204174746163686D656E74732028222B6E2E6974656D2B22293A20222B6E2E73657475705761726E696E673B747970656F6620636F6E736F6C653C2275222626636F6E736F6C652E776172';
wwv_flow_imp.g_varchar2_table(196) := '6E2874293B7472797B652E6D6573736167652E73686F774572726F7273285B7B747970653A226572726F72222C6C6F636174696F6E3A2270616765222C6D6573736167653A742C756E736166653A21317D5D297D63617463687B7D7D636F6E7374204B3D';
wwv_flow_imp.g_varchar2_table(197) := '6E6577204D61703B66756E6374696F6E20582874297B6966284B2E6861732874292972657475726E3B636F6E737420723D742E737562736372696265287B6F6E4368616E676528732C6F297B696628733D3D3D22636F7079222626286F2E7265636F7264';
wwv_flow_imp.g_varchar2_table(198) := '737C7C5B5D292E666F724561636828683D3E742E73657456616C756528682C792874292C222229292C733D3D3D22726576657274222626286F2E7265636F7264737C7C5B5D292E666F724561636828683D3E7B636F6E737420773D742E6765745265636F';
wwv_flow_imp.g_varchar2_table(199) := '726449642868292C6B3D4D2E6765742877293B696628216B2972657475726E3B4D2E64656C6574652877293B636F6E737420463D742E6765745265636F72644D657461646174612877297C7C7B7D3B6C657420523D6E756C6C3B7472797B523D462E696E';
wwv_flow_imp.g_varchar2_table(200) := '7365727465643F6E756C6C3A537472696E67285628742E67657456616C756528682C696528742929293F3F2222297C7C6E756C6C7D63617463687B72657475726E7D472E72657175657374282244495343415244222C7B746F6B656E3A6B2C6B65793A52';
wwv_flow_imp.g_varchar2_table(201) := '7D292E63617463682828293D3E7B7D297D292C733D3D3D227365742226266F26266F2E7265636F726426266F2E6669656C643D3D3D79287429297B636F6E737420683D5628742E67657456616C7565286F2E7265636F72642C6F2E6669656C6429292C77';
wwv_flow_imp.g_varchar2_table(202) := '3D4D2E67657428742E6765745265636F72644964286F2E7265636F726429293B6966286A286829262668213D3D77297B636F6E7374206B3D56286F2E6F6C6456616C7565293B742E73657456616C7565286F2E7265636F72642C6F2E6669656C642C216A';
wwv_flow_imp.g_varchar2_table(203) := '286B297C7C6B3D3D3D773F537472696E67286B3F3F2222293A2222297D7D733D3D3D2264657374726F792226264B2E64656C6574652874297D7D293B4B2E73657428742C72297D66756E6374696F6E204228297B6C657420743B7472797B743D4328297D';
wwv_flow_imp.g_varchar2_table(204) := '63617463687B72657475726E7D636F6E737420723D28742E76696577242E677269642822676574436F6C756D6E7322297C7C5B5D292E66696E6428733D3E732E656C656D656E7449643D3D3D6E2E6974656D7C7C732E70726F70657274793D3D3D792874';
wwv_flow_imp.g_varchar2_table(205) := '2E6D6F64656C29293B696628722626722E657363617065213D3D2131297B722E6573636170653D21313B7472797B742E76696577242E67726964282272656672657368436F6C756D6E7322297D63617463687B7D742E76696577242E6772696428227265';
wwv_flow_imp.g_varchar2_table(206) := '667265736822297D7D7472797B58284328292E6D6F64656C292C4228297D63617463687B7D636F6E737420483D6928646F63756D656E74292C633D222E6967615F222B6E2E6974656D2E7265706C616365282F5B5E612D7A412D5A302D395D2F672C225F';
wwv_flow_imp.g_varchar2_table(207) := '22293B482E6F66662863292E6F6E2822696E74657261637469766567726964766965776D6F64656C637265617465222B632C28742C72293D3E7B4128742E746172676574292626285828722E6D6F64656C292C7828292C73657454696D656F7574284229';
wwv_flow_imp.g_varchar2_table(208) := '297D292C482E6F6E2822636C69636B222B632C222E6967612D63656C6C222C743D3E7B76617220773B696628702E636F6E7461696E7328742E746172676574297C7C762E6469616C6F672E6F70656E7C7C2828773D742E7461726765742E636C6F736573';
wwv_flow_imp.g_varchar2_table(209) := '7428222E6967612D63656C6C2229293D3D6E756C6C3F766F696420303A772E6765744174747269627574652822646174612D6967612D6974656D222929213D3D6E2E6974656D2972657475726E3B6C657420723B7472797B723D4328297D63617463687B';
wwv_flow_imp.g_varchar2_table(210) := '72657475726E7D69662821722E76696577245B305D2E636F6E7461696E7328742E746172676574292972657475726E3B636F6E737420733D742E7461726765742E636C6F736573742822747222292C6F3D732626732E6861734174747269627574652822';
wwv_flow_imp.g_varchar2_table(211) := '646174612D696422293F722E6D6F64656C2E6765745265636F726428732E6765744174747269627574652822646174612D69642229293A6E756C6C2C683D742E7461726765742E636C6F736573742822746422293B73657454696D656F75742828293D3E';
wwv_flow_imp.g_varchar2_table(212) := '71286F2C702E636C6F736573742822746422293D3D3D683F6E756C6C3A68292E6361746368286B3D3E652E6D6573736167652E616C657274286B2E6D6573736167652929297D293B636F6E737420623D28293D3E542E627573797C7C762E6469616C6F67';
wwv_flow_imp.g_varchar2_table(213) := '2E6F70656E3B66756E6374696F6E205F28297B7472797B636F6E737420743D4328293B69662821742E76696577242E677269642822696E456469744D6F646522292972657475726E3B636F6E737420723D742E76696577242E6772696428226765744163';
wwv_flow_imp.g_varchar2_table(214) := '7469766543656C6C46726F6D436F6C756D6E4974656D222C6C293B722626722E686173436C6173732626722E686173436C617373282269732D61637469766522292626742E76696577242E677269642822736574456469744D6F6465222C2131297D6361';
wwv_flow_imp.g_varchar2_table(215) := '7463687B7D7D636F6E7374207A3D6E6577205365743B66756E6374696F6E207828297B6C657420743B7472797B743D4C28292E63616C6C2822676574416374696F6E7322297D63617463687B72657475726E7D636F6E737420723D742E6C6F6F6B757028';
wwv_flow_imp.g_varchar2_table(216) := '227361766522293B69662821722972657475726E3B6C657420733D552E6765742874293B69662821737C7C722E616374696F6E213D3D732E67756172646564297B636F6E7374206F3D722E616374696F6E3B696628747970656F66206F213D2266756E63';
wwv_flow_imp.g_varchar2_table(217) := '74696F6E222972657475726E3B636F6E737420683D6E6577205365742C773D6E6577205365742C6B3D66756E6374696F6E282E2E2E46297B666F7228636F6E73742052206F66206829696628522829297B652E6D6573736167652E616C6572742822436C';
wwv_flow_imp.g_varchar2_table(218) := '6F736520746865206174746163686D656E742070616E656C206265666F726520736176696E672074686520677269642E22293B72657475726E7D666F7228636F6E73742052206F662077295228293B72657475726E206F2E6170706C7928746869732C46';
wwv_flow_imp.g_varchar2_table(219) := '297D3B733D7B6F726967696E616C3A6F2C677561726465643A6B2C636865636B733A682C6C65617665733A777D2C552E73657428742C73292C722E616374696F6E3D6B7D732E636865636B732E6164642862292C732E6C65617665732E616464285F292C';
wwv_flow_imp.g_varchar2_table(220) := '7A2E6164642874297D7828292C482E6F6E2822696E74657261637469766567726964766965776368616E6765222B632C743D3E7B4128742E746172676574292626287828292C73657454696D656F7574284229297D293B636F6E7374204E3D743D3E7B28';
wwv_flow_imp.g_varchar2_table(221) := '542E627573797C7C762E6469616C6F672E6F70656E29262628742E70726576656E7444656661756C7428292C652E6576656E742E6743616E63656C466C61673D21302C652E6D6573736167652E616C6572742822436C6F73652074686520617474616368';
wwv_flow_imp.g_varchar2_table(222) := '6D656E742070616E656C206265666F7265207375626D697474696E672E2229297D3B482E6F6E2822617065786265666F7265706167657375626D6974222B632C4E293B636F6E737420493D7B6F70656E3A712C6973427573793A622C64657374726F7928';
wwv_flow_imp.g_varchar2_table(223) := '297B76617220723B6D26266D2E76696577242E677269642822756E6C6F636B41637469766522293B666F7228636F6E73745B732C6F5D6F66204B29732E756E537562736372696265286F293B666F7228636F6E73742073206F66207A297B636F6E737420';
wwv_flow_imp.g_varchar2_table(224) := '6F3D552E6765742873293B6F2626286F2E636865636B732E64656C6574652862292C6F2E6C65617665732E64656C657465285F292C6F2E636865636B732E73697A657C7C282828723D732E6C6F6F6B75702822736176652229293D3D6E756C6C3F766F69';
wwv_flow_imp.g_varchar2_table(225) := '6420303A722E616374696F6E293D3D3D6F2E67756172646564262628732E6C6F6F6B757028227361766522292E616374696F6E3D6F2E6F726967696E616C292C552E64656C65746528732929297D482E6F66662863292C762E64657374726F7928292C70';
wwv_flow_imp.g_varchar2_table(226) := '2E6F6E636C69636B3D6E756C6C3B636F6E737420743D5A2E6765742849293B742626502E6765742874293D3D3D492626502E64656C6574652874292C5A2E64656C6574652849297D7D3B72657475726E20502E736574286E2E6974656D2C49292C6E2E63';
wwv_flow_imp.g_varchar2_table(227) := '6F6C756D6E26266E2E636F6C756D6E213D3D6E2E6974656D262621502E686173286E2E636F6C756D6E29262628502E736574286E2E636F6C756D6E2C49292C5A2E73657428492C6E2E636F6C756D6E29292C497D66756E6374696F6E20666528297B7265';
wwv_flow_imp.g_varchar2_table(228) := '7475726E20747970656F6620617065783C2275223F617065783A6E756C6C7D72657475726E7B696E69743A77652C6765743A6E3D3E502E676574286E292C53657373696F6E3A63652C63726561746550616E656C3A64652C76616C696461746546696C65';
wwv_flow_imp.g_varchar2_table(229) := '3A6F652C62797465733A242C756E777261703A562C746F4261736536343A61657D7D293B0A';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(13763252969159728)
,p_plugin_id=>wwv_flow_imp.id(13045247398558757)
,p_file_name=>'js/igAttachments.min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false)
);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
