-- ============================================================================
-- AKTIVASI PENUH RLS, POLICIES, HELPER SECURITY DEFINER, STORAGE & REALTIME
-- KOSTARA (Supabase / PostgreSQL)
--
-- File ini idempoten (aman dijalankan ulang di Supabase SQL Editor).
-- Memastikan seluruh 17 tabel public mengaktifkan RLS dan seluruh fitur
-- aplikasi (Owner & Penghuni) berjalan tanpa terblokir policy.
-- ============================================================================

-- 1. PASTIKAN KOLOM & TABEL TAMBAHAN TERSEDIA
alter table public.profil_pengguna
  add column if not exists alamat text;

alter table public.kamar
  add column if not exists foto_url text;

alter table public.laporan_kerusakan
  alter column fasilitas_kamar_id drop not null;

alter table public.laporan_kerusakan
  add column if not exists fasilitas_nama text;

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

-- 2. HELPER RLS (SECURITY DEFINER, TANPA REKURSI)
create or replace function public.is_kos_owner(p_kos_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.kos k
    where k.id = p_kos_id
      and k.pemilik_id = auth.uid()
  ) or exists (
    select 1
    from public.anggota_kos a
    where a.kos_id = p_kos_id
      and a.pengguna_id = auth.uid()
      and a.peran = 'pemilik'
      and a.status = 'aktif'
  );
$$;

-- Anggota kos = terdaftar di anggota_kos aktif ATAU punya penyewaan aktif/menunggu di kos tersebut
create or replace function public.is_kos_member(p_kos_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.anggota_kos a
    where a.kos_id = p_kos_id
      and a.pengguna_id = auth.uid()
      and a.status = 'aktif'
  ) or exists (
    select 1
    from public.penyewaan p
    join public.kamar km on km.id = p.kamar_id
    where km.kos_id = p_kos_id
      and p.penghuni_id = auth.uid()
      and p.status in ('aktif', 'menunggu_mulai')
  );
$$;

-- Pemilik dapat melihat data pengguna yang menjadi anggota ATAU penyewa pada kos miliknya
create or replace function public.owner_can_view_user(p_pengguna_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.anggota_kos target
    where target.pengguna_id = p_pengguna_id
      and public.is_kos_owner(target.kos_id)
  ) or exists (
    select 1
    from public.penyewaan p
    join public.kamar km on km.id = p.kamar_id
    where p.penghuni_id = p_pengguna_id
      and public.is_kos_owner(km.kos_id)
  );
$$;

create or replace function public.is_kamar_member(p_kamar_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.kamar km
    where km.id = p_kamar_id
      and public.is_kos_member(km.kos_id)
  );
$$;

create or replace function public.is_kamar_owner(p_kamar_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.kamar km
    where km.id = p_kamar_id
      and public.is_kos_owner(km.kos_id)
  );
$$;

create or replace function public.is_fasilitas_kamar_member(p_fasilitas_kamar_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.fasilitas_kamar fk
    where fk.id = p_fasilitas_kamar_id
      and public.is_kamar_member(fk.kamar_id)
  );
$$;

create or replace function public.is_fasilitas_kamar_owner(p_fasilitas_kamar_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.fasilitas_kamar fk
    where fk.id = p_fasilitas_kamar_id
      and public.is_kamar_owner(fk.kamar_id)
  );
$$;

create or replace function public.is_penyewaan_tenant(p_penyewaan_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.penyewaan p
    where p.id = p_penyewaan_id
      and p.penghuni_id = auth.uid()
  );
$$;

create or replace function public.is_penyewaan_owner(p_penyewaan_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.penyewaan p
    join public.kamar km on km.id = p.kamar_id
    where p.id = p_penyewaan_id
      and public.is_kos_owner(km.kos_id)
  );
$$;

create or replace function public.is_tagihan_tenant(p_tagihan_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.tagihan t
    join public.penyewaan p on p.id = t.penyewaan_id
    where t.id = p_tagihan_id
      and p.penghuni_id = auth.uid()
  );
$$;

create or replace function public.is_tagihan_owner(p_tagihan_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.tagihan t
    join public.penyewaan p on p.id = t.penyewaan_id
    join public.kamar km on km.id = p.kamar_id
    where t.id = p_tagihan_id
      and public.is_kos_owner(km.kos_id)
  );
