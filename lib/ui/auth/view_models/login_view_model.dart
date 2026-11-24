import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/repositories/auth_repository.dart';
import 'package:belajar_dart/data/services/auth_service.dart';
import 'package:belajar_dart/data/services/notification_service.dart';
import 'package:belajar_dart/data/services/supabase_service.dart';
import 'package:belajar_dart/data/services/token_session_service.dart';
import 'package:belajar_dart/data/services/undangan_service.dart';

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
      if (isAdmin) {
        await _repository.login(
          identifier: identifier,
          token: token,
          isAdmin: true,
        );
      } else {
        await _loginPenghuni(identifier: identifier, token: token);
        await TokenSessionService().simpan(token);
      }

      final userId = SupabaseService.currentUser?.id;
      if (userId != null) {
        unawaited(_mulaiNotifikasi(userId));
      }

      return true;
    } on AuthFailure catch (error) {
      _errorMessage = error.message;
      return false;
    } on UndanganException catch (error) {
      _errorMessage = error.pesan;
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

  Future<void> _mulaiNotifikasi(String userId) async {
    try {
      await NotificationService().init();
      NotificationService().listenToNotifikasi(userId);
    } catch (error) {
      debugPrint('Notifikasi tidak diaktifkan: $error');
    }
  }

  Future<void> _loginPenghuni({
    required String identifier,
    required String token,
  }) async {
    try {
      await UndanganService().masukDenganToken(
        identifier: identifier,
        token: token,
      );

      final role = await _repository.currentRole();
      if (role == 'penghuni') return;

      await _repository.logout();
      throw const AuthFailure('Akun ini belum terdaftar sebagai penghuni kos.');
    } on UndanganException catch (error) {
      final fungsiBelumAda = error.pesan.toLowerCase().contains('not found');
      if (!fungsiBelumAda) rethrow;

      await _repository.login(
        identifier: identifier,
        token: token,
        isAdmin: false,
      );
    }
  }
}
