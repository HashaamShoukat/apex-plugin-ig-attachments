// Upload "receipt (2) ü.txt" to the claim "QA existing claim" without saving, download it, compare the name.
const { chromium, BASE, USER, PASSWORD, launchOptions, login } = require("./config");
const path = require("path");
const fs = require("fs");
(async () => {
    const dir = path.join(__dirname, "out", "files");
    fs.mkdirSync(dir, { recursive: true });
    const name = "receipt (2) \u00fc.txt";
    fs.writeFileSync(path.join(dir, name), "hello\n");
    const browser = await chromium.launch(launchOptions);
    const page = await (await browser.newContext({ acceptDownloads: true })).newPage();
    const S = await login(page);
    await page.goto(BASE + "ig-attachments?session=" + S); await page.waitForSelector("#expenses_ig .a-GV-table");
    await page.evaluate(() => {
        const v = apex.region("expenses_ig").call("getViews", "grid");
        apex.region("expenses_ig").call("getActions").set("edit", true);
        let rec; v.model.forEach(r => { if (v.model.getValue(r, "DESCRIPTION") === "QA existing claim") rec = r; });
        v.view$.grid("gotoCell", v.model.getRecordId(rec), "ATTACHMENT_EDIT");
    });
    await page.waitForTimeout(400);
    await page.click("#ATTACHMENT_EDIT_OPEN");
    await page.waitForFunction(() => !document.querySelector("#ATTACHMENT_EDIT_PANEL .iga-browse").disabled);
    await page.setInputFiles("#ATTACHMENT_EDIT_PANEL input[type=file]", [path.join(dir, name)]);
    await page.waitForTimeout(300);
    await page.waitForFunction(() => !document.querySelector("#ATTACHMENT_EDIT_PANEL .iga-browse").disabled);
    const row = page.locator("#ATTACHMENT_EDIT_PANEL .iga-file", { hasText: "receipt (2)" });
    const [dl] = await Promise.all([page.waitForEvent("download"), row.locator("button", { hasText: "Download" }).click()]);
    console.log(JSON.stringify({ expected: name, got: dl.suggestedFilename(), same: dl.suggestedFilename() === name }));
    // remove it again: the claim stays unchanged
    await row.locator("button", { hasText: "Remove" }).click();
    await page.waitForTimeout(1200);
    await browser.close();
})().catch(e => { console.error(e); process.exit(1); });
