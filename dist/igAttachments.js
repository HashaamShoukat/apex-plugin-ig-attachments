/* IG Attachments 1.1.0 | MIT */
(function (root, factory) {
    "use strict";
    const api = factory();
    if (typeof module === "object" && module.exports) module.exports = api;
    else root.igaAttachments = api;
}(typeof globalThis !== "undefined" ? globalThis : this, function () {
    "use strict";
    const instances = new Map();
    const aliases = new Map();   // instance -> its column name, when that differs from the item id
    // the grids' Save actions wrapped by attachment columns: actions -> { original, guarded, checks }
    const saveGuards = new Map();
    const unwrap = value => value && typeof value === "object" && "v" in value ? value.v : value;
    function bytes(value) {
        // 5 MB, 2.5 MB, 450 KB: no ".0" on whole numbers
        const fmt = n => String(Math.round(n * 10) / 10);
        return value < 1024 ? value + " B" : value < 1048576
            ? fmt(value / 1024) + " KB" : fmt(value / 1048576) + " MB";
    }
    function validateFile(file, cfg) {
        const ext = file.name.includes(".") ? file.name.split(".").pop().toLowerCase() : "";
        const allowed = cfg.accept.split(",").map(x => x.trim().replace(/^\./, "").toLowerCase());
        if (!allowed.includes(ext)) throw new Error(file.name + ": this file type is not allowed.");
        if (!file.size) throw new Error(file.name + " is empty.");
        if (file.size > cfg.maxBytes) throw new Error(file.name + " (" + bytes(file.size) + ") is larger than the " + bytes(cfg.maxBytes) + " limit.");
    }
    function toBase64(buffer) {
        let binary = "";
        new Uint8Array(buffer).forEach(n => { binary += String.fromCharCode(n); });
        return btoa(binary);
    }
    const CHUNK = 196608; // 192 KB of file bytes per request
    const DIRECT_DOWNLOAD_BYTES = 26214400; // larger downloads go straight to the browser (25 MB)
    // an edit token; the column can also hold a file count (a number) from the grid query
    const TOKEN = /^[A-F0-9]{32}$/;
    const isToken = v => TOKEN.test(v == null ? "" : String(v));
    class Session {
        constructor(cfg, adapter) {
            this.cfg = cfg; this.adapter = adapter; this.token = "";
            this.files = []; this.busy = false; this.context = null;
            this.ready = false; this.progress = null; this.onchange = () => {};
            this.claimed = false;
            // Extra Field values typed but not confirmed by the server yet: file id -> { index: value }.
            // A refused or lost FIELDS request keeps them (the input shows them again, closing retries).
            this.drafts = new Map();
            // FIELDS requests wait for each other and for running work (never "Please wait")
            this.fieldQueue = Promise.resolve();
        }
        // The row holds the token only while something is really pending: a new file (also one
        // whose upload did not finish - the save refuses it until it is removed), a saved file marked
        // for removal or with changed fields. Opening and closing - or adding a file and removing it
        // again - leaves the row as it was. The row is updated when the panel closes, never while
        // files are being picked (no grid work behind the dialog).
        settle() {
            const pending = this.files.some(f => f.staged ? !f.removed : f.removed || f.changed);
            if (pending && !this.claimed && this.token) {
                this.adapter.setToken(this.context, this.token);
                this.claimed = true;
            } else if (!pending && this.claimed && this.adapter.clearToken) {
                this.adapter.clearToken(this.context);
                this.claimed = false;
            }
        }
        async request(op, extra = {}) {
            const response = await this.adapter.request(op, {
                token: this.token, key: this.context.key, ...extra
            });
            if (!response || response.ok === false) throw new Error(response?.reason || response?.error || "Attachment request failed.");
            return response;
        }
        async open(context) {
            if (this.busy) throw new Error("An attachment operation is still running.");
            this.ready = false; this.files = []; this.drafts = new Map();
            // context.token: the token the row holds; context.reuse: this panel's own empty edit of the
            // row from an earlier opening (the row does not hold it), sent so the server reuses it
            this.context = Object.freeze({ ...context });
            this.token = isToken(context.token) ? context.token : isToken(context.reuse) ? context.reuse : "";
            this.claimed = false;
            await this.run(async () => {
                const response = await this.request(this.context.readOnly ? "LIST" : "OPEN");
                if (response.readOnly) {
                    // read only: no edit - an old token of the row must not go with the downloads
                    this.context = Object.freeze({ ...this.context, readOnly: true });
                    this.token = "";
                }
                if (response.token) {
                    // the row already holds this token: nothing to claim
                    this.claimed = response.token === context.token;
                    this.token = response.token;
                }
                // values of new files from the Grid Column / Page Item of each field
                this.defaults = [0, 1, 2].map(i => (context.defaults || [])[i] ?? "");
                this.files = response.files || [];
                this.ready = true;
            });
        }
        async run(fn) {
            if (this.busy) throw new Error("Please wait for the current attachment operation.");
            this.busy = true; this.onchange();
            const work = (async () => {
                try { return await fn(); }
                finally { this.busy = false; this.progress = null; this.running = null; this.onchange(); }
            })();
            this.running = work;
            return work;
        }
        // resolves when no request is running and no field change is waiting (their errors are
        // reported by their callers)
        async idle() {
            for (;;) {
                const queue = this.fieldQueue;
                await queue;
                while (this.running) { try { await this.running; } catch (_) { /* reported elsewhere */ } }
                if (queue === this.fieldQueue && !this.running) return;
            }
        }
        async refresh() {
            this.files = (await this.request("LIST")).files || [];
            this.onchange();
        }
        async upload(files) {
            if (!this.ready) throw new Error("Reopen attachments before making changes.");
            if (this.context.readOnly) throw new Error("This row is read only.");
            return this.run(async () => {
                const problems = [];
                let interrupted = false;
                this.cancelled = false;
                for (const file of files) {
                    // Cancel: no further file; a large one stops between its parts (see below)
                    if (this.cancelled) break;
                    let sent = false;   // a request went out: the server may have stored the file
                    try {
                        validateFile(file, this.cfg);
                        if (this.files.filter(f => !f.removed).length >= this.cfg.maxCount)
                            throw new Error("Maximum " + this.cfg.maxCount + (this.cfg.maxCount === 1 ? " file" : " files") + " per row.");
                        this.progress = { name: file.name, received: 0, size: file.size };
                        this.onchange();
                        if (file.size <= CHUNK) {
                            // one round trip: start, bytes and finish together; the reply is the new list.
                            // Not retried: a lost reply after success would add the file twice.
                            const chunks = toBase64(await file.arrayBuffer()).match(/.{1,8000}/g);
                            sent = true;
                            this.files = (await this.request("PUT", { name: file.name, size: file.size, chunks, values: this.defaults })).files || [];
                        } else {
                            sent = true;
                            const started = await this.request("START", { name: file.name, size: file.size, values: this.defaults });
                            let offset = 0;
                            while (offset < file.size) {
                                if (this.cancelled) {
                                    // the parts already stored are removed (the list below no longer shows the file)
                                    try { await this.request("REMOVE", { id: started.uploadId }); } catch (_) { /* the list shows it */ }
                                    throw new Error(file.name + ": upload cancelled.");
                                }
                                const buffer = await file.slice(offset, offset + CHUNK).arrayBuffer();
                                // 8000 is divisible by 4: each f01 element decodes independently.
                                const chunks = toBase64(buffer).match(/.{1,8000}/g);
                                let response;
                                for (let attempt = 0; attempt < 2; attempt++) {
                                    try {
                                        response = await this.request("CHUNK", { id: started.uploadId, offset, chunks });
                                        break;
                                    } catch (error) { if (attempt === 1) throw error; }
                                }
                                if (!Number.isInteger(response.received) || response.received < offset + buffer.byteLength ||
                                    response.received > file.size) throw new Error("Server returned an invalid upload offset.");
                                offset = response.received;
                                this.progress = { name: file.name, received: offset, size: file.size };
                                this.onchange();
                            }
                            const finished = await this.request("FINISH", { id: started.uploadId });
                            this.files = finished.files || (await this.request("LIST")).files || [];
                        }
                    } catch (error) {
                        // one file refused (type, size, content ...): the others are still sent
                        problems.push(error.message || String(error));
                        // a lost reply after the server stored the file: the list below shows it
                        if (sent) interrupted = true;
                    }
                }
                // An interrupted upload remains visible and removable (an incomplete one blocks
                // finalization); a refused one is not in the list.
                if (interrupted) { try { this.files = (await this.request("LIST")).files || []; } catch (_) { /* keep list */ } }
                if (this.cancelled && !problems.some(p => /cancelled/.test(p))) problems.push("Upload cancelled.");
                this.cancelled = false;
                if (problems.length) throw new Error(problems.join(" "));
            });
        }
        // stops a running upload: no further file, and a large file between two of its parts (its part
        // already stored is removed); a small file is one request and finishes
        cancel() { if (this.busy) this.cancelled = true; }
        async remove(file) {
            if (!this.ready) throw new Error("Reopen attachments before making changes.");
            if (this.context.readOnly) throw new Error("This row is read only.");
            return this.run(async () => {
                const response = await this.request("REMOVE", { id: file.id, restore: file.removed });
                this.files = response.files || (await this.request("LIST")).files || [];
            });
        }
        // the Extra Fields of a file (new or saved); saved files keep the change until the grid is saved
        async setFields(file, values) {
            if (!this.ready) throw new Error("Reopen attachments before making changes.");
            if (this.context.readOnly) throw new Error("This row is read only.");
            return this.run(async () => {
                const response = await this.request("FIELDS", { id: file.id, values });
                this.files = response.files || (await this.request("LIST")).files || [];
            });
        }
        // the value an Extra Field shows: the user's unconfirmed draft, else the server's value
        fieldValue(file, index) {
            const id = String(file.id);
            const draft = this.drafts.get(id);
            if (draft && index in draft) return draft[index];
            const current = this.files.find(f => String(f.id) === id) || file;
            return (current.values || [])[index] ?? "";
        }
        // One Extra Field of a file changed. The value is kept as a draft at once; the request waits
        // for running work (an upload, another field) and then sends the file's newest values, so
        // quick changes of several fields never overwrite each other.
        setField(file, index, value) {
            if (!this.ready) return Promise.reject(new Error("Reopen attachments before making changes."));
            if (this.context.readOnly) return Promise.reject(new Error("This row is read only."));
            const id = String(file.id);
            const draft = this.drafts.get(id) || {};
            draft[index] = value;
            this.drafts.set(id, draft);
            return this.queueFields(id);
        }
        queueFields(id) {
            const job = this.fieldQueue.then(() => this.sendFields(id));
            this.fieldQueue = job.catch(() => { /* reported by the caller */ });
            return job;
        }
        async sendFields(id) {
            // resolves true when a request was sent and accepted
            if (!this.drafts.has(id)) return false;   // sent together with an earlier change
            while (this.busy) {
                try { await (this.running || new Promise(r => setTimeout(r, 50))); } catch (_) { /* its caller reports it */ }
            }
            const file = this.files.find(f => String(f.id) === id);
            const draft = this.drafts.get(id);
            if (!file || file.removed || !draft) { this.drafts.delete(id); return false; }
            const values = [0, 1, 2].map(i => i in draft ? draft[i] : (file.values || [])[i] ?? "");
            // the old value put back (e.g. after a refusal): the server has it already, nothing to send
            if (values.every((v, i) => v === ((file.values || [])[i] ?? ""))) { this.drafts.delete(id); return false; }
            await this.run(async () => {
                const response = await this.request("FIELDS", { id: file.id, values });
                this.files = response.files || (await this.request("LIST")).files || [];
            });
            // confirmed: drop what was sent; a value typed meanwhile stays a draft (its own request follows)
            const current = this.drafts.get(id);
            if (current) {
                for (const i of Object.keys(current)) if (current[i] === values[i]) delete current[i];
                if (!Object.keys(current).length) this.drafts.delete(id);
            }
            return true;
        }
        // drafts of files that are still there (a removed file's draft no longer matters)
        hasDrafts() {
            return [...this.drafts.keys()].some(id => this.files.some(f => String(f.id) === id && !f.removed));
        }
        // sends every draft again (closing the panel after a refused or lost field change)
        async flushFields() {
            for (const id of [...this.drafts.keys()]) await this.queueFields(id);
        }
        // required fields still empty on files that are new or changed in this edit
        missing() {
            const out = [];
            for (const field of this.cfg.fields || []) {
                if (!field.required || field.kind === "HIDDEN") continue;
                for (const file of this.files) {
                    const touched = file.staged ? file.ready && !file.removed : file.changed && !file.removed;
                    // a value of only spaces is empty (the server checks it the same way)
                    if (touched && !String((file.values || [])[field.n - 1] ?? "").trim()) out.push(field.label + " for " + file.name);
                }
            }
            return out;
        }
        canSave() { return this.ready && !this.busy && this.files.every(f => f.ready || f.removed); }
    }

    const DOT = " \u00b7 ";
    const count = n => n + (n === 1 ? " attachment" : " attachments");
    // Font APEX / Font Awesome icon (APEX pages load it)
    function icon(name) {
        const node = el("span", "fa " + name);
        node.setAttribute("aria-hidden", "true");
        return node;
    }
    function iconFor(file) {
        const ext = file.name.includes(".") ? file.name.split(".").pop().toLowerCase() : "";
        return file.mime.startsWith("image/") || ["png", "jpg", "jpeg", "gif", "webp"].includes(ext) ? "fa-file-image-o"
            : ext === "pdf" ? "fa-file-pdf-o" : ["txt", "csv", "log"].includes(ext) ? "fa-file-text-o"
            : ["doc", "docx"].includes(ext) ? "fa-file-word-o" : ["xls", "xlsx"].includes(ext) ? "fa-file-excel-o" : "fa-file-o";
    }
    function el(tag, cls, text) {
        const node = document.createElement(tag);
        if (cls) node.className = cls;
        if (text !== undefined) node.textContent = text;
        return node;
    }
    // a file action: an icon, its label as the tooltip and (hidden) for screen readers
    function iconButton(label, iconName, cls, onclick) {
        const button = el("button", "iga-icon-button" + (cls ? " " + cls : ""));
        button.type = "button"; button.title = label;
        button.append(icon(iconName), el("span", "iga-vh", label));
        button.onclick = onclick;
        return button;
    }
    function createPanel(cfg, session, options = {}) {
        const dialog = el("dialog", "iga-panel");
        dialog.id = cfg.item + "_PANEL";
        dialog.tabIndex = -1;
        const titleId = dialog.id + "_TITLE";
        dialog.setAttribute("aria-labelledby", titleId);
        const header = el("header", "iga-header");
        const heading = el("div");
        heading.append(el("span", "iga-eyebrow", "ROW ATTACHMENTS"));
        const title = el("h2", "", "Manage attachments"); title.id = titleId; heading.append(title);
        const close = el("button", "iga-close"); close.append(icon("fa-times"));
        close.type = "button"; close.setAttribute("aria-label", "Close attachments");
        header.append(heading, close);
        const context = el("p", "iga-context");
        const drop = el("div", "iga-drop");
        const dropIcon = el("div", "iga-drop-icon"); dropIcon.append(icon("fa-cloud-upload"));
        drop.append(dropIcon, el("strong", "", "Drop files here"),
            el("span", "", "or choose files from your device"));
        const browse = el("button", "iga-browse", "Choose files"); browse.type = "button";
        const input = el("input"); input.type = "file"; input.multiple = true; input.accept = cfg.accept; input.hidden = true;
        // ASCII only in this file: APEX may serve it without a charset
        const types = cfg.accept.split(",").map(x => x.trim().replace(/^\./, "").toUpperCase()).join(", ");
        drop.append(browse, input, el("small", "", types + DOT + bytes(cfg.maxBytes) + " per file" + DOT +
            "Up to " + cfg.maxCount + (cfg.maxCount === 1 ? " file" : " files") +
            (cfg.maxTotal ? DOT + bytes(cfg.maxTotal) + " together" : "") +
            (cfg.minCount ? DOT + cfg.minCount + (cfg.minCount === 1 ? " file" : " files") + " required" : "")));
        const message = el("div", "iga-message"); message.setAttribute("role", "alert");
        const status = el("div", "iga-status"); status.setAttribute("role", "status"); status.setAttribute("aria-live", "polite");
        const list = el("div", "iga-files");
        const footer = el("footer", "iga-footer");
        footer.append(el("p", "", "Attachment changes are applied when you save the grid."));
        const done = el("button", "iga-done", "Done"); done.type = "button"; footer.append(done);
        dialog.append(header, context, drop, message, status, list, footer);
        document.body.append(dialog);
        let objectUrls = [];
        function clearUrls() { objectUrls.forEach(URL.revokeObjectURL); objectUrls = []; }
        function error(err) { message.textContent = err.message || String(err); }
        async function attempt(fn) { message.textContent = ""; try { await fn(); return true; } catch (err) { error(err); return false; } }
        // A field change (sent when the field loses the focus): an earlier message stays until a request
        // really succeeds - cleared at once, the panel would shrink under the pointer and a click on
        // Done would land beside it.
        async function attemptField(fn) {
            try { if (await fn()) message.textContent = ""; return true; } catch (err) { error(err); return false; }
        }
        // Done, the close button and Escape: a field value not sent yet (still focused - Escape does not
        // blur it) is saved first and running requests are awaited; the panel stays open when that
        // fails. Only then the dialog closes and the row is settled (onclose).
        let closing = false;
        async function closePanel() {
            if (closing) return;
            closing = true;
            try {
                await session.idle();
                for (const field of list.querySelectorAll(".iga-field input")) {
                    if (field.commit && !(await field.commit())) return;
                }
                await session.idle();
                // a field value the server refused (or did not answer) is still in its input: send it
                // again; when that fails the panel stays open - correct the value or put the old one back
                if (session.hasDrafts() && !(await attempt(() => session.flushFields()))) return;
                const missing = session.missing();
                if (missing.length) { error(new Error("Fill in " + missing.join(", ") + ".")); return; }
                dialog.close();
            } finally { closing = false; }
        }
        // the Extra Fields of one file: a Text Field each (Hidden fields have no input)
        function fieldInputs(file, readOnly) {
            const fields = (cfg.fields || []).filter(x => x.kind !== "HIDDEN");
            if (!fields.length) return null;
            const box = el("div", "iga-fields");
            fields.forEach(field => {
                const id = dialog.id + "_F" + field.n + "_" + String(file.id).replace(/[^A-Za-z0-9]/g, "");
                const wrap = el("div", "iga-field" + (field.required ? " is-required" : ""));
                const label = el("label", "", field.label); label.htmlFor = id;
                const input = el("input"); input.type = "text";
                input.id = id; input.dataset.key = id;
                // the server's value, or what the user typed and the server has not confirmed yet
                input.value = session.fieldValue(file, field.n - 1);
                input.shown = input.value;   // a redraw keeps text typed since then
                // the length the developer's column holds (Storage = My Table), else the staging limit
                input.maxLength = Math.min(field.max || 4000, 4000);
                input.disabled = readOnly || file.removed || !file.ready;
                if (field.required) input.required = true;
                // sends a changed value once (change event, or closePanel for a field still being typed
                // in); it waits for running work instead of being refused
                input.commit = async () => {
                    if (input.disabled || input.value === session.fieldValue(file, field.n - 1)) return true;
                    return attemptField(() => session.setField(file, field.n - 1, input.value));
                };
                input.onchange = () => { input.commit(); };
                // also on leaving the field: text kept across a redraw has no change event of its own
                input.onblur = () => { input.commit(); };
                wrap.append(label, input); box.append(wrap);
            });
            return box;
        }
        close.onclick = done.onclick = closePanel;
        // Escape is handled here: Chrome ignores a prevented "cancel" when it comes twice without a
        // click in between and closes the dialog, which would drop a refused field value
        dialog.addEventListener("keydown", event => {
            if (event.key === "Escape" && !event.defaultPrevented) { event.preventDefault(); closePanel(); }
        });
        dialog.addEventListener("cancel", event => { event.preventDefault(); closePanel(); });
        dialog.addEventListener("close", () => { clearUrls(); options.onclose?.(); });
        browse.onclick = () => input.click();
        input.onchange = () => { const files = [...input.files]; input.value = ""; attempt(() => session.upload(files)); };
        for (const type of ["dragenter", "dragover", "dragleave", "drop"]) drop.addEventListener(type, event => {
            event.preventDefault(); event.stopPropagation();
            drop.classList.toggle("is-over", type === "dragenter" || type === "dragover");
            if (type === "drop" && !session.busy && !session.context.readOnly)
                attempt(() => session.upload([...event.dataTransfer.files]));
        });
        session.onchange = () => {
            const readOnly = session.context?.readOnly;
            browse.disabled = session.busy || readOnly || !session.ready;
            close.disabled = done.disabled = session.busy;
            drop.hidden = Boolean(readOnly);
            context.textContent = session.context ? session.context.label : "";
            context.hidden = !context.textContent;
            // the status is a live region: during an upload it changes in steps of 25 %, so screen readers
            // are not handed every percent (the bar below still moves smoothly)
            const statusText = session.progress
                ? "Uploading " + session.progress.name + DOT +
                  Math.floor(session.progress.received / session.progress.size * 4) * 25 + "%"
                : session.busy ? "Working..." : count(session.files.filter(f => !f.removed).length);
            if (status.textContent !== statusText) status.textContent = statusText;
            if (session.busy) {
                // Preserve existing previews while uploading; the file being sent shows at once with its progress.
                let row = list.querySelector(".iga-file.is-uploading");
                if (session.progress) {
                    if (!row || row.dataset.name !== session.progress.name) {
                        row?.remove();
                        list.querySelector(".iga-empty")?.remove();
                        row = el("article", "iga-file is-uploading"); row.dataset.name = session.progress.name;
                        const rowIcon = el("div", "iga-file-icon"); rowIcon.append(icon("fa-circle-o-notch fa-spin"));
                        const info = el("div", "iga-file-info");
                        info.append(el("strong", "", session.progress.name), el("span", "", bytes(session.progress.size)),
                            el("span", "iga-badge", "Uploading"));
                        const bar = el("div", "iga-bar"); bar.append(el("span"));
                        info.append(bar);
                        const actions = el("div", "iga-file-actions");
                        actions.append(iconButton("Cancel upload", "fa-times", "iga-danger iga-cancel", () => session.cancel()));
                        row.append(rowIcon, info, actions); list.append(row);
                    }
                    row.querySelector(".iga-bar span").style.width =
                        Math.round(session.progress.received / session.progress.size * 100) + "%";
                }
                return;
            }
            // keep the focus in the field being edited across the redraw
            const focusKey = document.activeElement && list.contains(document.activeElement) ? document.activeElement.dataset.key : null;
            // text typed in a field and not sent yet (no change event so far) survives the redraw
            const typing = new Map();
            for (const node of list.querySelectorAll(".iga-field input")) {
                if (node.value !== node.shown) typing.set(node.dataset.key, node.value);
            }
            clearUrls(); list.replaceChildren();
            if (!session.files.length) {
                list.append(el("div", "iga-empty", "No attachments yet. Add the files that support this row."));
                return;
            }
            session.files.forEach(file => {
                const row = el("article", "iga-file" + (file.removed ? " is-removed" : ""));
                const fileIcon = el("div", "iga-file-icon"); fileIcon.append(icon(iconFor(file)));
                const info = el("div", "iga-file-info");
                info.append(el("strong", "", file.name), el("span", "", bytes(file.size)));
                const badge = el("span", "iga-badge", file.removed ? "Removal pending" : !file.ready
                    ? "Incomplete - remove to save" : file.staged ? "Pending save" : file.changed ? "Changes pending" : "Saved");
                info.append(badge);
                const inputs = fieldInputs(file, readOnly);
                if (inputs) info.append(inputs);
                const actions = el("div", "iga-file-actions");
                if (file.ready && !file.removed) {
                    actions.append(iconButton("Download", "fa-download", "", () => attempt(() => options.download(file, session))));
                    if (["image/png", "image/jpeg"].includes(file.mime) && options.preview) {
                        const preview = iconButton("Preview", "fa-eye", "", () => attempt(async () => {
                            const blob = await options.preview(file, session);
                            if (!["image/png", "image/jpeg"].includes(blob.type)) throw new Error("Preview unavailable.");
                            const url = URL.createObjectURL(blob); objectUrls.push(url);
                            const image = el("img", "iga-preview"); image.src = url; image.alt = file.name;
                            fileIcon.replaceChildren(image);
                        }));
                        actions.append(preview);
                    }
                }
                if (!readOnly) {
                    actions.append(file.removed
                        ? iconButton("Restore", "fa-undo", "", () => attempt(() => session.remove(file)))
                        : iconButton("Remove", "fa-trash-o", "iga-danger", () => attempt(() => session.remove(file))));
                }
                row.append(fileIcon, info, actions); list.append(row);
            });
            for (const [key, value] of typing) {
                const node = list.querySelector('[data-key="' + key + '"]');
                if (node && !node.disabled) node.value = value;
            }
            if (focusKey) list.querySelector('[data-key="' + focusKey + '"]')?.focus();
        };
        return {
            dialog, session,
            async open(ctx) {
                if (dialog.open) return;
                message.textContent = ""; list.replaceChildren();
                dialog.showModal();
                await attempt(() => session.open(ctx));
                browse.focus();
            },
            destroy() { clearUrls(); dialog.remove(); }
        };
    }

    // Cell markup (also the editor's content, so the active cell looks the same as the others).
    // The grid escapes cells by default; this column's escaping is switched off and the markup is
    // built here, with the label escaped: the value itself is only ever an edit token.
    function cellHtml(cfg, value, esc) {
        const pending = isToken(value);
        const files = /^\d+$/.test(value == null ? "" : String(value)) ? Number(value) : 0;
        const text = cfg.label || "Attachments";
        const iconPart = cfg.display === "TEXT" ? "" :
            '<span class="iga-cell-icon fa ' + esc(cfg.icon || "fa-paperclip") + '" aria-hidden="true"></span>';
        const textPart = cfg.display === "ICON" ? '<span class="u-VisuallyHidden">' + esc(text) + "</span>" :
            '<span class="iga-cell-label">' + esc(text) + "</span>";
        const pendingPart = pending ? (cfg.display === "ICON"
            ? '<span class="iga-cell-dot" title="Changes not saved yet"></span><span class="u-VisuallyHidden">Pending</span>'
            : '<span class="iga-cell-pending">Pending</span>') : "";
        const countPart = files > 0 && !pending ? '<span class="iga-cell-count">' + files + "</span>" : "";
        return '<span class="iga-cell' + (pending ? " is-pending" : "") + '" data-iga-item="' + esc(cfg.item) + '">' +
            iconPart + textPart + countPart + pendingPart + "</span>";
    }

    function init(cfg) {
        if (!rootApex()) throw new Error("IG Attachments needs Oracle APEX.");
        const apex = rootApex(), $ = apex.jQuery;
        const esc = apex.util?.escapeHTML || (v => String(v).replace(/[&<>"']/g, c => "&#" + c.charCodeAt(0) + ";"));
        instances.get(cfg.item)?.destroy();
        const input = document.getElementById(cfg.item), button = document.getElementById(cfg.item + "_OPEN");
        let disabled = Boolean(cfg.readOnly), lockedView = null, activePanel = null;
        // The grid, its key and this column's field are read from the grid itself. The grid
        // registers after its columns initialize, so it is looked up when first needed.
        let regionId = cfg.region || null;
        function region() {
            if (!regionId) {
                const found = apex.region.findClosest(input) || apex.region.findClosest(button);
                if (!found) throw new Error("IG Attachments: " + cfg.item + " is not inside an Interactive Grid.");
                regionId = found.element.attr("id");
            }
            return apex.region(regionId);
        }
        function view() { return region().call("getViews", "grid"); }
        const mine = target => target && target.contains && (target.contains(input) || target.contains(button));
        function fieldOf(model) {
            const fields = model.getOption("fields") || {};
            return Object.keys(fields).find(name => fields[name].elementId === cfg.item) || cfg.item;
        }
        function keyOf(model) {
            const id = model.getOption("identityField");
            const key = Array.isArray(id) ? id : id ? [id] : [];
            if (key.length !== 1) throw new Error("IG Attachments needs a grid with one primary key column.");
            return key[0];
        }
        function paint() {
            button.innerHTML = cellHtml(cfg, input.value, esc);
            button.setAttribute("aria-label", (cfg.label || "Attachments") + (isToken(input.value) ? ", pending" : ""));
        }
        // tokens this column put on rows (record id -> token): any other token in the cell (pasted,
        // filled down) is taken off again - it belongs to another row's files
        const ownTokens = new Map();
        // record key -> the token of an edit opened and closed without changes (the row does not hold
        // it): sent again on the next opening, so this panel reuses it and other tabs get their own
        const emptyEdits = new Map();
        const adapter = {
            async request(op, data) {
                try {
                    return await apex.server.plugin(cfg.ajax, {
                        x01: op, x02: data.token, x03: data.key, x04: data.id,
                        x05: data.restore ? "RESTORE" : data.name,
                        x06: data.offset ?? data.size, f01: data.chunks, f02: data.values
                    }, { dataType: "json" });
                } catch (xhr) {
                    // apex.server rejects with the jqXHR: surface the server's message.
                    const json = xhr && xhr.responseJSON;
                    throw new Error((json && (json.reason || json.error || json.message)) ||
                        (xhr && xhr.status ? "Attachment request failed (HTTP " + xhr.status + ")." : "Attachment request failed."));
                }
            },
            setToken(ctx, token) {
                ownTokens.set(ctx.model.getRecordId(ctx.record), token);
                const result = ctx.model.setValue(ctx.record, fieldOf(ctx.model), token);
                if (result === "DUP") throw new Error("Duplicate attachment token.");
                input.value = token;
                paint();
                apex.event.trigger(input, "change");
            },
            // Nothing pending any more: take the token off the row again, and when nothing else
            // on an existing row was changed, undo the row change completely.
            clearToken(ctx) {
                const field = fieldOf(ctx.model);
                ownTokens.delete(ctx.model.getRecordId(ctx.record));
                const original = ctx.original == null || isToken(ctx.original) ? "" : String(ctx.original);
                ctx.model.setValue(ctx.record, field, original);
                input.value = original;
                paint();
                const meta = ctx.model.getRecordMetadata(ctx.model.getRecordId(ctx.record)) || {};
                const others = Object.keys(meta.fields || {}).some(name => name !== field && meta.fields[name].changed);
                if (meta.updated && !meta.inserted && !others) ctx.model.revertRecords([ctx.record]);
            }
        };
        const session = new Session(cfg, adapter);
        async function fetchFile(file) {
            const response = await fetch(fileUrl(file), { credentials: "same-origin" });
            if (!response.ok || (response.headers.get("content-type") || "").includes("application/json")) {
                let reason = "";
                try { reason = (await response.json()).reason || ""; } catch (_) { /* not JSON */ }
                throw new Error(reason || "The file could not be downloaded (HTTP " + response.status + ").");
            }
            return response.blob();
        }
        function fileUrl(file) {
            return apex.server.pluginUrl(cfg.ajax, { x01: "DOWNLOAD", x02: session.token,
                x03: session.context.key, x04: file.id });
        }
        activePanel = createPanel(cfg, session, {
            onclose() {
                try { session.settle(); } catch (e) { apex.message.alert(e.message); }
                const key = session.context && session.context.key;
                if (key) {
                    if (session.token && !session.claimed && !session.context.readOnly) emptyEdits.set(key, session.token);
                    else emptyEdits.delete(key);
                }
                if (lockedView) { lockedView.view$.grid("unlockActive"); lockedView = null; }
                (returnFocus && document.contains(returnFocus) ? returnFocus : button).focus();
            },
            async download(file) {
                // a large file goes straight to the browser's downloads (saved to disk as it arrives, not held in
                // memory); smaller ones are fetched first, so a refusal shows the server's reason
                if (Number(file.size) > DIRECT_DOWNLOAD_BYTES) {
                    const link = el("a"); link.href = fileUrl(file); link.download = file.name;
                    document.body.append(link); link.click(); link.remove();
                    return;
                }
                const blob = await fetchFile(file);
                const url = URL.createObjectURL(blob);
                const anchor = el("a"); anchor.href = url; anchor.download = file.name;
                document.body.append(anchor); anchor.click(); anchor.remove();
                setTimeout(() => URL.revokeObjectURL(url), 60000);
            },
            preview: fetchFile
        });
        // record: the clicked row; else the active row (Edit mode)
        let returnFocus = null;
        async function open(clicked, from) {
            if (activePanel.dialog.open) return;
            returnFocus = from || null;
            const gridView = view(), model = gridView.model;
            const record = clicked || gridView.view$.grid("getActiveRecord");
            if (!record) { apex.message.alert("Click the attachments button of a row."); return; }
            const metadata = model.getRecordMetadata(model.getRecordId(record)) || {};
            const isNew = Boolean(metadata.inserted);
            // the row may not be changed, or APEX made this cell read only (a checksum marks read-only cells)
            const cellMeta = (metadata.fields || {})[fieldOf(model)] || {};
            const readOnly = disabled || !model.allowEdit(record) || Boolean(cellMeta.ck || cellMeta.disabled);
            const key = isNew ? null : String(unwrap(model.getValue(record, keyOf(model))) ?? "");
            if (!isNew && !key) { apex.message.alert("This row has no record key."); return; }
            // in Edit mode the active cell must not move while the panel is open
            if (gridView.view$.grid("inEditMode") && gridView.view$.grid("getActiveRecord") === record) {
                gridView.view$.grid("lockActive"); lockedView = gridView;
            }
            try {
                // Extra Field values of new files: from a column of the row or a page item
                const defaults = [0, 1, 2].map(i => {
                    const field = (cfg.fields || []).find(x => x.n === i + 1);
                    if (!field) return "";
                    if (field.dkind === "COLUMN") { try { return String(unwrap(model.getValue(record, field.dval)) ?? ""); } catch (_) { return ""; } }
                    if (field.dkind === "ITEM") return apex.item(field.dval).getValue() || "";
                    return "";
                });
                const current = unwrap(model.getValue(record, fieldOf(model)));
                await activePanel.open({
                    key, token: isToken(current) ? current : "", original: current,
                    reuse: !isToken(current) && key ? emptyEdits.get(key) || "" : "",
                    record, model, readOnly, defaults,
                    label: isNew ? "New row - the files are linked to it when you save the grid." : ""
                });
            } catch (err) {
                if (lockedView) { lockedView.view$.grid("unlockActive"); lockedView = null; }
                throw err;
            }
        }
        button.onclick = () => { open().catch(e => apex.message.alert(e.message)); };
        apex.item.create(cfg.item, {
            item_type: "IG_ATTACHMENTS",
            // The grid writes the editor's value into the active row whenever it leaves the cell. An edit
            // token in the editor that is not the active row's value is stale - the row was saved meanwhile
            // (it holds its file count now) or the panel of another row set it - so the row's own value is
            // reported: writing it back changes nothing. Any other value is the editor's own, as set.
            getValue() {
                if (isToken(input.value)) {
                    try {
                        const gridView = view(), record = gridView.view$.grid("getActiveRecord");
                        if (record) {
                            const value = unwrap(gridView.model.getValue(record, fieldOf(gridView.model)));
                            const text = value == null ? "" : String(value);
                            if (text !== input.value) { input.value = text; paint(); }
                        }
                    } catch (_) { /* the grid is not there yet */ }
                }
                return input.value;
            },
            setValue(value) { input.value = unwrap(value) || ""; paint(); },
            displayValueFor(value) { return cellHtml(cfg, unwrap(value), esc); },
            getPopupSelector() { return "#" + activePanel.dialog.id; },
            setFocus() { button.focus(); },
            disable() { disabled = true; },
            enable() { disabled = false; },
            isDisabled() { return disabled; },
            // Always valid: the grid validates on change, which happens while OPEN is still running,
            // and a cell error would stay and block Save. Busy saves are stopped by the save guard,
            // and finalize_edit rejects incomplete uploads.
            getValidity() { return { valid: true }; },
            getValidationMessage() { return ""; }
        });
        paint();
        // for developers only (App Builder session): the grid's row processing does not save the files
        if (cfg.setupWarning) {
            const text = "IG Attachments (" + cfg.item + "): " + cfg.setupWarning;
            if (typeof console !== "undefined") console.warn(text);
            try { apex.message.showErrors([{ type: "error", location: "page", message: text, unsafe: false }]); } catch (_) { /* console only */ }
        }
        const subscriptions = new Map();
        function watch(model) {
            if (subscriptions.has(model)) return;
            const id = model.subscribe({
                onChange(type, change) {
                    if (type === "copy") (change.records || []).forEach(record => model.setValue(record, fieldOf(model), ""));
                    // a row reverted in the grid: its unsaved attachment changes go on the server at once
                    // (they would hold the staging limits until they expire). The panel's own revert when
                    // nothing is pending (clearToken) has taken its token off first and is not affected.
                    if (type === "revert") (change.records || []).forEach(record => {
                        const id = model.getRecordId(record), token = ownTokens.get(id);
                        if (!token) return;
                        ownTokens.delete(id);
                        const meta = model.getRecordMetadata(id) || {};
                        let key = null;
                        try { key = meta.inserted ? null : String(unwrap(model.getValue(record, keyOf(model))) ?? "") || null; } catch (_) { return; }
                        adapter.request("DISCARD", { token, key }).catch(() => { /* it expires anyway */ });
                    });
                    // a token pasted or filled into this column (not one this column put there) is undone
                    if (type === "set" && change && change.record && change.field === fieldOf(model)) {
                        const value = unwrap(model.getValue(change.record, change.field));
                        const own = ownTokens.get(model.getRecordId(change.record));
                        if (isToken(value) && value !== own) {
                            const old = unwrap(change.oldValue);
                            model.setValue(change.record, change.field, !isToken(old) || old === own ? String(old ?? "") : "");
                        }
                    }
                    if (type === "destroy") subscriptions.delete(model);
                }
            });
            subscriptions.set(model, id);
        }
        // This column renders its own markup (see cellHtml): turn the grid's escaping off for it only.
        function unescapeColumn() {
            let gridView;
            try { gridView = view(); } catch (_) { return; }
            const column = (gridView.view$.grid("getColumns") || []).find(c => c.elementId === cfg.item || c.property === fieldOf(gridView.model));
            if (column && column.escape !== false) {
                column.escape = false;
                try { gridView.view$.grid("refreshColumns"); } catch (_) { /* older grid: refresh is enough */ }
                gridView.view$.grid("refresh");
            }
        }
        try { watch(view().model); unescapeColumn(); } catch (_) { /* Grid may initialize after the column editor. */ }
        const doc$ = $(document);
        const namespace = ".iga_" + cfg.item.replace(/[^a-zA-Z0-9]/g, "_");
        doc$.off(namespace).on("interactivegridviewmodelcreate" + namespace, (event, data) => {
            if (!mine(event.target)) return;
            watch(data.model); guardSave(); setTimeout(unescapeColumn);
        });
        // The button in a cell opens the panel for that row (the grid makes its row active on mousedown).
        doc$.on("click" + namespace, ".iga-cell", event => {
            if (button.contains(event.target) || activePanel.dialog.open) return;
            // another attachment column of the same grid handles its own cells
            if (event.target.closest(".iga-cell")?.getAttribute("data-iga-item") !== cfg.item) return;
            let gridView;
            try { gridView = view(); } catch (_) { return; }
            if (!gridView.view$[0].contains(event.target)) return;
            const row = event.target.closest("tr");
            // a grid row carries its record id in data-id
            const record = row && row.hasAttribute("data-id") ? gridView.model.getRecord(row.getAttribute("data-id")) : null;
            const cell = event.target.closest("td");
            setTimeout(() => open(record, button.closest("td") === cell ? null : cell).catch(e => apex.message.alert(e.message)));
        });
        // Model finalization also rejects incomplete uploads: a direct model.save cannot bypass it.
        // The grid's Save action is wrapped once; every attachment column of the grid adds its check.
        const isBusy = () => session.busy || activePanel.dialog.open;
        // This column's cell still being edited when the grid saves: edit mode is left first, while the
        // cell can still be written. A save can make the cell read only (a Read Only condition for each
        // row, e.g. saved as a Fuel claim); leaving it afterwards fails in the grid ("Set value not allowed
        // for field" - the grid writes a cell back whenever it leaves it).
        function leaveActiveCell() {
            try {
                const gridView = view();
                if (!gridView.view$.grid("inEditMode")) return;
                const cell$ = gridView.view$.grid("getActiveCellFromColumnItem", input);
                if (cell$ && cell$.hasClass && cell$.hasClass("is-active")) gridView.view$.grid("setEditMode", false);
            } catch (_) { /* nothing to leave */ }
        }
        const myGuards = new Set();
        function guardSave() {
            let actions;
            try { actions = region().call("getActions"); } catch (_) { return; }
            const action = actions.lookup("save");
            if (!action) return;
            let guard = saveGuards.get(actions);
            if (!guard || action.action !== guard.guarded) {
                const original = action.action;
                if (typeof original !== "function") return;
                const checks = new Set(), leaves = new Set();
                const guarded = function (...args) {
                    for (const busy of checks) {
                        if (busy()) { apex.message.alert("Close the attachment panel before saving the grid."); return; }
                    }
                    for (const leave of leaves) leave();
                    return original.apply(this, args);
                };
                guard = { original, guarded, checks, leaves };
                saveGuards.set(actions, guard); action.action = guarded;
            }
            guard.checks.add(isBusy); guard.leaves.add(leaveActiveCell); myGuards.add(actions);
        }
        guardSave();
        doc$.on("interactivegridviewchange" + namespace, event => { if (mine(event.target)) { guardSave(); setTimeout(unescapeColumn); } });
        const submit = event => {
            if (session.busy || activePanel.dialog.open) {
                event.preventDefault(); apex.event.gCancelFlag = true;
                apex.message.alert("Close the attachment panel before submitting.");
            }
        };
        doc$.on("apexbeforepagesubmit" + namespace, submit);
        const instance = {
            open,
            isBusy,
            destroy() {
                if (lockedView) lockedView.view$.grid("unlockActive");
                for (const [model, id] of subscriptions) model.unSubscribe(id);
                for (const actions of myGuards) {
                    const guard = saveGuards.get(actions);
                    if (!guard) continue;
                    guard.checks.delete(isBusy); guard.leaves.delete(leaveActiveCell);
                    if (!guard.checks.size) {
                        if (actions.lookup("save")?.action === guard.guarded) actions.lookup("save").action = guard.original;
                        saveGuards.delete(actions);
                    }
                }
                doc$.off(namespace);
                activePanel.destroy(); button.onclick = null;
                const alias = aliases.get(instance);
                if (alias && instances.get(alias) === instance) instances.delete(alias);
                aliases.delete(instance);
            }
        };
        instances.set(cfg.item, instance);
        // also by the column's name (a column without a Static ID has the DOM id C<column id>)
        if (cfg.column && cfg.column !== cfg.item && !instances.has(cfg.column)) {
            instances.set(cfg.column, instance);
            aliases.set(instance, cfg.column);
        }
        return instance;
    }
    function rootApex() { return typeof apex !== "undefined" ? apex : null; }
    return { init, get: id => instances.get(id), Session, createPanel, validateFile, bytes, unwrap, toBase64 };
}));

