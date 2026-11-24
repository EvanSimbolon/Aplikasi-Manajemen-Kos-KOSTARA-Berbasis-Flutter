-- Semua penghuni dan pemilik kos dapat melihat jadwal pemeliharaan kos.
-- Sebelumnya jadwal hanya terlihat oleh penghuni kamar yang memiliki fasilitas
-- tersebut, sehingga kalender penghuni lain tidak menampilkan maintenance.

drop policy if exists "jadwal_select_kos_member" on public.jadwal_pemeliharaan;
create policy "jadwal_select_kos_member"
on public.jadwal_pemeliharaan for select to authenticated
using (
  exists (
    select 1
    from public.fasilitas_kamar fk
    join public.kamar km on km.id = fk.kamar_id
    where fk.id = fasilitas_kamar_id
      and (
        public.is_kos_member(km.kos_id)
        or public.is_kos_owner(km.kos_id)
      )
  )
);
