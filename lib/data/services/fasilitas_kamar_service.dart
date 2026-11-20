import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/jenis_fasilitas_model.dart';
import '../../domain/models/supabase_fasilitas_kamar_model.dart';

class FasilitasKamarService {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  // =========================
  // READ FASILITAS KAMAR
  // =========================

  Future<List<SupabaseFasilitasKamarModel>>
  getFasilitasKamar() async {
    final data = await _supabase
        .from('fasilitas_kamar')
        .select()
        .order('tanggal_pemasangan');

    return (data as List)
        .map(
          (item) =>
          SupabaseFasilitasKamarModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
    )
        .toList();
  }

  // =========================
  // READ JENIS FASILITAS
  // =========================

  Future<List<JenisFasilitasModel>>
  getJenisFasilitas() async {
    final data = await _supabase
        .from('jenis_fasilitas')
        .select()
        .order('nama_fasilitas');

    return (data as List)
        .map(
          (item) => JenisFasilitasModel.fromMap(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  // =========================
  // CREATE
  // =========================

  Future<void> tambahFasilitasKamar(
      SupabaseFasilitasKamarModel fasilitas,
      ) async {
    await _supabase
        .from('fasilitas_kamar')
        .insert({
      'kamar_id': fasilitas.kamarId,
      'jenis_fasilitas_id':
      fasilitas.jenisFasilitasId,
      'jumlah': fasilitas.jumlah,
      'kondisi': fasilitas.kondisi,
      'tanggal_pemasangan':
      fasilitas.tanggalPemasangan
          ?.toIso8601String()
          .split('T')
          .first,
    });
  }

  // =========================
  // UPDATE
  // =========================

  Future<void> ubahFasilitasKamar(
      SupabaseFasilitasKamarModel fasilitas,
      ) async {
    await _supabase
        .from('fasilitas_kamar')
        .update({
      'kamar_id': fasilitas.kamarId,
      'jenis_fasilitas_id':
      fasilitas.jenisFasilitasId,
      'jumlah': fasilitas.jumlah,
      'kondisi': fasilitas.kondisi,
      'tanggal_pemasangan':
      fasilitas.tanggalPemasangan
          ?.toIso8601String()
          .split('T')
          .first,
    }).eq('id', fasilitas.id);
  }

  // =========================
  // DELETE
  // =========================

  Future<void> hapusFasilitasKamar(
      String id,
      ) async {
    await _supabase
        .from('fasilitas_kamar')
        .delete()
        .eq('id', id);
  }
}