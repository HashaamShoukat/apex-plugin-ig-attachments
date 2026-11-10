// Screenshots for the README (docs/images) from the demo page "ig-attachments" - opens panels, saves nothing.
//   IGA_BASE=... IGA_USER=... IGA_PASSWORD=... node qa/shots.js
const path = require("path");
const fs = require("fs");
const { BASE, chromium, launchOptions, login } = require("./config");

const OUT = path.join(__dirname, "..", "docs", "images");

(async () => {
    fs.mkdirSync(OUT, { recursive: true });
    const browser = await chromium.launch(launchOptions);
    for (const [name, viewport] of [["grid", { width: 1440, height: 860 }], ["phone", { width: 390, height: 844 }]]) {
        const ctx = await browser.newContext({ viewport, deviceScaleFactor: name === "phone" ? 2 : 1, serviceWorkers: "block" });
        const page = await ctx.newPage();
        const session = await login(page);
        await page.goto(BASE + "ig-attachments?session=" + session);
        await page.waitForSelector(".iga-cell");
        // only the demo's seeded claims are shown, not what visitors typed into the shared demo account
        await page.evaluate(keep => {
            const v = apex.region("expenses_ig").call("getViews", "grid");
            const re = new RegExp(keep);
            v.model.forEach(r => {
                if (!re.test(String(v.model.getValue(r, "DESCRIPTION")))) {
                    document.querySelectorAll(`#expenses_ig tr[data-id="${v.model.getRecordId(r)}"]`).forEach(tr => { tr.style.display = "none"; });
                }
            });
            document.querySelectorAll("#expenses_ig .a-GV-footer, #expenses_ig .a-GV-status").forEach(e => { e.style.visibility = "hidden"; });
        }, process.env.SHOT_ROWS || "^(Flight Riyadh - Jeddah, site visit|Two nights, Jeddah|Client dinner|Printer toner)$");
        await page.waitForTimeout(500);
        if (name === "grid") { await page.screenshot({ path: path.join(OUT, "grid.png") }); }
        // the claim SHOT_ROW (default: the flight), else the first row with files
        const id = await page.evaluate(text => {
            const v = apex.region("expenses_ig").call("getViews", "grid");
            let found = null;
            v.model.forEach(r => { if (!found && String(v.model.getValue(r, "DESCRIPTION")).includes(text)) found = v.model.getRecordId(r); });
            return found;
        }, process.env.SHOT_ROW || "QA old file claim");
        if (!id) { throw new Error("claim not found"); }
        await page.evaluate(i => document.querySelectorAll(`#expenses_ig tr[data-id="${i}"]`).forEach(tr => { tr.style.display = ""; }), id);
        // a grid row is split over two tables (frozen columns): pick the part with the button
        await page.locator(`#expenses_ig .a-GV-bdy tr[data-id="${id}"] .iga-cell`).first().click();
        await page.waitForSelector("dialog.iga-panel[open], .iga-panel[open], dialog[open]");
        await page.waitForTimeout(900);
        await page.screenshot({ path: path.join(OUT, name === "grid" ? "panel.png" : "phone.png") });
        await ctx.close();
    }
    await browser.close();
    console.log("docs/images: grid.png, panel.png, phone.png");
})().catch(e => { console.error(e); process.exit(1); });
