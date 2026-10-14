# Dashboard Alokasi CPR

Dashboard untuk membagikan CPR ke Key Account (KA) HO dengan aturan DSS
(vendor sama → PIC rumah sakit → beban paling ringan) dan melihat lama kerja tiap KA.
Bagian dari skripsi *Decision Support System untuk forecasting CPR dan redistribusi beban kerja KA*.

## Isi repo

| File | Fungsi |
|---|---|
| `index.html` | Seluruh dashboard dalam satu file (HTML + CSS + JavaScript) |
| `supabase_setup.sql` | Membuat tabel dan aturan keamanan di Supabase (dijalankan sekali) |

Repo ini **tidak berisi data CPR**. Data di-upload lewat dashboard dan disimpan di Supabase.

## Cara kerja

1. Admin login, lalu upload **List RS PIC** dan **data CPR** (CPR_Cleaned atau CPRHistory).
2. Dashboard membagikan setiap CPR baru ke KA dan menyimpan hasilnya di Supabase.
3. CPR yang sudah punya KA tidak dipindah pada upload berikutnya; hanya tanggalnya yang diperbarui.
4. User lain cukup login untuk melihat hasil yang sama. Tanpa login hanya tampil data contoh.

## Setup (sekali)

1. **Supabase**: buat project di supabase.com.
   - Buka *SQL Editor*, tempel isi `supabase_setup.sql`, ganti email admin di baris terakhir, lalu *Run*.
   - Buka *Authentication → Users → Add user* untuk membuat akun (email + password) setiap orang yang boleh melihat dashboard, termasuk admin.
   - Buka *Project Settings → API*, salin **Project URL** dan **anon public key**.
2. **index.html**: isi baris `const CONFIG = { supabaseUrl: "", supabaseKey: "" };` dengan URL dan anon key tadi.
   Jangan pernah memakai key `service_role` di file ini.
3. **GitHub Pages**: di repo buka *Settings → Pages*, pilih *Deploy from a branch*, branch `main`, folder `/ (root)`.
   Beberapa menit kemudian dashboard bisa dibuka di `https://<username>.github.io/<nama-repo>/`.

## Keamanan

- Anon key memang aman dipasang di halaman publik; yang melindungi data adalah Row Level Security di Supabase.
- Tanpa login: tidak bisa membaca data apa pun.
- User yang login: hanya bisa membaca.
- Admin (email di tabel `cpr_admins`): bisa upload, menyimpan, dan menghapus.

## Rencana berikutnya

- Data otomatis masuk dari CGP Flow, tanpa upload manual.
- Model forecast dari notebook (Linear Regression / XGBoost) menggantikan median per rumah sakit.
