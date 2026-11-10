import 'package:belajar_dart/domain/models/pembayaran.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PembayaranRepository {
  final SupabaseClient _supabase;

PembayaranRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

/// Mengambil daftar pembayaran dari Supabase dengan opsi filter status
  Future<List<Pembayaran>> getDaftarPembayaran({String filterStatus = 'Semua'}) async {
    try {
      // Menyiapkan query relasi dari tabel pembayaran ke tagihan, penyewaan, dan pengguna
      var query = _supabase.from('pembayaran').select('''
        id,
        status,
        jumlah_pembayaran,
        pembayar:pengguna!pembayar_id(nama_lengkap),
        tagihan:tagihan_id(
          periode_mulai,
          penyewaan:penyewaan_id(
            kamar:kamar_id(nomor_kamar)
          )
        )
      ''');

      // Penerapan filter status jika bukan 'Semua'
      if (filterStatus != 'Semua') {
        query = query.eq('status', filterStatus);
      }

      final List<dynamic> response = await query.order('dibayar_pada', ascending: false);

      // Mapping data JSON dari Supabase ke Model Pembayaran
      return response.map((data) {
        final namaPenghuni = data['pembayar']?['nama_lengkap'] ?? 'Penghuni';
        final nomorKamar = data['tagihan']?['penyewaan']?['kamar']?['nomor_kamar'] ?? '-';
        final nominalFormat = 'Rp ${data['jumlah_pembayaran']}';
        
        return Pembayaran(
          nama: namaPenghuni,
          kamar: 'Kamar $nomorKamar',
          nominal: nominalFormat,
          status: data['status'] ?? 'Belum Dibayar',
        );
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data pembayaran: $e');
    }
  }

  /// Verifikasi status pembayaran oleh Admin (Terima / Tolak)
  Future<void> verifikasiPembayaran({
    required String pembayaranId,
    required String tagihanId,
    required String adminId,
    required bool statusSetuju,
  }) async {
    final statusText = statusSetuju ? 'Lunas' : 'Ditolak';

    // 1. Update status transaksi di tabel pembayaran
    await _supabase.from('pembayaran').update({
      'status': statusText,
      'pemeriksa_id': adminId,
      'diperiksa_pada': DateTime.now().toIso8601String(),
    }).eq('id', pembayaranId);

    // 2. Jika disetujui, update status di tabel tagihan menjadi Lunas
    if (statusSetuju) {
      await _supabase.from('tagihan').update({
        'status': 'Lunas',
      }).eq('id', tagihanId);
    }
  }
}
