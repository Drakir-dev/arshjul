-- =====================================================================
--  ORT ÅRSHJUL – oppsett av databasen i Supabase
--  Lim inn HELE denne fila i Supabase: SQL Editor -> New query -> Run.
--
--  FØR du kjører: bytt ut  BYTT-MEG-TIL-EN-LANG-KODE  nederst i fila
--  med koden seksjonen skal bruke for å redigere (minst 10 tegn).
-- =====================================================================

create extension if not exists pgcrypto with schema extensions;

-- ---------- Tabeller ----------
create table if not exists public.oppgaver (
  id          uuid primary key default gen_random_uuid(),
  maned       int  not null check (maned between 1 and 12),
  tekst       text not null check (char_length(tekst) between 1 and 300),
  frist       text check (frist is null or frist ~ '^\d{1,2}\.\d{1,2}$'),
  ansvarlig   text not null default '' check (char_length(ansvarlig) <= 100),
  notat       text not null default '' check (char_length(notat) <= 3000),
  lenker      jsonb not null default '[]'::jsonb,
  rekkefolge  int  not null default 0,
  oppdatert   timestamptz not null default now()
);

create table if not exists public.avkrysninger (
  aar         int  not null check (aar between 2000 and 2100),
  oppgave_id  uuid not null references public.oppgaver(id) on delete cascade,
  utfort_av   text not null default '' check (char_length(utfort_av) <= 100),
  tidspunkt   timestamptz not null default now(),
  primary key (aar, oppgave_id)
);

-- Redigeringskoden lagres kryptert her. Ingen kan lese denne tabellen fra nettsiden.
create table if not exists public.hemmelig (
  id        int primary key default 1 check (id = 1),
  kode_hash text not null
);

-- ---------- Tilgang: alle kan LESE, ingen kan skrive direkte ----------
alter table public.oppgaver     enable row level security;
alter table public.avkrysninger enable row level security;
alter table public.hemmelig     enable row level security;

drop policy if exists "alle kan lese oppgaver" on public.oppgaver;
create policy "alle kan lese oppgaver" on public.oppgaver for select using (true);

drop policy if exists "alle kan lese avkrysninger" on public.avkrysninger;
create policy "alle kan lese avkrysninger" on public.avkrysninger for select using (true);
-- (hemmelig har ingen policy = helt stengt)

-- Eksplisitte rettigheter (virker også når "Automatically expose new tables" er slått av)
grant usage on schema public to anon, authenticated;
revoke all on public.oppgaver, public.avkrysninger, public.hemmelig from anon, authenticated;
grant select on public.oppgaver, public.avkrysninger to anon, authenticated;

-- ---------- Funksjoner: all skriving går via disse og krever koden ----------
create or replace function public.sjekk_kode(kode text)
returns boolean language sql security definer set search_path = public, extensions as $$
  select exists (select 1 from hemmelig where kode_hash = crypt(kode, kode_hash));
$$;

create or replace function public.lagre_oppgave(
  kode text, p_id uuid, p_maned int, p_tekst text, p_frist text,
  p_ansvarlig text, p_notat text, p_lenker jsonb
) returns uuid language plpgsql security definer set search_path = public, extensions as $$
declare v_id uuid; v_rekke int;
begin
  if not sjekk_kode(kode) then raise exception 'Feil kode' using errcode = '28000'; end if;
  if p_frist = '' then p_frist := null; end if;
  if p_id is null then
    select coalesce(max(rekkefolge), 0) + 1 into v_rekke from oppgaver where maned = p_maned;
    insert into oppgaver (maned, tekst, frist, ansvarlig, notat, lenker, rekkefolge)
    values (p_maned, p_tekst, p_frist, coalesce(p_ansvarlig,''), coalesce(p_notat,''), coalesce(p_lenker,'[]'::jsonb), v_rekke)
    returning id into v_id;
  else
    update oppgaver set
      rekkefolge = case when maned = p_maned then rekkefolge
                        else (select coalesce(max(rekkefolge),0)+1 from oppgaver where maned = p_maned) end,
      maned = p_maned, tekst = p_tekst, frist = p_frist,
      ansvarlig = coalesce(p_ansvarlig,''), notat = coalesce(p_notat,''),
      lenker = coalesce(p_lenker,'[]'::jsonb), oppdatert = now()
    where id = p_id returning id into v_id;
  end if;
  return v_id;
end $$;

