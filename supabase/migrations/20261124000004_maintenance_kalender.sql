-- Tabel maintenance dipakai oleh layar Maintenance dan kalender.
-- Dibuat idempoten agar project baru tetap memiliki struktur yang sama dengan
-- database yang sudah berjalan.
create table if not exists public.maintenance (
  id uuid primary key default gen_random_uuid(),
  kamar_id uuid not null references public.kamar (id) on delete cascade,
  jenis_perawatan text not null,
  tanggal_perawatan date not null,
  teknisi text,
  status text not null default 'Terjadwal',
  catatan text,
  dibuat_pada timestamptz not null default now(),
  diperbarui_pada timestamptz not null default now()
);

alter table public.maintenance enable row level security;

drop policy if exists "maintenance_select_member" on public.maintenance;
create policy "maintenance_select_member"
on public.maintenance for select to authenticated
using (
  public.is_kamar_member(kamar_id)
  or public.is_kamar_owner(kamar_id)
);

drop policy if exists "maintenance_write_owner" on public.maintenance;
create policy "maintenance_write_owner"
on public.maintenance for all to authenticated
using (public.is_kamar_owner(kamar_id))
with check (public.is_kamar_owner(kamar_id));

notify pgrst, 'reload schema';
