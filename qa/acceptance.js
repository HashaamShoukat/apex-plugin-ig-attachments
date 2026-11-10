// Live acceptance checks of IG Attachments on the demo page (Expense Claims), with two browser
// sessions (A, B) and SQLcl for the database steps. Settings: qa/config.js, plus
//   IGA_SQLCL       path of SQLcl's sql(.exe)
//   IGA_SQLCL_CONN  a saved SQLcl connection to the demo application's parsing schema
// Works on its own claims only ("QA ..."), created and removed here.
const { chromium, BASE, launchOptions, login, OUT } = require("./config");
const path = require("path");
const fs = require("fs");
const crypto = require("crypto");
const { execFileSync } = require("child_process");

const SQLCL = process.env.IGA_SQLCL, CONN = process.env.IGA_SQLCL_CONN;
if (!SQLCL || !CONN) { console.error("Set IGA_SQLCL and IGA_SQLCL_CONN (see qa/acceptance.js)."); process.exit(2); }
const res = {}, fails = [];
const check = (name, ok, detail) => { res[name] = ok ? "ok" : { FAIL: detail }; if (!ok) fails.push(name); };

// runs SQL in the parsing schema; returns the output
function sql(text) {
    const file = path.join(OUT, "acceptance.sql");
    fs.writeFileSync(file, "connect -name " + CONN + "\nset feedback off heading off pagesize 0\n" + text + "\nexit\n");
    return execFileSync(SQLCL, ["-S", "/nolog", "@" + file], { encoding: "utf8", cwd: OUT });
}

const files = {};
function file(name, content) {
    const p = path.join(OUT, "files", name);
    fs.writeFileSync(p, content);
    return files[name] = p;
}

async function session(browser) {
    const page = await (await browser.newContext({ viewport: { width: 1366, height: 900 } })).newPage();
    page.on("dialog", d => d.accept());
    const S = await login(page);
    await page.goto(BASE + "ig-attachments?session=" + S);
    await page.waitForSelector("#expenses_ig .a-GV-table");
    await page.waitForTimeout(800);
    await helpers(page);
    return page;
}
// the plug-in's Ajax calls, straight (as a tampering user would); again after each reload
function helpers(page) {
    return page.evaluate(() => {
        const cfg = JSON.parse(document.getElementById("ATTACHMENT_EDIT_CFG").textContent);
        window.qaCall = (op, p) => apex.server.plugin(cfg.ajax, Object.assign({ x01: op }, p), { dataType: "json" })
            .catch(x => x.responseJSON || { ok: false, reason: "HTTP " + x.status });
        window.qaKey = desc => { const v = apex.region("expenses_ig").call("getViews", "grid"); let k = null;
            v.model.forEach(r => { if (v.model.getValue(r, "DESCRIPTION") === desc) k = v.model.getValue(r, "ID"); }); return k; };
        window.qaValue = desc => { const v = apex.region("expenses_ig").call("getViews", "grid"); let k = null;
            v.model.forEach(r => { if (v.model.getValue(r, "DESCRIPTION") === desc) k = v.model.getValue(r, "ATTACHMENT_EDIT"); }); return k; };
    });
}
const panel = "#ATTACHMENT_EDIT_PANEL";
const ready = page => page.waitForFunction(p => !document.querySelector(p + " .iga-browse")?.disabled, panel, { timeout: 120000 });
async function openRow(page, desc) {
    const n = await page.evaluate(d => { const v = apex.region("expenses_ig").call("getViews", "grid"); let i = -1, k = 0;
        v.model.forEach(r => { if (v.model.getValue(r, "DESCRIPTION") === d) i = k; k++; }); return i; }, desc);
    await page.locator("#expenses_ig .a-GV-bdy tr[data-id]").nth(n).locator(".iga-cell").click();
    await page.waitForFunction(p => document.querySelector(p)?.open, panel);
    await page.waitForFunction(p => !document.querySelector(p + " .iga-status").textContent.includes("Working"), panel, { timeout: 30000 });
}
const upload = async (page, list) => { await page.setInputFiles(panel + " input[type=file]", list); await page.waitForTimeout(200); await ready(page); };
const message = page => page.evaluate(p => document.querySelector(p + " .iga-message").textContent, panel);
const names = page => page.evaluate(p => Array.from(document.querySelectorAll(p + " .iga-file strong")).map(s => s.textContent), panel);
// Done, after filling in the column's required Extra Field (Document Type) where it is empty
const done = async page => {
    const empty = page.locator(panel + " .iga-field.is-required input:not(:disabled)");
    for (let i = 0; i < await empty.count(); i++) {
        const input = empty.nth(i);
        if (!(await input.inputValue())) { await input.fill("Receipt"); await input.press("Tab"); await page.waitForTimeout(300); await ready(page); }
    }
    await page.click(panel + " .iga-done"); await page.waitForTimeout(400);
};
async function save(page) {
    await page.evaluate(() => apex.region("expenses_ig").call("getActions").invoke("save"));
    await page.waitForTimeout(3000);
    return page.evaluate(() => (document.body.innerText.match(/Changes saved|1 error has occurred\s*\n?.*/) || [""])[0]);
}