$$;

-- 3. AKTIFKAN RLS PADA SELURUH 17 TABEL PUBLIC
alter table public.pengguna enable row level security;
alter table public.profil_pengguna enable row level security;
alter table public.kos enable row level security;
alter table public.anggota_kos enable row level security;
alter table public.undangan_penghuni enable row level security;
alter table public.kamar enable row level security;
alter table public.jenis_fasilitas enable row level security;
alter table public.fasilitas_kamar enable row level security;
alter table public.penyewaan enable row level security;
alter table public.tagihan enable row level security;
alter table public.pembayaran enable row level security;
alter table public.bukti_pembayaran enable row level security;
alter table public.laporan_kerusakan enable row level security;
alter table public.jadwal_pemeliharaan enable row level security;
alter table public.maintenance enable row level security;
alter table public.acara_kalender enable row level security;
alter table public.notifikasi enable row level security;

-- 4. POLICIES PER TABEL

-- pengguna
drop policy if exists "pengguna_select_own_or_owner" on public.pengguna;
create policy "pengguna_select_own_or_owner"
on public.pengguna for select to authenticated
using (id = auth.uid() or public.owner_can_view_user(id));

drop policy if exists "pengguna_update_own" on public.pengguna;
create policy "pengguna_update_own"
on public.pengguna for update to authenticated
using (id = auth.uid())
with check (id = auth.uid());

-- profil_pengguna
drop policy if exists "profil_select_own_or_owner" on public.profil_pengguna;
create policy "profil_select_own_or_owner"
on public.profil_pengguna for select to authenticated
using (pengguna_id = auth.uid() or public.owner_can_view_user(pengguna_id));

drop policy if exists "profil_insert_own" on public.profil_pengguna;
create policy "profil_insert_own"
on public.profil_pengguna for insert to authenticated
with check (pengguna_id = auth.uid());

drop policy if exists "profil_update_own" on public.profil_pengguna;
create policy "profil_update_own"
on public.profil_pengguna for update to authenticated
using (pengguna_id = auth.uid())
with check (pengguna_id = auth.uid());

-- kos
drop policy if exists "kos_select_member" on public.kos;
create policy "kos_select_member"
on public.kos for select to authenticated
using (pemilik_id = auth.uid() or public.is_kos_member(id) or public.is_kos_owner(id));

drop policy if exists "kos_insert_owner" on public.kos;
create policy "kos_insert_owner"
on public.kos for insert to authenticated
with check (pemilik_id = auth.uid());

drop policy if exists "kos_update_owner" on public.kos;
create policy "kos_update_owner"
on public.kos for update to authenticated
using (pemilik_id = auth.uid())
with check (pemilik_id = auth.uid());

drop policy if exists "kos_delete_owner" on public.kos;
create policy "kos_delete_owner"
on public.kos for delete to authenticated
using (pemilik_id = auth.uid());

-- anggota_kos
drop policy if exists "anggota_select_own_or_owner" on public.anggota_kos;
create policy "anggota_select_own_or_owner"
on public.anggota_kos for select to authenticated
using (pengguna_id = auth.uid() or public.is_kos_owner(kos_id));

drop policy if exists "anggota_insert_owner" on public.anggota_kos;
create policy "anggota_insert_owner"
on public.anggota_kos for insert to authenticated
with check (public.is_kos_owner(kos_id));

drop policy if exists "anggota_update_owner" on public.anggota_kos;
create policy "anggota_update_owner"
on public.anggota_kos for update to authenticated
using (public.is_kos_owner(kos_id))
with check (public.is_kos_owner(kos_id));

drop policy if exists "anggota_delete_owner" on public.anggota_kos;
create policy "anggota_delete_owner"
on public.anggota_kos for delete to authenticated
using (public.is_kos_owner(kos_id));

-- undangan_penghuni
drop policy if exists "undangan_select_owner" on public.undangan_penghuni;
create policy "undangan_select_owner"
on public.undangan_penghuni for select to authenticated
using (
  public.is_kos_owner(kos_id)
  or lower(email_tujuan) = lower(coalesce(auth.jwt() ->> 'email', ''))
);

