alter table if exists public.messages
add column if not exists "imageUrl" text;

alter table if exists public.messages
add column if not exists "type" text;

update public.messages
set "type" = 'text'
where "type" is null;

alter table if exists public.chats
add column if not exists "lastMessageType" text;

alter table if exists public.chats
add column if not exists "lastImageUrl" text;
