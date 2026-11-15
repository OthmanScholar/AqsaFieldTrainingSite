alter table public.public_supervisors
  add column if not exists supervisor_group text;

update public.public_supervisors
set supervisor_group = case id
  when 1 then 'العلوم التكنولوجية'
  when 2 then 'العلوم التكنولوجية'
  when 3 then 'العلاج الوظيفي'
  when 4 then 'العلوم التكنولوجية'
  when 5 then 'العلوم الإعلامية'
  when 6 then 'العلوم الإعلامية'
  when 7 then 'العلاج الوظيفي'
  when 8 then 'العلاج الوظيفي'
  when 9 then 'علوم التربية البدنية'
  when 12 then 'العلوم التكنولوجية'
  when 13 then 'العلوم الإدارية'
  when 14 then 'العلوم التكنولوجية'
  when 15 then 'العلوم التكنولوجية'
  when 16 then 'العلوم التربوية'
  else null
end;

do $$
declare
  v_definition text;
  v_old_select text := 'select ps.id, ps.name, ps.region, ps.category, case when ps.id = 13 then ''العلوم الإدارية'' when ps.id in (10,11,17) then ''غير مصنف'' else ps.specialty end as specialty, ps.is_active';
  v_new_select text := 'select ps.id, ps.name, ps.region, ps.category, ps.specialty, ps.supervisor_group, ps.is_active';
  v_old_norm text := 'trim(coalesce(v_supervisor.specialty,''''))';
  v_new_norm text := 'trim(coalesce(v_supervisor.supervisor_group, v_supervisor.specialty,''''))';
  v_old_match text := 'v_specialty_ok := v_student_spec_norm = v_group_norm;';
  v_new_match text := 'if v_student_spec_norm in (
      lower(regexp_replace(translate(''إدارة الأعمال'',''أإآٱىؤئة'',''اااايويه''),''[[:space:]_/-]+'','''',''g'')),
      lower(regexp_replace(translate(''السكرتاريا الدولية'',''أإآٱىؤئة'',''اااايويه''),''[[:space:]_/-]+'','''',''g'')),
      lower(regexp_replace(translate(''العلوم المالية والمصرفية'',''أإآٱىؤئة'',''اااايويه''),''[[:space:]_/-]+'','''',''g''))
    ) then
      v_specialty_ok := v_group_norm = lower(regexp_replace(translate(''العلوم الإدارية'',''أإآٱىؤئة'',''اااايويه''),''[[:space:]_/-]+'','''',''g''));
    else
      v_specialty_ok := v_student_spec_norm = v_group_norm;
    end if;';
begin
  select pg_get_functiondef('public.assign_training_supervisor(uuid,uuid,bigint,bigint)'::regprocedure) into v_definition;
  if position(v_old_select in v_definition) = 0 or position(v_old_norm in v_definition) = 0 or position(v_old_match in v_definition) = 0 then
    raise exception 'Could not locate expected supervisor assignment expressions';
  end if;
  v_definition := replace(v_definition, v_old_select, v_new_select);
  v_definition := replace(v_definition, v_old_norm, v_new_norm);
  v_definition := replace(v_definition, v_old_match, v_new_match);
  execute v_definition;
end;
$$;