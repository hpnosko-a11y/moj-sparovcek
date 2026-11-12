-- Moj Šparovček: osnovna podatkovna baza
create extension if not exists pgcrypto;

create table if not exists public.households (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  invite_code text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.household_members (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (household_id, user_id)
);

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (type in ('income','expense')),
  amount numeric(12,2) not null check (amount > 0),
  description text not null,
  category text,
  created_at timestamptz not null default now()
);

create or replace function public.is_household_member(p_household_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.household_members
    where household_id = p_household_id and user_id = auth.uid()
  );
$$;

create or replace function public.create_household(p_name text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_household_id uuid;
  v_code text;
begin
  if auth.uid() is null then
    raise exception 'Prijava je obvezna.';
  end if;
  if nullif(trim(p_name), '') is null then
    raise exception 'Ime blagajne je obvezno.';
  end if;

  v_code := upper(encode(gen_random_bytes(4), 'hex'));
  insert into public.households(name, invite_code)
  values (trim(p_name), v_code)
  returning id into v_household_id;

  insert into public.household_members(household_id, user_id)
  values (v_household_id, auth.uid());

  return v_household_id;
end;
$$;

create or replace function public.join_household(p_invite_code text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_household_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Prijava je obvezna.';
  end if;

  select id into v_household_id
  from public.households
  where invite_code = upper(trim(p_invite_code));

  if v_household_id is null then
    raise exception 'Koda blagajne ni pravilna.';
  end if;

  insert into public.household_members(household_id, user_id)
  values (v_household_id, auth.uid())
  on conflict (household_id, user_id) do nothing;

  return v_household_id;
end;
$$;

alter table public.households enable row level security;
alter table public.household_members enable row level security;
alter table public.transactions enable row level security;

drop policy if exists "Members can view their households" on public.households;
create policy "Members can view their households"
on public.households for select to authenticated
using (public.is_household_member(id));

drop policy if exists "Members can view household members" on public.household_members;
create policy "Members can view household members"
on public.household_members for select to authenticated
using (public.is_household_member(household_id));

drop policy if exists "Members can view transactions" on public.transactions;
create policy "Members can view transactions"
on public.transactions for select to authenticated
using (public.is_household_member(household_id));

drop policy if exists "Members can add their own transactions" on public.transactions;
create policy "Members can add their own transactions"
on public.transactions for insert to authenticated
with check (
  user_id = auth.uid()
  and public.is_household_member(household_id)
);

grant execute on function public.is_household_member(uuid) to authenticated;
grant execute on function public.create_household(text) to authenticated;
grant execute on function public.join_household(text) to authenticated;
grant select on public.households, public.household_members, public.transactions to authenticated;
grant insert on public.transactions to authenticated;
