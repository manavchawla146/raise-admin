-- Supabase > SQL Editor > paste this whole file > Run

create table if not exists site_data (
  id text primary key,
  data jsonb not null default '{}',
  updated_at timestamptz default now()
);

alter table public.site_data enable row level security;

-- This table contains the public salon catalog. Replace any previous table
-- policies so older restrictive policies cannot continue blocking writes.
do $$
declare
  existing_policy record;
begin
  for existing_policy in
    select policyname
    from pg_policies
    where schemaname = 'public' and tablename = 'site_data'
  loop
    execute format('drop policy %I on public.site_data', existing_policy.policyname);
  end loop;
end;
$$;

revoke all on table public.site_data from anon, authenticated;
grant select on table public.site_data to anon, authenticated;
grant insert, update on table public.site_data to authenticated;

-- Visitors can read. A user signed in through Supabase Auth (email/password)
-- can insert or update the single published site row; no manually assigned
-- app_metadata role is required.
create policy "public read" on public.site_data
  for select to anon, authenticated using (true);
create policy "signed-in insert" on public.site_data
  for insert to authenticated with check (id = 'main');
create policy "signed-in update" on public.site_data
  for update to authenticated using (id = 'main')
  with check (id = 'main');