drop policy if exists "undangan_insert_owner" on public.undangan_penghuni;
create policy "undangan_insert_owner"
on public.undangan_penghuni for insert to authenticated
with check (public.is_kos_owner(kos_id) and pengundang_id = auth.uid());

drop policy if exists "undangan_update_owner" on public.undangan_penghuni;
create policy "undangan_update_owner"
on public.undangan_penghuni for update to authenticated
using (public.is_kos_owner(kos_id))
with check (public.is_kos_owner(kos_id));

drop policy if exists "undangan_delete_owner" on public.undangan_penghuni;
create policy "undangan_delete_owner"
on public.undangan_penghuni for delete to authenticated
using (public.is_kos_owner(kos_id));

-- kamar
drop policy if exists "kamar_select_member" on public.kamar;
create policy "kamar_select_member"
on public.kamar for select to authenticated
using (public.is_kos_member(kos_id) or public.is_kos_owner(kos_id));

drop policy if exists "kamar_insert_owner" on public.kamar;
create policy "kamar_insert_owner"
on public.kamar for insert to authenticated
with check (public.is_kos_owner(kos_id));

drop policy if exists "kamar_update_owner" on public.kamar;
create policy "kamar_update_owner"
on public.kamar for update to authenticated
using (public.is_kos_owner(kos_id))
with check (public.is_kos_owner(kos_id));

drop policy if exists "kamar_delete_owner" on public.kamar;
create policy "kamar_delete_owner"
on public.kamar for delete to authenticated
using (public.is_kos_owner(kos_id));

-- jenis_fasilitas
drop policy if exists "jenis_fasilitas_select_authenticated" on public.jenis_fasilitas;
create policy "jenis_fasilitas_select_authenticated"
on public.jenis_fasilitas for select to authenticated
using (true);

-- fasilitas_kamar
drop policy if exists "fasilitas_kamar_select_member" on public.fasilitas_kamar;
create policy "fasilitas_kamar_select_member"
on public.fasilitas_kamar for select to authenticated
using (public.is_kamar_member(kamar_id) or public.is_kamar_owner(kamar_id));

drop policy if exists "fasilitas_kamar_write_owner" on public.fasilitas_kamar;
create policy "fasilitas_kamar_write_owner"
on public.fasilitas_kamar for all to authenticated
using (public.is_kamar_owner(kamar_id))
with check (public.is_kamar_owner(kamar_id));

-- penyewaan
drop policy if exists "penyewaan_select_tenant_or_owner" on public.penyewaan;
create policy "penyewaan_select_tenant_or_owner"
on public.penyewaan for select to authenticated
using (penghuni_id = auth.uid() or public.is_penyewaan_owner(id));

drop policy if exists "penyewaan_insert_owner" on public.penyewaan;
create policy "penyewaan_insert_owner"
on public.penyewaan for insert to authenticated
with check (public.is_kamar_owner(kamar_id));

drop policy if exists "penyewaan_update_owner" on public.penyewaan;
create policy "penyewaan_update_owner"
on public.penyewaan for update to authenticated
using (public.is_penyewaan_owner(id))
with check (public.is_penyewaan_owner(id));

drop policy if exists "penyewaan_delete_owner" on public.penyewaan;
create policy "penyewaan_delete_owner"
on public.penyewaan for delete to authenticated
using (public.is_penyewaan_owner(id));

-- tagihan
drop policy if exists "tagihan_select_tenant_or_owner" on public.tagihan;
create policy "tagihan_select_tenant_or_owner"
on public.tagihan for select to authenticated
using (public.is_tagihan_tenant(id) or public.is_tagihan_owner(id));

drop policy if exists "tagihan_write_owner" on public.tagihan;
create policy "tagihan_write_owner"
on public.tagihan for all to authenticated
using (public.is_penyewaan_owner(penyewaan_id))
with check (public.is_penyewaan_owner(penyewaan_id));

-- pembayaran
drop policy if exists "pembayaran_select_payer_or_owner" on public.pembayaran;
create policy "pembayaran_select_payer_or_owner"
on public.pembayaran for select to authenticated
using (pembayar_id = auth.uid() or public.is_tagihan_owner(tagihan_id));

