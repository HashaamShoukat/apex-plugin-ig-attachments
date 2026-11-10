// IG Attachments build: dist/ (assets plain and minified + one-file installer) and, with APEX_APP_DIR, an
// APEXlang application's copy of the plug-in (static files, #MIN# file URLs with ?v=<version>-<hash> and the
// version in plugin.apx, install/iga_api.pkb). The version comes from package.json.
//   node build.mjs
//   APEX_APP_DIR=<path of an APEXlang application folder> node build.mjs
// The importable plug-in (plugin/*.sql) is exported from that application: see tools/export-plugin.sql.
import { readFileSync, writeFileSync, mkdirSync, readdirSync, existsSync, copyFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { createHash } from "node:crypto";
import { build } from "esbuild";

const read = p => readFileSync(new URL(p, import.meta.url), "utf8").replace(/^\uFEFF/, "").replaceAll("\r\n", "\n");
const write = (p, s) => writeFileSync(new URL(p, import.meta.url), s);
const path = p => fileURLToPath(new URL(p, import.meta.url));
const version = JSON.parse(read("package.json")).version;

// the JS must stay ASCII: APEX may serve static files without a charset
const js = read("src/igAttachments.js").replace(/^\/\* IG Attachments \S+ /, "/* IG Attachments " + version + " ");
const bad = [...js].findIndex(c => c.charCodeAt(0) > 127);
if (bad >= 0) throw new Error("src/igAttachments.js has a non-ASCII character at " + bad + " - write it as \\uXXXX");

mkdirSync(new URL("dist", import.meta.url), { recursive: true });
write("dist/igAttachments.js", js);
write("dist/igAttachments.css", read("src/igAttachments.css"));
await build({ entryPoints: [path("dist/igAttachments.js")], outfile: path("dist/igAttachments.min.js"), allowOverwrite: true,
              minify: true, charset: "ascii", legalComments: "inline", target: ["es2020", "chrome90", "firefox90", "safari14"] });
await build({ entryPoints: [path("dist/igAttachments.css")], outfile: path("dist/igAttachments.min.css"), allowOverwrite: true,
              minify: true, charset: "ascii", target: ["chrome111", "firefox113", "safari16.2"] });

// one file for SQL Workshop > SQL Scripts: tables, package, check, job (same as db/install.sql)
const check = `declare
    n number;
begin
    select count(*) into n from user_errors where name = 'IGA_API';
    if n > 0 then raise_application_error(-20000, 'IGA_API does not compile: see USER_ERRORS.'); end if;
end;
/
`;
write("dist/install.sql", `-- IG Attachments ${version}: install or upgrade in the application's parsing schema.
-- Safe to run again: tables are created or upgraded, existing files are kept.
set define off
set serveroutput on
` + ["001_tables.sql", "002_package_spec.sql", "003_package_body.sql"].map(p => read("db/" + p).trim() + "\n").join("\n") +
    "\n" + check + "\n" + read("db/004_purge_job.sql"));
write("dist/uninstall.sql", read("db/uninstall.sql"));

// the importable plug-in: the export with the highest number (f1530.sql, f1530_1.sql, ... made by
// tools/export-plugin.sql) - chosen by its name, not its file date, which a copy or a checkout changes
const exportDir = new URL("plugin/export/", import.meta.url);
if (existsSync(exportDir)) {
    const latest = readdirSync(exportDir).filter(n => /^f\d+(_\d+)?\.sql$/.test(n))
        .map(n => ({ n, no: Number((n.match(/_(\d+)\.sql$/) || [0, 0])[1]) })).sort((a, b) => b.no - a.no)[0];
    if (latest) {
        copyFileSync(new URL(latest.n, exportDir), new URL("plugin/item_type_plugin_com_hashaam_ig_attachments.sql", import.meta.url));
        console.log("plugin/item_type_plugin_com_hashaam_ig_attachments.sql from plugin/export/" + latest.n);
    }
}

const appDir = process.env.APEX_APP_DIR;
if (appDir) {
    const app = p => new URL(p, "file:///" + appDir.replaceAll("\\", "/").replace(/\/?$/, "/"));
    const plugDir = "shared-components/plugins/item/igAttachments/";
    const tag = version + "-" + createHash("sha256").update(readFileSync(path("dist/igAttachments.min.js")))
        .update(readFileSync(path("dist/igAttachments.min.css"))).digest("hex").slice(0, 8);
    const files = [["js", "igAttachments.js"], ["js", "igAttachments.min.js"], ["css", "igAttachments.css"], ["css", "igAttachments.min.css"]];
    for (const [dir, name] of files) {
        mkdirSync(app(plugDir + "static-files/" + dir + "/"), { recursive: true });
        writeFileSync(app(plugDir + "static-files/" + dir + "/" + name), readFileSync(path("dist/" + name)));
    }
    writeFileSync(app(plugDir + "static-files.apx"), files.map(([dir, name]) => `file "${dir}/${name}" (\n    mimeType: ` +
        (dir === "js" ? "application/javascript" : "text/css") + "\n    charSet: utf-8\n)\n").join("\n") + "\n");
    const apx = readFileSync(app(plugDir + "plugin.apx"), "utf8")
        .replace(/igAttachments(?:#MIN#)?\.(js|css)\?v=\S+/g, "igAttachments#MIN#.$1?v=" + tag)
        .replace(/(\n {8}version: )\S+/, "$1" + version);
    writeFileSync(app(plugDir + "plugin.apx"), apx);
    mkdirSync(app("shared-components/static-files/install/"), { recursive: true });
    writeFileSync(app("shared-components/static-files/install/iga_api.pkb"),
        read("db/003_package_body.sql").trim().replace(/\s*\/\s*$/, "") + "\n");
    console.log("Updated the plug-in in " + appDir + " (?v=" + tag + ").");
}
for (const f of ["igAttachments.js", "igAttachments.min.js", "igAttachments.css", "igAttachments.min.css"]) {
    console.log(f.padEnd(24), (readFileSync(path("dist/" + f)).length / 1024).toFixed(1) + " KB");
}
console.log("Built dist/ (" + version + ").");
