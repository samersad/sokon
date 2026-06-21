revoke execute on function public.rate_booking(uuid, integer) from public;
revoke execute on function public.rate_booking(uuid, integer) from anon;
grant execute on function public.rate_booking(uuid, integer) to authenticated;
