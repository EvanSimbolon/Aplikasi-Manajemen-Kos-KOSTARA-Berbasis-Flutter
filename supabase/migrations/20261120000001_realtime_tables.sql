-- Aktifkan Realtime untuk tabel yang dipakai stream di aplikasi.
do $$
declare
  tabel text;
begin
  foreach tabel in array array[
    'notifikasi',
    'pembayaran',
    'penyewaan',
    'tagihan'
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
