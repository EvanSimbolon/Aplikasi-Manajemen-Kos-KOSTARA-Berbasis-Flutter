import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:belajar_dart/domain/models/pembayaran.dart';
import 'package:flutter/foundation.dart';

class PembayaranRepository {
  final SupabaseClient _supabase;

  PembayaranRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Mengambil daftar pembayaran dan tagihan belum dibayar dari Supabase
  Future<List<Pembayaran>> getDaftarPembayaran({String filterStatus = 'Semua'}) async {
    final List<Pembayaran> hasilGabungan = [];
    final statusNormalized = filterStatus.trim();

    // 1. Ambil dari tabel 'pembayaran' (untuk 'Semua', 'Menunggu', 'Lunas', 'Ditolak')
    if (statusNormalized != 'Belum Dibayar') {
      try {
        var queryPembayaran = _supabase.from('pembayaran').select('''
          id,
          tagihan_id,
          pengguna!pembayaran_pembayar_id_fkey (
            nama_lengkap
          ),
          tagihan (
            penyewaan (
              kamar (
                nomor_kamar
              )
            )
          ),
          jumlah_pembayaran,
          dibayar_pada,
          status,
          bukti_pembayaran (
            lokasi_berkas
          ),
          catatan
        ''');

        final String? dbStatus = switch (statusNormalized) {
          'Menunggu' => 'menunggu_verifikasi',
          'Lunas' => 'terverifikasi',
          'Ditolak' => 'ditolak',
          _ => null, // 'Semua' -> tanpa filter eq
        };

        final List<dynamic> resPembayaran = dbStatus != null
            ? await queryPembayaran.eq('status', dbStatus)
            : await queryPembayaran;

        hasilGabungan.addAll(
          resPembayaran.map((data) => Pembayaran.fromJson(data as Map<String, dynamic>)),
        );
      } catch (e) {
        debugPrint('ERROR QUERY PEMBAYARAN ($statusNormalized): $e');
      }
    }

    // 2. Ambil dari tabel 'tagihan' (untuk 'Semua' dan 'Belum Dibayar')
    if (statusNormalized == 'Semua' || statusNormalized == 'Belum Dibayar') {
      try {
        final List<dynamic> resTagihan = await _supabase
            .from('tagihan')
            .select('''
              *,
              penyewaan (
                pengguna (
                  nama_lengkap
                ),
                kamar (
                  nomor_kamar
                )
              )
            ''')
            .inFilter('status', ['belum_bayar', 'terlambat']);

        hasilGabungan.addAll(
          resTagihan.map((data) => Pembayaran.fromTagihanJson(data as Map<String, dynamic>)),
        );
      } catch (e) {
        debugPrint('ERROR QUERY TAGIHAN ($statusNormalized): $e');
      }
    }

    return hasilGabungan;
  }

  /// Verifikasi status pembayaran oleh Admin
  Future<void> verifikasiPembayaran({
    required String pembayaranId,
    required String tagihanId,
    required String adminId,
    required bool statusSetuju,
  }) async {
    final statusPembayaran = statusSetuju ? 'terverifikasi' : 'ditolak';
    final statusTagihan = statusSetuju ? 'lunas' : 'belum_bayar';

    await _supabase.from('pembayaran').update({
      'status': statusPembayaran,
      if (adminId.isNotEmpty && adminId != 'admin') 'pemeriksa_id': adminId,
    }).eq('id', pembayaranId);

    if (tagihanId.isNotEmpty) {
      await _supabase.from('tagihan').update({
        'status': statusTagihan,
      }).eq('id', tagihanId);
    }
  }
}
