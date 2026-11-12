import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:belajar_dart/data/services/supabase_service.dart';

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
  }) {
    final email = emailUntukNomorTelepon(nomorTelepon);
    if (email == null) {
      throw const AuthFailure('Nomor HP tidak valid.');
    }

    return _login(
      email: email,
      password: token,
      invalidCredentialsMessage: 'No. HP atau token salah.',
    );
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

    return rows
        .map((row) => row['peran'] as String?)
        .whereType<String>()
        .where((peran) => peran.isNotEmpty)
        .toList();
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
  }

  Future<void> ubahKataSandi(String kataSandiBaru) async {
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
