# Dashboard Alokasi CPR

Dashboard untuk membagikan CPR ke Key Account (KA) HO dengan aturan DSS
(vendor sama → KA dengan beban paling ringan; List RS PIC dipakai sebagai daftar KA) dan melihat lama kerja tiap KA.
Bagian dari skripsi *Decision Support System untuk forecasting CPR dan redistribusi beban kerja KA*.

## Isi repo

| File | Fungsi |
|---|---|
| `index.html` | Seluruh dashboard dalam satu file (HTML + CSS + JavaScript) |
| `supabase_setup.sql` | Membuat tabel dan aturan keamanan di Supabase (dijalankan sekali) |

Repo ini **tidak berisi data CPR**. Data di-upload lewat dashboard dan disimpan di Supabase.

## Cara kerja

1. Buka dashboard dan masukkan **kode akses** (diingat di browser).
2. Dengan **kode admin**: upload **List RS PIC** dan **data CPR** (CPR_Cleaned atau CPRHistory).
   Dashboard membagikan setiap CPR baru ke KA dan menyimpan hasilnya di Supabase.
3. CPR yang sudah punya KA tidak dipindah pada upload berikutnya; hanya tanggalnya yang diperbarui.
4. Dengan **kode lihat**: melihat hasil yang sama tanpa bisa mengubah. Tanpa kode hanya tampil data contoh.

## Setup (sekali)

1. **Supabase**: buat project di supabase.com.
   - Buka *SQL Editor*, tempel isi `supabase_setup.sql`, **ganti dua kode di bagian 5**, lalu *Run*.
     Jangan commit kode asli ke repo ini.
   - Buka *Project Settings → API Keys*, salin **Project URL** dan **Publishable key**.
2. **index.html**: isi baris `const CONFIG = { supabaseUrl: "", supabaseKey: "" };` dengan URL dan key tadi.
   Jangan pernah memakai Secret key / `service_role` di file ini.
3. **GitHub Pages**: *Settings → Pages*, *Deploy from a branch*, branch `main`, folder `/ (root)`.

## Keamanan

- Publishable key memang aman dipasang di halaman publik; yang melindungi data adalah Row Level Security di Supabase.
- Setiap permintaan membawa kode akses (header `x-access-code`). Supabase yang memeriksa kode, bukan halaman.
- Tanpa kode: tidak bisa membaca apa pun. Kode lihat: hanya membaca. Kode admin: membaca, menyimpan, menghapus.
- Kalau kode tersebar, ganti kodenya dengan menjalankan ulang bagian 5 di SQL Editor.

## Rencana berikutnya

- Data otomatis masuk dari CGP Flow, tanpa upload manual.
- Model forecast dari notebook (Linear Regression / XGBoost) menggantikan median per rumah sakit.
