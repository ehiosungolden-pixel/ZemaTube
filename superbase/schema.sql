-- Run this entire file in Supabase SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  avatar_url text,
  created_at timestamptz default now()
);
create table if not exists public.videos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text default '',
  category text default 'Other',
  video_url text not null,
  thumbnail_url text,
  channel_name text,
  visibility text default 'public' check (visibility in ('public','unlisted','private')),
  views bigint default 0,
  created_at timestamptz default now()
);
create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  video_id uuid not null references public.videos(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  body text not null,
  created_at timestamptz default now()
);
create table if not exists public.likes (
  user_id uuid references auth.users(id) on delete cascade,
  video_id uuid references public.videos(id) on delete cascade,
  created_at timestamptz default now(),
  primary key(user_id, video_id)
);
create table if not exists public.subscriptions (
  subscriber_id uuid references auth.users(id) on delete cascade,
  creator_id uuid references auth.users(id) on delete cascade,
  created_at timestamptz default now(),
  primary key(subscriber_id, creator_id),
  check (subscriber_id <> creator_id)
);
alter table public.profiles enable row level security;
alter table public.videos enable row level security;
alter table public.comments enable row level security;
alter table public.likes enable row level security;
alter table public.subscriptions enable row level security;
create policy "Profiles are readable" on public.profiles for select using (true);
create policy "Users update own profile" on public.profiles for update using (auth.uid()=id);
create policy "Users insert own profile" on public.profiles for insert with check (auth.uid()=id);
create policy "Public videos readable" on public.videos for select using (visibility='public' or auth.uid()=user_id);
create policy "Users upload own videos" on public.videos for insert with check (auth.uid()=user_id);
create policy "Owners update videos" on public.videos for update using (auth.uid()=user_id);
create policy "Owners delete videos" on public.videos for delete using (auth.uid()=user_id);
create policy "Comments readable" on public.comments for select using (true);
create policy "Signed in users comment" on public.comments for insert with check (auth.uid()=user_id);
create policy "Users delete own comments" on public.comments for delete using (auth.uid()=user_id);
create policy "Likes readable" on public.likes for select using (true);
create policy "Users manage own likes" on public.likes for all using (auth.uid()=user_id) with check (auth.uid()=user_id);
create policy "Subscriptions readable" on public.subscriptions for select using (true);
create policy "Users manage own subscriptions" on public.subscriptions for all using (auth.uid()=subscriber_id) with check (auth.uid()=subscriber_id);

-- Public video storage bucket. For production, consider private storage + signed URLs,
-- upload size limits, transcoding, moderation, and CDN delivery.
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('videos','videos',true,1073741824,array['video/mp4','video/webm','video/quicktime','video/ogg'])
on conflict (id) do nothing;
create policy "Public can view videos" on storage.objects for select using (bucket_id='videos');
create policy "Users upload to own folder" on storage.objects for insert to authenticated
with check (bucket_id='videos' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "Users delete own files" on storage.objects for delete to authenticated
using (bucket_id='videos' and (storage.foldername(name))[1]=auth.uid()::text);
