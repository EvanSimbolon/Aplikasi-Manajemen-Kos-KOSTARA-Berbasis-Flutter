import 'package:belajar_dart/domain/models/pembayaran.dart';

class PembayaranRepository {
  const PembayaranRepository();

  List<Pembayaran> getDaftarPembayaran() {
    return const [
      Pembayaran(
        nama: 'Assiya Nazrun',
        kamar: 'Kamar A03 - Apr 2026',
        nominal: 'Rp 1.000.000',
        status: 'Belum Dibayar',
      ),
      Pembayaran(
        nama: 'Siti Aisyah',
        kamar: 'Kamar A01 - Apr 2026',
        nominal: 'Rp 1.000.000',
        status: 'Belum Dibayar',
      ),
      Pembayaran(
        nama: 'Kamila',
        kamar: 'Kamar A07 - Apr 2026',
        nominal: 'Rp 1.000.000',
        status: 'Belum Dibayar',
      ),
      Pembayaran(
        nama: 'Dini Aulia',
        kamar: 'Kamar B02 - Apr 2026',
        nominal: 'Rp 1.500.000',
        status: 'Menunggu',
      ),
      Pembayaran(
        nama: 'Zahra Natashya',
        kamar: 'Kamar B06 - Apr 2026',
        nominal: 'Rp 1.500.000',
        status: 'Menunggu',
      ),
      Pembayaran(
        nama: 'Ayuna',
        kamar: 'Kamar A06 - Apr 2026',
        nominal: 'Rp 1.000.000',
        status: 'Lunas',
      ),
    ];
  }
}
