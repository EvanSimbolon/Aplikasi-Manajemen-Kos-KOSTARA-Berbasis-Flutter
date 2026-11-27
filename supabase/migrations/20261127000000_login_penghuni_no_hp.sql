-- ============================================================================
-- LOGIN PENGHUNI DENGAN NO. HP ATAU EMAIL + TOKEN
-- ============================================================================
-- Menyediakan helper normalisasi nomor HP dan RPC `cari_email_penghuni_by_hp`
-- agar penghuni dapat masuk memakai nomor HP (format 08..., 628..., +628...,
-- 8..., atau dengan spasi/strip) yang didaftarkan oleh pemilik kos.
-- ============================================================================

create or replace function public.normalisasi_no_hp(p_telepon text)
returns text
language plpgsql
immutable
as $$
declare
  v_digits text;
begin
  v_digits := regexp_replace(coalesce(p_telepon, ''), '[^0-9]', '', 'g');
  if v_digits = '' then
    return '';
  end if;
  if left(v_digits, 2) = '62' then
    v_digits := '0' || substring(v_digits from 3);
  elsif left(v_digits, 1) = '8' then
    v_digits := '0' || v_digits;
  end if;
  return v_digits;
end;
$$;

create or replace function public.cari_email_penghuni_by_hp(p_telepon text)
returns text
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_norm text;
  v_email text;
begin
  v_norm := public.normalisasi_no_hp(p_telepon);
  if length(v_norm) < 9 then
    return null;
  end if;

  -- 1. Cari di undangan_penghuni (menunggu / diterima) terbaru
  select u.email_tujuan
  into v_email
  from public.undangan_penghuni u
  where u.status in ('menunggu', 'diterima')
    and public.normalisasi_no_hp(u.telepon_tujuan) = v_norm
    and coalesce(trim(u.email_tujuan), '') <> ''
  order by u.dibuat_pada desc
  limit 1;

  if v_email is not null then
    return lower(trim(v_email));
  end if;

  -- 2. Fallback: cari di tabel pengguna (yang terdaftar sebagai penghuni/punya penyewaan)
  select pg.email
  into v_email
  from public.pengguna pg
  where public.normalisasi_no_hp(pg.nomor_telepon) = v_norm
    and coalesce(trim(pg.email), '') <> ''
    and (
      exists (
        select 1 from public.anggota_kos ak
        where ak.pengguna_id = pg.id and ak.peran = 'penghuni'
      )
      or exists (
        select 1 from public.penyewaan pw
        where pw.penghuni_id = pg.id
      )
      or exists (
        select 1 from public.undangan_penghuni u2
        where lower(u2.email_tujuan) = lower(pg.email)
      )
    )
  order by pg.diperbarui_pada desc
  limit 1;

  if v_email is not null then
    return lower(trim(v_email));
  end if;

  return null;
end;
$$;

grant execute on function public.cari_email_penghuni_by_hp(text) to anon, authenticated;

notify pgrst, 'reload schema';