drop policy if exists "pembayaran_insert_tenant" on public.pembayaran;
create policy "pembayaran_insert_tenant"
on public.pembayaran for insert to authenticated
with check (pembayar_id = auth.uid() and public.is_tagihan_tenant(tagihan_id));

drop policy if exists "pembayaran_update_owner" on public.pembayaran;
create policy "pembayaran_update_owner"
on public.pembayaran for update to authenticated
using (public.is_tagihan_owner(tagihan_id))
with check (public.is_tagihan_owner(tagihan_id));

-- bukti_pembayaran
drop policy if exists "bukti_select_payer_or_owner" on public.bukti_pembayaran;
create policy "bukti_select_payer_or_owner"
on public.bukti_pembayaran for select to authenticated
using (
  exists (
    select 1
    from public.pembayaran pb
    where pb.id = pembayaran_id
      and (pb.pembayar_id = auth.uid() or public.is_tagihan_owner(pb.tagihan_id))
  )
);

drop policy if exists "bukti_insert_payer" on public.bukti_pembayaran;
create policy "bukti_insert_payer"
on public.bukti_pembayaran for insert to authenticated
with check (
  exists (
    select 1
    from public.pembayaran pb
    where pb.id = pembayaran_id
      and pb.pembayar_id = auth.uid()
  )
);

-- laporan_kerusakan
drop policy if exists "laporan_select_reporter_or_owner" on public.laporan_kerusakan;
create policy "laporan_select_reporter_or_owner"
on public.laporan_kerusakan for select to authenticated
using (
  pelapor_id = auth.uid()
  or public.owner_can_view_user(pelapor_id)
  or (fasilitas_kamar_id is not null and public.is_fasilitas_kamar_owner(fasilitas_kamar_id))
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
  or (fasilitas_kamar_id is not null and public.is_fasilitas_kamar_owner(fasilitas_kamar_id))
)
with check (
  public.owner_can_view_user(pelapor_id)
  or (fasilitas_kamar_id is not null and public.is_fasilitas_kamar_owner(fasilitas_kamar_id))
);

-- jadwal_pemeliharaan
drop policy if exists "jadwal_select_member" on public.jadwal_pemeliharaan;
drop policy if exists "jadwal_select_kos_member" on public.jadwal_pemeliharaan;
create policy "jadwal_select_kos_member"
on public.jadwal_pemeliharaan for select to authenticated
using (
  exists (
    select 1
    from public.fasilitas_kamar fk
    join public.kamar km on km.id = fk.kamar_id
    where fk.id = fasilitas_kamar_id
      and (public.is_kos_member(km.kos_id) or public.is_kos_owner(km.kos_id))
  )
);

drop policy if exists "jadwal_write_owner" on public.jadwal_pemeliharaan;
create policy "jadwal_write_owner"
on public.jadwal_pemeliharaan for all to authenticated
using (public.is_fasilitas_kamar_owner(fasilitas_kamar_id))
with check (
  public.is_fasilitas_kamar_owner(fasilitas_kamar_id)
  and pembuat_jadwal_id = auth.uid()
);

-- maintenance
drop policy if exists "maintenance_select_member" on public.maintenance;
create policy "maintenance_select_member"
on public.maintenance for select to authenticated
using (public.is_kamar_member(kamar_id) or public.is_kamar_owner(kamar_id));

drop policy if exists "maintenance_write_owner" on public.maintenance;
create policy "maintenance_write_owner"
on public.maintenance for all to authenticated
using (public.is_kamar_owner(kamar_id))
with check (public.is_kamar_owner(kamar_id));

-- acara_kalender
drop policy if exists "acara_select_member" on public.acara_kalender;
create policy "acara_select_member"
on public.acara_kalender for select to authenticated
using (public.is_kos_member(kos_id) or public.is_kos_owner(kos_id));

drop policy if exists "acara_write_owner" on public.acara_kalender;
create policy "acara_write_owner"
on public.acara_kalender for all to authenticated
using (public.is_kos_owner(kos_id))
with check (public.is_kos_owner(kos_id) and pembuat_id = auth.uid());

