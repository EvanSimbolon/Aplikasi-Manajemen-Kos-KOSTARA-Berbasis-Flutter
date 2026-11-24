import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/supabase_kamar_model.dart';

class KamarService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<String>> getOwnerKosIds() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return const [];

    final ids = <String>{};
    try {
      final kosList = await _supabase
          .from('kos')
          .select('id')
          .eq('pemilik_id', user.id);
      for (final r in kosList) {
        if (r['id'] != null) ids.add(r['id'].toString());
      }
    } catch (_) {}

    try {
      final anggota = await _supabase
          .from('anggota_kos')
          .select('kos_id')
          .eq('pengguna_id', user.id)
          .eq('peran', 'pemilik')
          .eq('status', 'aktif');
      for (final r in anggota) {
        if (r['kos_id'] != null) ids.add(r['kos_id'].toString());
      }
    } catch (_) {}

    return ids.toList();
  }

  Future<String> getOwnerKosId() async {
    final ids = await getOwnerKosIds();
    if (ids.isEmpty) {
      throw StateError('Data kos pemilik tidak ditemukan untuk akun ini.');
    }
    return ids.first;
  }

  // =========================
  // MENGAMBIL SEMUA DATA KAMAR + STATUS TERISI
  // =========================
  Future<List<SupabaseKamarModel>> getKamar() async {
    final kosIds = await getOwnerKosIds();
    var query = _supabase.from('kamar').select();
    if (kosIds.isNotEmpty) {
      query = query.inFilter('kos_id', kosIds);
    }
    final data = await query.order('nomor_kamar');
    final kamarRows = (data as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    final kamarIds = kamarRows
        .map((r) => r['id']?.toString())
        .whereType<String>()
        .toList();

    final occupiedIds = <String>{};
    if (kamarIds.isNotEmpty) {
      try {
        final now = DateTime.now();
        final todayStr =
            '${now.year.toString().padLeft(4, '0')}-'
            '${now.month.toString().padLeft(2, '0')}-'
            '${now.day.toString().padLeft(2, '0')}';

        final penyewaanRows = await _supabase
            .from('penyewaan')
            .select('kamar_id, status, tanggal_selesai')
            .inFilter('kamar_id', kamarIds)
            .inFilter('status', ['aktif', 'menunggu_mulai']);

        for (final row in penyewaanRows) {
          final kamarId = row['kamar_id']?.toString();
          final selesai = row['tanggal_selesai']?.toString();
          if (kamarId != null &&
              (selesai == null || selesai.compareTo(todayStr) >= 0)) {
            occupiedIds.add(kamarId);
          }
        }
      } catch (_) {}
    }

    return kamarRows
        .map(
          (item) => SupabaseKamarModel.fromMap(
            item,
            isTerisi: occupiedIds.contains(item['id']?.toString()),
          ),
        )
        .toList();
  }

  // =========================
  // UPLOAD FOTO KAMAR
  // =========================
  Future<String> uploadFotoKamar(File foto, String kosId) async {
    final namaFile = foto.path.split(RegExp(r'[\\/]')).last;
    final ekstensi = namaFile.contains('.') ? namaFile.split('.').last : 'jpg';
    final path = '$kosId/${DateTime.now().millisecondsSinceEpoch}.$ekstensi';
    final storage = _supabase.storage.from('foto-kamar');

    await storage.upload(path, foto);
    return storage.getPublicUrl(path);
  }

  // =========================
  // MENAMBAHKAN KAMAR
  // =========================
  Future<void> tambahKamar(SupabaseKamarModel kamar) async {
    final payload = <String, dynamic>{
      'kos_id': kamar.kosId,
      'nomor_kamar': kamar.nomorKamar,
      'tipe_kamar': kamar.tipeKamar,
      'harga_sewa_bulanan': kamar.hargaSewaBulanan,
      'deskripsi': kamar.deskripsi,
      if (kamar.fotoUrl != null) 'foto_url': kamar.fotoUrl,
    };

    try {
      await _supabase.from('kamar').insert(payload);
    } on PostgrestException catch (e) {
      if (kamar.fotoUrl != null && e.message.contains('foto_url')) {
        payload.remove('foto_url');
        await _supabase.from('kamar').insert(payload);
        return;
      }
      rethrow;
    }
  }

  // =========================
  // MENGUBAH KAMAR
  // =========================
  Future<void> ubahKamar(SupabaseKamarModel kamar) async {
    final payload = <String, dynamic>{
      'nomor_kamar': kamar.nomorKamar,
      'tipe_kamar': kamar.tipeKamar,
      'harga_sewa_bulanan': kamar.hargaSewaBulanan,
      'deskripsi': kamar.deskripsi,
      if (kamar.fotoUrl != null) 'foto_url': kamar.fotoUrl,
    };

    try {
      await _supabase.from('kamar').update(payload).eq('id', kamar.id);
    } on PostgrestException catch (e) {
      if (kamar.fotoUrl != null && e.message.contains('foto_url')) {
        payload.remove('foto_url');
        await _supabase.from('kamar').update(payload).eq('id', kamar.id);
        return;
      }
      rethrow;
    }
  }

  // =========================
  // MENGHAPUS KAMAR
  // =========================
  Future<void> hapusKamar(String id) async {
    try {
      await _supabase.from('kamar').delete().eq('id', id);
    } on PostgrestException catch (e) {
      final msg = '${e.code ?? ''} ${e.message} ${e.details ?? ''}'.toLowerCase();
      if (e.code == '23503' ||
          msg.contains('foreign key') ||
          msg.contains('violates') ||
          msg.contains('penyewaan')) {
        throw const KamarMasihDihuniException();
      }
      rethrow;
    }
  }
}

class KamarMasihDihuniException implements Exception {
  const KamarMasihDihuniException();

  @override
  String toString() =>
      'Maaf, kamar tidak dapat dihapus karena masih ada penghuni';
}
