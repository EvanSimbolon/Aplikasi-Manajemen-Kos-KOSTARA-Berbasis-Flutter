# KOSTARA

Aplikasi pengelolaan kos berbasis Flutter untuk Owner dan Tenant.

## Arsitektur

```text
lib/
  config/       konfigurasi aplikasi dan Supabase
  data/         repository, service, dan model API
  domain/       model bisnis
  routing/      route dan router
  ui/           layar, widget, dan view model per fitur
  utils/        formatter dan validator
supabase/
  migrations/   schema database PostgreSQL/Supabase
```

## Menjalankan aplikasi

1. Install dependency:

   ```bash
   flutter pub get
   ```

2. Buat file `.env` dari contoh:

   ```powershell
   Copy-Item .env.example .env
   ```

   Isi `SUPABASE_URL` dan `SUPABASE_PUBLISHABLE_KEY` dari Supabase Dashboard
   (Project Settings -> API). File `.env` tidak di-commit.

3. Terapkan schema database:

   Buka Supabase Dashboard -> SQL Editor, lalu jalankan isi
   `supabase/migrations/20261110000000_kostara_initial_schema.sql`.

4. Jalankan aplikasi:

   ```bash
   flutter run
   ```

   Atau gunakan environment spesifik:

   ```bash
   flutter run -t lib/main_development.dart
   flutter run -t lib/main_staging.dart
   ```

## Supabase

Panduan lengkap database, RLS, auth trigger, dan storage ada di
[`supabase/README.md`](supabase/README.md).

Data aplikasi sudah diambil dari Supabase melalui `lib/data/repositories`:

- Kamar dari view `v_kamar_ketersediaan`.
- Penghuni dari tabel `penyewaan` dan relasi `pengguna` / `kamar`.
- Pembayaran dari tabel `tagihan` dan `pembayaran`.
- Riwayat pembayaran dari view `v_riwayat_pembayaran`.
- Profil dari tabel `pengguna` dan `profil_pengguna`.

Repository memakai data contoh hanya saat Supabase belum diinisialisasi
(misalnya pada unit test). Saat aplikasi berjalan dengan Supabase, data kosong
di database akan ditampilkan sebagai daftar kosong.

## Autentikasi

- **Admin/pemilik** masuk memakai email dan kata sandi.
- **Penghuni** masuk memakai No. HP dan token yang diberikan pemilik kos.
  Penghuni tidak melakukan pendaftaran mandiri.
- Tombol **Daftar** hanya tampil pada halaman masuk Admin. Halaman pendaftaran
  admin belum dibuat; tombol tersebut baru menampilkan informasi bahwa fitur
  belum tersedia.
- Peran ditentukan dari tabel `anggota_kos` dengan status `aktif`.
- `pemilik` diarahkan ke dashboard admin, `penghuni` ke dashboard penghuni.
- Akun tanpa keanggotaan aktif akan ditolak.
- Sesi disimpan oleh Supabase; saat aplikasi dibuka kembali, landing page
  memeriksa sesi dan langsung mengarahkan ke dashboard yang sesuai.
- Tombol **Keluar** pada profil admin dan penghuni memanggil
  `AuthService.logout()`.

Untuk login penghuni, aplikasi menormalkan nomor HP (misalnya `+62 812-3456`
atau `8123456` menjadi `08123456`) lalu memakai email internal
`<no_hp>@kostara.local` dengan token sebagai kata sandi Supabase Auth. Karena
itu, akun auth penghuni harus dibuat dengan email internal tersebut dan token
yang sama.

Akun owner sudah disiapkan untuk proyek ini. Kata sandi akun owner wajib
diganti melalui Supabase Dashboard -> Authentication -> Users sebelum dipakai
di production.

## Pengujian

```bash
flutter analyze
flutter test
```

## Keamanan

- Hanya gunakan **publishable/anon key** di aplikasi Flutter.
- Jangan pernah memasukkan `service_role` key, `secret key`, atau password
  database ke dalam repository.
- RLS wajib aktif untuk semua tabel yang diakses dari client.
