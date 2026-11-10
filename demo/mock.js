/* UI demonstration only. No Oracle database or persistence. */
(() => {
    "use strict";
    const api = igaAttachments, edits = new Map(), uploads = new Map(), savedFiles = new Map();
    let rows = [
        { id: "EX-1042", description: "Hotel accommodation", amount: 850, token: "", saved: true },
        { id: "EX-1043", description: "Airport transfer", amount: 120, token: "", saved: true },
        { id: null, description: "Client meeting expenses", amount: 240, token: "", saved: false }
    ];
    let nextId = 1044;
    function uuid() { return crypto.randomUUID().replaceAll("-", "").toUpperCase(); }
    function seed(row, name, text) {
        const blob = new Blob([text], { type: "application/octet-stream" });
        const file = { id: uuid(), name, mime: blob.type, size: blob.size, ready: true, staged: false, removed: false, blob };
        savedFiles.set(row.id, [file]);
    }
    seed(rows[0], "hotel-booking.txt", "Hotel booking confirmation\nGuest: Demo user\nTotal: SAR 850");
    const notice = text => { document.getElementById("notice").textContent = text; };
    function visible(data) {
        const edit = edits.get(data.token);
        return [
            ...(savedFiles.get(data.key) || []).map(f => ({ ...f, removed: Boolean(edit?.removed.has(f.id)) })),
            ...[...uploads.values()].filter(f => f.token === data.token).map(f => ({ ...f, staged: true, removed: false }))
        ].map(({ blob, parts, token, ...f }) => f);
    }
    const cfg = { item: "DEMO_ATTACHMENTS", maxBytes: 10485760, maxCount: 10, accept: ".pdf,.png,.jpg,.jpeg,.txt" };
    const adapter = {
        setToken(ctx, token) { ctx.row.token = token; render(); },
        clearToken(ctx) { ctx.row.token = ""; render(); },
        async request(op, data) {
            await new Promise(resolve => setTimeout(resolve, op === "CHUNK" ? 18 : 60));
            if (op === "OPEN") {
                if (!data.token) {
                    data.token = uuid();
                    edits.set(data.token, { key: data.key, removed: new Set() });
                }
                return { ok: true, token: data.token, files: visible(data) };
            }
            if (op === "LIST") return { ok: true, files: visible(data) };
            if (op === "START") {
                const id = uuid();
                uploads.set(id, { id, token: data.token, name: data.name, size: data.size,
                    mime: "application/octet-stream", ready: false, parts: [], received: 0 });
                return { ok: true, uploadId: id };
            }
            const mimeOf = name => ({ png: "image/png", jpg: "image/jpeg", jpeg: "image/jpeg", pdf: "application/pdf" })[name.split(".").pop().toLowerCase()] || "application/octet-stream";
            if (op === "PUT") {
                // one request for a small file: start, bytes and finish; the reply is the new list
                const binary = atob(data.chunks.join(""));
                const mime = mimeOf(data.name), id = uuid();
                uploads.set(id, { id, token: data.token, name: data.name, size: data.size, mime, ready: true,
                    blob: new Blob([Uint8Array.from(binary, c => c.charCodeAt(0))], { type: mime }) });
                return { ok: true, files: visible(data) };
            }
            const file = uploads.get(data.id);
            if (op === "CHUNK") {
                const binary = atob(data.chunks.join(""));
                const part = Uint8Array.from(binary, c => c.charCodeAt(0));
                if (data.offset === file.received) { file.parts.push(part); file.received += part.length; }
                return { ok: true, received: file.received };
            }
            if (op === "FINISH") {
                if (file.received !== file.size) throw new Error("Incomplete upload.");
                file.mime = mimeOf(file.name);
                file.blob = new Blob(file.parts, { type: file.mime }); file.ready = true; delete file.parts;
                return { ok: true, files: visible(data) };
            }
            if (op === "REMOVE") {
                if (file) uploads.delete(data.id);
                else if (data.restore) edits.get(data.token).removed.delete(data.id);
                else edits.get(data.token).removed.add(data.id);
                return { ok: true, files: visible(data) };
            }
            throw new Error("Unknown demo operation.");
        }
    };
    const session = new api.Session(cfg, adapter);
    const findFile = file => uploads.get(file.id) || [...savedFiles.values()].flat().find(f => f.id === file.id);
    const panel = api.createPanel(cfg, session, {
        onclose() { session.settle(); render(); },
        preview: async file => findFile(file).blob,
        download(file) {
            const url = URL.createObjectURL(findFile(file).blob);
            const a = document.createElement("a"); a.href = url; a.download = file.name; a.click();
            setTimeout(() => URL.revokeObjectURL(url), 1000);
        }
    });
    function render() {
        const body = document.getElementById("rows"); body.replaceChildren();
        rows.forEach((row, index) => {
            const tr = document.createElement("tr");
            for (const text of [String(index + 1).padStart(2, "0"), row.description, row.amount.toFixed(2)]) {
                const td = document.createElement("td"); td.textContent = text; tr.append(td);
            }
            const status = document.createElement("td"), badge = document.createElement("span");
            badge.className = "status" + (!row.saved || row.token ? " new" : "");
            badge.textContent = !row.saved ? "New row" : row.token ? "Pending edits" : "Saved"; status.append(badge);
            const cell = document.createElement("td"), button = document.createElement("button");
            button.className = "row-attach";
            const files = visible({ key: row.id, token: row.token }).filter(f => !f.removed);
            button.textContent = files.length ? "↳ " + files.length + " files" : "＋ Add files";
            button.onclick = () => panel.open({ key: row.id, token: row.token, row,
                label: (row.id || "New row") + " · " + row.description, readOnly: false });
            cell.append(button); tr.append(status, cell); body.append(tr);
        });
        document.getElementById("rowCount").textContent = rows.length + " records";
    }
    document.getElementById("add").onclick = () => {
        rows.push({ id: null, description: "New expense", amount: 0, token: "", saved: false }); render();
    };
    document.getElementById("save").onclick = () => {
        if (panel.dialog.open || session.busy) { notice("Close the attachment panel before saving."); return; }
        if ([...uploads.values()].some(f => !f.ready)) { notice("Remove incomplete uploads before saving."); return; }
        rows.forEach(row => {
            const edit = edits.get(row.token);
            if (!row.id) row.id = "EX-" + nextId++;
            const files = (savedFiles.get(row.id) || []).filter(f => !edit?.removed.has(f.id));
            for (const [id, file] of uploads) if (file.token === row.token) {
                files.push({ ...file, staged: false, removed: false }); uploads.delete(id);
            }
            savedFiles.set(row.id, files); edits.delete(row.token); row.token = ""; row.saved = true;
        });
        render(); notice("Demo saved. Attachment additions and removals are now applied.");
    };
    document.getElementById("revert").onclick = () => {
        rows = rows.filter(r => r.saved); rows.forEach(r => { r.token = ""; });
        edits.clear(); uploads.clear(); render(); notice("Pending edits reverted. Saved files are unchanged.");
    };
    render();
})();

