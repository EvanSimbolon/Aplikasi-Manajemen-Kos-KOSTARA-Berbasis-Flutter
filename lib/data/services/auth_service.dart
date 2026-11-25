import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:belajar_dart/data/services/supabase_service.dart';
import 'package:belajar_dart/data/services/token_session_service.dart';

class AuthResult {
  const AuthResult({required this.user, required this.role});

  final User user;
  final String role;

  bool get isOwner => role == 'pemilik';
  bool get isPenghuni => role == 'penghuni';
  bool get hasAccess => isOwner || isPenghuni;
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  const AuthService();

  Future<AuthResult> loginOwner({
    required String email,
    required String password,
  }) {
    return _login(
      email: email.trim(),
      password: password,
      invalidCredentialsMessage: 'Email atau kata sandi salah.',
    );
  }

  Future<AuthResult> loginPenghuni({
    required String nomorTelepon,
    required String token,
  }) async {
    final identifier = nomorTelepon.trim();
    final email = identifier.contains('@')
        ? identifier.toLowerCase()
        : emailUntukNomorTelepon(identifier);
    if (email == null) {
      throw const AuthFailure('Nomor HP tidak valid.');
    }

    final tokenBersih = token.trim();
    final kataSandi = <String>[
      tokenBersih,
      if (tokenBersih.isNotEmpty) 'Kt-${tokenBersih.toUpperCase()}-1a',
    ];

    AuthFailure? lastFailure;
    for (final sandi in kataSandi.toSet()) {
      try {
        return await _login(
          email: email,
          password: sandi,
          invalidCredentialsMessage: 'Email/No. HP atau token salah.',
        );
      } on AuthFailure catch (error) {
        lastFailure = error;
        if (!error.message.toLowerCase().contains('salah')) rethrow;
      }
    }

    throw lastFailure ?? const AuthFailure('Email/No. HP atau token salah.');
  }

