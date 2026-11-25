-- ============================================================================
-- FIX: Jangan hapus penghuni berstatus 'aktif' meski tanggal_selesai lewat,
-- pulihkan penyewaan & anggota_kos dari undangan yang sudah diterima,
-- dan sinkronkan view v_kamar_ketersediaan.
-- ============================================================================

-- 1. Perbaiki RPC hapus_penghuni_tidak_aktif: hanya hapus status berakhir/dihentikan
create or replace function public.hapus_penghuni_tidak_aktif(p_kos_id uuid)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_deleted integer := 0;
  v_penyewaan_ids uuid[];
  v_penghuni_ids uuid[];
begin
  if not public.is_kos_owner(p_kos_id) then
    raise exception 'Tidak memiliki izin untuk kos ini.';
  end if;

  select
    array_agg(p.id),
    array_agg(distinct p.penghuni_id)
  into v_penyewaan_ids, v_penghuni_ids
  from public.penyewaan p
  join public.kamar km on km.id = p.kamar_id
  where km.kos_id = p_kos_id
    and p.status in ('berakhir', 'dihentikan');

  if v_penyewaan_ids is null or array_length(v_penyewaan_ids, 1) is null then
    return 0;
  end if;

  delete from public.pembayaran
  where tagihan_id in (
    select t.id from public.tagihan t
    where t.penyewaan_id = any(v_penyewaan_ids)
  );

  delete from public.tagihan
  where penyewaan_id = any(v_penyewaan_ids);

  delete from public.penyewaan
  where id = any(v_penyewaan_ids);

  get diagnostics v_deleted = row_count;

  delete from public.anggota_kos ak
  where ak.kos_id = p_kos_id
    and ak.peran = 'penghuni'
    and ak.pengguna_id = any(v_penghuni_ids)
    and not exists (
      select 1
      from public.penyewaan p2
      join public.kamar km2 on km2.id = p2.kamar_id
      where km2.kos_id = p_kos_id
        and p2.penghuni_id = ak.pengguna_id
        and p2.status in ('aktif', 'menunggu_mulai')
    );

  return v_deleted;
end;
$$;

-- 2. Sinkronkan view v_kamar_ketersediaan berdasarkan status penyewaan aktif
create or replace view public.v_kamar_ketersediaan
with (security_invoker = true)
as
select
  km.id,
  km.kos_id,
  km.nomor_kamar,
  km.tipe_kamar,
  km.harga_sewa_bulanan,
  km.deskripsi,
  not exists (
    select 1
    from public.penyewaan p
    where p.kamar_id = km.id
      and p.status in ('menunggu_mulai', 'aktif')
  ) as tersedia
from public.kamar km;

-- 3. Pulihkan keanggotaan (anggota_kos) untuk undangan yang sudah diterima
insert into public.anggota_kos (kos_id, pengguna_id, peran, status)
select distinct
  u.kos_id,
  pg.id as pengguna_id,
  'penghuni',
  'aktif'
from public.undangan_penghuni u
join public.pengguna pg on lower(pg.email) = lower(u.email_tujuan)
where u.status = 'diterima'
on conflict (kos_id, pengguna_id) do update
  set status = 'aktif';

-- 4. Pulihkan penyewaan aktif dari undangan yang diterima jika terhapus
insert into public.penyewaan (
  kamar_id,
  penghuni_id,
  tanggal_mulai,
  tanggal_selesai,
  harga_sewa_disepakati,
  status
)
select distinct on (u.kamar_id)
  u.kamar_id,
  pg.id as penghuni_id,
  coalesce(u.tanggal_mulai, current_date) as tanggal_mulai,
  greatest(
    (coalesce(u.tanggal_mulai, current_date) + interval '1 month')::date,
    (current_date + interval '1 month')::date
  ) as tanggal_selesai,
  coalesce(km.harga_sewa_bulanan, 0),
  'aktif'
from public.undangan_penghuni u
join public.pengguna pg on lower(pg.email) = lower(u.email_tujuan)
join public.kamar km on km.id = u.kamar_id
where u.status = 'diterima'
  and u.kamar_id is not null
  and not exists (
    select 1
    from public.penyewaan p
    where p.kamar_id = u.kamar_id
      and p.status in ('aktif', 'menunggu_mulai')
  )
order by u.kamar_id, u.diterima_pada desc nulls last, u.dibuat_pada desc;

notify pgrst, 'reload schema';
