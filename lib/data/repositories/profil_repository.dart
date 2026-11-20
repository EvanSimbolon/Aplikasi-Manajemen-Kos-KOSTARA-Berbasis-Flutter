import 'package:belajar_dart/data/services/supabase_service.dart';
import 'package:belajar_dart/domain/models/profil.dart';

class ProfilRepository {
  ProfilRepository._();

  static final ProfilRepository instance = ProfilRepository._();

  Profil _profil = const Profil(
    nama: 'Siti Aisyah',
    email: 'aisyahsiti12@gmail.com',
    telp: '0811-2233-4455',
    kamar: 'A05',
  );

  Profil get profil => _profil;

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
        .select('foto_url,alamat')
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

    _profil = Profil(
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
    );

    return _profil;
  }

  Future<void> simpan(Profil profil) async {
    _profil = profil;

    if (!SupabaseService.isAvailable || !SupabaseService.isAuthenticated) {
      return;
    }

    final userId = profil.id ?? SupabaseService.currentUser?.id;
    if (userId == null) return;

    await SupabaseService.client
        .from('pengguna')
        .update({'nama_lengkap': profil.nama, 'nomor_telepon': profil.telp})
        .eq('id', userId);

    await SupabaseService.client
        .from('profil_pengguna')
        .update({'alamat': profil.alamat})
        .eq('pengguna_id', userId);
  }

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
