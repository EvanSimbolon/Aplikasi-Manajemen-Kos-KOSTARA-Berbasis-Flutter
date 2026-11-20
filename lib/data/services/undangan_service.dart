import 'package:supabase_flutter/supabase_flutter.dart';

/// Kamar yang sedang kosong, dibaca langsung dari view `v_kamar_ketersediaan`.
class KamarTersedia {
  const KamarTersedia({
    required this.id,
    required this.kosId,
    required this.nomorKamar,
    required this.tipeKamar,
    required this.hargaSewaBulanan,
  });

  final String id;
  final String kosId;
  final String nomorKamar;
  final String? tipeKamar;
  final num hargaSewaBulanan;

  factory KamarTersedia.fromMap(Map<String, dynamic> map) {
    return KamarTersedia(
      id: map['id'] as String,
      kosId: map['kos_id'] as String,
      nomorKamar: (map['nomor_kamar'] ?? '').toString(),
      tipeKamar: map['tipe_kamar'] as String?,
      hargaSewaBulanan: (map['harga_sewa_bulanan'] as num?) ?? 0,
    );
  }
}

/// Hasil pembuatan undangan: token inilah yang diserahkan admin ke penghuni.
class HasilUndangan {
  const HasilUndangan({
    required this.nama,
    required this.email,
    required this.token,
    required this.nomorKamar,
    this.berlakuSampai,
  });

  final String nama;
  final String email;
  final String token;
  final String nomorKamar;
  final DateTime? berlakuSampai;

  factory HasilUndangan.fromMap(Map<String, dynamic> map) {
    return HasilUndangan(
      nama: (map['nama'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      token: (map['token'] ?? '').toString(),
      nomorKamar: (map['nomor_kamar'] ?? '').toString(),
      berlakuSampai: DateTime.tryParse((map['berlaku_sampai'] ?? '').toString())
          ?.toLocal(),
    );
  }
}

/// Error yang pesannya sudah ramah dibaca pengguna.
class UndanganException implements Exception {
  const UndanganException(this.pesan);

  final String pesan;

  @override
  String toString() => pesan;
}

/// Jembatan aplikasi Flutter ke Edge Function undangan penghuni.
class UndanganService {
  UndanganService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<KamarTersedia>> daftarKamarTersedia() async {
    try {
      final data = await _client
          .from('v_kamar_ketersediaan')
          .select()
          .eq('tersedia', true)
          .order('nomor_kamar');

      return List<Map<String, dynamic>>.from(data)
          .map(KamarTersedia.fromMap)
          .toList();
    } catch (e) {
      throw UndanganException(
        'Gagal memuat daftar kamar kosong. Periksa koneksi dan view '
            'v_kamar_ketersediaan. ($e)',
      );
    }
  }

  Future<HasilUndangan> buatUndangan({
    required String nama,
    required String telepon,
    required String email,
    required KamarTersedia kamar,
    required DateTime tanggalMulai,
    bool aktif = true,
  }) async {
    try {
      final res = await _client.functions.invoke(
        'buat_undangan',
        body: {
          'nama': nama,
          'telepon': telepon,
          'email': email,
          'nomor_kamar': kamar.nomorKamar,
          'kamar_id': kamar.id,
          'tanggal_mulai': _formatTanggal(tanggalMulai),
          'aktif': aktif,
        },
      );

      final data = res.data;
      if (data is! Map) {
        throw const UndanganException(
          'Server tidak mengembalikan data undangan yang valid.',
        );
      }

      final hasil = Map<String, dynamic>.from(data);
      if (hasil['token'] == null || hasil['token'].toString().isEmpty) {
        throw const UndanganException(
          'Undangan tersimpan tetapi token tidak diterima. Cek log Edge Function.',
        );
      }
      return HasilUndangan.fromMap(hasil);
    } on FunctionException catch (e) {
      throw UndanganException(_pesanError(e));
    }
  }

  /// Verifikasi token lalu buat sesi login Supabase untuk penghuni.
  /// (Tidak diubah. Fungsi `masuk-penghuni` belum ada di Supabase.)
  Future<String> masukDenganToken({
    required String identifier,
    required String token,
  }) async {
    final tokenBersih = token.trim().toUpperCase();
    try {
      final res = await _client.functions.invoke(
        'masuk-penghuni',
        body: {'identifier': identifier.trim(), 'token': tokenBersih},
      );

      final data = res.data;
      if (data is! Map || data['email'] == null) {
        throw const UndanganException(
          'Server tidak mengembalikan data login yang valid.',
        );
      }

      final email = data['email'].toString();
      await _client.auth.signInWithPassword(
        email: email,
        password: 'Kt-$tokenBersih-1a',
      );
      return email;
    } on FunctionException catch (e) {
      throw UndanganException(_pesanError(e));
    } on AuthException catch (e) {
      throw UndanganException(
        'Token diterima, tetapi sesi login gagal dibuat: ${e.message}',
      );
    }
  }

  String _pesanError(FunctionException e) {
    final detail = e.details;
    if (detail is Map) {
      final pesan = detail['error'] ?? detail['message'];
      if (pesan != null && pesan.toString().trim().isNotEmpty) {
        return pesan.toString();
      }
    }
    return (detail ?? e.reasonPhrase ?? 'Gagal menghubungi server').toString();
  }

  String _formatTanggal(DateTime tanggal) {
    final bulan = tanggal.month.toString().padLeft(2, '0');
    final hari = tanggal.day.toString().padLeft(2, '0');
    return '${tanggal.year}-$bulan-$hari';
  }
}