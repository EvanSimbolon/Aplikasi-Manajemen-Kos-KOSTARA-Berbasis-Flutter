import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({AuthRepository repository = const AuthRepository()})
      : _repository = repository;

  final AuthRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login({
    required String identifier,
    required String token,
    required bool isAdmin,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.login(
      identifier: identifier,
      token: token,
      isAdmin: isAdmin,
    );

    if (!result) {
      _errorMessage = 'Email/No. HP dan token wajib diisi.';
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }
}
