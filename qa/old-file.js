// Edit the Extra Fields of a saved file that has no values yet (saved before the fields existed).
const { chromium, BASE, USER, PASSWORD, launchOptions, login } = require("./config");
(async () => {
    const browser = await chromium.launch(launchOptions);
    const page = await (await browser.newContext({ viewport: { width: 1366, height: 900 } })).newPage();
    const replies = [];
    page.on("response", async r => {
        const op = (decodeURIComponent(r.request().postData() || "").match(/x01=([A-Z]+)/) || [])[1];
        if (op) replies.push({ op, post: decodeURIComponent(r.request().postData() || "").replace(/p_json=[^&]*/, "").slice(0, 260), body: (await r.text().catch(() => "")).slice(0, 600) });
    });
    const S = await login(page);
    await page.goto(BASE + "ig-attachments?session=" + S); await page.waitForSelector("#expenses_ig .a-GV-table");
    await page.waitForTimeout(800);
    const n = await page.evaluate(() => { const v = apex.region("expenses_ig").call("getViews", "grid"); let i = -1, k = 0;
        v.model.forEach(r => { if (v.model.getValue(r, "DESCRIPTION") === "QA old file claim") i = k; k++; }); return i; });
    await page.locator("#expenses_ig .a-GV-bdy tr[data-id]").nth(n).locator(".iga-cell").click();
    await page.waitForFunction(() => !document.querySelector("#ATTACHMENT_EDIT_PANEL .iga-browse").disabled);
    const row = page.locator("#ATTACHMENT_EDIT_PANEL .iga-file", { hasText: "old-receipt.txt" });
    await row.locator(".iga-field input").nth(0).fill("Invoice");
    await row.locator(".iga-field input").nth(0).press("Tab");
    await page.waitForTimeout(1500);
    const afterSelect = await row.evaluate(r => ({ doc: r.querySelectorAll(".iga-field input")[0].value, badge: r.querySelector(".iga-badge").textContent }));
    await row.locator(".iga-field input").nth(1).fill("typed remark");
    await row.locator(".iga-field input").nth(1).press("Tab");
    await page.waitForTimeout(1500);
    const afterType = await row.evaluate(r => ({ doc: r.querySelectorAll(".iga-field input")[0].value, remarks: r.querySelectorAll(".iga-field input")[1].value,
        badge: r.querySelector(".iga-badge").textContent, msg: document.querySelector("#ATTACHMENT_EDIT_PANEL .iga-message").textContent }));
    await page.click("#ATTACHMENT_EDIT_PANEL .iga-done");
    await page.waitForTimeout(400);
    await page.evaluate(() => apex.region("expenses_ig").call("getActions").invoke("save"));
    await page.waitForTimeout(2500);
    const notice = await page.evaluate(() => (document.body.innerText.match(/Changes saved|error has occurred.*/) || [""])[0]);
    console.log(JSON.stringify({ afterSelect, afterType, notice }, null, 1));
    await browser.close();
})().catch(e => { console.error(e); process.exit(1); });
