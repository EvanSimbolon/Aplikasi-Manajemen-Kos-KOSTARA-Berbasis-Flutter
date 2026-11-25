-- ============================================================================
-- 1. FOTO BUKTI VERIFIKASI SELESAI PADA MAINTENANCE
-- 2. TRIGGER NOTIFIKASI OTOMATIS KE ADMIN SAAT PENGHUNI MENGIRIM PEMBAYARAN
-- ============================================================================

-- 1. Tambah kolom foto_url pada tabel maintenance
alter table public.maintenance
  add column if not exists foto_url text;

-- Bucket storage foto-maintenance (public read, owner write)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'foto-maintenance',
  'foto-maintenance',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
  set public = true,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "foto_maintenance_public_read" on storage.objects;
create policy "foto_maintenance_public_read"
on storage.objects for select to public
using (bucket_id = 'foto-maintenance');

drop policy if exists "foto_maintenance_insert_owner" on storage.objects;
create policy "foto_maintenance_insert_owner"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'foto-maintenance'
  and case
    when (storage.foldername(name))[1] ~ '^[0-9a-fA-F-]{36}$'
    then public.is_kamar_owner(((storage.foldername(name))[1])::uuid)
    else false
  end
);

drop policy if exists "foto_maintenance_update_owner" on storage.objects;
create policy "foto_maintenance_update_owner"
on storage.objects for update to authenticated
using (
  bucket_id = 'foto-maintenance'
  and case
    when (storage.foldername(name))[1] ~ '^[0-9a-fA-F-]{36}$'
    then public.is_kamar_owner(((storage.foldername(name))[1])::uuid)
    else false
  end
)
with check (
  bucket_id = 'foto-maintenance'
  and case
    when (storage.foldername(name))[1] ~ '^[0-9a-fA-F-]{36}$'
    then public.is_kamar_owner(((storage.foldername(name))[1])::uuid)
    else false
  end
);

drop policy if exists "foto_maintenance_delete_owner" on storage.objects;
create policy "foto_maintenance_delete_owner"
on storage.objects for delete to authenticated
using (
  bucket_id = 'foto-maintenance'
  and case
    when (storage.foldername(name))[1] ~ '^[0-9a-fA-F-]{36}$'
    then public.is_kamar_owner(((storage.foldername(name))[1])::uuid)
    else false
  end
);

-- 2. Trigger otomatis kirim notifikasi ke pemilik kos saat penghuni kirim pembayaran
create or replace function public.notify_owner_on_pembayaran_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pemilik_id uuid;
  v_nama_penghuni text;
  v_nomor_kamar text;
  v_nominal text;
begin
  if new.status <> 'menunggu_verifikasi' then
    return new;
  end if;

  select
    k.pemilik_id,
    coalesce(nullif(trim(u.nama_lengkap), ''), 'Penghuni'),
    coalesce(km.nomor_kamar, '-')
  into v_pemilik_id, v_nama_penghuni, v_nomor_kamar
  from public.tagihan t
  join public.penyewaan p on p.id = t.penyewaan_id
  join public.kamar km on km.id = p.kamar_id
  join public.kos k on k.id = km.kos_id
  left join public.pengguna u on u.id = new.pembayar_id
  where t.id = new.tagihan_id
  limit 1;

  if v_pemilik_id is null then
    return new;
  end if;

  v_nominal := to_char(coalesce(new.jumlah_pembayaran, 0), 'FM999,999,999');
  v_nominal := replace(v_nominal, ',', '.');

  insert into public.notifikasi (
    penerima_id,
    tagihan_id,
    judul,
    pesan,
    dijadwalkan_pada,
    status
  ) values (
    v_pemilik_id,
    new.tagihan_id,
    'Pembayaran Baru Menunggu Verifikasi',
    v_nama_penghuni || ' (Kamar ' || v_nomor_kamar || ') telah mengirim bukti pembayaran Rp ' || v_nominal || '. Ketuk untuk verifikasi.',
    now(),
    'menunggu'
  );

  return new;
end;
$$;

drop trigger if exists trg_pembayaran_notify_owner on public.pembayaran;
create trigger trg_pembayaran_notify_owner
after insert on public.pembayaran
for each row execute function public.notify_owner_on_pembayaran_insert();

notify pgrst, 'reload schema';
