import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:belajar_dart/domain/models/penghuni.dart';

class PenghuniRepository {
  const PenghuniRepository();

  Future<List<Penghuni>> getPenghuni() async {
    final rows = await Supabase.instance.client
        .from('pengguna')
        .select(
        'id, email, nomor_telepon, nama_lengkap, aktif, profil_pengguna(foto_url)')
        .order('nama_lengkap');

    return (rows as List)
        .map((e) => Penghuni.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}