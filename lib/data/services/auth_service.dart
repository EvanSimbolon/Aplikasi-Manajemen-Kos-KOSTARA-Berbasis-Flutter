class AuthService {
  const AuthService();

  Future<bool> login({
    required String identifier,
    required String token,
    required bool isAdmin,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return identifier.trim().isNotEmpty && token.trim().isNotEmpty;
  }
}
