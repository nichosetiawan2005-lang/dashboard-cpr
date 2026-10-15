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

## Aturan bisnis

1. **CPR tidak dipindah** setelah dibagikan, kecuali belum mulai dikerjakan (belum tiba, atau review 1 belum selesai).
2. **Pengalihan otomatis**: KA tidak hadir (cuti/sakit/dinas) pada hari review, atau beban KA melewati batas saat CPR tiba.
3. **Pengalihan oleh SPV** dari tab Kontrol SPV, wajib dengan alasan. Semua pengalihan tercatat (kapan, dari siapa, ke siapa, alasan, oleh siapa).
4. **CPR tertahan di approver** tidak membebani KA (beban hanya dihitung pada hari review) dan masuk daftar tindak lanjut SPV beserta tahapnya.
5. PIC rumah sakit opsional dengan **batas adil**: PIC hanya mendapat CPR selama jumlah CPR-nya ≤ rata-rata semua KA (tanpa toleransi).
6. Upload berikutnya **menambah** data: CPR baru ditambahkan, CPR lama diperbarui dan KA-nya tetap; periode pembagian diperluas otomatis.

## Forecast

- **Forecast 1** (CPR dibuat → tiba di KA): Linear Regression seperti di notebook, tanpa fitur kemiripan teks dan tanpa kategori capex (tidak ada di export harian).
  Model dilatih ulang di browser setiap kali pembagian dijalankan. Di data uji Jul–Sep 2026: MAE 3,33 hari, 67% CPR meleset ≤ 2 hari.
- **Forecast 2** (KA approve → kembali ke KA): median per rumah sakit (setara dengan model notebook, MAE ±3,9 hari).
- Upload CPR_Cleaned sebagai data riwayat agar model punya cukup data untuk belajar.

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
- Forecast 2 memakai model notebook (saat ini median per rumah sakit; hasilnya setara).
