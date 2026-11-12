import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/supabase_kamar_model.dart';
import '../../domain/models/supabase_maintenance_model.dart';

class MaintenanceService {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<List<SupabaseMaintenanceModel>>
  getMaintenance() async {
    final data = await _supabase
        .from('maintenance')
        .select()
        .order('tanggal_perawatan');

    return (data as List)
        .map(
          (item) =>
          SupabaseMaintenanceModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
    )
        .toList();
  }

  Future<List<SupabaseKamarModel>>
  getKamar() async {
    final data = await _supabase
        .from('kamar')
        .select()
        .order('nomor_kamar');

    return (data as List)
        .map(
          (item) =>
          SupabaseKamarModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
    )
        .toList();
  }

  Future<void> tambahMaintenance(
      SupabaseMaintenanceModel maintenance,
      ) async {
    await _supabase
        .from('maintenance')
        .insert({
      'kamar_id':
      maintenance.kamarId,
      'jenis_perawatan':
      maintenance.jenisPerawatan,
      'tanggal_perawatan':
      maintenance.tanggalPerawatan
          .toIso8601String()
          .split('T')
          .first,
      'teknisi':
      maintenance.teknisi,
      'status':
      maintenance.status,
      'catatan':
      maintenance.catatan,
    });
  }

  Future<void> ubahMaintenance(
      SupabaseMaintenanceModel maintenance,
      ) async {
    await _supabase
        .from('maintenance')
        .update({
      'kamar_id':
      maintenance.kamarId,
      'jenis_perawatan':
      maintenance.jenisPerawatan,
      'tanggal_perawatan':
      maintenance.tanggalPerawatan
          .toIso8601String()
          .split('T')
          .first,
      'teknisi':
      maintenance.teknisi,
      'status':
      maintenance.status,
      'catatan':
      maintenance.catatan,
    })
        .eq('id', maintenance.id);
  }

  Future<void> hapusMaintenance(
      String id,
      ) async {
    await _supabase
        .from('maintenance')
        .delete()
        .eq('id', id);
  }
}