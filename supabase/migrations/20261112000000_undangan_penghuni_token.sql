-- KOSTARA — undangan penghuni berbasis token
--
-- Jalankan file ini melalui Supabase Dashboard -> SQL Editor, atau:
--   supabase db push
--
-- Perubahan:
--   1. Menyimpan nama calon penghuni, kamar yang dipilih admin, dan tanggal
--      mulai sewa langsung di baris undangan.
--   2. Mengizinkan penghuni membaca undangan miliknya sendiri setelah login
--      (berdasarkan email pada JWT).
--
-- Token TIDAK disimpan dalam bentuk asli. Yang disimpan hanya SHA-256 dari
-- token (kolom hash_token) supaya bocornya tabel tidak membocorkan token.

alter table public.undangan_penghuni
  add column if not exists nama_tujuan text,
  add column if not exists kamar_id uuid references public.kamar (id) on delete set null,
  add column if not exists tanggal_mulai date;

create index if not exists idx_undangan_kamar_id
  on public.undangan_penghuni (kamar_id);

-- Penghuni boleh melihat undangan yang ditujukan ke email-nya sendiri.
drop policy if exists "undangan_select_penerima" on public.undangan_penghuni;
create policy "undangan_select_penerima"
on public.undangan_penghuni for select to authenticated
using (
  lower(email_tujuan) = lower(coalesce(auth.jwt() ->> 'email', ''))
);
