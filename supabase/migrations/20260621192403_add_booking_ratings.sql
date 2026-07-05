create schema if not exists private;

alter table public.bookings
add column if not exists rating integer,
add column if not exists rated_at timestamptz;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'bookings_rating_check'
  ) then
    alter table public.bookings
    add constraint bookings_rating_check check (rating is null or rating between 1 and 5);
  end if;
end $$;

alter table public.apartments
add column if not exists rating_sum integer not null default 0,
add column if not exists rating_count integer not null default 0,
add column if not exists rating_average numeric(3,2) not null default 0;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'apartments_rating_sum_check'
  ) then
    alter table public.apartments
    add constraint apartments_rating_sum_check check (rating_sum >= 0);
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'apartments_rating_count_check'
  ) then
    alter table public.apartments
    add constraint apartments_rating_count_check check (rating_count >= 0);
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'apartments_rating_average_check'
  ) then
    alter table public.apartments
    add constraint apartments_rating_average_check check (rating_average between 0 and 5);
  end if;
end $$;

create or replace function private.recalculate_apartment_rating(p_apartment_id uuid)
returns void
language plpgsql
security definer
set search_path = public, private
as $$
declare
  v_rating_sum integer;
  v_rating_count integer;
begin
  select
    coalesce(sum(rating), 0)::integer,
    count(rating)::integer
  into v_rating_sum, v_rating_count
  from public.bookings
  where "apartmentId" = p_apartment_id
    and rating is not null
    and lower(coalesce(status, 'pending')) in ('accepted', 'confirmed');

  update public.apartments
  set
    rating_sum = v_rating_sum,
    rating_count = v_rating_count,
    rating_average = case
      when v_rating_count = 0 then 0
      else round((v_rating_sum::numeric / v_rating_count::numeric), 2)
    end
  where id = p_apartment_id;
end;
$$;

create or replace function public.rate_booking(
  p_booking_id uuid,
  p_rating integer
)
returns public.bookings
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_id uuid := auth.uid();
  v_booking public.bookings%rowtype;
begin
  if v_actor_id is null then
    raise exception 'Authentication required';
  end if;

  if p_rating is null or p_rating < 1 or p_rating > 5 then
    raise exception 'Rating must be between 1 and 5';
  end if;

  select *
  into v_booking
  from public.bookings
  where id = p_booking_id
  for update;

  if not found then
    raise exception 'Booking not found';
  end if;

  if v_actor_id <> v_booking."clientId" then
    raise exception 'Only the booking client can rate this apartment';
  end if;

  if lower(coalesce(v_booking.status, 'pending')) not in ('accepted', 'confirmed') then
    raise exception 'Only accepted bookings can be rated';
  end if;

  update public.bookings
  set
    rating = p_rating,
    rated_at = now()
  where id = p_booking_id
  returning * into v_booking;

  perform private.recalculate_apartment_rating(v_booking."apartmentId");

  return v_booking;
end;
$$;

revoke all on function public.rate_booking(uuid, integer) from public;
grant execute on function public.rate_booking(uuid, integer) to authenticated;

do $$
declare
  v_apartment record;
begin
  for v_apartment in
    select id
    from public.apartments
  loop
    perform private.recalculate_apartment_rating(v_apartment.id);
  end loop;
end $$;
