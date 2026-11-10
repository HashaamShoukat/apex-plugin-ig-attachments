// Settings of the live checks (qa/*.js), from environment variables - no server or account in the repo.
//   IGA_BASE      the application's base URL, e.g. https://host/ords/r/myworkspace/my-app/
//   IGA_USER      a test account of that application
//   IGA_PASSWORD  its password
//   CHROME        optional: path of chrome.exe (else the installed Chrome is used)
// Needs playwright-core (npm install --no-save playwright-core). The page under test is the demo page
// "ig-attachments" (Expense Claims) of the demo application.
const path = require("path");

function need(name) {
    const value = process.env[name];
    if (!value) {
        console.error("Set " + name + " first (see qa/config.js).");
        process.exit(2);
    }
    return value;
}

const BASE = need("IGA_BASE").replace(/\/?$/, "/");
const USER = need("IGA_USER");
const PASSWORD = need("IGA_PASSWORD");
const { chromium } = require("playwright-core");

module.exports = {
    BASE, USER, PASSWORD, chromium,
    OUT: path.join(__dirname, "out"),
    launchOptions: process.env.CHROME ? { executablePath: process.env.CHROME, headless: true } : { channel: "chrome", headless: true },
    // signs in on the application's login page and returns the session id
    async login(page) {
        await page.goto(BASE + "login");
        await page.fill("#P9999_USERNAME", USER);
        await page.fill("#P9999_PASSWORD", PASSWORD);
        await Promise.all([page.waitForNavigation(), page.click("button:has-text('Sign In')")]);
        return new URL(page.url()).searchParams.get("session");
    }
};
