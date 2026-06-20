create or replace function public.update_booking_status_with_capacity(
  p_booking_id uuid,
  p_status text
)
returns public.bookings
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_id uuid := auth.uid();
  v_booking public.bookings%rowtype;
  v_apartment public.apartments%rowtype;
  v_next_status text := lower(trim(coalesce(p_status, '')));
  v_previous_status text;
  v_people_count integer;
  v_was_accepted boolean;
  v_will_be_accepted boolean;
begin
  if v_actor_id is null then
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

  if v_actor_id <> v_booking."clientId" and v_actor_id <> v_booking."ownerId" then
    raise exception 'Not allowed to update this booking';
  end if;

  if v_next_status in ('accepted', 'confirmed', 'rejected')
     and v_actor_id <> v_booking."ownerId" then
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

revoke all on function public.update_booking_status_with_capacity(uuid, text) from public;
grant execute on function public.update_booking_status_with_capacity(uuid, text) to authenticated;
