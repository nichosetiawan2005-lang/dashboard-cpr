-- Jalankan sekali di Supabase: SQL Editor -> New query -> tempel -> Run.
-- GANTI dua kode di bagian 5 sebelum Run. Jangan simpan kode asli di GitHub.

-- 1. Tabel penyimpanan dashboard (satu baris = satu dokumen, contoh path: "cpr/meta", "alloc/2026-07")
create table if not exists public.cpr_store (
  path       text primary key,
  data       jsonb not null,
  updated_at timestamptz not null default now()
);

-- 2. Tabel kode akses: "view" = hanya lihat, "admin" = boleh upload dan menyimpan.
--    Tabel ini tidak bisa dibaca dari halaman web (tidak ada policy), hanya dari dashboard Supabase.
create table if not exists public.cpr_codes (
  role text primary key check (role in ('view', 'admin')),
  code text not null
);

alter table public.cpr_store enable row level security;
alter table public.cpr_codes enable row level security;

-- 3. Level akses dari kode yang dikirim halaman (header "x-access-code")
create or replace function public.cpr_access_level()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select role from public.cpr_codes
      where code = coalesce(current_setting('request.headers', true)::json ->> 'x-access-code', '')
      order by case role when 'admin' then 0 else 1 end
      limit 1),
    'none');
$$;
grant execute on function public.cpr_access_level() to anon, authenticated;

-- 4. Aturan: kode lihat/admin boleh membaca, hanya kode admin boleh menulis
drop policy if exists "baca: user login" on public.cpr_store;
drop policy if exists "tulis: admin" on public.cpr_store;
drop policy if exists "baca: punya kode" on public.cpr_store;
drop policy if exists "tulis: kode admin" on public.cpr_store;

create policy "baca: punya kode" on public.cpr_store
  for select to anon, authenticated
  using (public.cpr_access_level() in ('view', 'admin'));

create policy "tulis: kode admin" on public.cpr_store
  for all to anon, authenticated
  using      (public.cpr_access_level() = 'admin')
  with check (public.cpr_access_level() = 'admin');

-- 5. Kode akses (ganti dengan kode kamu). Untuk mengganti kode nanti, ubah lalu jalankan bagian ini lagi.
insert into public.cpr_codes (role, code) values
  ('view',  'GANTI-KODE-LIHAT'),
  ('admin', 'GANTI-KODE-ADMIN')
on conflict (role) do update set code = excluded.code;
