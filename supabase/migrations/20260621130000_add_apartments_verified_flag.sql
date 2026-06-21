alter table public.apartments
add column if not exists verified boolean not null default false;

update public.apartments
set verified = coalesce(verified, false)
where verified is null;
