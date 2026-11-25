import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/supabase_kamar_model.dart';
import '../../domain/models/supabase_maintenance_model.dart';

class MaintenanceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<SupabaseMaintenanceModel>> getMaintenance() async {
    final data = await _supabase
        .from('maintenance')
        .select()
        .order('tanggal_perawatan', ascending: false);

    return (data as List)
        .map(
          (item) => SupabaseMaintenanceModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<List<SupabaseKamarModel>> getKamar() async {
    final data = await _supabase.from('kamar').select().order('nomor_kamar');

    return (data as List)
        .map(
          (item) => SupabaseKamarModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<String> uploadFotoVerifikasi(File foto, String kamarId) async {
    final namaFile = foto.path.split(RegExp(r'[\\/]')).last;
    final ext = namaFile.contains('.') ? namaFile.split('.').last : 'jpg';
    final path = '$kamarId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    final storage = _supabase.storage.from('foto-maintenance');

    await storage.upload(path, foto);
    return storage.getPublicUrl(path);
  }

  Future<void> tambahMaintenance(
    SupabaseMaintenanceModel maintenance,
  ) async {
    final payload = <String, dynamic>{
      'kamar_id': maintenance.kamarId,
      'jenis_perawatan': maintenance.jenisPerawatan,
      'tanggal_perawatan': maintenance.tanggalPerawatan
          .toIso8601String()
          .split('T')
          .first,
      'teknisi': maintenance.teknisi,
      'status': maintenance.status,
      'catatan': maintenance.catatan,
      if (maintenance.fotoUrl != null) 'foto_url': maintenance.fotoUrl,
    };

    try {
      await _supabase.from('maintenance').insert(payload);
    } on PostgrestException catch (e) {
      if (maintenance.fotoUrl != null && e.message.contains('foto_url')) {
        payload.remove('foto_url');
        await _supabase.from('maintenance').insert(payload);
        return;
      }
      rethrow;
    }
  }

  Future<void> ubahMaintenance(
    SupabaseMaintenanceModel maintenance,
  ) async {
    final payload = <String, dynamic>{
      'kamar_id': maintenance.kamarId,
      'jenis_perawatan': maintenance.jenisPerawatan,
      'tanggal_perawatan': maintenance.tanggalPerawatan
          .toIso8601String()
          .split('T')
          .first,
      'teknisi': maintenance.teknisi,
      'status': maintenance.status,
      'catatan': maintenance.catatan,
      if (maintenance.fotoUrl != null) 'foto_url': maintenance.fotoUrl,
    };

    try {
      await _supabase
          .from('maintenance')
          .update(payload)
          .eq('id', maintenance.id);
    } on PostgrestException catch (e) {
      if (maintenance.fotoUrl != null && e.message.contains('foto_url')) {
        payload.remove('foto_url');
        await _supabase
            .from('maintenance')
            .update(payload)
            .eq('id', maintenance.id);
        return;
      }
      rethrow;
    }
  }

  Future<void> hapusMaintenance(String id) async {
    await _supabase.from('maintenance').delete().eq('id', id);
  }
}