-- notifikasi
drop policy if exists "notifikasi_select_own" on public.notifikasi;
create policy "notifikasi_select_own"
on public.notifikasi for select to authenticated
using (penerima_id = auth.uid());

drop policy if exists "notifikasi_update_own" on public.notifikasi;
create policy "notifikasi_update_own"
on public.notifikasi for update to authenticated
using (penerima_id = auth.uid())
with check (penerima_id = auth.uid());

-- 5. STORAGE BUCKETS & POLICIES (AMAN TERHADAP CAST UUID)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('foto-profil', 'foto-profil', true, 5242880, array['image/jpeg', 'image/png', 'image/webp', 'image/gif']),
  ('foto-kamar', 'foto-kamar', true, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('bukti-pembayaran', 'bukti-pembayaran', true, 5242880, array['image/jpeg', 'image/png', 'image/webp', 'application/pdf'])
on conflict (id) do update
  set public = true,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- Public read untuk bucket foto & bukti
drop policy if exists "foto_kamar_public_read" on storage.objects;
drop policy if exists "foto_profil_read_public" on storage.objects;
drop policy if exists "bukti_pembayaran_public_read" on storage.objects;
create policy "kostara_storage_public_read"
on storage.objects for select to public
using (bucket_id in ('foto-profil', 'foto-kamar', 'bukti-pembayaran'));

-- foto-profil (folder pertama = auth.uid())
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

-- foto-kamar (folder pertama = kos_id, cast UUID aman dengan guard regex)
drop policy if exists "foto_kamar_insert_owner" on storage.objects;
create policy "foto_kamar_insert_owner"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'foto-kamar'
  and case
    when (storage.foldername(name))[1] ~ '^[0-9a-fA-F-]{36}$'
    then public.is_kos_owner(((storage.foldername(name))[1])::uuid)
    else false
  end
);

drop policy if exists "foto_kamar_update_owner" on storage.objects;
create policy "foto_kamar_update_owner"
on storage.objects for update to authenticated
using (
  bucket_id = 'foto-kamar'
  and case
    when (storage.foldername(name))[1] ~ '^[0-9a-fA-F-]{36}$'
    then public.is_kos_owner(((storage.foldername(name))[1])::uuid)
    else false
  end
)
with check (
  bucket_id = 'foto-kamar'
  and case
    when (storage.foldername(name))[1] ~ '^[0-9a-fA-F-]{36}$'
    then public.is_kos_owner(((storage.foldername(name))[1])::uuid)
    else false
  end
);

drop policy if exists "foto_kamar_delete_owner" on storage.objects;
create policy "foto_kamar_delete_owner"
on storage.objects for delete to authenticated
using (
  bucket_id = 'foto-kamar'
  and case
    when (storage.foldername(name))[1] ~ '^[0-9a-fA-F-]{36}$'
    then public.is_kos_owner(((storage.foldername(name))[1])::uuid)
    else false
  end
);

-- bukti-pembayaran (folder pertama = pembayaran_id milik penghuni)
drop policy if exists "bukti_pembayaran_insert_own" on storage.objects;
create policy "bukti_pembayaran_insert_own"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'bukti-pembayaran'
  and exists (
    select 1
    from public.pembayaran pb
    where pb.id::text = (storage.foldername(name))[1]
      and pb.pembayar_id = auth.uid()
  )
);

drop policy if exists "bukti_pembayaran_delete_own" on storage.objects;
create policy "bukti_pembayaran_delete_own"
on storage.objects for delete to authenticated
using (bucket_id = 'bukti-pembayaran' and owner_id = auth.uid()::text);

-- 6. REALTIME PUBLICATION UNTUK STREAM APLIKASI
do $$
declare
  tabel text;
begin
  foreach tabel in array array[
    'notifikasi',
    'pembayaran',
    'penyewaan',
    'tagihan',
    'kamar',
    'maintenance',
    'laporan_kerusakan'
  ] loop
    begin
      execute format(
        'alter publication supabase_realtime add table public.%I',
        tabel
      );
    exception
      when duplicate_object then null;
      when undefined_object then null;
    end;
  end loop;
end $$;

notify pgrst, 'reload schema';
