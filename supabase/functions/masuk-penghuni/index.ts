// KOSTARA — Edge Function `masuk-penghuni`
//
// Dipanggil dari aplikasi Flutter (layar login) oleh calon penghuni yang
// memegang token dari admin.
//
// Tugasnya:
//   1. Mencari undangan berdasarkan email ATAU nomor HP.
//   2. Mencocokkan token dengan hash_token yang tersimpan.
//   3. Menandai undangan diterima, membuat keanggotaan kos + penyewaan.
//   4. Mengembalikan email akun, sehingga aplikasi bisa login memakai
//      kombinasi email + token (token juga menjadi password akun).

import { createClient } from 'jsr:@supabase/supabase-js@2';

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, 'Content-Type': 'application/json' },
  });
}

function bacaSecretKey(): string | undefined {
  const mentah = Deno.env.get('SUPABASE_SECRET_KEYS');
  if (mentah) {
    try {
      const parsed = JSON.parse(mentah);
      if (parsed?.default) return parsed.default as string;
    } catch (_) {
      // Abaikan: pakai fallback di bawah.
    }
  }
  return Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ??
    Deno.env.get('SERVICE_ROLE_KEY');
}

async function sha256Hex(nilai: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    'SHA-256',
    new TextEncoder().encode(nilai),
  );
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

function varianTelepon(nilai: string): string[] {
  const digit = nilai.replace(/\D/g, '');
  if (!digit) return [];
  let lokal = digit;
  if (digit.startsWith('62')) {
    lokal = `0${digit.slice(2)}`;
  } else if (digit.startsWith('8')) {
    lokal = `0${digit}`;
  }
  const tanpaNol = lokal.replace(/^0/, '');
  return Array.from(
    new Set([
      lokal,
      tanpaNol,
      `62${tanpaNol}`,
      `+62${tanpaNol}`,
      digit,
      `+${digit}`,
    ]),
  );
}

function tambahSatuBulan(tanggal: string): string {
  const tgl = new Date(`${tanggal}T00:00:00Z`);
  tgl.setUTCMonth(tgl.getUTCMonth() + 1);
  return tgl.toISOString().slice(0, 10);
}

/**
 * Harus sama dengan `kataSandi()` di fungsi `tambah-penghuni` dan di
 * `undangan_service.dart`. Password ini yang dipakai aplikasi untuk
 * `signInWithPassword` setelah token terverifikasi.
 */
