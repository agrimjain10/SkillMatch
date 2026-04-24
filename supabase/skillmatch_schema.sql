-- SkillMatch live Supabase schema/policy repair.
-- Run this in Supabase SQL Editor with owner/service privileges.

create extension if not exists pgcrypto;

create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text not null default '',
  role text not null default 'CONTRIBUTOR',
  course text,
  year text,
  bio text,
  avatar_url text,
  open_to_collab boolean not null default true,
  onboarding_completed boolean not null default false,
  is_admin boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.users add column if not exists email text;
alter table public.users add column if not exists full_name text not null default '';
alter table public.users add column if not exists role text not null default 'CONTRIBUTOR';
alter table public.users add column if not exists course text;
alter table public.users add column if not exists year text;
alter table public.users add column if not exists bio text;
alter table public.users add column if not exists avatar_url text;
alter table public.users add column if not exists open_to_collab boolean not null default true;
alter table public.users add column if not exists onboarding_completed boolean not null default false;
alter table public.users add column if not exists is_admin boolean not null default false;
alter table public.users add column if not exists total_points integer not null default 0;
alter table public.users add column if not exists created_at timestamptz not null default now();
alter table public.users add column if not exists updated_at timestamptz not null default now();

create table if not exists public.skills (
  id uuid primary key default gen_random_uuid(),
  name text not null unique
);

create table if not exists public.user_skills (
  user_id uuid not null references public.users(id) on delete cascade,
  skill_id uuid not null references public.skills(id) on delete cascade,
  primary key (user_id, skill_id)
);

alter table public.user_skills add column if not exists user_id uuid;
alter table public.user_skills add column if not exists skill_id uuid;

create table if not exists public.matches (
  id uuid primary key default gen_random_uuid(),
  user1_id uuid not null references public.users(id) on delete cascade,
  user2_id uuid not null references public.users(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending', 'matched', 'rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint matches_no_self check (user1_id <> user2_id),
  constraint matches_unique_pair unique (user1_id, user2_id)
);

alter table public.matches add column if not exists user1_id uuid;
alter table public.matches add column if not exists user2_id uuid;
alter table public.matches add column if not exists status text not null default 'pending';
alter table public.matches add column if not exists created_at timestamptz not null default now();
alter table public.matches add column if not exists updated_at timestamptz not null default now();

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  match_id uuid not null references public.matches(id) on delete cascade,
  sender_id uuid not null references public.users(id) on delete cascade,
  content text not null,
  created_at timestamptz not null default now()
);

alter table public.messages add column if not exists match_id uuid;
alter table public.messages add column if not exists sender_id uuid;
alter table public.messages add column if not exists content text;
alter table public.messages add column if not exists created_at timestamptz not null default now();
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'body'
  ) then
    execute 'update public.messages set content = body where content is null';
  end if;
end $$;

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  category text,
  status text not null default 'open',
  created_by uuid not null references public.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.projects add column if not exists title text;
alter table public.projects add column if not exists description text;
alter table public.projects add column if not exists category text;
alter table public.projects add column if not exists status text not null default 'open';
alter table public.projects add column if not exists created_by uuid;
alter table public.projects add column if not exists created_at timestamptz not null default now();
alter table public.projects add column if not exists updated_at timestamptz not null default now();

