import 'package:intl/intl.dart';

class RiwayatPembayaran {
  const RiwayatPembayaran({
    required this.bulan,
    required this.nominal,
    required this.tanggal,
    required this.status,
  });

  final String bulan;
  final String nominal;
  final String tanggal;
  final String status;

  bool get berhasil => status == 'Terverifikasi';

  factory RiwayatPembayaran.fromMap(Map<String, dynamic> m) {
    final tagihan = m['tagihan'] as Map<String, dynamic>?;
    final jumlah = (m['jumlah_pembayaran'] as num).toDouble();
    final tgl = DateTime.tryParse('${m['dibayar_pada']}')?.toLocal();
    final statusDb = '${m['status']}';

    return RiwayatPembayaran(
      bulan: () {
        final raw = tagihan?['periode_mulai'];
        final d = raw == null ? null : DateTime.tryParse('$raw');
        return d == null ? '-' : DateFormat('MMMM yyyy', 'id_ID').format(d);
      }(),
      nominal: NumberFormat.currency(
          locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
          .format(jumlah),
      tanggal: tgl == null ? '-' : DateFormat('dd MMM yyyy').format(tgl),
      status:
      statusDb == 'terverifikasi' ? 'Terverifikasi' : 'Menunggu Verifikasi',
    );
  }
}