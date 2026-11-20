# Deploy backend KOSTARA (Supabase)

Langkah ini **wajib** dijalankan sekali di Supabase Dashboard. Selama belum
di-deploy, layar "Tambah Penghuni" akan menampilkan error dari server
(misalnya `Unregistered API key`).

Proyek: `https://cbvhufmufcredviwguko.supabase.co`

## 1. Jalankan migrasi SQL

1. Buka **Dashboard → SQL Editor → New query**.
2. Buka file `supabase/migrations/20261112000000_undangan_penghuni_token.sql`,
   salin seluruh isinya, tempel di editor.
3. Klik **Run**.

Migrasi ini menambah kolom `nama_tujuan`, `kamar_id`, dan `tanggal_mulai` pada
tabel `undangan_penghuni` serta policy agar penghuni bisa melihat undangannya
sendiri setelah login.

## 2. Deploy Edge Function `tambah-penghuni`

1. Buka **Dashboard → Edge Functions**.
2. Pilih function `tambah-penghuni` (kalau belum ada, klik **Deploy a new
   function** dengan nama `tambah-penghuni`).
3. Ganti seluruh isi editor dengan isi
   `supabase/functions/tambah-penghuni/index.ts` dari repo ini.
4. Pastikan **Verify JWT / Enforce JWT verification** = **OFF** (fungsi ini
   dipanggil sebelum ada sesi login).
5. Klik **Deploy**.

## 3. Deploy Edge Function `masuk-penghuni`

Ulangi langkah 2 dengan nama function `masuk-penghuni` dan file
`supabase/functions/masuk-penghuni/index.ts`.

## 4. Cek secret key

Edge Function membutuhkan secret key untuk melewati RLS. Supabase otomatis
menyediakan:

- `SUPABASE_URL`
- `SUPABASE_SECRET_KEYS` (key baru, JSON dengan properti `default`)
- `SUPABASE_SERVICE_ROLE_KEY` (proyek lama)

Kode fungsi membaca `SUPABASE_SECRET_KEYS.default` lebih dulu, lalu jatuh ke
`SUPABASE_SERVICE_ROLE_KEY`. Jadi tidak perlu menambahkan secret manual — asal
fungsi **di-redeploy** agar env var baru terbaca.

> **Penyebab `Unregistered API key`:** versi fungsi yang sedang aktif di server
> memakai key lama (anon/service_role JWT) yang sudah tidak terdaftar setelah
> proyek migrasi ke publishable/secret key. Error ini muncul dari dalam fungsi,
> bukan dari aplikasi Flutter, sehingga hanya bisa hilang setelah fungsi
> di-redeploy dengan kode di atas.

## 5. (Opsional) Cek lewat curl

```bash
curl -X POST "https://cbvhufmufcredviwguko.supabase.co/functions/v1/tambah-penghuni" \
  -H "apikey: sb_publishable_PcNyzyod-QXvavBeHbsLpA_9hevDLkw" \
  -H "Content-Type: application/json" \
  -d '{"nama":"Tes","telepon":"08123456789","email":"tes@example.com","kamar_id":"<uuid kamar>","tanggal_mulai":"2026-11-12"}'
```

Respons sukses berisi `token`. Respons gagal berisi `error` yang jelas
(misalnya `Kamar A02 sudah terisi`).

## 6. Catatan keamanan

- Token disimpan hanya sebagai SHA-256 (`hash_token`).
- Password akun penghuni diturunkan dari token dengan format `Kt-<token>-1a`.
  Format ini dipakai di `supabase/functions/tambah-penghuni`,
  `supabase/functions/masuk-penghuni`, dan
  `lib/data/services/undangan_service.dart`. Ubah ketiganya bersamaan.
- Secret/service key hanya ada di server, tidak pernah di aplikasi Flutter.