create table if not exists public.project_members (
  project_id uuid not null references public.projects(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  status text not null default 'pending',
  created_at timestamptz not null default now(),
  primary key (project_id, user_id)
);

alter table public.project_members add column if not exists project_id uuid;
alter table public.project_members add column if not exists user_id uuid;
alter table public.project_members add column if not exists status text not null default 'pending';
alter table public.project_members add column if not exists created_at timestamptz not null default now();

create table if not exists public.badges (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  points integer not null default 0,
  created_at timestamptz not null default now()
);

alter table public.badges add column if not exists name text;
alter table public.badges add column if not exists description text;
alter table public.badges add column if not exists points integer not null default 0;
alter table public.badges add column if not exists created_at timestamptz not null default now();

create table if not exists public.user_badges (
  user_id uuid not null references public.users(id) on delete cascade,
  badge_id uuid not null references public.badges(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, badge_id)
);

alter table public.user_badges add column if not exists user_id uuid;
alter table public.user_badges add column if not exists badge_id uuid;
alter table public.user_badges add column if not exists created_at timestamptz not null default now();

create table if not exists public.user_streaks (
  user_id uuid primary key references public.users(id) on delete cascade,
  last_claim_date date,
  streak_count integer not null default 0,
  updated_at timestamptz not null default now()
);

alter table public.user_streaks add column if not exists user_id uuid;
alter table public.user_streaks add column if not exists last_claim_date date;
alter table public.user_streaks add column if not exists streak_count integer not null default 0;
alter table public.user_streaks add column if not exists updated_at timestamptz not null default now();

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update set public = true;

alter table public.users enable row level security;
alter table public.skills enable row level security;
alter table public.user_skills enable row level security;
alter table public.matches enable row level security;
alter table public.messages enable row level security;
alter table public.projects enable row level security;
alter table public.project_members enable row level security;
alter table public.badges enable row level security;
alter table public.user_badges enable row level security;
alter table public.user_streaks enable row level security;

grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on all tables in schema public to authenticated;
grant select on all tables in schema public to anon;

drop policy if exists users_select_all on public.users;
create policy users_select_all on public.users for select using (true);
drop policy if exists users_upsert_self on public.users;
create policy users_upsert_self on public.users for insert with check (id = auth.uid());
drop policy if exists users_update_self on public.users;
create policy users_update_self on public.users for update using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists skills_read_all on public.skills;
create policy skills_read_all on public.skills for select using (true);
drop policy if exists skills_insert_authenticated on public.skills;
create policy skills_insert_authenticated on public.skills for insert with check (auth.uid() is not null);

drop policy if exists user_skills_read_all on public.user_skills;
create policy user_skills_read_all on public.user_skills for select using (true);
drop policy if exists user_skills_write_self on public.user_skills;
create policy user_skills_write_self on public.user_skills for all using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists matches_read_participants on public.matches;
create policy matches_read_participants on public.matches for select using (auth.uid() in (user1_id, user2_id));
drop policy if exists matches_create_self on public.matches;
create policy matches_create_self on public.matches for insert with check (user1_id = auth.uid());
drop policy if exists matches_update_participants on public.matches;
create policy matches_update_participants on public.matches for update using (auth.uid() in (user1_id, user2_id)) with check (auth.uid() in (user1_id, user2_id));

drop policy if exists messages_read_matched_participants on public.messages;
create policy messages_read_matched_participants on public.messages for select using (
  exists (
    select 1 from public.matches m
    where m.id = messages.match_id
      and m.status = 'matched'
      and auth.uid() in (m.user1_id, m.user2_id)
  )
);
drop policy if exists messages_insert_matched_participants on public.messages;
create policy messages_insert_matched_participants on public.messages for insert with check (
  sender_id = auth.uid()
  and exists (
    select 1 from public.matches m
    where m.id = messages.match_id
      and m.status = 'matched'
      and auth.uid() in (m.user1_id, m.user2_id)
  )
);

drop policy if exists projects_read_open on public.projects;
create policy projects_read_open on public.projects for select using (status in ('open', 'active') or created_by = auth.uid());
drop policy if exists projects_insert_self on public.projects;
create policy projects_insert_self on public.projects for insert with check (created_by = auth.uid());
drop policy if exists projects_update_owner on public.projects;
create policy projects_update_owner on public.projects for update using (created_by = auth.uid()) with check (created_by = auth.uid());

drop policy if exists project_members_read_related on public.project_members;
create policy project_members_read_related on public.project_members for select using (
  user_id = auth.uid()
  or exists (select 1 from public.projects p where p.id = project_members.project_id and p.created_by = auth.uid())
);
drop policy if exists project_members_insert_self on public.project_members;
create policy project_members_insert_self on public.project_members for insert with check (user_id = auth.uid());
drop policy if exists project_members_update_related on public.project_members;
create policy project_members_update_related on public.project_members for update using (
  user_id = auth.uid()
  or exists (select 1 from public.projects p where p.id = project_members.project_id and p.created_by = auth.uid())
) with check (
  user_id = auth.uid()
  or exists (select 1 from public.projects p where p.id = project_members.project_id and p.created_by = auth.uid())
);

drop policy if exists badges_read_all on public.badges;
create policy badges_read_all on public.badges for select using (true);
drop policy if exists badges_insert_authenticated on public.badges;
create policy badges_insert_authenticated on public.badges for insert with check (auth.uid() is not null);
drop policy if exists badges_update_authenticated on public.badges;
create policy badges_update_authenticated on public.badges for update using (auth.uid() is not null) with check (auth.uid() is not null);

drop policy if exists user_badges_read_all on public.user_badges;
create policy user_badges_read_all on public.user_badges for select using (true);
drop policy if exists user_badges_insert_self on public.user_badges;
create policy user_badges_insert_self on public.user_badges for insert with check (user_id = auth.uid());
drop policy if exists user_badges_update_self on public.user_badges;
create policy user_badges_update_self on public.user_badges for update using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists user_streaks_read_self on public.user_streaks;
create policy user_streaks_read_self on public.user_streaks for select using (user_id = auth.uid());
drop policy if exists user_streaks_insert_self on public.user_streaks;
create policy user_streaks_insert_self on public.user_streaks for insert with check (user_id = auth.uid());
drop policy if exists user_streaks_update_self on public.user_streaks;
create policy user_streaks_update_self on public.user_streaks for update using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists avatars_public_read on storage.objects;
create policy avatars_public_read on storage.objects for select using (bucket_id = 'avatars');
drop policy if exists avatars_insert_own on storage.objects;
create policy avatars_insert_own on storage.objects for insert with check (
  bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]
);
drop policy if exists avatars_update_own on storage.objects;
create policy avatars_update_own on storage.objects for update using (
  bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]
) with check (
  bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]
);

insert into public.badges (name, description, points) values
  ('DAILY STREAK', 'Claimed a daily SkillMatch streak.', 25),
  ('3 DAY STREAK', 'Checked in for 3 days.', 75),
  ('PEER REVIEWER', 'Submitted a peer collaboration review.', 40),
  ('UI/UX MASTERY', 'Completed UI/UX evaluation.', 60),
  ('DART PROTOCOLS', 'Completed Dart evaluation.', 60),
  ('SYSTEM ARCHITECTURE', 'Completed architecture evaluation.', 60),
  ('REACTION GRID GAME', 'Completed the evaluation game.', 60)
on conflict (name) do update set
  description = excluded.description,
  points = excluded.points;

update public.users
set is_admin = true
where lower(email) = 'agrimjain056@gmail.com';

select pg_notify('pgrst', 'reload schema');
