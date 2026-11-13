// KOSTARA — Edge Function `tambah-penghuni`
//
// Dipanggil dari aplikasi Flutter (layar "Tambah Penghuni") oleh admin.
// Tugasnya:
//   1. Membuat akun Supabase Auth untuk calon penghuni (password = token).
//   2. Menyimpan profil di tabel `pengguna`.
//   3. Menulis undangan ke `undangan_penghuni` (hanya hash token yang disimpan).
//   4. Mengembalikan token ke admin untuk diberikan ke penghuni.
//
// Penting: fungsi ini memakai SECRET key (service role) sehingga RLS dilewati.
// Secret key tidak pernah dikirim ke aplikasi Flutter.

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

/**
 * Supabase versi baru menyuntikkan `SUPABASE_SECRET_KEYS` (JSON berisi key
 * `default`), sedangkan proyek lama memakai `SUPABASE_SERVICE_ROLE_KEY`.
 * Keduanya didukung agar fungsi tidak gagal dengan "Unregistered API key".
 */
function bacaSecretKey(): string | undefined {
  const mentah = Deno.env.get('SUPABASE_SECRET_KEYS');
  if (mentah) {
    try {
      const parsed = JSON.parse(mentah);
      if (parsed?.default) return parsed.default as string;
    } catch (_) {
      // Abaikan: format tidak dikenal, pakai fallback di bawah.
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

/** Token 10 karakter, tanpa huruf/angka yang mudah tertukar (0/O, 1/I/L). */
function buatToken(): string {
  const alfabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  const bytes = crypto.getRandomValues(new Uint8Array(10));
  return Array.from(bytes).map((b) => alfabet[b % alfabet.length]).join('');
}

/**
 * Password akun Supabase Auth diturunkan dari token, bukan token apa adanya.
 * Tujuannya agar tetap memenuhi kebijakan password kuat (huruf besar + kecil +
 * angka + simbol). Aplikasi Flutter menurunkan nilai yang sama saat login,
 * jadi jangan ubah format ini di satu sisi saja.
 */
function kataSandi(token: string): string {
  return `Kt-${token}-1a`;
}

function normalisasiTelepon(nilai?: string | null): string | null {
  if (!nilai) return null;
  const digit = nilai.replace(/\D/g, '');
  if (!digit) return null;
  if (digit.startsWith('62')) return `0${digit.slice(2)}`;
  return digit;
}

function hariKedaluwarsa(hari: number): string {
  const tgl = new Date();
  tgl.setDate(tgl.getDate() + hari);
  return tgl.toISOString();
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

  const nama = String(body.nama ?? '').trim();
  const telepon = normalisasiTelepon(body.telepon as string | undefined);
  const email = String(body.email ?? '').trim().toLowerCase();
  const kamarId = String(body.kamar_id ?? '').trim();
  const kosId = String(body.kos_id ?? '').trim();
  const tanggalMulai = String(body.tanggal_mulai ?? '').trim();

  if (!nama) return json({ error: 'Nama wajib diisi' }, 400);
  if (!email || !email.includes('@')) {
    return json({ error: 'Email wajib diisi dengan format yang benar' }, 400);
  }
  if (!kamarId) {
    return json({ error: 'Kamar wajib dipilih dari daftar kamar kosong' }, 400);
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(tanggalMulai)) {
    return json({ error: 'Tanggal mulai sewa tidak valid' }, 400);
  }

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
    // ---- 1. Tentukan kos & kamar --------------------------------------
    let idKos = kosId;
    if (!idKos) {
      const { data: kosPertama, error: errKos } = await admin
        .from('kos')
        .select('id')
        .order('dibuat_pada', { ascending: true })
        .limit(1)
        .maybeSingle();
      if (errKos) throw new Error(`Gagal membaca data kos: ${errKos.message}`);
      if (!kosPertama) throw new Error('Belum ada data kos di database');
      idKos = kosPertama.id as string;
    }

    const { data: kamar, error: errKamar } = await admin
      .from('kamar')
      .select('id, kos_id, nomor_kamar, tipe_kamar, harga_sewa_bulanan')
      .eq('id', kamarId)
      .maybeSingle();
    if (errKamar) throw new Error(`Gagal membaca kamar: ${errKamar.message}`);
    if (!kamar) throw new Error('Kamar tidak ditemukan');
    if (kamar.kos_id !== idKos) {
      return json({ error: 'Kamar bukan milik kos yang dipilih' }, 400);
    }

    const { data: sewaAktif, error: errSewa } = await admin
      .from('penyewaan')
      .select('id')
      .eq('kamar_id', kamarId)
      .in('status', ['menunggu_mulai', 'aktif'])
      .gte('tanggal_selesai', new Date().toISOString().slice(0, 10))
      .limit(1);
    if (errSewa) throw new Error(`Gagal cek kamar: ${errSewa.message}`);
    if (sewaAktif && sewaAktif.length > 0) {
      return json({ error: `Kamar ${kamar.nomor_kamar} sudah terisi` }, 409);
    }

    // ---- 2. Siapkan akun login penghuni -------------------------------
    const token = buatToken();
    const hashToken = await sha256Hex(token);
    const berlakuSampai = hariKedaluwarsa(7);

    let penggunaId: string | null = null;

    const { data: penggunaLama } = await admin
      .from('pengguna')
      .select('id')
      .ilike('email', email)
      .limit(1)
      .maybeSingle();
    if (penggunaLama?.id) penggunaId = penggunaLama.id as string;

    if (!penggunaId) {
      const { data: dibuat, error: errBuat } = await admin.auth.admin
        .createUser({
          email,
          password: kataSandi(token),
          email_confirm: true,
          user_metadata: { nama_lengkap: nama, nomor_telepon: telepon },
        });
      if (errBuat || !dibuat?.user) {
        throw new Error(`Gagal membuat akun penghuni: ${errBuat?.message}`);
      }
      penggunaId = dibuat.user.id;
    } else {
      // Penghuni lama ditambahkan lagi: token baru sekaligus jadi password baru.
      const { error: errUpdate } = await admin.auth.admin.updateUserById(
        penggunaId,
        {
          password: kataSandi(token),
          email_confirm: true,
          user_metadata: { nama_lengkap: nama, nomor_telepon: telepon },
        },
      );
      if (errUpdate) {
        throw new Error(`Gagal memperbarui akun penghuni: ${errUpdate.message}`);
      }
    }

    const { error: errProfil } = await admin.from('pengguna').upsert({
      id: penggunaId,
      email,
      nomor_telepon: telepon,
      nama_lengkap: nama,
      aktif: true,
    }, { onConflict: 'id' });
    if (errProfil) {
      throw new Error(`Gagal menyimpan profil penghuni: ${errProfil.message}`);
    }

    // ---- 3. Tulis undangan --------------------------------------------
    const { data: pemilik, error: errPemilik } = await admin
      .from('kos')
      .select('pemilik_id')
      .eq('id', idKos)
      .maybeSingle();
    if (errPemilik || !pemilik?.pemilik_id) {
      throw new Error('Pemilik kos tidak ditemukan');
    }

    // Undangan lama yang masih menunggu untuk email ini dibatalkan agar
    // hanya token terbaru yang berlaku.
    await admin
      .from('undangan_penghuni')
      .update({ status: 'dibatalkan' })
      .eq('kos_id', idKos)
      .eq('status', 'menunggu')
      .ilike('email_tujuan', email);

    const { data: undangan, error: errUndangan } = await admin
      .from('undangan_penghuni')
      .insert({
        kos_id: idKos,
        pengundang_id: pemilik.pemilik_id,
        nama_tujuan: nama,
        email_tujuan: email,
        telepon_tujuan: telepon,
        kamar_id: kamarId,
        tanggal_mulai: tanggalMulai,
        hash_token: hashToken,
        status: 'menunggu',
        berlaku_sampai: berlakuSampai,
      })
      .select('id, berlaku_sampai')
      .single();
    if (errUndangan) {
      throw new Error(`Gagal menyimpan undangan: ${errUndangan.message}`);
    }

    return json({
      ok: true,
      undangan_id: undangan.id,
      nama,
      email,
      token,
      berlaku_sampai: undangan.berlaku_sampai,
      kamar: {
        id: kamar.id,
        nomor_kamar: kamar.nomor_kamar,
        tipe_kamar: kamar.tipe_kamar,
        harga_sewa_bulanan: kamar.harga_sewa_bulanan,
      },
    });
  } catch (e) {
    const pesan = e instanceof Error ? e.message : String(e);
    return json({ error: pesan }, 500);
  }
});
