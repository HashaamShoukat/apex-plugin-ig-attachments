// Live check of the Extra Fields on page 300 (Document Type and Remarks text fields, hidden Category from the grid).
// Works on the claim "QA existing claim" (created by the cleanup script).
const { chromium, BASE, USER, PASSWORD, launchOptions, login } = require("./config");
const path = require("path");
const fs = require("fs");
const OUT = path.join(__dirname, "out");
const res = {}, fails = [];
const check = (name, ok, detail) => { res[name] = ok ? "ok" : { FAIL: detail }; if (!ok) fails.push(name); };
(async () => {
    fs.mkdirSync(path.join(OUT, "files"), { recursive: true });
    const note = path.join(OUT, "files", "taxi.txt");
    fs.writeFileSync(note, "Taxi receipt\n");
    const browser = await chromium.launch(launchOptions);
    const page = await (await browser.newContext({ viewport: { width: 1366, height: 900 } })).newPage();
    const log = [];
    page.on("pageerror", e => log.push("pageerror: " + e.message));
    page.on("console", m => { if (["error", "warning"].includes(m.type())) log.push(m.type() + ": " + m.text()); });
    page.on("dialog", d => d.accept());
    const panel = "#ATTACHMENT_EDIT_PANEL";
    const wait = ms => page.waitForTimeout(ms);
    const ready = () => page.waitForFunction(p => !document.querySelector(p + " .iga-browse").disabled, panel, { timeout: 30000 });
    const S = await login(page);
    await page.goto(BASE + "ig-attachments?session=" + S); await page.waitForSelector("#expenses_ig .a-GV-table");
    await wait(800);
    const rowIndex = () => page.evaluate(() => {
        const v = apex.region("expenses_ig").call("getViews", "grid"); let i = -1, n = 0;
        v.model.forEach(r => { if (v.model.getValue(r, "DESCRIPTION") === "QA existing claim") i = n; n++; });
        return i;
    });
    const openRow = async () => {
        const n = await rowIndex();
        await page.locator("#expenses_ig .a-GV-bdy tr[data-id]").nth(n).locator(".iga-cell").click();
        await page.waitForFunction(p => document.querySelector(p)?.open, panel);
        await ready();
    };
    const fileRow = name => page.locator(panel + " .iga-file", { hasText: name });
    const docInput = () => fileRow("taxi.txt").locator(".iga-field input").nth(0);
    const remarksInput = () => fileRow("taxi.txt").locator(".iga-field input").nth(1);
    const save = async () => {
        await page.evaluate(() => apex.region("expenses_ig").call("getActions").invoke("save"));
        await page.waitForFunction(() => !apex.region("expenses_ig").call("getViews", "grid").model.isChanged(), null, { timeout: 30000 }).catch(() => {});
        await wait(1200);
    };
    const pending = () => page.evaluate(() => {
        const v = apex.region("expenses_ig").call("getViews", "grid"); let t = null;
        v.model.forEach(r => { if (v.model.getValue(r, "DESCRIPTION") === "QA existing claim") t = v.model.getValue(r, "ATTACHMENT_EDIT"); });
        // pending = an edit token; a number is the file count
        return /^[A-F0-9]{32}$/.test(t || "") ? t : null;
    });

    // ---- new file: defaults, inputs, hidden field not shown
    await openRow();
    await page.setInputFiles(panel + " input[type=file]", [note]);
    await wait(200); await ready();
    const first = await fileRow("taxi.txt").evaluate(r => ({
        labels: Array.from(r.querySelectorAll(".iga-field label")).map(l => l.textContent),
        inputs: r.querySelectorAll(".iga-field input[type=text]").length, selects: r.querySelectorAll("select, textarea").length,
        doc: r.querySelectorAll(".iga-field input")[0].value, required: !!r.querySelector(".iga-field.is-required")
    }));
    check("inputsShown", JSON.stringify(first.labels) === JSON.stringify(["Document Type", "Remarks"]), first.labels);
    check("hiddenFieldNotShown", !first.labels.includes("Category"), first.labels);
    check("textFieldsOnly", first.inputs === 2 && first.selects === 0, first);
    check("noDefault", first.doc === "", first.doc);
    check("requiredMarked", first.required, first);
    await page.screenshot({ path: path.join(OUT, "fields-1-new.png") });
    // required: empty Document Type blocks Done
    await page.click(panel + " .iga-done");
    await wait(300);
    const blocked = await page.evaluate(p => ({ open: document.querySelector(p).open, msg: document.querySelector(p + " .iga-message").textContent }), panel);
    check("requiredBlocksDone", blocked.open && /Fill in Document Type for taxi\.txt/.test(blocked.msg), blocked);
    // fill in
    await docInput().fill("Invoice");
    await docInput().press("Tab");
    await wait(700); await ready();
    await remarksInput().fill("Taxi to the airport");
    await remarksInput().press("Tab");
    await wait(900); await ready();
    const filled = await fileRow("taxi.txt").evaluate(r => ({ doc: r.querySelectorAll(".iga-field input")[0].value, remarks: r.querySelectorAll(".iga-field input")[1].value }));
    check("valuesKeptAfterRedraw", filled.doc === "Invoice" && filled.remarks === "Taxi to the airport", filled);
    await page.click(panel + " .iga-done");
    await wait(400);
    check("doneClosesWhenFilled", !(await page.evaluate(p => document.querySelector(p).open, panel)), "still open");
    check("rowPendingAfterAdd", !!(await pending()), "no token");
    await save();
    check("savedRowClean", !(await pending()), await pending());

    // ---- saved file: values shown, change remarks -> Changes pending -> saved
    await openRow();
    const saved = await fileRow("taxi.txt").evaluate(r => ({ doc: r.querySelectorAll(".iga-field input")[0].value, remarks: r.querySelectorAll(".iga-field input")[1].value,
        badge: r.querySelector(".iga-badge").textContent }));
    check("savedValuesShown", saved.doc === "Invoice" && saved.remarks === "Taxi to the airport" && saved.badge === "Saved", saved);
    await remarksInput().fill("Taxi to the airport and back");
    await remarksInput().press("Tab");
    await wait(900); await ready();
    const changed = await fileRow("taxi.txt").evaluate(r => r.querySelector(".iga-badge").textContent);
    check("savedChangeBadge", changed === "Changes pending", changed);
    await page.screenshot({ path: path.join(OUT, "fields-2-changed.png") });
    await page.click(panel + " .iga-done"); await wait(400);
    check("rowPendingAfterChange", !!(await pending()), "no token");
    await save();

    // ---- change back to the saved value: not pending
    await openRow();
    await remarksInput().fill("Taxi");
    await remarksInput().press("Tab");
    await wait(900); await ready();
    await remarksInput().fill("Taxi to the airport and back");
    await remarksInput().press("Tab");
    await wait(900); await ready();
    const back = await fileRow("taxi.txt").evaluate(r => r.querySelector(".iga-badge").textContent);
    check("changeBackNotPending", back === "Saved", back);
    await page.click(panel + " .iga-done"); await wait(400);
    check("rowCleanAfterChangeBack", !(await pending()), await pending());

    // ---- tampering: a value that is too long, sent straight to the plug-in
    const html = await page.content();
    const ajax = JSON.parse('"' + ((html.match(/"ajax":"((?:[^"\\]|\\.)+)"/) || [])[1] || "") + '"');
    const tamper = await page.evaluate(async ({ ajax }) => { try {
        const v = apex.region("expenses_ig").call("getViews", "grid"); let key = null;
        v.model.forEach(r => { if (v.model.getValue(r, "DESCRIPTION") === "QA existing claim") key = v.model.getValue(r, "ID"); });
        const open = await apex.server.plugin(ajax, { x01: "OPEN", x03: key }, { dataType: "json" });
        const file = open.files.find(f => f.name === "taxi.txt");
        const bad = await apex.server.plugin(ajax, { x01: "FIELDS", x02: open.token, x03: key, x04: file.id, f02: ["x".repeat(4100), "x", "y"] }, { dataType: "json" });
        // a Hidden value cannot be changed from the browser either
        const hid = await apex.server.plugin(ajax, { x01: "FIELDS", x02: open.token, x03: key, x04: file.id, f02: ["Other", "ok", "Changed"] }, { dataType: "json" });
        const after = hid.files.find(f => f.name === "taxi.txt");
        return { bad, hiddenAfter: after.values };
    } catch (x) { return { bad: { ok: "threw", status: x.status, text: String(x.responseText || x.message || x).slice(0, 300) }, hiddenAfter: [] }; } }, { ajax });
    check("serverRejectsTooLong", tamper.bad.ok === false && /Document Type is too long/.test(tamper.bad.reason), tamper.bad);
    check("serverKeepsHiddenValue", tamper.hiddenAfter[2] === "Travel", tamper.hiddenAfter);

    // ---- Hidden Category follows the grid column when the row is saved
    const hiddenValues = desc => page.evaluate(async ({ ajax, desc }) => {
        const v = apex.region("expenses_ig").call("getViews", "grid"); let key = null;
        v.model.forEach(r => { if (v.model.getValue(r, "DESCRIPTION") === desc) key = v.model.getValue(r, "ID"); });
        const open = await apex.server.plugin(ajax, { x01: "OPEN", x03: key }, { dataType: "json" });
        return (open.files || []).map(f => f.values[2]);
    }, { ajax, desc });
    // as a user would: the Category cell becomes the active cell first (Fuel makes the attachment cell
    // read only; the grid must not still be editing it then)
    const setCategory = (desc, value) => page.evaluate(([desc, value]) => {
        const v = apex.region("expenses_ig").call("getViews", "grid");
        v.model.forEach(r => { if (v.model.getValue(r, "DESCRIPTION") === desc) {
            v.view$.grid("gotoCell", v.model.getRecordId(r), "CATEGORY");
            v.model.setValue(r, "CATEGORY", value);
        } });
    }, [desc, value]);
    // a saved row: a new category goes to its saved files, without opening the attachments
    await setCategory("QA existing claim", "Meals");
    await save();
    const changedCat = await hiddenValues("QA existing claim");
    check("hiddenFollowsColumnChange", changedCat.length > 0 && changedCat.every(c => c === "Meals"), changedCat);
    // a new row: files added while the category is empty get the category chosen afterwards
    await page.evaluate(() => apex.region("expenses_ig").call("getActions").invoke("selection-add-row"));
    await wait(500);
    await page.evaluate(() => {
        const v = apex.region("expenses_ig").call("getViews", "grid"), rec = v.view$.grid("getActiveRecord");
        v.model.setValue(rec, "DESCRIPTION", "QA category later row"); v.model.setValue(rec, "AMOUNT", "8");
    });
    await wait(300);
    const later = await page.evaluate(() => { const v = apex.region("expenses_ig").call("getViews", "grid"); let i = -1, n = 0;
        v.model.forEach(r => { if (v.model.getValue(r, "DESCRIPTION") === "QA category later row") i = n; n++; }); return i; });
    await page.locator("#expenses_ig .a-GV-bdy tr[data-id]").nth(later).locator(".iga-cell").click();
    await page.waitForFunction(p => document.querySelector(p)?.open, panel); await ready();
    await page.setInputFiles(panel + " input[type=file]", [note]);
    await wait(200); await ready();
    await docInput().fill("Receipt"); await docInput().press("Tab");
    await wait(700); await ready();
    await page.click(panel + " .iga-done"); await wait(400);
    await setCategory("QA category later row", "Fuel");
    await save();
    const laterCat = await hiddenValues("QA category later row");
    check("hiddenTakenAtSave", laterCat.length === 1 && laterCat[0] === "Fuel", laterCat);

    // ---- Minimum Files per Row = 1: rows without a file are not saved
    const saveMessage = async () => {
        await page.evaluate(() => apex.region("expenses_ig").call("getActions").invoke("save"));
        await wait(2500);
        return page.evaluate(() => document.body.innerText.includes("Add an attachment to this row."));
    };
    const limits = await page.evaluate(p => document.querySelector(p + " .iga-drop small").textContent, panel);
    check("panelShowsMinimum", /1 file required/.test(limits), limits);
    // an existing claim without files: changing it is refused
    await page.evaluate(() => {
        const v = apex.region("expenses_ig").call("getViews", "grid");
        v.model.forEach(r => { if (v.model.getValue(r, "DESCRIPTION") === "QA empty claim") v.model.setValue(r, "AMOUNT", "21"); });
    });
    check("existingRowWithoutFileRefused", await saveMessage(), "no message");
    await page.screenshot({ path: path.join(OUT, "fields-3-minimum.png") });
    await page.evaluate(() => { const v = apex.region("expenses_ig").call("getViews", "grid"); const recs = [];
        v.model.forEach(r => { if (v.model.getValue(r, "DESCRIPTION") === "QA empty claim") recs.push(r); }); v.model.revertRecords(recs); });
    // a new row without files is refused too
    await page.evaluate(() => apex.region("expenses_ig").call("getActions").invoke("selection-add-row"));
    await wait(500);
    await page.evaluate(() => {
        const v = apex.region("expenses_ig").call("getViews", "grid"), rec = v.view$.grid("getActiveRecord");
        v.model.setValue(rec, "CATEGORY", "Fuel"); v.model.setValue(rec, "DESCRIPTION", "QA no file row"); v.model.setValue(rec, "AMOUNT", "5");
    });
    check("newRowWithoutFileRefused", await saveMessage(), "no message");
    const stored = await page.evaluate(() => { const v = apex.region("expenses_ig").call("getViews", "grid"); let id = null;
        v.model.forEach(r => { if (v.model.getValue(r, "DESCRIPTION") === "QA no file row") id = v.model.getValue(r, "ID"); }); return id; });
    check("newRowNotSaved", !/^d+$/.test(String(stored)), stored);

    res.log = log; res.FAILED = fails;
    console.log(JSON.stringify(res, null, 2));
    await browser.close();
    process.exit(fails.length ? 1 : 0);
})().catch(e => { console.error(e.message.split("\n")[0]); res.FAILED = fails; console.log(JSON.stringify(res, null, 2)); process.exit(1); });
