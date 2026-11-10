# Live APEX checks

Automated, against APEX 26.1 (app 1530 page 300, own-table storage): run the clean-up of the QA claims between the suites (each suite works on its own "QA ..." claims).

- qa/live.js: cell icon/label and hand pointer, one click in Navigation and Edit mode, open/close leaves the row untouched, refused type / fake content / size, the remaining files still upload, upload timing, preview, download, remove and restore, pending state, count after save, new rows (add and remove leaves no pending), saved new row with file.
- qa/fields.js: Text Field inputs, Hidden field not shown, required value blocks Done, values kept after redraw, saved values shown, changes of saved files pending and saved, change back not pending, too long value refused by the server, Hidden values not changeable from the browser, Hidden Grid Column value taken when the row is saved (new row, category chosen after the upload) and following a later change, Minimum Files per Row on existing and new rows.
- qa/old-file.js: fields of a file saved before the fields existed.
- qa/acceptance.js (review 2026-11-07 additions: a pasted token taken off, Minimum Files not blocking a read-only row, reopening reusing its empty edit while another tab gets its own, a second editor's added files merged and its removal refused; the tampering checks switch the plug-in's JavaScript off first; the lock test waits until SQLcl really holds the lock): a new-row token saved on an existing (closed) claim, a token of another column, a Hidden category change on a claim without WRITE, an incomplete upload blocking the save, 105 views of one row and 210 new rows without a lock-out, two sessions reserving at once near the per-user limit (one accepted, both waited for the lock), empty file, File Check Function (EICAR), hostile file names, token of another session, token of another record, unknown file download (403, not a file), foreign record, stale second editor, revert restores the count, read-only closed claim, the column's Read Only condition for each row (Category = Fuel) in the panel and on the server, Maximum Total Size per Row, per-user quota, purge of expired staging, the purge job.
- qa/review-2026-11-05/grid-restrictions.cjs (with the temporary page variant page300-variant.cjs, page restored afterwards): Allowed Row Operations Column without U, a true Read Only condition of the column (also with a token from before, and for new rows), and writable again when it is false.
- tests/regressions.cjs (Chrome, test doubles): Escape while a field is focused saves it before closing, a failed field save keeps the panel open and the typed text (also on a second Escape), putting the old value back closes, a lost field request is retried on close, two fields typed quickly, a field typed during an upload and text kept across the redraw, two columns in one grid, the shared save guard in any destroy order.

Still to check by hand before production:

- Network loss in the middle of a multi-part upload, then retry; compare the downloaded bytes.
- Keyboard only: Tab to the cell, Enter, Escape; a 390 px wide screen.
- The grid in a modal dialog page.
- A real page with two IG Attachments columns (p_column in the row process); covered so far by tests/regressions.cjs with test doubles.
- Hidden field from a Page Item (the live page has no page item; the code path is the one of Grid Column).
- An attachment column without a Static ID (DOM id C<column id>), and two grids of one page each with an attachment column of the same name.
- A save that moves a row out of the grid's filter while its files change (page 300's filter is the owner, which the grid cannot change).
- A grid region or column with an Authorization Scheme or Build Option the user fails; a grid with Edit switched off.
- A developer's table whose File Name or Extra Field columns are shorter than the file name / value (shortened name, message).
- Cancel during a large upload on a slow connection.

Live testing note: app 1530 runs a service worker. Playwright's request interception (ctx.route) does not see requests the service worker makes - create the context with `serviceWorkers: "block"` when a test serves its own JavaScript.
