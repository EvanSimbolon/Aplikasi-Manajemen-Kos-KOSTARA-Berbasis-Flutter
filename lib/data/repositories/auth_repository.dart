import 'package:belajar_dart/data/services/auth_service.dart';

class AuthRepository {
  const AuthRepository({AuthService service = const AuthService()})
    : _service = service;

  final AuthService _service;

  Future<bool> login({
    required String identifier,
    required String token,
    required bool isAdmin,
  }) async {
    if (isAdmin) {
      if (identifier.trim().isEmpty || token.trim().isEmpty) {
        throw const AuthFailure('Email dan kata sandi wajib diisi.');
      }

      final result = await _service.loginOwner(
        email: identifier,
        password: token,
      );

      if (!result.isOwner) {
        await _service.logout();
        throw const AuthFailure('Akun ini tidak memiliki akses admin.');
      }

      return true;
    }

    if (identifier.trim().isEmpty || token.trim().isEmpty) {
      throw const AuthFailure('No. HP dan token wajib diisi.');
    }

    final result = await _service.loginPenghuni(
      nomorTelepon: identifier,
      token: token,
    );

    if (result.isOwner) {
      await _service.logout();
      throw const AuthFailure('Akun pemilik harus masuk melalui menu Admin.');
    }

    if (!result.isPenghuni) {
      await _service.logout();
      throw const AuthFailure(
        'No. HP ini belum terdaftar sebagai penghuni kos.',
      );
    }

    return true;
  }

  Future<void> logout() => _service.logout();

  Future<String?> currentRole() => _service.currentRole();
}
