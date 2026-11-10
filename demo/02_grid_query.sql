-- Source of the editable Interactive Grid. ID is the grid's primary key; ATTACHMENT_EDIT is the
-- IG Attachments column - its value is the file count shown in the cell.
select e.id,
       e.expense_date,
       e.category,
       e.description,
       e.amount,
       to_char((select count(*) from expense_files f where f.expense_id = e.id)) as attachment_edit
  from expenses e
 where e.owner_name = :APP_USER
