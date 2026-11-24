import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/services/supabase_service.dart';
import 'package:belajar_dart/domain/models/profil.dart';

class ProfilRepository extends ChangeNotifier {
  ProfilRepository._();

  static final ProfilRepository instance = ProfilRepository._();

  Profil _profil = const Profil(
    nama: 'Siti Aisyah',
    email: 'aisyahsiti12@gmail.com',
    telp: '0811-2233-4455',
    kamar: 'A05',
  );

  Profil get profil => _profil;

  void _setProfil(Profil profil) {
    _profil = profil;
    notifyListeners();
  }

  Future<Profil> fetch() async {
    if (!SupabaseService.isAvailable || !SupabaseService.isAuthenticated) {
      return _profil;
    }

    final user = SupabaseService.currentUser;
    if (user == null) return _profil;

    final pengguna = await SupabaseService.client
        .from('pengguna')
        .select('id,nama_lengkap,email,nomor_telepon')
        .eq('id', user.id)
        .maybeSingle();

    final detail = await SupabaseService.client
        .from('profil_pengguna')
        .select('*')
        .eq('pengguna_id', user.id)
        .maybeSingle();

    final penyewaan = await SupabaseService.client
        .from('penyewaan')
        .select('kamar!inner(nomor_kamar)')
        .eq('penghuni_id', user.id)
        .eq('status', 'aktif')
        .order('tanggal_mulai', ascending: false)
        .limit(1)
        .maybeSingle();

    final kamar = _asMap(penyewaan?['kamar']);

    _setProfil(
      Profil(
        id: user.id,
        nama:
            pengguna?['nama_lengkap'] as String? ??
            user.userMetadata?['nama_lengkap'] as String? ??
            '-',
        email: pengguna?['email'] as String? ?? user.email ?? '-',
        telp: pengguna?['nomor_telepon'] as String? ?? '-',
        kamar: kamar?['nomor_kamar'] as String? ?? '-',
        fotoUrl: detail?['foto_url'] as String?,
        alamat: detail?['alamat'] as String?,
      ),
    );

    return _profil;
  }

  Future<String> unggahFoto(File foto) async {
    if (!SupabaseService.isAvailable || !SupabaseService.isAuthenticated) {
      throw StateError('Sesi login tidak tersedia.');
    }

    final userId = SupabaseService.currentUser?.id;
    if (userId == null) {
      throw StateError('Sesi login tidak tersedia.');
    }

    final namaFile = foto.path.split(RegExp(r'[\\/]')).last;
    final ekstensi = namaFile.contains('.') ? namaFile.split('.').last : 'jpg';
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ekstensi';
    final storage = SupabaseService.client.storage.from('foto-profil');

    await storage.upload(path, foto);
    final url = storage.getPublicUrl(path);

    await _simpanDetail(userId, {'foto_url': url});
    _setProfil(_profil.copyWith(fotoUrl: url));

    return url;
  }

  Future<void> simpan(Profil profil) async {
    if (!SupabaseService.isAvailable || !SupabaseService.isAuthenticated) {
      _setProfil(profil);
      return;
    }

    final userId = profil.id ?? SupabaseService.currentUser?.id;
    if (userId == null) {
      _setProfil(profil);
      return;
    }

    final detail = <String, dynamic>{
      if (profil.fotoUrl != null) 'foto_url': profil.fotoUrl,
      if (profil.alamat != null) 'alamat': profil.alamat,
    };
    if (detail.isNotEmpty) {
      await _simpanDetail(userId, detail);
    }

    await SupabaseService.client
        .from('pengguna')
        .update({'nama_lengkap': profil.nama, 'nomor_telepon': profil.telp})
        .eq('id', userId);

    _setProfil(profil);
  }

  Future<void> _simpanDetail(String userId, Map<String, dynamic> data) async {
    final updated = await SupabaseService.client
        .from('profil_pengguna')
        .update(data)
        .eq('pengguna_id', userId)
        .select('pengguna_id');

    if ((updated as List).isEmpty) {
      await SupabaseService.client.from('profil_pengguna').upsert({
        'pengguna_id': userId,
        ...data,
      });
    }
  }

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
