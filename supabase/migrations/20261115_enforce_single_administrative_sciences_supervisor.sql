do $$
declare
  v_definition text;
  v_old text := 'case when ps.id = 13 then ''العلوم الإدارية'' else ps.specialty end as specialty';
  v_new text := 'case when ps.id = 13 then ''العلوم الإدارية'' when ps.id in (10,11,17) then ''غير مصنف'' else ps.specialty end as specialty';
begin
  select pg_get_functiondef('public.assign_training_supervisor(uuid,uuid,bigint,bigint)'::regprocedure)
    into v_definition;
  if position(v_old in v_definition) = 0 then
    raise exception 'Could not locate the existing administrative supervisor override';
  end if;
  execute replace(v_definition, v_old, v_new);
end;
$$;