create or replace view public.apartment_editor_view
with (security_invoker = true)
as
select
  a.id as apartment_id,
  a.name,
  a.description,
  a.price,
  a.images,
  a.video_url,
  a.bedrooms,
  a.bathrooms,
  a.living_rooms,
  a.max_people,
  a.available_people,
  (a.max_people - a.available_people) as occupied_people,
  a.address,
  a."locationAddress" as location_address,
  a.lat,
  a.lng,
  a."ownerId" as owner_id,
  a."ownerName" as owner_name,
  a."ownerPhotoUrl" as owner_photo_url,
  a."createdAt" as created_at,
  coalesce(
    jsonb_agg(
      jsonb_build_object(
        'booking_id', b.id,
        'client_id', b."clientId",
        'client_name', b."clientName",
        'people_count', b.people_count,
        'start_date', b."startDate",
        'end_date', b."endDate",
        'total_price', b."totalPrice",
        'status', b.status,
        'booked_at', b."createdAt"
      )
      order by b."createdAt" desc
    ) filter (where b.id is not null),
    '[]'::jsonb
  ) as renters,
  coalesce(sum(b.people_count) filter (
    where lower(coalesce(b.status, 'pending')) in ('accepted', 'confirmed')
  ), 0) as total_people_rented
from public.apartments a
left join public.bookings b
  on b."apartmentId" = a.id
 and lower(coalesce(b.status, 'pending')) in ('accepted', 'confirmed')
group by
  a.id,
  a.name,
  a.description,
  a.price,
  a.images,
  a.video_url,
  a.bedrooms,
  a.bathrooms,
  a.living_rooms,
  a.max_people,
  a.available_people,
  a.address,
  a."locationAddress",
  a.lat,
  a.lng,
  a."ownerId",
  a."ownerName",
  a."ownerPhotoUrl",
  a."createdAt";
