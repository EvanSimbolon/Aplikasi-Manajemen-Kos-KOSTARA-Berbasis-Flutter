-- Keluhan dapat menyebut fasilitas secara manual ketika fasilitas kamar belum
-- terdaftar. fasilitas_kamar_id tetap dipakai jika pengguna memilih fasilitas
-- yang cocok dari daftar.
alter table public.laporan_kerusakan
  alter column fasilitas_kamar_id drop not null;

alter table public.laporan_kerusakan
  add column if not exists fasilitas_nama text;

drop policy if exists "laporan_select_reporter_or_owner" on public.laporan_kerusakan;
create policy "laporan_select_reporter_or_owner"
on public.laporan_kerusakan for select to authenticated
using (
  pelapor_id = auth.uid()
  or public.owner_can_view_user(pelapor_id)
  or public.is_fasilitas_kamar_owner(fasilitas_kamar_id)
);

drop policy if exists "laporan_insert_member" on public.laporan_kerusakan;
create policy "laporan_insert_member"
on public.laporan_kerusakan for insert to authenticated
with check (
  pelapor_id = auth.uid()
  and (
    fasilitas_kamar_id is null
    or public.is_fasilitas_kamar_member(fasilitas_kamar_id)
  )
);

drop policy if exists "laporan_update_owner" on public.laporan_kerusakan;
create policy "laporan_update_owner"
on public.laporan_kerusakan for update to authenticated
using (
  public.owner_can_view_user(pelapor_id)
  or public.is_fasilitas_kamar_owner(fasilitas_kamar_id)
)
with check (
  public.owner_can_view_user(pelapor_id)
  or public.is_fasilitas_kamar_owner(fasilitas_kamar_id)
);

notify pgrst, 'reload schema';