function kataSandi(token: string): string {
  return `Kt-${token}-1a`;
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS });
  }
  if (req.method !== 'POST') {
    return json({ error: 'Gunakan method POST' }, 405);
  }

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch (_) {
    return json({ error: 'Body harus berupa JSON yang valid' }, 400);
  }

  const identifier = String(body.identifier ?? body.email ?? body.telepon ?? '')
    .trim();
  const token = String(body.token ?? '').trim().toUpperCase();

  if (!identifier) {
    return json({ error: 'Email atau nomor HP wajib diisi' }, 400);
  }
  if (!token) return json({ error: 'Token wajib diisi' }, 400);

  const url = Deno.env.get('SUPABASE_URL');
  const secretKey = bacaSecretKey();
  if (!url || !secretKey) {
    return json({
      error:
        'Konfigurasi server belum lengkap: SUPABASE_URL / secret key tidak ditemukan. ' +
        'Redeploy fungsi ini agar env var baru (SUPABASE_SECRET_KEYS) terbaca.',
    }, 500);
  }

  const admin = createClient(url, secretKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  try {
    // ---- 1. Cari undangan ---------------------------------------------
    let kueri = admin
      .from('undangan_penghuni')
      .select(
        'id, kos_id, pengundang_id, nama_tujuan, email_tujuan, telepon_tujuan, kamar_id, tanggal_mulai, hash_token, status, berlaku_sampai',
      )
      .in('status', ['menunggu', 'diterima']);

    if (identifier.includes('@')) {
      kueri = kueri.ilike('email_tujuan', identifier.toLowerCase());
    } else {
      kueri = kueri.in('telepon_tujuan', varianTelepon(identifier));
    }

    let { data: undangan, error: errUndangan } = await kueri
      .order('dibuat_pada', { ascending: false })
      .limit(1)
      .maybeSingle();
    if (errUndangan) {
      throw new Error(`Gagal membaca undangan: ${errUndangan.message}`);
    }

    // Fallback: jika login pakai No. HP dan belum ketemu di `undangan_penghuni.telepon_tujuan`,
    // cek di `pengguna.nomor_telepon` lalu cocokkan undangan berdasarkan email-nya.
    if (!undangan && !identifier.includes('@')) {
      const varian = varianTelepon(identifier);
      if (varian.length > 0) {
        const { data: penggunaHp } = await admin
          .from('pengguna')
          .select('email')
          .in('nomor_telepon', varian)
          .limit(1)
          .maybeSingle();

        if (penggunaHp?.email) {
          const { data: undanganViaHp, error: errViaHp } = await admin
            .from('undangan_penghuni')
            .select(
              'id, kos_id, pengundang_id, nama_tujuan, email_tujuan, telepon_tujuan, kamar_id, tanggal_mulai, hash_token, status, berlaku_sampai',
            )
            .in('status', ['menunggu', 'diterima'])
            .ilike('email_tujuan', String(penggunaHp.email).toLowerCase())
            .order('dibuat_pada', { ascending: false })
            .limit(1)
            .maybeSingle();
          if (errViaHp) {
            throw new Error(`Gagal membaca undangan: ${errViaHp.message}`);
          }
          undangan = undanganViaHp;
        }
      }
    }

    if (!undangan) {
      return json({
        error:
          'Undangan tidak ditemukan. Pastikan email/nomor HP sesuai dengan yang didaftarkan admin.',
      }, 404);
    }

    // ---- 2. Verifikasi token ------------------------------------------
    // Undangan yang sudah diterima tetap boleh dipakai login ulang supaya
    // penghuni tidak terkunci di luar aplikasi.
    const masihMenunggu = undangan.status === 'menunggu';

    if (masihMenunggu && new Date(undangan.berlaku_sampai) < new Date()) {
      await admin
        .from('undangan_penghuni')
        .update({ status: 'kedaluwarsa' })
        .eq('id', undangan.id);
      return json({
        error: 'Token sudah kedaluwarsa. Minta token baru ke admin.',
      }, 410);
    }

    const hashInput = await sha256Hex(token);
    if (hashInput !== undangan.hash_token) {
      return json({ error: 'Token tidak cocok' }, 401);
    }

    // ---- 3. Aktifkan keanggotaan --------------------------------------
    const { data: pengguna } = await admin
      .from('pengguna')
      .select('id, nama_lengkap')
      .ilike('email', undangan.email_tujuan)
      .limit(1)
      .maybeSingle();
    if (!pengguna?.id) {
      return json({
        error: 'Akun penghuni tidak ditemukan. Minta admin membuat undangan baru.',
      }, 404);
    }

    await admin.from('anggota_kos').upsert({
      kos_id: undangan.kos_id,
      pengguna_id: pengguna.id,
      peran: 'penghuni',
      status: 'aktif',
    }, { onConflict: 'kos_id,pengguna_id' });

    // Pastikan password akun selalu mengikuti token terbaru, supaya aplikasi
    // bisa langsung signInWithPassword setelah ini.
    const { error: errSandi } = await admin.auth.admin.updateUserById(
      pengguna.id,
      { password: kataSandi(token) },
    );
    if (errSandi) {
      throw new Error(`Gagal menyiapkan sesi login: ${errSandi.message}`);
    }

    let kamar: Record<string, unknown> | null = null;
    if (undangan.kamar_id) {
      const { data: dataKamar } = await admin
        .from('kamar')
        .select('id, nomor_kamar, tipe_kamar, harga_sewa_bulanan')
        .eq('id', undangan.kamar_id)
        .maybeSingle();
      kamar = dataKamar ?? null;

      const mulai = (undangan.tanggal_mulai as string | null) ??
        new Date().toISOString().slice(0, 10);
      const selesai = tambahSatuBulan(mulai);

      const { data: sewaLama } = await admin
        .from('penyewaan')
        .select('id')
        .eq('kamar_id', undangan.kamar_id)
        .eq('penghuni_id', pengguna.id)
        .in('status', ['menunggu_mulai', 'aktif'])
        .limit(1)
        .maybeSingle();

      let penyewaanId: string | null = sewaLama?.id ?? null;

      if (!sewaLama) {
        const { data: sewaBaru, error: errSewa } = await admin
          .from('penyewaan')
          .insert({
            kamar_id: undangan.kamar_id,
            penghuni_id: pengguna.id,
            tanggal_mulai: mulai,
            tanggal_selesai: selesai,
            harga_sewa_disepakati: kamar?.harga_sewa_bulanan ?? 0,
            status: 'aktif',
          })
          .select('id')
          .single();
        if (errSewa) {
          throw new Error(`Gagal membuat penyewaan: ${errSewa.message}`);
        }
        penyewaanId = sewaBaru?.id ?? null;
      }

      if (penyewaanId) {
        const { data: tagihanAktif } = await admin
          .from('tagihan')
          .select('id')
          .eq('penyewaan_id', penyewaanId)
          .in('status', ['belum_bayar', 'terlambat', 'dibayar_sebagian'])
          .limit(1)
          .maybeSingle();

        if (!tagihanAktif) {
          const jatuhTempo = new Date(`${mulai}T00:00:00Z`);
          jatuhTempo.setUTCDate(jatuhTempo.getUTCDate() + 7);
          await admin.from('tagihan').upsert(
            {
              penyewaan_id: penyewaanId,
              periode_mulai: mulai,
              periode_selesai: selesai,
              tanggal_jatuh_tempo: jatuhTempo.toISOString().slice(0, 10),
              jumlah_tagihan: kamar?.harga_sewa_bulanan ?? 0,
              status: 'belum_bayar',
            },
            { onConflict: 'penyewaan_id,periode_mulai,periode_selesai' },
          );
        }
      }
    }

    if (masihMenunggu) {
      const { error: errTerima } = await admin
        .from('undangan_penghuni')
        .update({ status: 'diterima', diterima_pada: new Date().toISOString() })
        .eq('id', undangan.id);
      if (errTerima) {
        throw new Error(`Gagal memperbarui undangan: ${errTerima.message}`);
      }
    }

    return json({
      ok: true,
      email: undangan.email_tujuan,
      nama: undangan.nama_tujuan ?? pengguna.nama_lengkap ?? '',
      kos_id: undangan.kos_id,
      kamar,
    });
  } catch (e) {
    const pesan = e instanceof Error ? e.message : String(e);
    return json({ error: pesan }, 500);
  }
});
