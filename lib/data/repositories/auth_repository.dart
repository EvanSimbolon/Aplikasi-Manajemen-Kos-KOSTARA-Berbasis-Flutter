import 'package:belajar_dart/data/services/auth_service.dart';

class AuthRepository {
  const AuthRepository({AuthService service = const AuthService()})
      : _service = service;

  final AuthService _service;

  Future<bool> login({
    required String identifier,
    required String token,
    required bool isAdmin,
  }) {
    return _service.login(
      identifier: identifier,
      token: token,
      isAdmin: isAdmin,
    );
  }
}
