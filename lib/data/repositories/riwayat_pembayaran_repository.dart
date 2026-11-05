import 'package:belajar_dart/domain/models/riwayat_pembayaran.dart';

class RiwayatPembayaranRepository {
  const RiwayatPembayaranRepository();

  List<RiwayatPembayaran> getRiwayat() {
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
}