  Future<AuthResult> _login({
    required String email,
    required String password,
    required String invalidCredentialsMessage,
  }) async {
    try {
      final response = await SupabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthFailure('Gagal masuk. Silakan coba lagi.');
      }

      final roles = await _ambilPeran(user.id);
      final role = roles.contains('pemilik')
          ? 'pemilik'
          : roles.contains('penghuni')
          ? 'penghuni'
          : 'tanpa_akses';

      return AuthResult(user: user, role: role);
    } on AuthException catch (error) {
      throw AuthFailure(_pesanAuth(error.message, invalidCredentialsMessage));
    }
  }

  Future<List<String>> _ambilPeran(String userId) async {
    final rows = await SupabaseService.client
        .from('anggota_kos')
        .select('peran')
        .eq('pengguna_id', userId)
        .eq('status', 'aktif');

    final peran = rows
        .map((row) => row['peran'] as String?)
        .whereType<String>()
        .where((peran) => peran.isNotEmpty)
        .toList();
    if (peran.isNotEmpty) return peran;

    final ownedKos = await SupabaseService.client
        .from('kos')
        .select('id')
        .eq('pemilik_id', userId)
        .limit(1);
    if (ownedKos.isNotEmpty) return ['pemilik'];

    final sewa = await SupabaseService.client
        .from('penyewaan')
        .select('id')
        .eq('penghuni_id', userId)
        .inFilter('status', ['aktif', 'menunggu_mulai'])
        .limit(1);

    return sewa.isEmpty ? peran : ['penghuni'];
  }

  /// Daftar akun pemilik (admin) baru dengan email & kata sandi sendiri.
  /// Mengembalikan `true` jika langsung login, atau `false` jika butuh
  /// konfirmasi email terlebih dahulu.
  Future<bool> daftarOwner({
    required String nama,
    required String namaKos,
    required String email,
    required String password,
  }) async {
    final namaBersih = nama.trim();
    final kosBersih = namaKos.trim();
    final emailBersih = email.trim().toLowerCase();

    if (namaBersih.isEmpty || kosBersih.isEmpty) {
      throw const AuthFailure('Nama lengkap dan nama kos wajib diisi.');
    }
    if (!emailBersih.contains('@')) {
      throw const AuthFailure('Format email tidak valid.');
    }
    if (password.length < 6) {
      throw const AuthFailure('Kata sandi minimal 6 karakter.');
    }

    try {
      final response = await SupabaseService.auth.signUp(
        email: emailBersih,
        password: password,
        data: {'nama_lengkap': namaBersih, 'nama_kos': kosBersih},
      );

      if (response.session != null && response.user != null) {
        await pastikanProfilPemilik(namaKosDefault: kosBersih);
        return true;
      }
      return false;
    } on AuthException catch (error) {
      throw AuthFailure(_pesanAuth(error.message, 'Gagal mendaftar akun admin.'));
    }
  }

  /// Login / Daftar akun pemilik (admin) via Google Single Sign-On (OAuth).
  Future<void> loginOwnerDenganGoogle() async {
    try {
      await SupabaseService.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'kostara://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } on AuthException catch (error) {
      throw AuthFailure(
        _pesanAuth(error.message, 'Gagal masuk dengan akun Google.'),
      );
    }
  }

  /// Memastikan akun pemilik (misalnya setelah daftar email atau Google SSO)
  /// sudah memiliki record `kos` dan `anggota_kos` dengan peran `'pemilik'`.
  Future<void> pastikanProfilPemilik({String? namaKosDefault}) async {
    final user = SupabaseService.currentUser;
    if (user == null) return;

    final existingRoles = await _ambilPeran(user.id);
    if (existingRoles.contains('pemilik')) return;

    final meta = user.userMetadata ?? const <String, dynamic>{};
    final namaLengkap =
        (meta['nama_lengkap'] ?? meta['full_name'] ?? meta['name'] ?? '')
            .toString()
            .trim();
    final namaKos =
        (namaKosDefault ?? meta['nama_kos'] ?? '').toString().trim().isNotEmpty
            ? (namaKosDefault ?? meta['nama_kos']).toString().trim()
            : (namaLengkap.isNotEmpty ? 'Kos $namaLengkap' : 'Kos Saya');

    try {
      final kosRow = await SupabaseService.client
          .from('kos')
          .insert({
            'pemilik_id': user.id,
            'nama_kos': namaKos,
          })
          .select('id')
          .single();

      await SupabaseService.client.from('anggota_kos').upsert({
        'kos_id': kosRow['id'],
        'pengguna_id': user.id,
        'peran': 'pemilik',
        'status': 'aktif',
      }, onConflict: 'kos_id,pengguna_id');
    } catch (_) {
      // Jika sudah ada kos yang dibuat paralel, abaikan error duplikat.
    }
  }

  Future<String?> currentRole() async {
    final user = SupabaseService.currentUser;
    if (user == null) return null;

    final roles = await _ambilPeran(user.id);
    if (roles.contains('pemilik')) return 'pemilik';
    if (roles.contains('penghuni')) return 'penghuni';
    return null;
  }

  Future<void> logout() async {
    await SupabaseService.auth.signOut();
    await TokenSessionService().hapus();
  }

  String? get emailSaatIni => SupabaseService.currentUser?.email;

  Future<void> ubahKataSandi({
    required String kataSandiLama,
    required String kataSandiBaru,
  }) async {
    final email = emailSaatIni;
    if (email == null) {
      throw const AuthFailure('Sesi login tidak ditemukan.');
    }

    try {
      await SupabaseService.auth.signInWithPassword(
        email: email,
        password: kataSandiLama,
      );
    } on AuthException {
      throw const AuthFailure('Kata sandi lama salah.');
    }

    await SupabaseService.auth.updateUser(
      UserAttributes(password: kataSandiBaru),
    );
  }

  Future<void> kirimEmailResetKataSandi(String email) async {
    final target = email.trim().toLowerCase();
    if (!target.contains('@')) {
      throw const AuthFailure('Email tidak valid.');
    }

    try {
      await SupabaseService.auth.resetPasswordForEmail(
        target,
        redirectTo: 'kostara://reset-password',
      );
    } on AuthException catch (error) {
      throw AuthFailure(
        _pesanAuth(error.message, 'Gagal mengirim email reset kata sandi.'),
      );
    }
  }

  Future<void> simpanKataSandiBaru(String kataSandiBaru) async {
    await SupabaseService.auth.updateUser(
      UserAttributes(password: kataSandiBaru),
    );
  }

  String? emailUntukNomorTelepon(String nomorTelepon) {
    var digits = nomorTelepon.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.startsWith('62')) {
      digits = '0${digits.substring(2)}';
    } else if (digits.startsWith('8')) {
      digits = '0$digits';
    }

    if (digits.length < 9) return null;
    return '$digits@kostara.local';
  }

  String _pesanAuth(String message, String invalidCredentialsMessage) {
    final normalized = message.toLowerCase();
    if (normalized.contains('invalid login credentials')) {
      return invalidCredentialsMessage;
    }
    if (normalized.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Hubungi pemilik kos.';
    }
    if (normalized.contains('too many requests')) {
      return 'Terlalu banyak percobaan. Coba lagi beberapa saat.';
    }
    return message;
  }
}
