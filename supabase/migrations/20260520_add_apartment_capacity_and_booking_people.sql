create schema if not exists private;

alter table public.apartments
add column if not exists max_people integer,
add column if not exists available_people integer;

update public.apartments
set
  max_people = greatest(coalesce(max_people, bedrooms, 1), 1),
  available_people = greatest(coalesce(available_people, max_people, bedrooms, 1), 0)
where max_people is null or available_people is null;

update public.apartments
set available_people = least(available_people, max_people)
where available_people > max_people;

alter table public.apartments
alter column max_people set default 1,
alter column available_people set default 1,
alter column max_people set not null,
alter column available_people set not null;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'apartments_max_people_check'
  ) then
    alter table public.apartments
    add constraint apartments_max_people_check check (max_people > 0);
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'apartments_available_people_check'
  ) then
    alter table public.apartments
    add constraint apartments_available_people_check
    check (available_people >= 0 and available_people <= max_people);
  end if;
end $$;

alter table public.bookings
add column if not exists people_count integer;

update public.bookings
set people_count = greatest(coalesce(people_count, 1), 1)
where people_count is null;

alter table public.bookings
alter column people_count set default 1,
alter column people_count set not null;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'bookings_people_count_check'
  ) then
    alter table public.bookings
    add constraint bookings_people_count_check check (people_count > 0);
  end if;
end $$;

create or replace function private.apply_booking_status_change(
  p_actor_id uuid,
  p_booking_id uuid,
  p_status text
)
returns public.bookings
language plpgsql
security definer
set search_path = public, private
as $$
declare
  v_booking public.bookings%rowtype;
  v_apartment public.apartments%rowtype;
  v_next_status text := lower(trim(coalesce(p_status, '')));
  v_previous_status text;
  v_people_count integer;
  v_was_accepted boolean;
  v_will_be_accepted boolean;
begin
  if p_actor_id is null then
    raise exception 'Authentication required';
  end if;

  if v_next_status = '' then
    raise exception 'Booking status is required';
  end if;

  select *
  into v_booking
  from public.bookings
  where id = p_booking_id
  for update;

  if not found then
    raise exception 'Booking not found';
  end if;

  if p_actor_id <> v_booking."clientId" and p_actor_id <> v_booking."ownerId" then
    raise exception 'Not allowed to update this booking';
  end if;

  if v_next_status in ('accepted', 'confirmed', 'rejected')
     and p_actor_id <> v_booking."ownerId" then
    raise exception 'Only the owner can approve or reject this booking';
  end if;

  if v_next_status not in ('pending', 'accepted', 'confirmed', 'rejected', 'cancelled', 'canceled') then
    raise exception 'Unsupported booking status: %', v_next_status;
  end if;

  select *
  into v_apartment
  from public.apartments
  where id = v_booking."apartmentId"
  for update;

  if not found then
    raise exception 'Apartment not found for this booking';
  end if;

  v_previous_status := lower(trim(coalesce(v_booking.status, 'pending')));
  v_people_count := greatest(coalesce(v_booking.people_count, 1), 1);
  v_was_accepted := v_previous_status in ('accepted', 'confirmed');
  v_will_be_accepted := v_next_status in ('accepted', 'confirmed');

  if not v_was_accepted and v_will_be_accepted then
    if v_apartment.available_people < v_people_count then
      raise exception 'Only % people can still rent this apartment', v_apartment.available_people;
    end if;

    update public.apartments
    set available_people = available_people - v_people_count
    where id = v_apartment.id
    returning * into v_apartment;
  elsif v_was_accepted and not v_will_be_accepted then
    update public.apartments
    set available_people = least(max_people, available_people + v_people_count)
    where id = v_apartment.id
    returning * into v_apartment;
  end if;

  update public.bookings
  set status = v_next_status
  where id = v_booking.id
  returning * into v_booking;

  return v_booking;
end;
$$;

create or replace function public.update_booking_status_with_capacity(
  p_booking_id uuid,
  p_status text
)
returns public.bookings
language sql
set search_path = public
as $$
  select private.apply_booking_status_change(auth.uid(), p_booking_id, p_status);
$$;

revoke all on function public.update_booking_status_with_capacity(uuid, text) from public;
grant execute on function public.update_booking_status_with_capacity(uuid, text) to authenticated;
