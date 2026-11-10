// Reproduces "first file appears at once, the second takes seconds": two uploads through the real
// Choose files button and file chooser, with in-page timing of every step and long main-thread tasks.
const { chromium, BASE, USER, PASSWORD, launchOptions, login } = require("./config");
const path = require("path");
const fs = require("fs");
(async () => {
    const dir = path.join(__dirname, "out", "files");
    fs.mkdirSync(dir, { recursive: true });
    const a = path.join(dir, "first-10kb.txt"), b = path.join(dir, "second-5kb.txt"), c = path.join(dir, "third-8kb.txt");
    fs.writeFileSync(a, "a".repeat(10240)); fs.writeFileSync(b, "b".repeat(5120)); fs.writeFileSync(c, "c".repeat(8192));
    const browser = await chromium.launch(launchOptions);
    const page = await (await browser.newContext({ viewport: { width: 1366, height: 900 } })).newPage();
    const log = [];
    page.on("console", m => log.push(m.type() + ": " + m.text()));
    const S = await login(page);
    await page.goto(BASE + "ig-attachments?session=" + S); await page.waitForSelector("#expenses_ig .a-GV-table");
    await page.waitForTimeout(800);
    // instrumentation: long tasks, change events, Ajax sends, list changes
    await page.evaluate(() => {
        window.__t = [];
        const mark = what => window.__t.push([Math.round(performance.now()), what]);
        new PerformanceObserver(l => l.getEntries().forEach(e => mark("LONGTASK " + Math.round(e.duration) + "ms"))).observe({ entryTypes: ["longtask"] });
        document.addEventListener("change", e => { if (e.target.type === "file") mark("change event (" + e.target.files.length + " file)"); }, true);
        const send = XMLHttpRequest.prototype.send;
        XMLHttpRequest.prototype.send = function (body) {
            const op = (decodeURIComponent(String(body || "")).match(/x01=([A-Z]+)/) || [])[1];
            if (op) { mark("send " + op); this.addEventListener("loadend", () => mark("reply " + op)); }
            return send.apply(this, arguments);
        };
        new MutationObserver(() => {
            const names = Array.from(document.querySelectorAll("#ATTACHMENT_EDIT_PANEL .iga-file strong")).map(s => s.textContent).join(",");
            if (names !== window.__names) { window.__names = names; mark("list: " + names); }
        }).observe(document.body, { subtree: true, childList: true });
        window.__mark = mark;
    });
    // new row, as in the screenshot
    await page.evaluate(() => apex.region("expenses_ig").call("getActions").invoke("selection-add-row"));
    await page.waitForTimeout(500);
    await page.evaluate(() => {
        const v = apex.region("expenses_ig").call("getViews", "grid"), rec = v.view$.grid("getActiveRecord");
        v.model.setValue(rec, "CATEGORY", "Fuel"); v.model.setValue(rec, "DESCRIPTION", "QA second-file test"); v.model.setValue(rec, "AMOUNT", "1");
        v.view$.grid("gotoCell", v.model.getRecordId(rec), "ATTACHMENT_EDIT");
    });
    await page.waitForTimeout(400);
    await page.click("#ATTACHMENT_EDIT_OPEN");
    await page.waitForFunction(() => !document.querySelector("#ATTACHMENT_EDIT_PANEL .iga-browse").disabled);
    for (const file of [a, b, c]) {
        await page.evaluate(n => window.__mark("click Choose files for " + n), path.basename(file));
        const [chooser] = await Promise.all([page.waitForEvent("filechooser"), page.click("#ATTACHMENT_EDIT_PANEL .iga-browse")]);
        await page.evaluate(() => window.__mark("chooser open"));
        await chooser.setFiles(file);
        await page.waitForFunction(n => (window.__names || "").includes(n), path.basename(file), { timeout: 20000 });
        await page.waitForFunction(() => !document.querySelector("#ATTACHMENT_EDIT_PANEL .iga-browse").disabled, null, { timeout: 20000 });
        await page.waitForTimeout(500);
    }
    const t = await page.evaluate(() => window.__t);
    const t0 = t[0][0];
    console.log(t.map(([ms, w]) => String(ms - t0).padStart(6) + " ms  " + w).join("\n"));
    console.log(log.filter(l => !l.startsWith("log:")).join("\n"));
    // clean up: Done, revert the new row
    await page.click("#ATTACHMENT_EDIT_PANEL .iga-done");
    await page.evaluate(() => { const v = apex.region("expenses_ig").call("getViews", "grid"); v.model.revertRecords([v.view$.grid("getActiveRecord")]); });
    await browser.close();
})().catch(e => { console.error(e); process.exit(1); });
