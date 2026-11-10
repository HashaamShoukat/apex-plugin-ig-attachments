// Live check of IG Attachments on the demo page (Expense Claims). Settings: see qa/config.js.
//   node qa/live.js [outDir]
// Works on its own claims only: "QA existing claim" (created by the cleanup script) and "QA new row ...".
const { chromium, BASE, USER, PASSWORD, launchOptions, login } = require("./config");
const path = require("path");
const fs = require("fs");
const crypto = require("crypto");

const OUT = path.resolve(process.argv[2] || path.join(__dirname, "out"));
const res = {}, fails = [];
const sha = b => crypto.createHash("sha256").update(b).digest("hex");
const check = (name, ok, detail) => { res[name] = ok ? "ok" : { FAIL: detail }; if (!ok) fails.push(name); };

function files() {
    const dir = path.join(OUT, "files");
    fs.mkdirSync(dir, { recursive: true });
    const png = Buffer.from("89504E470D0A1A0A0000000D49484452000000010000000108060000001F15C4890000000D4944415478DA63F8CFC0F01F0005000201FFA65F8E0F0000000049454E44AE426082", "hex");
    const out = {
        png: [path.join(dir, "receipt.png"), png],
        pdf: [path.join(dir, "invoice.pdf"), Buffer.concat([Buffer.from("%PDF-1.4\n"), crypto.randomBytes(450 * 1024)])], // 3 chunks
        txt: [path.join(dir, "note.txt"), Buffer.from("Taxi receipt lost - approved by manager.\n")],
        kb25: [path.join(dir, "scan-25kb.txt"), crypto.randomBytes(12 * 1024).toString("hex").slice(0, 25 * 1024)],
        big: [path.join(dir, "too-big.txt"), Buffer.alloc(5 * 1024 * 1024 + 10, 65)],
        exe: [path.join(dir, "tool.exe"), Buffer.from("MZ....")],
        fakePdf: [path.join(dir, "fake.pdf"), Buffer.from("not a pdf at all")]
    };
    for (const [p, b] of Object.values(out)) fs.writeFileSync(p, b);
    return out;
}

