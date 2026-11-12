import 'package:belajar_dart/data/services/supabase_service.dart';
import 'package:belajar_dart/domain/models/pembayaran.dart';
import 'package:belajar_dart/utils/formatters.dart';

class PembayaranRepository {
  const PembayaranRepository();

  List<Pembayaran> getDemoDaftarPembayaran() {
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

  Future<List<Pembayaran>> getDaftarPembayaran() async {
    if (!SupabaseService.isAvailable) return getDemoDaftarPembayaran();

    final rows = await SupabaseService.client
        .from('tagihan')
        .select(
          'id,jumlah_tagihan,status,periode_mulai,periode_selesai,'
          'penyewaan!inner(penghuni_id,'
          'pengguna!penyewaan_penghuni_id_fkey(nama_lengkap),'
          'kamar!inner(nomor_kamar)),'
          'pembayaran(jumlah_pembayaran,status)',
        )
        .order('periode_mulai', ascending: false);

    return rows.map(_mapPembayaran).toList();
  }

  Pembayaran _mapPembayaran(Map<String, dynamic> row) {
    final penyewaan = _asMap(row['penyewaan']);
    final pengguna = _asMap(penyewaan?['pengguna']);
    final kamar = _asMap(penyewaan?['kamar']);
    final nomorKamar = kamar?['nomor_kamar'] as String? ?? '-';
    final periode = Formatters.parseDate(row['periode_mulai']);
    final jumlah = row['jumlah_tagihan'];

    return Pembayaran(
      id: row['id'] as String?,
      nama: pengguna?['nama_lengkap'] as String? ?? '-',
      kamar: periode == null
          ? 'Kamar $nomorKamar'
          : 'Kamar $nomorKamar - ${Formatters.bulanTahun(periode)}',
      nominal: Formatters.rupiah(Formatters.toNumber(jumlah)),
      status: _statusPembayaran(row['status'] as String?, row['pembayaran']),
    );
  }

  String _statusPembayaran(String? statusTagihan, Object? pembayaran) {
    if (statusTagihan == 'lunas') return 'Lunas';

    if (pembayaran is List) {
      final adaMenunggu = pembayaran.whereType<Map>().any(
        (item) => item['status'] == 'menunggu_verifikasi',
      );
      if (adaMenunggu) return 'Menunggu';
    }

    return 'Belum Dibayar';
  }

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
