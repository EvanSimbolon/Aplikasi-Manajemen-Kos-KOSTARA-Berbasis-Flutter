import 'package:belajar_dart/data/services/supabase_service.dart';
import 'package:belajar_dart/domain/models/kamar.dart';
import 'package:belajar_dart/utils/formatters.dart';

class KamarRepository {
  const KamarRepository();

  List<Kamar> getDemoKamar() {
    return const [
      Kamar(
        nomor: 'Kamar A02',
        tipe: 'Standar',
        harga: 'Rp. 1.000.000',
        tersedia: true,
        gambar: 'assets/img/kamar_standar.png',
      ),
      Kamar(
        nomor: 'Kamar A04',
        tipe: 'Standar',
        harga: 'Rp. 1.000.000',
        tersedia: true,
        gambar: 'assets/img/kamar_standar.png',
      ),
      Kamar(
        nomor: 'Kamar B02',
        tipe: 'Deluxe',
        harga: 'Rp. 1.500.000',
        tersedia: true,
        gambar: 'assets/img/kamar_deluxe.png',
      ),
      Kamar(
        nomor: 'Kamar B07',
        tipe: 'Deluxe',
        harga: 'Rp. 1.500.000',
        tersedia: true,
        gambar: 'assets/img/kamar_deluxe.png',
      ),
      Kamar(
        nomor: 'Kamar B08',
        tipe: 'Deluxe',
        harga: 'Rp. 1.500.000',
        tersedia: true,
        gambar: 'assets/img/kamar_deluxe.png',
      ),
      Kamar(
        nomor: 'Kamar A01',
        tipe: 'Standar',
        harga: 'Rp. 1.000.000',
        tersedia: false,
        gambar: 'assets/img/kamar_standar.png',
      ),
      Kamar(
        nomor: 'Kamar A03',
        tipe: 'Standar',
        harga: 'Rp. 1.000.000',
        tersedia: false,
        gambar: 'assets/img/kamar_standar.png',
      ),
      Kamar(
        nomor: 'Kamar A05',
        tipe: 'Standar',
        harga: 'Rp. 1.000.000',
        tersedia: false,
        gambar: 'assets/img/kamar_standar.png',
      ),
    ];
  }

  Future<List<Kamar>> getDaftarKamar() async {
    if (!SupabaseService.isAvailable) return getDemoKamar();

    final rows = await SupabaseService.client
        .from('v_kamar_ketersediaan')
        .select('id,kos_id,nomor_kamar,tipe_kamar,harga_sewa_bulanan,tersedia')
        .order('nomor_kamar', ascending: true);

    return rows.map(_mapKamar).toList();
  }

  Kamar _mapKamar(Map<String, dynamic> row) {
    final tipe = (row['tipe_kamar'] as String?)?.trim();
    final resolvedTipe = (tipe == null || tipe.isEmpty) ? 'Standar' : tipe;
    final harga = row['harga_sewa_bulanan'];

    return Kamar(
      id: row['id'] as String?,
      kosId: row['kos_id'] as String?,
      nomor: row['nomor_kamar'] as String? ?? '-',
      tipe: resolvedTipe,
      harga: Formatters.rupiah(Formatters.toNumber(harga)),
      tersedia: row['tersedia'] == true,
      gambar: resolvedTipe.toLowerCase().contains('deluxe')
          ? 'assets/img/kamar_deluxe.png'
          : 'assets/img/kamar_standar.png',
    );
  }
}
