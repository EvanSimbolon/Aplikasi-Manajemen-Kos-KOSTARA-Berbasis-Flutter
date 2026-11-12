import 'package:belajar_dart/data/services/supabase_service.dart';
import 'package:belajar_dart/domain/models/riwayat_pembayaran.dart';
import 'package:belajar_dart/utils/formatters.dart';

class RiwayatPembayaranRepository {
  const RiwayatPembayaranRepository();

  List<RiwayatPembayaran> getDemoRiwayat() {
    return const [
      RiwayatPembayaran(
        bulan: 'Januari 2026',
        nominal: 'Rp 1.000.000',
        tanggal: '15 Januari 2026',
        status: 'Berhasil',
      ),
      RiwayatPembayaran(
        bulan: 'Februari 2026',
        nominal: 'Rp 1.000.000',
        tanggal: '15 Februari 2026',
        status: 'Berhasil',
      ),
      RiwayatPembayaran(
        bulan: 'Maret 2026',
        nominal: 'Rp 1.000.000',
        tanggal: '15 Maret 2026',
        status: 'Berhasil',
      ),
      RiwayatPembayaran(
        bulan: 'April 2026',
        nominal: 'Rp 1.000.000',
        tanggal: '15 April 2026',
        status: 'Menunggu',
      ),
    ];
  }

  Future<List<RiwayatPembayaran>> getRiwayat() async {
    if (!SupabaseService.isAvailable) return getDemoRiwayat();

    final rows = await SupabaseService.client
        .from('v_riwayat_pembayaran')
        .select(
          'pembayaran_id,periode_mulai,jumlah_pembayaran,dibayar_pada,'
          'status_pembayaran',
        )
        .order('dibayar_pada', ascending: false);

    return rows.map((row) {
      final periode = Formatters.parseDate(row['periode_mulai']);
      final dibayar = Formatters.parseDate(row['dibayar_pada']);
      final jumlah = row['jumlah_pembayaran'];

      return RiwayatPembayaran(
        id: row['pembayaran_id'] as String?,
        bulan: periode == null ? '-' : Formatters.bulanTahun(periode),
        nominal: Formatters.rupiah(Formatters.toNumber(jumlah)),
        tanggal: dibayar == null ? '-' : Formatters.tanggalPanjang(dibayar),
        status: _statusPembayaran(row['status_pembayaran'] as String?),
      );
    }).toList();
  }

  String _statusPembayaran(String? status) {
    return switch (status) {
      'terverifikasi' => 'Berhasil',
      'menunggu_verifikasi' => 'Menunggu',
      'ditolak' => 'Ditolak',
      _ => 'Menunggu',
    };
  }
}
