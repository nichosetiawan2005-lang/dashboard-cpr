-- Jalankan sekali di Supabase: menu SQL Editor -> New query -> tempel -> Run.
-- Ganti email di bagian paling bawah dengan email admin (yang boleh upload data).

-- 1. Tabel penyimpanan dashboard (satu baris = satu dokumen, contoh path: "cpr/meta", "alloc/2026-07")
create table if not exists public.cpr_store (
  path       text primary key,
  data       jsonb not null,
  updated_at timestamptz not null default now()
);

-- 2. Daftar admin (email yang boleh upload dan menyimpan)
create table if not exists public.cpr_admins (
  email text primary key
);

-- 3. Keamanan: tanpa login tidak bisa membaca apa pun
alter table public.cpr_store  enable row level security;
alter table public.cpr_admins enable row level security;

-- semua user yang login boleh membaca data
drop policy if exists "baca: user login" on public.cpr_store;
create policy "baca: user login" on public.cpr_store
  for select to authenticated using (true);

-- hanya admin yang boleh menambah, mengubah, dan menghapus
drop policy if exists "tulis: admin" on public.cpr_store;
create policy "tulis: admin" on public.cpr_store
  for all to authenticated
  using      (exists (select 1 from public.cpr_admins a where a.email = auth.jwt() ->> 'email'))
  with check (exists (select 1 from public.cpr_admins a where a.email = auth.jwt() ->> 'email'));

-- user hanya bisa melihat apakah dirinya admin
drop policy if exists "admin: lihat diri sendiri" on public.cpr_admins;
create policy "admin: lihat diri sendiri" on public.cpr_admins
  for select to authenticated using (email = auth.jwt() ->> 'email');

-- 4. Email admin (ganti dengan email kamu)
insert into public.cpr_admins (email) values ('email.admin@contoh.com')
on conflict do nothing;
