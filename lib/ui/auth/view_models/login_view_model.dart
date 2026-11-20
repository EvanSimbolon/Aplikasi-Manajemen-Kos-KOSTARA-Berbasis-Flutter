import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/repositories/auth_repository.dart';
import 'package:belajar_dart/data/services/auth_service.dart';

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

    try {
      await _repository.login(
        identifier: identifier,
        token: token,
        isAdmin: isAdmin,
      );
      return true;
    } on AuthFailure catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (error) {
      _errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi Anda.';
      debugPrint('LoginViewModel.login: $error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
