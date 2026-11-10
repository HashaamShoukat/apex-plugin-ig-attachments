-- Interactive Grid - Automatic Row Processing (DML), Target Type PL/SQL Code.
-- The row and its attachments are saved in one transaction; no COMMIT here.
-- finalize_edit puts the row's new file count into :ATTACHMENT_EDIT, so the cell shows it after the save.
begin
    case :APEX$ROW_STATUS
    when 'C' then
        insert into expenses (expense_date, category, description, amount, owner_name)
        values (to_date(:EXPENSE_DATE, 'DD-Mon-YYYY'), :CATEGORY, :DESCRIPTION,
                to_number(:AMOUNT, '999G999G999G990D00'), :APP_USER)
        returning id into :ID;
        iga_api.finalize_edit(:ATTACHMENT_EDIT, :ID);
    when 'U' then
        update expenses
           set expense_date = to_date(:EXPENSE_DATE, 'DD-Mon-YYYY'),
               category     = :CATEGORY,
               description  = :DESCRIPTION,
               amount       = to_number(:AMOUNT, '999G999G999G990D00')
         where id = :ID
           and owner_name = :APP_USER;
        if sql%rowcount <> 1 then
            raise_application_error(-20000, 'Record unavailable.');
        end if;
        iga_api.finalize_edit(:ATTACHMENT_EDIT, :ID);
    when 'D' then
        -- the files first, while the row still exists (who may delete is checked on it)
        iga_api.delete_record_files(:ID);
        delete from expenses
         where id = :ID
           and owner_name = :APP_USER;
    end case;
end;
