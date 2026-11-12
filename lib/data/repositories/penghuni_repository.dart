import 'package:belajar_dart/data/services/supabase_service.dart';
import 'package:belajar_dart/domain/models/penghuni.dart';
import 'package:belajar_dart/utils/formatters.dart';

class PenghuniRepository {
  const PenghuniRepository();

  List<Penghuni> getDemoDaftarPenghuni() {
    return const [
      Penghuni(
        nama: 'Assiya Nazrun',
        roomDetails: 'Kamar A03 - Apr 2026',
        status: 'Aktif',
      ),
      Penghuni(
        nama: 'Siti Aisyah',
        roomDetails: 'Kamar A01 - Apr 2026',
        status: 'Aktif',
      ),
      Penghuni(
        nama: 'Kamila',
        roomDetails: 'Kamar A07 - Apr 2026',
        status: 'Aktif',
      ),
      Penghuni(
        nama: 'Dini Aulia',
        roomDetails: 'Kamar B02 - Apr 2026',
        status: 'Aktif',
      ),
      Penghuni(
        nama: 'Zahra Natashya',
        roomDetails: 'Kamar B06 - Apr 2026',
        status: 'Tidak Aktif',
      ),
      Penghuni(
        nama: 'Ayuna',
        roomDetails: 'Kamar A06 - Apr 2026',
        status: 'Tidak Aktif',
      ),
      Penghuni(
        nama: 'Rina Rahmawati',
        roomDetails: 'Kamar C01 - Jan 2026',
        status: 'Tidak Aktif',
      ),
    ];
  }

  Future<List<Penghuni>> getDaftarPenghuni() async {
    if (!SupabaseService.isAvailable) return getDemoDaftarPenghuni();

    final rows = await SupabaseService.client
        .from('penyewaan')
        .select(
          'id,penghuni_id,status,tanggal_mulai,tanggal_selesai,'
          'pengguna!penyewaan_penghuni_id_fkey(nama_lengkap),'
          'kamar!inner(nomor_kamar)',
        )
        .order('tanggal_mulai', ascending: false);

    final result = <Penghuni>[];
    final seen = <String>{};

    for (final row in rows) {
      final penghuniId = row['penghuni_id'] as String?;
      if (penghuniId != null && !seen.add(penghuniId)) continue;

      final pengguna = _asMap(row['pengguna']);
      final kamar = _asMap(row['kamar']);
      final nomorKamar = kamar?['nomor_kamar'] as String? ?? '-';
      final selesai = Formatters.parseDate(row['tanggal_selesai']);
      final status = _statusPenyewaan(row['status'] as String?);

      result.add(
        Penghuni(
          id: penghuniId ?? row['id'] as String?,
          nama: pengguna?['nama_lengkap'] as String? ?? '-',
          roomDetails: selesai == null
              ? 'Kamar $nomorKamar'
              : 'Kamar $nomorKamar - ${Formatters.bulanTahun(selesai)}',
          status: status,
        ),
      );
    }

    return result;
  }

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  String _statusPenyewaan(String? status) {
    return switch (status) {
      'aktif' || 'menunggu_mulai' => 'Aktif',
      _ => 'Tidak Aktif',
    };
  }
}
