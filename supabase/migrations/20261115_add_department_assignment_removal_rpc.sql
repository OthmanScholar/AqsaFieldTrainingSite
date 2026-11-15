create or replace function public.remove_training_supervisor_assignment(p_assignment_id bigint)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_deleted_id bigint;
begin
  if not public.has_staff_role(array['admin','department_head']::text[]) then
    raise exception 'غير مصرح: حذف التكليف متاح لرئيس القسم والإدارة فقط';
  end if;

  delete from public.supervisor_assignments
  where id = p_assignment_id
  returning id into v_deleted_id;

  if v_deleted_id is null then
    return false;
  end if;

  return true;
end;
$$;

revoke all on function public.remove_training_supervisor_assignment(bigint) from public, anon;
grant execute on function public.remove_training_supervisor_assignment(bigint) to authenticated;
