-- izinkan pengguna mengunggah foto profilnya sendiri ke bucket foto-profil
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