(async () => {
    fs.mkdirSync(path.join(OUT, "files"), { recursive: true });
    // ---- the test claims (the closed one is older than 90 days: its files are read only)
    sql(`delete from iga_demo_expenses where description like 'QA %';
insert into iga_demo_expenses (expense_date, category, description, amount, owner_name) values (trunc(sysdate), 'Travel', 'QA acceptance claim', 10, 'DEMO');
insert into iga_demo_expenses (expense_date, category, description, amount, owner_name) values (trunc(sysdate) - 120, 'Hotel', 'QA closed claim', 20, 'DEMO');
insert into iga_demo_expenses (expense_date, category, description, amount, owner_name) values (trunc(sysdate), 'Office', 'QA size claim', 30, 'DEMO');
insert into iga_demo_expenses (expense_date, category, description, amount, owner_name) values (trunc(sysdate), 'Fuel', 'QA fuel claim', 40, 'DEMO');
insert into iga_demo_expense_files (expense_id, file_name, mime_type, file_size, content, document_type)
select id, 'closed-receipt.txt', 'application/octet-stream', 5, utl_raw.cast_to_raw('hello'), 'RECEIPT' from iga_demo_expenses where description = 'QA closed claim';
commit;`);
    const browser = await chromium.launch(launchOptions);
    const A = await session(browser), B = await session(browser);
    const key = await A.evaluate(() => qaKey("QA acceptance claim"));
    const appId = await A.evaluate(() => apex.env.APP_ID);

    // ---- files the plug-in must refuse, one upload with good files among them
    file("ok.txt", "fine\n");
    file("empty.txt", "");
    file("eicar.txt", "X5O!P%@AP[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*");
    file("x' onmouseover=alert(1) b.txt", "hostile name\n");
    await openRow(A, "QA acceptance claim");
    await upload(A, [files["empty.txt"], files["ok.txt"], files["eicar.txt"], files["x' onmouseover=alert(1) b.txt"]]);
    const m1 = await message(A), n1 = await names(A);
    check("emptyFileRefused", /empty\.txt is empty/.test(m1), m1);
    check("fileCheckFunctionRefusesEicar", /eicar\.txt: it contains the EICAR anti-virus test signature/.test(m1), m1);
    check("goodFilesStillSent", n1.includes("ok.txt") && n1.includes("x' onmouseover=alert(1) b.txt"), n1);
    check("hostileNameShownAsText", await A.evaluate(p => !document.querySelector(p + " [onmouseover]"), panel), "an attribute was injected");

    // ---- tampering with the token, the key and other sessions
    const open = await A.evaluate(k => qaCall("OPEN", { x03: k }), key);
    const otherKey = await A.evaluate(() => qaKey("QA closed claim"));
    const r1 = await B.evaluate(([t, k]) => qaCall("LIST", { x02: t, x03: k }), [open.token, key]);
    check("otherSessionCannotUseToken", r1.ok === false && /expired|not owned/i.test(r1.reason), r1);
    const r2 = await A.evaluate(([t, k]) => qaCall("FIELDS", { x02: t, x03: k, x04: "1", f02: ["INVOICE", "", ""] }), [open.token, otherKey]);
    check("tokenOfAnotherRecordRefused", r2.ok === false, r2);
    const r3 = await A.evaluate(k => qaCall("DOWNLOAD", { x03: k, x04: "999999999" }), key);
    check("downloadOfUnknownFileRefused", r3.ok === false && /not found/i.test(r3.reason || ""), r3);
    const status = await A.evaluate(async k => {
        const cfg = JSON.parse(document.getElementById("ATTACHMENT_EDIT_CFG").textContent);
        const r = await fetch(apex.server.pluginUrl(cfg.ajax, { x01: "DOWNLOAD", x03: k, x04: "999999999" }), { credentials: "same-origin" });
        return r.status;
    }, key);
    check("failedDownloadIsNotAFile", status === 403, status);
    const r4 = await B.evaluate(k => qaCall("OPEN", { x03: String(Number(k) + 100000) }), key);
    check("foreignRecordRefused", r4.ok === false && /access denied/i.test(r4.reason), r4);

    // ---- two editors: the second save is stale
    await done(A);
    const sA = await save(A);
    check("firstEditorSaves", /Changes saved/.test(sA), sA);
    await B.evaluate(() => apex.region("expenses_ig").call("getActions").invoke("refresh"));
    await B.waitForTimeout(1500);
    await openRow(B, "QA acceptance claim");
    sql(`-- A saves again meanwhile: an attachment version B did not see
update iga_record_versions set attachment_version = attachment_version + 1 where scope_name = 'P300.ATTACHMENT_EDIT' and record_key = '${key}';
commit;`);
    await upload(B, [files["ok.txt"]]);
    await done(B);
    const sB = await save(B);
    // review 2026-11-07: files only added by the second editor go in as well (nothing B saw was changed)
    const merged = await B.evaluate(() => qaValue("QA acceptance claim"));
    check("staleSecondEditorAddsMerged", /Changes saved/.test(sB) && merged === "3", { sB, merged });
    // the added copy goes again with a normal save ...
    await openRow(B, "QA acceptance claim");
    await B.locator(panel + " .iga-file", { hasText: "ok.txt" }).last().locator("button", { hasText: "Remove" }).click();
    await B.waitForTimeout(500); await ready(B);
    await done(B);
    const sB2 = await save(B);
    const back = await B.evaluate(() => qaValue("QA acceptance claim"));
    check("removalSaved", /Changes saved/.test(sB2) && back === "2", { sB2, back });
    // ... but a removal made on files another save changed meanwhile is refused
    await openRow(B, "QA acceptance claim");
    await B.locator(panel + " .iga-file", { hasText: "ok.txt" }).first().locator("button", { hasText: "Remove" }).click();
    await B.waitForTimeout(500); await ready(B);
    sql(`update iga_record_versions set attachment_version = attachment_version + 1 where scope_name = 'P300.ATTACHMENT_EDIT' and record_key = '${key}';
commit;`);
    await done(B);
    const sB3 = await save(B);
    check("staleSecondEditorRemovalRefused", /Attachments changed in another editor/.test(sB3), sB3);

    // ---- a refused save keeps the staged files; reverting leaves the saved ones
    await B.evaluate(() => { const v = apex.region("expenses_ig").call("getViews", "grid"); const recs = [];
        v.model.forEach(r => { if (v.model.getValue(r, "DESCRIPTION") === "QA acceptance claim") recs.push(r); }); v.model.revertRecords(recs); });
    await B.waitForTimeout(500);
    const afterRevert = await B.evaluate(() => qaValue("QA acceptance claim"));
    check("revertRestoresCount", afterRevert === "2", afterRevert);

    // ---- maximum total size per row (10 MB on the demo page), on an empty claim: the third file would go over it
    const mb49 = Buffer.alloc(Math.round(4.9 * 1048576), 66);
    file("big-1.txt", mb49); file("big-2.txt", mb49); file("small.txt", Buffer.alloc(400 * 1024, 67));
    await openRow(A, "QA size claim");
    await upload(A, [files["big-1.txt"], files["big-2.txt"], files["small.txt"]]);
    const m2 = await message(A);
    check("totalSizePerRowRefused", /small\.txt would make the files of this row larger than 10240 KB together/.test(m2), m2);
    for (const n of ["big-1.txt", "big-2.txt"]) {
        await A.locator(panel + " .iga-file", { hasText: n }).locator("button", { hasText: "Remove" }).click();
        await A.waitForTimeout(500); await ready(A);
    }
    await done(A);

    // ---- read only: a closed claim shows its files without changes
    await openRow(A, "QA closed claim");
    const ro = await A.evaluate(p => ({ drop: !document.querySelector(p + " .iga-drop").hidden,
        removes: document.querySelectorAll(p + " .iga-danger").length, files: document.querySelectorAll(p + " .iga-file").length }), panel);
    check("readOnlyShowsFilesWithoutChanges", !ro.drop && ro.removes === 0 && ro.files === 1, ro);
    await done(A);
    // the column's Read Only condition for each row (page 300: Category = Fuel): read only in the panel,
    // and on the server for a request that ignores the browser
    await openRow(A, "QA fuel claim");
    const fuel = await A.evaluate(p => ({ drop: !document.querySelector(p + " .iga-drop").hidden }), panel);
    check("rowReadOnlyConditionInPanel", !fuel.drop, fuel);
    await done(A);
    const fuelOpen = await A.evaluate(() => qaCall("OPEN", { x03: qaKey("QA fuel claim") }));
    check("rowReadOnlyConditionOnServer", fuelOpen.readOnly === true && !fuelOpen.token, fuelOpen);
    const travelOpen = await A.evaluate(() => qaCall("OPEN", { x03: qaKey("QA size claim") }));
    check("otherRowsNotAffected", !!travelOpen.token && !travelOpen.readOnly, travelOpen);

    // ---- per-user staging limit (Component Settings, default 200 MB): another session of the same user
    // already holds almost 200 MB of unsaved files (planted), so this upload must be refused
    sql(`insert into iga_edits (edit_token, workspace_id, application_id, scope_name, session_id, user_name, expires_at)
select 'QA0000000000000000000000000000FF', workspace_id, application_id, scope_name, 1, user_name, systimestamp + interval '1' hour
  from iga_edits where record_key = '${key}' and rownum = 1;
insert into iga_uploads (upload_id, edit_token, file_name, expected_bytes, file_blob)
values ('QA0000000000000000000000000000FE', 'QA0000000000000000000000000000FF', 'planted.bin', 209715200 - 1000, empty_blob());
commit;`);
    file("q1.txt", Buffer.alloc(20 * 1024, 68));
    try {
        await A.reload(); await A.waitForSelector("#expenses_ig .a-GV-table"); await A.waitForTimeout(800);
        await openRow(A, "QA acceptance claim");
        await upload(A, [files["q1.txt"]]);
        const m3 = await message(A);
        check("perUserStagingLimit", /Your files not saved yet would exceed 200 MB/.test(m3), m3);
    } finally {
        sql(`delete from iga_edits where edit_token = 'QA0000000000000000000000000000FF';
commit;`);
    }
    // expire A's open edit: the next action is refused, the cleanup removes its staged file
    sql(`update iga_edits set expires_at = systimestamp - interval '1' minute
 where status = 'A' and record_key = '${key}' and scope_name = 'P300.ATTACHMENT_EDIT';
commit;`);
    file("late.txt", "late\n");
    await upload(A, [files["late.txt"]]);
    const m4 = await message(A);
    check("expiredEditRefused", /expired/i.test(m4), m4);
    const purged = sql(`begin iga_api.purge_expired; commit; end;
/
select count(*) from iga_uploads u where not exists (select 1 from iga_edits e where e.edit_token = u.edit_token);
select count(*) from iga_edits where expires_at < systimestamp;
select count(*) from iga_demo_expense_files f join iga_demo_expenses e on e.id = f.expense_id where e.description = 'QA acceptance claim';`);
    const nums = purged.split(/\s+/).filter(x => /^\d+$/.test(x));
    check("cleanupRemovesExpiredKeepsSaved", nums[0] === "0" && nums[1] === "0" && nums[2] === "2", nums);
    const job = sql(`select enabled from user_scheduler_jobs where job_name = 'IGA_PURGE_EXPIRED';`).trim();
    check("cleanupJobInstalled", /TRUE/.test(job), job);

    // ==== review of 2026-11-05 ====
    await A.keyboard.press("Escape"); await A.waitForTimeout(300);
    await A.reload(); await A.waitForSelector("#expenses_ig .a-GV-table"); await A.waitForTimeout(800); await helpers(A);
    // the grid row of a claim: set a column, save, read what APEX says, revert what is left
    const saveRow = async (page, desc, column, value) => {
        await page.evaluate(([d, c, v]) => { const g = apex.region("expenses_ig").call("getViews", "grid");
            g.model.forEach(r => { if (g.model.getValue(r, "DESCRIPTION") === d) g.model.setValue(r, c, v); }); }, [desc, column, value]);
        await page.evaluate(() => apex.region("expenses_ig").call("getActions").invoke("save"));
        await page.waitForTimeout(3000);
        const text = await page.evaluate(() => document.body.innerText);
        await page.evaluate(d => { const g = apex.region("expenses_ig").call("getViews", "grid"); const recs = [];
            g.model.forEach(r => { if (g.model.getValue(r, "DESCRIPTION") === d) recs.push(r); }); g.model.revertRecords(recs);
            apex.message.clearErrors(); }, desc);
        return text;
    };
    // review 2026-11-07: a token put into a cell by anything but the plug-in (paste, fill) is taken off
    const newTok = (await A.evaluate(() => qaCall("OPEN", {}))).token;
    const pasted = await A.evaluate(t => { const g = apex.region("expenses_ig").call("getViews", "grid"); let v = null;
        g.model.forEach(r => { if (g.model.getValue(r, "DESCRIPTION") === "QA acceptance claim") { g.model.setValue(r, "ATTACHMENT_EDIT", t); v = g.model.getValue(r, "ATTACHMENT_EDIT"); } });
        return v; }, newTok);
    check("pastedTokenTakenOff", pasted !== newTok, pasted);
    await A.evaluate(() => { const g = apex.region("expenses_ig").call("getViews", "grid"); const recs = [];
        g.model.forEach(r => { if (g.model.getValue(r, "DESCRIPTION") === "QA acceptance claim") recs.push(r); }); g.model.revertRecords(recs); });
    // The checks below are a tampering user's: the plug-in's JavaScript is switched off on the page (its
    // paste guard would take the planted tokens off), so only the server decides.
    const tamper = page => page.evaluate(() => igaAttachments.get("ATTACHMENT_EDIT").destroy());
    await tamper(A);
    // 1: a token made for a new row (CREATE) put into an existing, closed claim (WRITE denied) is refused
    const t1 = await saveRow(A, "QA closed claim", "ATTACHMENT_EDIT", newTok);
    check("newRowTokenRefusedOnUpdate", /These attachments were added to a new row/.test(t1), t1.slice(0, 300));
    // 1: a token of another attachment column is refused
    const accKey = await A.evaluate(() => qaKey("QA acceptance claim"));
    const accTok = (await A.evaluate(k => qaCall("OPEN", { x03: k }), accKey)).token;
    sql(`update iga_edits set column_name = 'OTHER_COLUMN' where edit_token = '${accTok}';
commit;`);
    const t2 = await saveRow(A, "QA acceptance claim", "ATTACHMENT_EDIT", accTok);
    check("tokenOfAnotherColumnRefused", /These attachments belong to another column/.test(t2), t2.slice(0, 300));
    // 2: changing the category of a closed claim saves the claim but not its files' Hidden Category
    const t3 = await saveRow(A, "QA closed claim", "CATEGORY", "Meals");
    const cat = sql(`select nvl(f.expense_category, '(null)') || '/' || e.category from iga_demo_expense_files f
  join iga_demo_expenses e on e.id = f.expense_id where e.description = 'QA closed claim';`).trim();
    check("hiddenNotChangedWithoutWrite", /Changes saved/.test(t3) && cat === "(null)/Meals", { cat, text: t3.slice(0, 200) });
    // review 2026-11-07: Minimum Files per Row (1) does not block a row whose files are read only
    // (QA fuel claim: no files, Category = Fuel makes the column read only on that row)
    const t3b = await saveRow(A, "QA fuel claim", "AMOUNT", "41");
    check("minimumNotForReadOnlyRow", /Changes saved/.test(t3b) && !/Add an attachment/.test(t3b), t3b.slice(0, 300));
    // 8: an incomplete upload in the row's edit: the save is refused until it is finished or removed
    await A.reload(); await A.waitForSelector("#expenses_ig .a-GV-table"); await A.waitForTimeout(800); await helpers(A);
    await tamper(A);
    const incTok = (await A.evaluate(k => qaCall("OPEN", { x03: k }), accKey)).token;
    const started = await A.evaluate(([t, k]) => qaCall("START", { x02: t, x03: k, x05: "half.txt", x06: "300000" }), [incTok, accKey]);
    const t4 = await saveRow(A, "QA acceptance claim", "ATTACHMENT_EDIT", incTok);
    check("incompleteUploadBlocksSave", started.ok !== false && /Finish or remove incomplete attachment uploads/.test(t4), { started, text: t4.slice(0, 300) });
    await A.evaluate(([t, k, id]) => qaCall("REMOVE", { x02: t, x03: k, x04: id }), [incTok, accKey, started.uploadId]);
    // 7: viewing a row 105 times reuses one empty edit (the panel presents its own token again);
    // another tab of the same session (no token) gets its own edit; 210 new rows never lock the user out
    const views = await A.evaluate(async k => { const t = new Set(); let bad = null, tok = "";
        for (let i = 0; i < 105; i++) { const r = await qaCall("OPEN", { x02: tok, x03: k }); if (r.ok === false) { bad = r.reason; break; } t.add(r.token); tok = r.token; }
        const other = await qaCall("OPEN", { x03: k });
        return { tokens: t.size, bad, first: tok, otherTab: other.token }; }, accKey);
    check("reopeningReusesEmptyEdit", views.tokens === 1 && !views.bad, views);
    check("otherTabGetsOwnEdit", !!views.otherTab && views.otherTab !== views.first, views);
    const fresh = await A.evaluate(async () => { let bad = null;
        for (let i = 0; i < 210; i++) { const r = await qaCall("OPEN", {}); if (r.ok === false) { bad = i + ": " + r.reason; break; } }
        return { bad, session: apex.env.APP_SESSION }; });
    const empties = sql(`select count(*) from iga_edits where session_id = ${String(fresh.session).replace(/\D/g, "")} and status = 'A';`).trim();
    check("emptyEditsDoNotLockOut", !fresh.bad && Number(empties) <= 200, { fresh, empties });
    // the plug-in back on the page (it was switched off for the tampering checks)
    await A.reload(); await A.waitForSelector("#expenses_ig .a-GV-table"); await A.waitForTimeout(800); await helpers(A);
    file("ok2.txt", "still fine\n");
    await openRow(A, "QA acceptance claim");
    await upload(A, [files["ok2.txt"]]);
    check("uploadAfterManyViews", (await names(A)).includes("ok2.txt"), await message(A));
    await done(A);
    await A.evaluate(() => { const g = apex.region("expenses_ig").call("getViews", "grid"); const recs = [];
        g.model.forEach(r => { if (g.model.getValue(r, "DESCRIPTION") === "QA acceptance claim") recs.push(r); }); g.model.revertRecords(recs); });
    // 6: two sessions reserve at the same time with room for one file: exactly one is accepted.
    // SQLcl holds the user's reservation lock for a few seconds, so both requests are waiting together.
    sql(`insert into iga_edits (edit_token, workspace_id, application_id, scope_name, session_id, user_name, expires_at)
select 'QA0000000000000000000000000000FF', workspace_id, application_id, scope_name, 1, user_name, systimestamp + interval '1' hour
  from iga_edits where record_key = '${accKey}' and rownum = 1;
insert into iga_uploads (upload_id, edit_token, file_name, expected_bytes, file_blob)
select 'QA0000000000000000000000000000FE', 'QA0000000000000000000000000000FF', 'planted.bin',
       209715200 - 300 * 1024 - nvl(sum(u.expected_bytes), 0), empty_blob()
  from iga_uploads u join iga_edits e on e.edit_token = u.edit_token
 where e.user_name = 'DEMO' and e.status = 'A' and e.expires_at > systimestamp;
commit;`);
    try {
        await B.reload(); await B.waitForSelector("#expenses_ig .a-GV-table"); await B.waitForTimeout(800); await helpers(B);
        const sizeKey = await B.evaluate(() => qaKey("QA size claim"));
        const ta = (await A.evaluate(k => qaCall("OPEN", { x03: k }), accKey)).token;
        const tb = (await B.evaluate(k => qaCall("OPEN", { x03: k }), sizeKey)).token;
        // the user's lock row exists (committed), so a probe can see whether it is held
        const lockId = `declare l_ws number; l_app number; l_id number := -1 - dbms_utility.get_hash_value('DEMO', 1, 1073741824); l_n number;`;
        sql(`${lockId}
begin
    select workspace_id, application_id into l_ws, l_app from iga_edits where edit_token = 'QA0000000000000000000000000000FF';
    insert into iga_stage_locks(workspace_id, application_id, session_id) values (l_ws, l_app, l_id);
    commit;
exception when dup_val_on_index then null;
end;
/`);
        // SQLcl holds the lock for 6 seconds - less than the 10 seconds a reservation waits at most
        const holdFile = path.join(OUT, "hold-lock.sql");
        fs.writeFileSync(holdFile, `connect -name ${CONN}
${lockId}
begin
    select workspace_id, application_id into l_ws, l_app from iga_edits where edit_token = 'QA0000000000000000000000000000FF';
    select session_id into l_n from iga_stage_locks where workspace_id = l_ws and application_id = l_app and session_id = l_id for update;
    dbms_session.sleep(6);
    commit;
end;
/
exit
`);
        // a second SQLcl ends as soon as the lock is held (SQLcl needs about 7 seconds to start, so a
        // fixed wait is not enough); it never keeps the row itself (rollback after each look)
        const probeFile = path.join(OUT, "probe-lock.sql");
        fs.writeFileSync(probeFile, `connect -name ${CONN}
${lockId} c sys_refcursor; l_found boolean;
begin
    select workspace_id, application_id into l_ws, l_app from iga_edits where edit_token = 'QA0000000000000000000000000000FF';
    for i in 1 .. 300 loop
        open c for select session_id from iga_stage_locks where workspace_id = l_ws and application_id = l_app and session_id = l_id for update skip locked;
        fetch c into l_n; l_found := c%found; close c;
        rollback;
        exit when not l_found;
        dbms_session.sleep(0.1);
    end loop;
end;
/
exit
`);
        const { spawn } = require("child_process");
        const probe = spawn(SQLCL, ["-S", "/nolog", "@" + probeFile], { cwd: OUT });
        const probed = new Promise(r => probe.on("exit", r));
        const holder = spawn(SQLCL, ["-S", "/nolog", "@" + holdFile], { cwd: OUT });
        let holderOut = "";
        holder.stdout.on("data", d => { holderOut += d; }); holder.stderr.on("data", d => { holderOut += d; });
        const held = new Promise(r => holder.on("exit", r));
        await probed;   // the lock is held now
        const t0 = Date.now();
        const [ra, rb] = await Promise.all([
            A.evaluate(([t, k]) => qaCall("START", { x02: t, x03: k, x05: "race-a.txt", x06: String(250 * 1024) }), [ta, accKey]),
            B.evaluate(([t, k]) => qaCall("START", { x02: t, x03: k, x05: "race-b.txt", x06: String(250 * 1024) }), [tb, sizeKey])]);
        const waited = Date.now() - t0;
        await held;
        const accepted = [ra, rb].filter(r => r.ok !== false).length;
        check("concurrentReservationsWithinUserLimit", accepted === 1 && [ra, rb].some(r => /Your files not saved yet would exceed/.test(r.reason || "")),
            { ra, rb, waited, holder: holderOut.trim().slice(0, 300) });
        check("reservationsWaitForTheUserLock", waited > 1000, waited);
    } finally {
        sql(`delete from iga_edits where edit_token = 'QA0000000000000000000000000000FF';
commit;`);
    }

    await browser.close();
    sql(`delete from iga_demo_expenses where description like 'QA %';
commit;`);
    res.FAILED = fails;
    console.log(JSON.stringify(res, null, 2));
    process.exit(fails.length ? 1 : 0);
})().catch(e => { console.error(e.message.split("\n")[0]); res.FAILED = fails; console.log(JSON.stringify(res, null, 2)); process.exit(1); });