(async () => {
    fs.mkdirSync(OUT, { recursive: true });
    const F = files();
    const browser = await chromium.launch(launchOptions);
    const ctx = await browser.newContext({ viewport: { width: 1366, height: 900 }, acceptDownloads: true });
    const page = await ctx.newPage();
    const log = [], ops = [];
    page.on("console", m => { if (["error", "warning"].includes(m.type())) log.push(`${m.type()}: ${m.text()}`); });
    page.on("pageerror", e => log.push(`pageerror: ${e.message}`));
    page.on("request", r => { const op = (decodeURIComponent(r.postData() || "").match(/x01=([A-Z]+)/) || [])[1]; if (op) ops.push(op); });
    page.on("dialog", d => d.accept());
    const shot = n => page.screenshot({ path: path.join(OUT, n + ".png") });
    const wait = ms => page.waitForTimeout(ms);
    const panel = "#ATTACHMENT_EDIT_PANEL";
    const ig = fn => page.evaluate(fn);

    // ---- login page: a demo account button (if the page has one) fills both fields
    await page.goto(BASE + "login");
    if (await page.$("#fill-demo")) {
        await page.click("#fill-demo");
        const filled = await page.evaluate(() => [apex.item("P9999_USERNAME").getValue(), apex.item("P9999_PASSWORD").getValue()]);
        check("loginButtonFills", filled[0] === USER && filled[1] === PASSWORD, "the button filled other values");
    }
    const SESSION = await login(page);
    await page.goto(BASE + "ig-attachments?session=" + SESSION);
    await page.waitForSelector("#expenses_ig .a-GV-table");
    await wait(800);

    const rows = () => ig(() => {
        const v = apex.region("expenses_ig").call("getViews", "grid"), out = [];
        v.model.forEach(r => { const m = v.model.getRecordMetadata(v.model.getRecordId(r)) || {};
            out.push({ id: v.model.getValue(r, "ID"), desc: v.model.getValue(r, "DESCRIPTION"), files: /^\d+$/.test(v.model.getValue(r, "ATTACHMENT_EDIT") || "") ? v.model.getValue(r, "ATTACHMENT_EDIT") : null,
                token: /^[A-F0-9]{32}$/.test(v.model.getValue(r, "ATTACHMENT_EDIT") || "") ? v.model.getValue(r, "ATTACHMENT_EDIT") : "", changed: !!(m.updated || m.inserted), inserted: !!m.inserted }); });
        return out;
    });
    const indexOf = async desc => (await rows()).findIndex(r => r.desc === desc);
    async function point(n) {
        return page.evaluate(n => {
            const th = Array.from(document.querySelectorAll("#expenses_ig .a-GV-hdr th")).find(h => h.textContent.trim() === "Attachments").getBoundingClientRect();
            const tr = document.querySelectorAll("#expenses_ig .a-GV-bdy tr[data-id]")[n].getBoundingClientRect();
            return { x: th.left + th.width / 2, y: tr.top + tr.height / 2 };
        }, n);
    }
    const isOpen = () => page.evaluate(p => !!document.querySelector(p)?.open, panel);
    const ready = () => page.waitForFunction(p => !document.querySelector(p + " .iga-browse").disabled, panel, { timeout: 60000 });
    // one real mouse click on the row's Attachments cell; returns whether the panel opened
    async function clickCell(n) {
        const xy = await point(n);
        await page.mouse.click(xy.x, xy.y);
        const opened = await page.waitForFunction(p => document.querySelector(p)?.open, panel, { timeout: 3000 }).then(() => true, () => false);
        if (opened) await ready();
        return opened;
    }
    const panelState = () => page.evaluate(p => ({
        context: document.querySelector(p + " .iga-context").textContent,
        message: document.querySelector(p + " .iga-message").textContent,
        files: Array.from(document.querySelectorAll(p + " .iga-file")).map(f => f.querySelector("strong").textContent + " | " + f.querySelector(".iga-badge").textContent)
    }), panel);
    // Done, after filling in the column's required Extra Field (Document Type) where it is empty
    const done = async () => {
        const empty = page.locator(panel + " .iga-field.is-required input:not(:disabled)");
        for (let i = 0; i < await empty.count(); i++) {
            const input = empty.nth(i);
            if (!(await input.inputValue())) { await input.fill("Receipt"); await input.press("Tab"); await wait(300); await ready(); }
        }
        await page.click(panel + " .iga-done"); await wait(400);
    };
    const upload = async list => { await page.setInputFiles(panel + " input[type=file]", list); await wait(150); await ready(); };
    const save = async () => {
        await ig(() => apex.region("expenses_ig").call("getActions").invoke("save"));
        await page.waitForFunction(() => !apex.region("expenses_ig").call("getViews", "grid").model.isChanged(), null, { timeout: 30000 }).catch(() => {});
        await wait(1200);
    };
    const cellText = n => page.evaluate(n => document.querySelectorAll("#expenses_ig .a-GV-bdy tr[data-id]")[n].querySelector(".iga-cell, .iga-open")?.textContent.trim(), n);

    // ---- the cell
    const base = await rows();
    const r1 = base.findIndex(r => r.desc === "QA existing claim");
    res.rows = base.length;
    const look = await page.evaluate(() => {
        const cell = document.querySelector("#expenses_ig .a-GV-bdy .iga-cell");
        return { icon: !!cell?.querySelector(".fa-paperclip"), text: cell?.textContent.trim(), cursor: cell && getComputedStyle(cell).cursor };
    });
    check("cellIconAndLabel", look.icon && /^Attachments\d*$/.test(look.text), look);
    check("cellHandPointer", look.cursor === "pointer", look);

    // ---- one click, starting in Navigation mode
    check("oneClickFromNavigationMode", await clickCell(r1), "panel did not open");
    const st0 = await panelState();
    check("noRecordLabel", st0.context === "", st0.context);
    await done();
    let now = (await rows())[r1];
    check("openCloseLeavesRowUnchanged", !now.changed && !now.token, now);
    check("openCloseCellNotPending", !/Pending/.test(await cellText(r1)), await cellText(r1));
    await shot("01-after-open-close");
    const cursorActive = await page.evaluate(() => getComputedStyle(document.getElementById("ATTACHMENT_EDIT_OPEN")).cursor);
    check("activeCellHandPointer", cursorActive === "pointer", cursorActive);

    // ---- one click on another row, in Edit mode
    const other = r1 === 0 ? 1 : 0;
    check("oneClickInEditMode", await clickCell(other), "panel did not open");
    await done();

    // ---- refused files: type, fake content, size
    await clickCell(r1);
    await upload([F.exe[0]]);
    check("refusesType", /tool\.exe: this file type is not allowed/.test((await panelState()).message), (await panelState()).message);
    await upload([F.fakePdf[0]]);
    const fake = await panelState();
    check("refusesFakePdf", /does not match its extension/.test(fake.message) && !fake.files.some(f => f.startsWith("fake.pdf")), fake);
    await upload([F.big[0]]);
    check("refusesTooBig", /too-big\.txt \(5 MB\) is larger than the 5 MB limit/.test((await panelState()).message), (await panelState()).message);
    now = (await rows())[r1];
    check("refusedFilesLeaveRowUnchanged", !now.changed, now);

    // ---- small file: shows at once, one request, timing
    ops.length = 0;
    const t0 = Date.now();
    await page.setInputFiles(panel + " input[type=file]", [F.kb25[0]]);
    const shownAt = await page.waitForFunction(p => Array.from(document.querySelectorAll(p + " .iga-file strong")).some(s => s.textContent === "scan-25kb.txt"), panel, { timeout: 20000 })
        .then(() => Date.now() - t0);
    await ready();
    res.small25kb = { shownInListMs: shownAt, doneMs: Date.now() - t0, requests: ops.slice() };
    check("smallFileOneRequest", ops.length === 1 && ops[0] === "PUT", ops);
    // add then remove on an existing row: back to unchanged
    await page.locator(panel + " .iga-file", { hasText: "scan-25kb.txt" }).locator("button", { hasText: "Remove" }).click();
    await wait(800); await ready();
    await done();
    now = (await rows())[r1];
    check("existingRowAddRemoveUnchanged", !now.changed && !now.token, now);

    // ---- 3 files incl. a 3-chunk PDF, count limit, save
    await clickCell(r1);
    await upload([F.png[0], F.pdf[0], F.txt[0]]);
    const up = await panelState();
    check("uploadThree", up.files.filter(f => f.endsWith("Pending save")).length === 3, up);
    await upload([F.kb25[0]]);
    check("countLimit", /Maximum 3 files per row/.test((await panelState()).message), (await panelState()).message);
    await shot("02-panel-uploaded");
    await done();
    check("pendingShownAfterChange", /Pending/.test(await cellText(r1)), await cellText(r1));
    await save();
    now = (await rows())[r1];
    check("savedThree", now.files === "3" && !now.token && !now.changed, now);

    // ---- reopen: saved, download bytes, preview, staged removal, save
    await clickCell(r1);
    const re = await panelState();
    check("reopenSaved", re.files.length === 3 && re.files.every(f => f.endsWith("Saved")), re);
    const [dl] = await Promise.all([page.waitForEvent("download", { timeout: 20000 }),
        page.locator(panel + " .iga-file", { hasText: "invoice.pdf" }).locator("button", { hasText: "Download" }).click()]);
    const dlPath = path.join(OUT, "dl-" + dl.suggestedFilename());
    await dl.saveAs(dlPath);
    check("downloadSameBytes", sha(fs.readFileSync(dlPath)) === sha(F.pdf[1]), dl.suggestedFilename());
    await page.locator(panel + " .iga-file", { hasText: "receipt.png" }).locator("button", { hasText: "Preview" }).click();
    await wait(1500);
    check("preview", await page.evaluate(p => !!document.querySelector(p + " img.iga-preview")?.naturalWidth, panel), "no image");
    await page.locator(panel + " .iga-file", { hasText: "note.txt" }).locator("button", { hasText: "Remove" }).click();
    await wait(800); await ready();
    // restore and remove again: restore alone must leave the row unchanged
    await page.locator(panel + " .iga-file", { hasText: "note.txt" }).locator("button", { hasText: "Restore" }).click();
    await wait(800); await ready();
    await done();
    now = (await rows())[r1];
    check("removeRestoreUnchanged", !now.changed && !now.token, now);
    await clickCell(r1);
    await page.locator(panel + " .iga-file", { hasText: "note.txt" }).locator("button", { hasText: "Remove" }).click();
    await wait(800); await ready();
    await done();
    await save();
    now = (await rows())[r1];
    check("removalSaved", now.files === "2", now);

    // ---- new row: add + remove -> not pending; then add + save
    await ig(() => apex.region("expenses_ig").call("getActions").invoke("selection-add-row"));
    await wait(500);
    await ig(() => {
        const v = apex.region("expenses_ig").call("getViews", "grid"), rec = v.view$.grid("getActiveRecord");
        v.model.setValue(rec, "CATEGORY", "Fuel");
        v.model.setValue(rec, "DESCRIPTION", "QA new row with attachment");
        v.model.setValue(rec, "AMOUNT", "75");
    });
    await wait(300);
    const ni = await indexOf("QA new row with attachment");
    check("oneClickNewRow", await clickCell(ni), "panel did not open");
    check("newRowHint", /New row/.test((await panelState()).context), (await panelState()).context);
    await upload([F.txt[0]]);
    await page.locator(panel + " .iga-file", { hasText: "note.txt" }).locator("button", { hasText: "Remove" }).click();
    await wait(800); await ready();
    await done();
    now = (await rows())[ni];
    check("newRowAddRemoveNotPending", !now.token && !/Pending/.test(await cellText(ni)), { now, cell: await cellText(ni) });
    await shot("03-new-row-add-remove");
    await clickCell(ni);
    await upload([F.txt[0]]);
    await done();
    await save();
    now = (await rows()).find(r => r.desc === "QA new row with attachment");
    check("newRowSavedWithFile", now && /^\d+$/.test(now.id) && now.files === "1", now);
    await shot("04-saved");

    res.log = log;
    res.FAILED = fails;
    fs.writeFileSync(path.join(OUT, "result.json"), JSON.stringify(res, null, 2));
    console.log(JSON.stringify(res, null, 2));
    await browser.close();
    process.exit(fails.length ? 1 : 0);
})().catch(e => {
    console.error(e.message.split("\n")[0]);
    res.FAILED = fails; res.crash = e.message.split("\n")[0];
    fs.writeFileSync(path.join(OUT, "result.json"), JSON.stringify(res, null, 2));
    console.log(JSON.stringify(res, null, 2));
    process.exit(1);
});
