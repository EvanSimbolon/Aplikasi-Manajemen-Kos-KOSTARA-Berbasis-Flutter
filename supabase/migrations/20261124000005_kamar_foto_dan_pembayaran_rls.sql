-- Tambah kolom foto_url pada tabel kamar + policy storage foto-kamar,
-- pastikan bukti-pembayaran bisa dimuat oleh Image.network, dan sediakan RPC
-- aman untuk menghapus penghuni yang sudah tidak aktif dari database.

alter table public.kamar
  add column if not exists foto_url text;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'foto-kamar',
  'foto-kamar',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
  set public = true,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "foto_kamar_insert_owner" on storage.objects;
create policy "foto_kamar_insert_owner"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'foto-kamar'
  and public.is_kos_owner((storage.foldername(name))[1]::uuid)
);

drop policy if exists "foto_kamar_update_owner" on storage.objects;
create policy "foto_kamar_update_owner"
on storage.objects for update to authenticated
using (
  bucket_id = 'foto-kamar'
  and public.is_kos_owner((storage.foldername(name))[1]::uuid)
)
with check (
  bucket_id = 'foto-kamar'
  and public.is_kos_owner((storage.foldername(name))[1]::uuid)
);

drop policy if exists "foto_kamar_delete_owner" on storage.objects;
create policy "foto_kamar_delete_owner"
on storage.objects for delete to authenticated
using (
  bucket_id = 'foto-kamar'
  and public.is_kos_owner((storage.foldername(name))[1]::uuid)
);

-- Pastikan bucket bukti-pembayaran public agar Image.network dapat memuat URL publik.
update storage.buckets
set public = true
where id = 'bukti-pembayaran';

drop policy if exists "bukti_pembayaran_public_read" on storage.objects;
create policy "bukti_pembayaran_public_read"
on storage.objects for select to public
using (bucket_id = 'bukti-pembayaran');

-- RPC untuk menghapus otomatis penyewaan & keanggotaan penghuni tidak aktif
-- (menangani FK on delete restrict pada pembayaran -> tagihan).
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

  -- Hapus keanggotaan anggota_kos jika penghuni tidak punya penyewaan aktif lain di kos ini.
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
        and p2.tanggal_selesai >= current_date
    );

  return v_deleted;
end;
$$;

create or replace function public.hapus_penyewaan_penghuni(p_penyewaan_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_kos_id uuid;
  v_penghuni_id uuid;
begin
  select km.kos_id, p.penghuni_id
  into v_kos_id, v_penghuni_id
  from public.penyewaan p
  join public.kamar km on km.id = p.kamar_id
  where p.id = p_penyewaan_id;

  if v_kos_id is null then
    return;
  end if;

  if not public.is_kos_owner(v_kos_id) then
    raise exception 'Tidak memiliki izin untuk menghapus penghuni ini.';
  end if;

  delete from public.pembayaran
  where tagihan_id in (
    select t.id from public.tagihan t where t.penyewaan_id = p_penyewaan_id
  );

  delete from public.tagihan where penyewaan_id = p_penyewaan_id;
  delete from public.penyewaan where id = p_penyewaan_id;

  delete from public.anggota_kos ak
  where ak.kos_id = v_kos_id
    and ak.peran = 'penghuni'
    and ak.pengguna_id = v_penghuni_id
    and not exists (
      select 1
      from public.penyewaan p2
      join public.kamar km2 on km2.id = p2.kamar_id
      where km2.kos_id = v_kos_id
        and p2.penghuni_id = v_penghuni_id
        and p2.status in ('aktif', 'menunggu_mulai')
        and p2.tanggal_selesai >= current_date
    );
end;
$$;

grant execute on function public.hapus_penghuni_tidak_aktif(uuid) to authenticated;
grant execute on function public.hapus_penyewaan_penghuni(uuid) to authenticated;

notify pgrst, 'reload schema';
