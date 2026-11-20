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
