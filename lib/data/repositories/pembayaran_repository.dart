import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:belajar_dart/domain/models/pembayaran.dart';

class PembayaranRepository {
  final SupabaseClient _supabase;

  PembayaranRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<List<String>> _ambilKosIdsPemilik() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return const [];

    final ids = <String>{};
    try {
      final kosList = await _supabase
          .from('kos')
          .select('id')
          .eq('pemilik_id', user.id);
      for (final r in kosList) {
        if (r['id'] != null) ids.add(r['id'].toString());
      }
    } catch (_) {}

    try {
      final anggota = await _supabase
          .from('anggota_kos')
          .select('kos_id')
          .eq('pengguna_id', user.id)
          .eq('peran', 'pemilik')
          .eq('status', 'aktif');
      for (final r in anggota) {
        if (r['kos_id'] != null) ids.add(r['kos_id'].toString());
      }
    } catch (_) {}

    return ids.toList();
  }

  /// Mengambil daftar pembayaran (sesuai kos_id pemilik) dari Supabase.
  Future<List<Pembayaran>> getDaftarPembayaran({
    String filterStatus = 'Semua',
  }) async {
    final List<Pembayaran> hasilGabungan = [];
    final statusNormalized = filterStatus.trim();
    final kosIds = await _ambilKosIdsPemilik();

    if (kosIds.isEmpty) {
      return hasilGabungan;
    }

    // 1. Ambil dari tabel 'pembayaran' milik kos_id pemilik
    if (statusNormalized != 'Belum Dibayar') {
      try {
        var queryPembayaran = _supabase.from('pembayaran').select('''
          id,
          tagihan_id,
          pengguna!pembayaran_pembayar_id_fkey (
            nama_lengkap
          ),
          tagihan!inner (
            penyewaan!inner (
              kamar!inner (
                nomor_kamar,
                kos_id
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
        ''').inFilter('tagihan.penyewaan.kamar.kos_id', kosIds);

        final String? dbStatus = switch (statusNormalized) {
          'Menunggu' => 'menunggu_verifikasi',
          'Lunas' => 'terverifikasi',
          'Ditolak' => 'ditolak',
          _ => null,
        };

        final List<dynamic> resPembayaran = dbStatus != null
            ? await queryPembayaran
                .eq('status', dbStatus)
                .order('dibayar_pada', ascending: false)
            : await queryPembayaran.order('dibayar_pada', ascending: false);

        hasilGabungan.addAll(
          resPembayaran.map(
            (data) => Pembayaran.fromJson(data as Map<String, dynamic>),
          ),
        );
      } catch (e) {
        debugPrint('ERROR QUERY PEMBAYARAN ($statusNormalized): $e');
      }
    }

    // 2. Ambil dari tabel 'tagihan' milik kos_id pemilik (jika dibutuhkan)
    if (statusNormalized == 'Belum Dibayar') {
      try {
        final List<dynamic> resTagihan = await _supabase
            .from('tagihan')
            .select('''
              *,
              penyewaan!inner (
                pengguna (
                  nama_lengkap
                ),
                kamar!inner (
                  nomor_kamar,
                  kos_id
                )
              )
            ''')
            .inFilter('penyewaan.kamar.kos_id', kosIds)
            .inFilter('status', ['belum_bayar', 'terlambat'])
            .order('tanggal_jatuh_tempo', ascending: true);

        hasilGabungan.addAll(
          resTagihan.map(
            (data) => Pembayaran.fromTagihanJson(data as Map<String, dynamic>),
          ),
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
    final pemeriksaId =
        adminId.isNotEmpty && adminId != 'admin'
            ? adminId
            : _supabase.auth.currentUser?.id;

    await _supabase
        .from('pembayaran')
        .update({
          'status': statusPembayaran,
          if (pemeriksaId != null && pemeriksaId.isNotEmpty)
            'pemeriksa_id': pemeriksaId,
          'diperiksa_pada': DateTime.now().toIso8601String(),
        })
        .eq('id', pembayaranId);

    if (tagihanId.isNotEmpty) {
      await _supabase
          .from('tagihan')
          .update({'status': statusTagihan})
          .eq('id', tagihanId);
    }
  }
}
