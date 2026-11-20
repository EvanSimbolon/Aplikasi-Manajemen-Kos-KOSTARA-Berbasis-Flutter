import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/supabase_kamar_model.dart';

class KamarService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // =========================
  // MENGAMBIL SEMUA DATA KAMAR
  // =========================
  Future<List<SupabaseKamarModel>> getKamar() async {
    final data = await _supabase
        .from('kamar')
        .select()
        .order('nomor_kamar');

    return (data as List)
        .map(
          (item) => SupabaseKamarModel.fromMap(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  // =========================
  // MENAMBAHKAN KAMAR
  // =========================
  Future<void> tambahKamar(SupabaseKamarModel kamar) async {
    await _supabase.from('kamar').insert({
      'kos_id': kamar.kosId,
      'nomor_kamar': kamar.nomorKamar,
      'tipe_kamar': kamar.tipeKamar,
      'harga_sewa_bulanan': kamar.hargaSewaBulanan,
      'deskripsi': kamar.deskripsi,
    });
  }

  // =========================
  // MENGUBAH KAMAR
  // =========================
  Future<void> ubahKamar(SupabaseKamarModel kamar) async {
    await _supabase
        .from('kamar')
        .update({
      'nomor_kamar': kamar.nomorKamar,
      'tipe_kamar': kamar.tipeKamar,
      'harga_sewa_bulanan': kamar.hargaSewaBulanan,
      'deskripsi': kamar.deskripsi,
    })
        .eq('id', kamar.id);
  }

  // =========================
  // MENGHAPUS KAMAR
  // =========================
  Future<void> hapusKamar(String id) async {
    await _supabase
        .from('kamar')
        .delete()
        .eq('id', id);
  }

  // =========================
  // TEST KONEKSI TABEL KAMAR
  // =========================
  Future<void> testKamar() async {
    final data = await _supabase
        .from('kamar')
        .select();

    print('DATA KAMAR DARI SUPABASE: $data');
  }
}