# KOSTARA Supabase

Folder ini berisi konfigurasi database Supabase untuk aplikasi KOSTARA.

## File penting

- `migrations/20261110000000_kostara_initial_schema.sql` — schema awal 16 tabel,
  index, trigger, RLS, view, dan storage bucket.

## Environment Flutter

Buat file `.env` di root proyek (sudah di-`.gitignore`):

```env
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_PUBLISHABLE_KEY=<publishable-key>
```

Contoh tersedia di `.env.example`.

Jangan pernah memakai atau menyimpan `service_role` / `secret key` di aplikasi
Flutter. Kunci tersebut hanya untuk server dan tidak boleh masuk ke repository.

Alternatif tanpa `.env`:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key>
```

## Menerapkan schema

### Opsi A — SQL Editor (paling mudah)

1. Buka Supabase Dashboard -> SQL Editor.
2. Salin seluruh isi
   `supabase/migrations/20261110000000_kostara_initial_schema.sql`.
3. Klik **Run**.

### Opsi B — Supabase CLI

```bash
supabase link --project-ref <project-ref>
supabase db push
```

`supabase db push` membutuhkan akses database (DB password atau access token).

## Daftar tabel

| Kelompok | Tabel |
|---|---|
| Akun & keanggotaan | `pengguna`, `profil_pengguna`, `kos`, `anggota_kos`, `undangan_penghuni` |
| Kos & kamar | `kamar`, `jenis_fasilitas`, `fasilitas_kamar` |
| Penyewaan & tagihan | `penyewaan`, `tagihan` |
| Pembayaran | `pembayaran`, `bukti_pembayaran` |
| Fasilitas & pemeliharaan | `laporan_kerusakan`, `jadwal_pemeliharaan` |
| Kalender | `acara_kalender` |
| Notifikasi | `notifikasi` |

View bantu:

- `v_kamar_ketersediaan`
- `v_penghuni_aktif`
- `v_riwayat_pembayaran`

## Auth dan RLS

- `pengguna.id` terhubung ke `auth.users.id`.
- Trigger `on_auth_user_created` otomatis membuat baris `pengguna` dan
  `profil_pengguna` saat user baru mendaftar.
- RLS aktif di semua tabel. Client hanya bisa membaca/menulis data sesuai
  keanggotaan kos dan peran (`pemilik` / `penghuni`).
- Jangan mematikan RLS untuk mempermudah debugging di production.

## Membuat owner pertama

1. Buat user melalui Dashboard -> Authentication -> Users.
2. Ambil UUID user tersebut.
3. Jalankan SQL berikut di SQL Editor:

```sql
insert into public.kos (id, pemilik_id, nama_kos, alamat)
values (gen_random_uuid(), '<USER_UUID>', 'Kos Contoh', 'Alamat Kos')
returning id;

insert into public.anggota_kos (kos_id, pengguna_id, peran, status)
values ('<KOS_UUID>', '<USER_UUID>', 'pemilik', 'aktif');
```

Owner dapat juga dibuat melalui Admin API (`/auth/v1/admin/users`) dengan
`email_confirm: true`. Jangan pernah memakai secret/service-role key di aplikasi
Flutter atau memasukkannya ke repository.

Akun owner proyek ini sudah dibuat dan terhubung ke satu kos. Kata sandi awal
harus segera diganti melalui Dashboard -> Authentication -> Users.

## Alur autentikasi aplikasi

1. Pengguna memilih **Penghuni Kos** atau **Admin** di landing page.
2. Admin masuk memakai email dan kata sandi. Penghuni masuk memakai No. HP dan
   token yang diberikan pemilik kos.
3. Untuk penghuni, nomor HP dinormalkan lalu dipetakan menjadi email internal
   `<no_hp>@kostara.local`; token dipakai sebagai password saat memanggil
   `signInWithPassword`. Akun auth penghuni harus dibuat dengan email internal
   dan token tersebut.
4. Aplikasi membaca `anggota_kos` milik user dengan `status = 'aktif'`.
5. Peran `pemilik` hanya boleh masuk lewat menu Admin; peran `penghuni` hanya
   boleh masuk lewat menu Penghuni Kos.
6. User tanpa keanggotaan aktif akan dikeluarkan kembali dan mendapat pesan
   kesalahan.
7. Tombol **Daftar** hanya ada di halaman Admin. Halaman pendaftaran admin
   belum diimplementasikan.
8. Logout memanggil `signOut()` sehingga sesi lokal dihapus.

## Migrasi data repository

Repository Flutter sudah memakai Supabase:

| Fitur | Sumber data |
|---|---|
| Kamar | `v_kamar_ketersediaan` |
| Penghuni | `penyewaan` + `pengguna` + `kamar` |
| Pembayaran | `tagihan` + `pembayaran` |
| Riwayat pembayaran | `v_riwayat_pembayaran` |
| Profil | `pengguna` + `profil_pengguna` |

Relasi dibaca memakai embedded select PostgREST, misalnya
`penyewaan!inner(pengguna!penyewaan_penghuni_id_fkey(nama_lengkap), kamar!inner(nomor_kamar))`.
Tidak ada view tambahan yang diperlukan untuk migrasi ini.

Data contoh di repository hanya dipakai jika Supabase belum diinisialisasi
(unit test). Jika database kosong, aplikasi menampilkan daftar kosong.

## Storage

Bucket yang dibuat:

- `foto-kamar` (public)
- `foto-profil` (public)
- `bukti-pembayaran` (private)

Bukti pembayaran disimpan dengan path:

```text
bukti-pembayaran/<pembayaran_id>/<nama-file>
```
