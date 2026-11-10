# Changelog

## 1.1.0 (2026-11-10)

The open low items of the 2026-11-07 review (25-34).

- **MIME types**: GIF and WebP are checked by their first bytes like PNG, JPEG and PDF and get a preview; text, CSV, Office, OpenDocument, RTF, ZIP, MP3, MP4, MSG and EML files get their usual type from the extension instead of `application/octet-stream`. A type longer than the MIME column of your own table is saved as `application/octet-stream`.
- **Large downloads** (over 25 MB) go straight to the browser's downloads instead of being held in memory first.
- **Saved files keep the order they were added in** (they came back in GUID order). `IGA_UPLOADS.CREATED_AT` is added by `db/001_tables.sql`.
- **Required Extra Fields** with only spaces count as empty, in the browser and on the server.
- **Session quota** no longer counts expired edits (the user quota already did not). The default total staging quota is 256 MB instead of 1 GB, and the README says to keep it below the free tablespace.
- The upload status is announced to screen readers in steps of 25 %, not every percent.
- A Read Only condition, authorization scheme or build option the server cannot evaluate is still treated as read only / not allowed, and now the reason is written to the debug log.
- Minified plug-in files (`#MIN#`) with a content hash; the build takes the importable plug-in export with the highest number instead of the newest file date.
- README: unsupported grid setups (function returning SQL, REST sources, `#OWNER#`, page 0, ROWID and composite keys, grid SQL over 32,000 characters) and supported browsers.

## 1.0.0

- Authorization comes from the grid: no scope to register. Read needs the row in the user's grid; adding needs the grid to add rows; changing and removing need the grid to update or delete rows (authorization schemes included). An optional Authorization Function on the column adds rules.
- `finalize_edit(:ATTACHMENT_EDIT, :ID)` and `delete_record_files(:ID)`: the grid, its primary key and the column are found from the page. finalize_edit returns the row's new file count in the column.
- Staging quotas (per session, per user, in total) are Component Settings.
- Storage in the plug-in table or your own table (column mapping on the column).
- Extra Fields 1-3 per file: Text Field (optionally starting from a grid column or page item) or Hidden (the grid column or page item value when the row is saved, on all the row's files).
- File limits on the column: size (KB), count, minimum files per row, types, total size per row, Keep Unsaved Files, File Check Function.
- One click on the cell's button opens the panel, in Navigation and Edit mode; opening and closing without changes leaves the row untouched.
- Re-runnable install and upgrade, uninstall script, scheduler job for expired staging.
- Read-only fallback for users who may read but not change a row's files.
- Theme colours (Universal Theme variables, dark mode).
- Review of 2026-11-05:
  - Saving checks the token against the column that saves and the row's real operation: a new-row token only for an insert (CREATE), WRITE on saved rows, never a token of another column.
  - Hidden values follow the row only where the user may change its files.
  - The server applies the grid's Allowed Row Operations Column and the Read Only conditions of the page, the grid and the column; a column condition evaluated for each row is evaluated on the saved row's values (the panel opens read only there, too).
  - Done / Escape save a field still being typed in before the panel closes.
  - Several attachment columns in one grid each open only their own panel and share one save guard.
  - Unsaved-file limits are reserved one at a time (session, user, installation).
  - Viewing rows no longer uses up the 100 pending rows per session; an incomplete upload keeps the row pending, so its save is refused.

- Review of 2026-11-07:
  - Extra Fields: a change made while a file uploads, or right after another field, waits and is saved instead of being refused ("Please wait") and lost. Quick changes of two fields no longer overwrite each other.
  - Text the server refuses (or does not answer) stays in its field; closing the panel sends it again and stays open while it fails. Putting the old value back needs no request. Text typed in a field survives when the list is redrawn.
  - Escape is handled by the panel itself: a second Escape no longer closes it past a refused value (Chrome skips a prevented "cancel" the second time).
  - After a refused field, the message stays until a field is really saved, so the first click on Done is not lost when the panel shrinks.
  - A column without a Static ID works (APEX names it C<column id>); the column is found by its id first. Two attachment columns of a page with the same name get a clear message to set a Static ID or a Storage Name. `igaAttachments.get()` also takes the column's name.
  - A lost reply to an upload: the list is read again, so a file the server stored is shown.
  - Small uploads commit their reservation before the bytes are checked: the staging locks are not held during the File Check Function. Lock waits end after 10 seconds with a message.
  - The read-only fallback drops an old token; downloads of saved files no longer depend on it.
  - An empty edit is reused only when the panel presents its own token: two tabs of one session no longer share an edit. Its version and limits are refreshed as before.
  - Minimum Files per Row applies only where the user may add files to the row (a read-only row saves).
  - Saving a row checks update permission, schemes, Read Only conditions and the Authorization Function, not the grid's filter again: a save that moves the row out of the filter keeps its files.
  - A token pasted or filled into another row's cell is taken off.
  - New `iga_api.move_files` for files of the plug-in table after moving a grid or importing the application under another ID.
  - Every request needs the grid region and the column to be there for the user (Authorization Scheme, Build Option); changes need the grid's Edit enabled.
  - The parts of a large upload are checked against the edit token only (START and FINISH run the full check): no grid query per part.
  - A refusal at save is written to the debug log as well (APEX gives the row processing no row number, so the message stays in the page notification).
  - The lengths of the developer's File Name and Extra Field columns are respected (shortened name, clear message, input maxlength); field values are checked in bytes, too.
  - Cancel for a running upload.
  - Reverting a row discards its unsaved attachment changes on the server (DISCARD); opening a panel removes a few expired edits.
  - Developers get a page message when the grid's row processing does not call finalize_edit.
  - A second editor's added files are merged instead of refused; removals and field changes on a changed row are still refused.
  - A Hidden field without Value From takes nothing from the browser.
  - The cell editor no longer hands a stale token back to the grid after a save ("Set value not allowed for field" when the saved row's cell became read only).

## 0.1.0

- First prototype.
