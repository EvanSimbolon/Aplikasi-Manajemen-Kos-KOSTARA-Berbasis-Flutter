-- Pastikan bucket foto profil tersedia dan dapat diunggah oleh pemilik akun.
-- Migration ini idempoten dan aman dijalankan pada project yang sudah memiliki
-- bucket/policy dari migration sebelumnya.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'foto-profil',
  'foto-profil',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
on conflict (id) do update
  set public = true,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "foto_profil_read_public" on storage.objects;
create policy "foto_profil_read_public"
on storage.objects for select to public
using (bucket_id = 'foto-profil');

drop policy if exists "foto_profil_insert_own" on storage.objects;
create policy "foto_profil_insert_own"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'foto-profil'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "foto_profil_update_own" on storage.objects;
create policy "foto_profil_update_own"
on storage.objects for update to authenticated
using (
  bucket_id = 'foto-profil'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'foto-profil'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "foto_profil_delete_own" on storage.objects;
create policy "foto_profil_delete_own"
on storage.objects for delete to authenticated
using (
  bucket_id = 'foto-profil'
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- Beberapa akun lama mungkin belum memiliki baris profil_pengguna.
drop policy if exists "profil_insert_own" on public.profil_pengguna;
create policy "profil_insert_own"
on public.profil_pengguna for insert to authenticated
with check (pengguna_id = auth.uid());

notify pgrst, 'reload schema';
