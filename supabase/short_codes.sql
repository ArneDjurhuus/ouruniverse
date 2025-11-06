-- Short invite codes for couples
-- Dependencies: couples(id uuid pk), couple_members(couple_id uuid, user_id uuid)

create table if not exists public.short_codes (
  couple_id uuid not null references public.couples(id) on delete cascade,
  code text not null,
  expires_at timestamptz not null default now() + interval '48 hours',
  created_at timestamptz not null default now(),
  created_by uuid null default auth.uid(),
  constraint short_codes_pkey primary key (code)
);

-- Ensure uniqueness of code (also primary key)
create unique index if not exists short_codes_code_key on public.short_codes(code);
create index if not exists short_codes_expires_at_idx on public.short_codes(expires_at);

-- Enable Row Level Security
alter table public.short_codes enable row level security;

-- Members of a couple can create (insert) short codes for that couple
create policy if not exists "members can create codes" on public.short_codes
  for insert to authenticated
  with check (
    exists (
      select 1 from public.couple_members m
      where m.couple_id = short_codes.couple_id
        and m.user_id = auth.uid()
    )
  );

-- Anyone authenticated can fetch a valid, unexpired code to learn the couple_id
-- This is safe because knowing a couple_id doesn't expose private data; joining still requires insert into couple_members which is RLS protected
create policy if not exists "resolve valid codes" on public.short_codes
  for select to authenticated
  using (expires_at > now());

-- Only couple members can delete their codes (optional cleanup)
create policy if not exists "members can delete codes" on public.short_codes
  for delete to authenticated
  using (
    exists (
      select 1 from public.couple_members m
      where m.couple_id = short_codes.couple_id
        and m.user_id = auth.uid()
    )
  );

-- Optional: a background job can periodically remove expired codes
-- Not included here; you can run a cron job or use Supabase Scheduler to delete where expires_at <= now();
