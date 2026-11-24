-- Kolom alamat pada profil pengguna.
-- Sebagian database lama dibuat tanpa kolom ini, sehingga halaman profil
-- gagal dimuat dan penyimpanan alamat gagal. Idempoten agar aman dijalankan
-- pada database yang sudah memiliki kolom alamat.
alter table public.profil_pengguna
  add column if not exists alamat text;

notify pgrst, 'reload schema';
