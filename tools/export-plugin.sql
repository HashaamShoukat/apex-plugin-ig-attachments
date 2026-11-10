-- Exports the IG Attachments plug-in from the demo application into plugin/ (run with SQLcl from this folder):
--   cd tools
--   sql -S /nolog @export-plugin.sql <connection name> <application id>
-- The application (APEXlang source in the demo app) is the plug-in's definition; this file is generated.
connect -name &1
set termout off feedback off verify off heading off pagesize 0
column plugin_id new_value plugin_id
select plugin_id from apex_appl_plugins where application_id = &2 and name = 'COM.HASHAAM.IG_ATTACHMENTS';
set termout on
apex export -applicationid &2 -expComponents "PLUGIN:&plugin_id" -dir ../plugin/export
exit
