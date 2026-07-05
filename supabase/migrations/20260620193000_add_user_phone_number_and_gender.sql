alter table public.users
add column if not exists college text,
add column if not exists "phoneNumber" text,
add column if not exists gender text;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'users_gender_check'
  ) then
    alter table public.users
    add constraint users_gender_check
    check (
      gender is null
      or gender in ('male', 'female', 'other')
    );
  end if;
end $$;
