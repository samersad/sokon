alter table public.apartments
add column if not exists city text,
add column if not exists district text,
add column if not exists floor integer;

with normalized as (
  select
    id,
    coalesce(nullif(trim(city), ''), 'Assuit') as normalized_city,
    case
      when district is null then 'فيريال'
      when btrim(
        translate(
          district,
          chr(160)
          || chr(8203)
          || chr(8204)
          || chr(8205)
          || chr(8206)
          || chr(8207)
          || chr(8234)
          || chr(8235)
          || chr(8236)
          || chr(8237)
          || chr(8238)
          || chr(65279)
          || chr(1564),
          ''
        )
      ) in (
        'فيريال',
        'سيتي',
        'سيد',
        'الجمهوريه',
        'يسري راغب',
        'آخر'
      ) then btrim(
        translate(
          district,
          chr(160)
          || chr(8203)
          || chr(8204)
          || chr(8205)
          || chr(8206)
          || chr(8207)
          || chr(8234)
          || chr(8235)
          || chr(8236)
          || chr(8237)
          || chr(8238)
          || chr(65279)
          || chr(1564),
          ''
        )
      )
      else 'فيريال'
    end as normalized_district,
    coalesce(floor, 1) as normalized_floor
  from public.apartments
)
update public.apartments a
set
  city = n.normalized_city,
  district = n.normalized_district,
  floor = n.normalized_floor
from normalized n
where n.id = a.id;

alter table public.apartments
alter column city set default 'Assuit',
alter column district set default 'فيريال',
alter column floor set default 1,
alter column city set not null,
alter column district set not null,
alter column floor set not null;

alter table public.apartments
drop constraint if exists apartments_city_assuit_check,
drop constraint if exists apartments_district_check;

alter table public.apartments
add constraint apartments_city_assuit_check check (city = 'Assuit'),
add constraint apartments_district_check check (
  btrim(
    translate(
      district,
      chr(160)
      || chr(8203)
      || chr(8204)
      || chr(8205)
      || chr(8206)
      || chr(8207)
      || chr(8234)
      || chr(8235)
      || chr(8236)
      || chr(8237)
      || chr(8238)
      || chr(65279)
      || chr(1564),
      ''
    )
  ) in (
    'فيريال',
    'سيتي',
    'سيد',
    'الجمهوريه',
    'يسري راغب',
    'آخر'
  )
);

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
  ), 0) as total_people_rented,
  a.city,
  a.district,
  a.floor
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
  a."createdAt",
  a.city,
  a.district,
  a.floor;
