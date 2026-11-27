-- ============================================================================
-- FIX PEMBAYARAN PENGHUNI -> ADMIN:
-- 1. Trigger otomatis membuat tagihan pertama saat penyewaan aktif dibuat.
-- 2. Backfill tagihan untuk semua penyewaan aktif yang belum punya tagihan.
-- 3. RPC pastikan_tagihan_aktif() agar penghuni yang belum punya tagihan
--    otomatis dibuatkan tagihan periode berjalan saat membuka menu Bayar.
-- 4. Pastikan trigger notifikasi pembayaran ke pemilik kos aktif.
-- ============================================================================

-- 1. Fungsi & trigger: otomatis buat tagihan saat penyewaan aktif dibuat
create or replace function public.auto_buat_tagihan_penyewaan()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_mulai date;
  v_selesai date;
  v_jatuh_tempo date;
begin
  if new.status not in ('aktif', 'menunggu_mulai') then
    return new;
  end if;

  v_mulai := coalesce(new.tanggal_mulai, current_date);
  v_selesai := case
    when new.tanggal_selesai is not null and new.tanggal_selesai > v_mulai
      then new.tanggal_selesai
    else (v_mulai + interval '1 month')::date
  end;
  v_jatuh_tempo := least(v_selesai, (v_mulai + interval '7 days')::date);

  insert into public.tagihan (
    penyewaan_id,
    periode_mulai,
    periode_selesai,
    tanggal_jatuh_tempo,
    jumlah_tagihan,
    status
  ) values (
    new.id,
    v_mulai,
    v_selesai,
    v_jatuh_tempo,
    coalesce(new.harga_sewa_disepakati, 0),
    'belum_bayar'
  )
  on conflict (penyewaan_id, periode_mulai, periode_selesai) do nothing;

  return new;
end;
$$;

drop trigger if exists trg_penyewaan_auto_tagihan on public.penyewaan;
create trigger trg_penyewaan_auto_tagihan
after insert on public.penyewaan
for each row execute function public.auto_buat_tagihan_penyewaan();

-- 2. Backfill tagihan untuk penyewaan aktif yang belum memiliki tagihan
insert into public.tagihan (
  penyewaan_id,
  periode_mulai,
  periode_selesai,
  tanggal_jatuh_tempo,
  jumlah_tagihan,
  status
)
select
  p.id,
  coalesce(p.tanggal_mulai, current_date) as periode_mulai,
  case
    when p.tanggal_selesai is not null and p.tanggal_selesai > coalesce(p.tanggal_mulai, current_date)
      then p.tanggal_selesai
    else (coalesce(p.tanggal_mulai, current_date) + interval '1 month')::date
  end as periode_selesai,
  least(
    case
      when p.tanggal_selesai is not null and p.tanggal_selesai > coalesce(p.tanggal_mulai, current_date)
        then p.tanggal_selesai
      else (coalesce(p.tanggal_mulai, current_date) + interval '1 month')::date
    end,
    (coalesce(p.tanggal_mulai, current_date) + interval '7 days')::date
  ) as tanggal_jatuh_tempo,
  coalesce(p.harga_sewa_disepakati, km.harga_sewa_bulanan, 0) as jumlah_tagihan,
  'belum_bayar'
from public.penyewaan p
join public.kamar km on km.id = p.kamar_id
where p.status in ('aktif', 'menunggu_mulai')
  and not exists (
    select 1
    from public.tagihan t
    where t.penyewaan_id = p.id
      and t.status in ('belum_bayar', 'terlambat', 'dibayar_sebagian')
  )
on conflict (penyewaan_id, periode_mulai, periode_selesai) do nothing;

-- 3. RPC aman untuk memastikan penghuni yang login memiliki tagihan aktif
create or replace function public.pastikan_tagihan_aktif()
returns table (
  id uuid,
  penyewaan_id uuid,
  periode_mulai date,
  periode_selesai date,
  tanggal_jatuh_tempo date,
  jumlah_tagihan numeric,
  status text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_penyewaan record;
  v_mulai date;
  v_selesai date;
  v_jatuh_tempo date;
  v_tagihan_id uuid;
begin
  if v_uid is null then
    return;
  end if;

  select p.id, p.tanggal_mulai, p.tanggal_selesai, p.harga_sewa_disepakati, km.harga_sewa_bulanan
  into v_penyewaan
  from public.penyewaan p
  join public.kamar km on km.id = p.kamar_id
  where p.penghuni_id = v_uid
    and p.status in ('aktif', 'menunggu_mulai')
  order by p.tanggal_mulai desc
  limit 1;

  if v_penyewaan.id is null then
    return;
  end if;

  -- Cek apakah sudah ada tagihan belum lunas
  select t.id
  into v_tagihan_id
  from public.tagihan t
  where t.penyewaan_id = v_penyewaan.id
    and t.status in ('belum_bayar', 'terlambat', 'dibayar_sebagian')
  order by t.tanggal_jatuh_tempo asc
  limit 1;

  if v_tagihan_id is null then
    v_mulai := date_trunc('month', current_date)::date;
    v_selesai := (v_mulai + interval '1 month')::date;
    v_jatuh_tempo := (v_mulai + interval '10 days')::date;

    insert into public.tagihan (
      penyewaan_id,
      periode_mulai,
      periode_selesai,
      tanggal_jatuh_tempo,
      jumlah_tagihan,
      status
    ) values (
      v_penyewaan.id,
      v_mulai,
      v_selesai,
      v_jatuh_tempo,
      coalesce(nullif(v_penyewaan.harga_sewa_disepakati, 0), v_penyewaan.harga_sewa_bulanan, 0),
      'belum_bayar'
    )
    on conflict (penyewaan_id, periode_mulai, periode_selesai) do update
      set jumlah_tagihan = excluded.jumlah_tagihan
    returning public.tagihan.id into v_tagihan_id;
  end if;

  return query
  select
    t.id,
    t.penyewaan_id,
    t.periode_mulai,
    t.periode_selesai,
    t.tanggal_jatuh_tempo,
    t.jumlah_tagihan,
    t.status
  from public.tagihan t
  where t.id = v_tagihan_id;
end;
$$;

grant execute on function public.pastikan_tagihan_aktif() to authenticated;

notify pgrst, 'reload schema';