create or replace function public.slett_oppgave(kode text, p_id uuid)
returns void language plpgsql security definer set search_path = public, extensions as $$
begin
  if not sjekk_kode(kode) then raise exception 'Feil kode' using errcode = '28000'; end if;
  delete from oppgaver where id = p_id;
end $$;

create or replace function public.sett_avkrysning(kode text, p_aar int, p_oppgave_id uuid, p_utfort boolean, p_utfort_av text)
returns void language plpgsql security definer set search_path = public, extensions as $$
begin
  if not sjekk_kode(kode) then raise exception 'Feil kode' using errcode = '28000'; end if;
  if p_utfort then
    insert into avkrysninger (aar, oppgave_id, utfort_av) values (p_aar, p_oppgave_id, coalesce(p_utfort_av,''))
    on conflict (aar, oppgave_id) do update set utfort_av = excluded.utfort_av, tidspunkt = now();
  else
    delete from avkrysninger where aar = p_aar and oppgave_id = p_oppgave_id;
  end if;
end $$;

revoke all on function public.sjekk_kode(text) from public;
revoke all on function public.lagre_oppgave(text,uuid,int,text,text,text,text,jsonb) from public;
revoke all on function public.slett_oppgave(text,uuid) from public;
revoke all on function public.sett_avkrysning(text,int,uuid,boolean,text) from public;
grant execute on function public.sjekk_kode(text) to anon, authenticated;
grant execute on function public.lagre_oppgave(text,uuid,int,text,text,text,text,jsonb) to anon, authenticated;
grant execute on function public.slett_oppgave(text,uuid) to anon, authenticated;
grant execute on function public.sett_avkrysning(text,int,uuid,boolean,text) to anon, authenticated;

-- ---------- Redigeringskoden (BYTT UT FØR DU KJØRER) ----------
insert into public.hemmelig (id, kode_hash)
values (1, crypt('BYTT-MEG-TIL-EN-LANG-KODE', gen_salt('bf')))
on conflict (id) do update set kode_hash = excluded.kode_hash;

-- ---------- Startinnhold: de 28 oppgavene (kjøres bare hvis tabellen er tom) ----------
insert into public.oppgaver (maned, tekst, frist, rekkefolge)
select * from (values
  (1,'Oppdatere oversikt over hjelpemiddellager',null,1),
  (1,'Hvilke brosjyrer og prosedyrer må utvikles/revideres?',null,2),
  (2,'Gjennomgang kurs: praktiske og elektroniske',null,1),
  (2,'Gjennomgang ExorLive og L5',null,2),
  (2,'Poliklinikk maidager','15.02',3),
  (3,'Poliklinikk sommer','15.03',1),
  (3,'Evaluering av endringer gjort siste 3 mnd',null,2),
  (4,'Evaluere nettsider',null,1),
  (4,'Planlegge kompetansefangst kommende halvår',null,2),
  (5,'Måloppfølging',null,1),
  (5,'Gjennomgang prioriteringer',null,2),
  (5,'Evaluering av endringer gjort siste 3 mnd',null,3),
  (6,'Hvilke brosjyrer og prosedyrer må utvikles/revideres?',null,1),
  (7,'Gjennomgang årshjulet',null,1),
  (8,'Oppdatere sektordokument',null,1),
  (8,'Evaluering av endringer gjort siste 3 mnd',null,2),
  (9,'Gjennomgang sektorens kompetansebehov',null,1),
  (9,'Individuelle kompetanseplaner',null,2),
  (9,'Poliklinikk jul','15.09',3),
  (10,'Målarbeid kommende år',null,1),
  (10,'Planlegge forskning/fagutvikling kommende år',null,2),
  (10,'Kursarrangement kommende år',null,3),
  (11,'Poliklinikk vinterferie','15.11',1),
  (11,'Planlegge kompetansefangst kommende halvår',null,2),
  (11,'Evaluering av endringer gjort siste 3 mnd',null,3),
  (12,'Poliklinikk påske','15.12',1),
  (12,'Måloppfølging',null,2),
  (12,'Gjennomgang prioriteringer',null,3)
) as v(maned, tekst, frist, rekkefolge)
where not exists (select 1 from public.oppgaver);

-- =====================================================================
--  BYTTE KODE SENERE: kjør bare denne linja (med ny kode) i SQL Editor:
--  update public.hemmelig set kode_hash = crypt('NY-KODE-HER', gen_salt('bf')) where id = 1;
-- =====================================================================
