import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/repositories/profil_repository.dart';
import 'package:belajar_dart/domain/models/profil.dart';

class ProfilViewModel extends ChangeNotifier {
  ProfilViewModel({ProfilRepository? repository})
    : _repository = repository ?? ProfilRepository.instance;

  final ProfilRepository _repository;

  Profil _profil = ProfilRepository.instance.profil;
  bool _isLoading = false;
  String? _errorMessage;

  Profil get profil => _profil;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profil = await _repository.fetch();
    } catch (error) {
      _errorMessage = 'Gagal memuat profil.';
      debugPrint('ProfilViewModel.load: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> simpan({
    required String nama,
    required String email,
    required String telp,
  }) async {
    _errorMessage = null;

    try {
      await _repository.simpan(
        _profil.copyWith(
          nama: nama.trim(),
          email: email.trim(),
          telp: telp.trim(),
        ),
      );
      _profil = _repository.profil;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = 'Gagal menyimpan profil.';
      debugPrint('ProfilViewModel.simpan: $error');
      notifyListeners();
      return false;
    }
  }
}
