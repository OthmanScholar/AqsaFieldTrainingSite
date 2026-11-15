alter table public.student_semester_evaluations
  add column if not exists specialty_id bigint references public.specialties(id);

update public.student_semester_evaluations e
set specialty_id = sp.specialty_id
from public.student_profiles sp
where sp.user_id = e.student_user_id
  and e.specialty_id is distinct from sp.specialty_id;

create index if not exists idx_student_semester_evaluations_specialty
  on public.student_semester_evaluations(specialty_id, semester_code);

create or replace function public.set_student_evaluation_specialty()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  select sp.specialty_id into new.specialty_id
  from public.student_profiles sp
  where sp.user_id = new.student_user_id;
  if new.specialty_id is null then
    raise exception 'Student specialty is missing; evaluation cannot be saved';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_set_student_evaluation_specialty
  on public.student_semester_evaluations;
create trigger trg_set_student_evaluation_specialty
before insert or update of student_user_id, specialty_id
on public.student_semester_evaluations
for each row execute function public.set_student_evaluation_specialty();

do $$
declare
  v_definition text;
  v_old text := 'select ps.id, ps.name, ps.region, ps.category, ps.specialty, ps.is_active';
  v_new text := 'select ps.id, ps.name, ps.region, ps.category, case when ps.id = 13 then ''العلوم الإدارية'' else ps.specialty end as specialty, ps.is_active';
begin
  select pg_get_functiondef('public.assign_training_supervisor(uuid,uuid,bigint,bigint)'::regprocedure)
    into v_definition;
  if position(v_old in v_definition) = 0 then
    raise exception 'Could not locate the supervisor specialty lookup';
  end if;
  execute replace(v_definition, v_old, v_new);
end;
$$;