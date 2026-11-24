import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/repositories/profil_repository.dart';
import 'package:belajar_dart/domain/models/profil.dart';

class ProfilViewModel extends ChangeNotifier {
  ProfilViewModel({ProfilRepository? repository})
    : _repository = repository ?? ProfilRepository.instance {
    _profil = _repository.profil;
    _repository.addListener(_onRepositoryChanged);
  }

  final ProfilRepository _repository;

  late Profil _profil;
  bool _isLoading = false;
  String? _errorMessage;

  Profil get profil => _profil;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _onRepositoryChanged() {
    _profil = _repository.profil;
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    super.dispose();
  }

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
    String? alamat,
    String? fotoUrl,
  }) async {
    _errorMessage = null;

    try {
      await _repository.simpan(
        _profil.copyWith(
          nama: nama.trim(),
          email: email.trim(),
          telp: telp.trim(),
          alamat: alamat,
          fotoUrl: fotoUrl,
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

  Future<String?> unggahFoto(File foto) async {
    _errorMessage = null;

    try {
      final url = await _repository.unggahFoto(foto);
      _profil = _repository.profil;
      notifyListeners();
      return url;
    } catch (error) {
      _errorMessage = 'Gagal mengunggah foto profil.';
      debugPrint('ProfilViewModel.unggahFoto: $error');
      notifyListeners();
      return null;
    }
  }
}
