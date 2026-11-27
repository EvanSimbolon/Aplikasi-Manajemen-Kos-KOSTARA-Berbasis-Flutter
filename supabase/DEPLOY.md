# Deploy backend KOSTARA (Supabase)

Langkah ini **wajib** dijalankan sekali di Supabase Dashboard. Selama belum
di-deploy, layar "Tambah Penghuni" akan menampilkan error dari server
(misalnya `Unregistered API key`).

Proyek: `https://cbvhufmufcredviwguko.supabase.co`

## 1. Jalankan migrasi SQL

1. Buka **Dashboard  SQL Editor  New query**.
2. Jalankan migrasi berikut secara berurutan:
   - `supabase/migrations/20261112000000_undangan_penghuni_token.sql`
   - `supabase/migrations/20261120000000_foto_profil_storage_policy.sql`
   - `supabase/migrations/20261120000001_realtime_tables.sql`
   - `supabase/migrations/20261124000000_kalender_maintenance_visible.sql`
   - `supabase/migrations/20261124000001_profil_pengguna_alamat.sql`
   - `supabase/migrations/20261124000002_storage_foto_profil.sql`
   - `supabase/migrations/20261124000003_laporan_fasilitas_manual.sql`
   - `supabase/migrations/20261124000004_maintenance_kalender.sql`
   - `supabase/migrations/20261124000005_kamar_foto_dan_pembayaran_rls.sql`
   - `supabase/migrations/20261125000000_enable_all_rls_and_policies.sql`
   - `supabase/migrations/20261125000001_fix_penghuni_aktif_dan_recovery.sql`
   - `supabase/migrations/20261125000002_maintenance_foto_dan_notif_admin.sql`
   - `supabase/migrations/20261126000000_auto_tagihan_dan_fix_pembayaran.sql`
   - `supabase/migrations/20261127000000_login_penghuni_no_hp.sql`
3. Klik **Run** untuk setiap file.

Migrasi `20261112000000` menambah kolom `nama_tujuan`, `kamar_id`, dan
`tanggal_mulai` pada tabel `undangan_penghuni` serta policy agar penghuni bisa
melihat undangannya sendiri setelah login. Migrasi
`20261124000000` membuat jadwal pemeliharaan terlihat oleh semua penghuni dan
pemilik kos pada kalender. `20261124000001` memastikan kolom
`profil_pengguna.alamat` tersedia (database lama bisa saja belum memilikinya),
sehingga halaman Ubah Profil dapat menyimpan alamat.

Migrasi `20261124000002` membuat bucket `foto-profil` (public, maksimal 5 MB)
beserta policy storage untuk unggah/ubah/hapus foto milik sendiri dan policy
insert `profil_pengguna`. Tanpa migrasi ini unggah foto gagal dengan pesan
`new row violates row-level security policy`.

Migrasi `20261124000003` membuat `laporan_kerusakan.fasilitas_kamar_id` boleh
kosong dan menambah kolom `fasilitas_nama`, sehingga penghuni dapat mengetik
fasilitas secara manual walaupun kamarnya belum punya data `fasilitas_kamar`.

Migrasi `20261124000004` memastikan tabel `maintenance` ada beserta policy
select (penghuni & pemilik) dan tulis (pemilik). Kalender membaca tabel ini
agar jadwal maintenance buatan pemilik tampil juga di akun penghuni.

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

## 5. Atur redirect reset kata sandi

1. Buka **Dashboard  Authentication  URL Configuration**.
2. Tambahkan `kostara://reset-password` pada **Redirect URLs**.
3. Simpan perubahan.

Tautan "Lupa Kata Sandi" di menu admin akan mengirim email reset. Saat tautan
dibuka di perangkat, aplikasi menerima deep link dan menampilkan form kata sandi
baru beserta konfirmasinya.

## 6. (Opsional) Cek lewat curl

```bash
curl -X POST "https://cbvhufmufcredviwguko.supabase.co/functions/v1/tambah-penghuni" \
  -H "apikey: sb_publishable_PcNyzyod-QXvavBeHbsLpA_9hevDLkw" \
  -H "Content-Type: application/json" \
  -d '{"nama":"Tes","telepon":"08123456789","email":"tes@example.com","kamar_id":"<uuid kamar>","tanggal_mulai":"2026-11-12"}'
```

Respons sukses berisi `token`. Respons gagal berisi `error` yang jelas
(misalnya `Kamar A02 sudah terisi`).

## 7. Catatan keamanan

- Token disimpan hanya sebagai SHA-256 (`hash_token`).
- Password akun penghuni diturunkan dari token dengan format `Kt-<token>-1a`.
  Format ini dipakai di `supabase/functions/tambah-penghuni`,
  `supabase/functions/masuk-penghuni`, dan
  `lib/data/services/undangan_service.dart`. Ubah ketiganya bersamaan.
- Secret/service key hanya ada di server, tidak pernah di aplikasi Flutter.
