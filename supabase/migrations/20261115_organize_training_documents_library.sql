alter table public.training_documents
  add column if not exists specialty text,
  add column if not exists target_audience text not null default 'all';

alter table public.training_documents
  drop constraint if exists training_documents_target_audience_check;
alter table public.training_documents
  add constraint training_documents_target_audience_check
  check (target_audience in ('all','students','supervisors','staff'));

create index if not exists idx_training_documents_specialty_published
  on public.training_documents(specialty,is_published,created_at desc);
