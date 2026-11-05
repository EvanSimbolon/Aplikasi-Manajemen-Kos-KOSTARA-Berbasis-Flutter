import 'package:belajar_dart/data/repositories/profil_repository.dart';
import 'package:belajar_dart/domain/models/profil.dart';

class ProfilViewModel {
  ProfilViewModel({ProfilRepository? repository})
      : _repository = repository ?? ProfilRepository.instance;

  final ProfilRepository _repository;

  Profil get profil => _repository.profil;

  void simpan({
    required String nama,
    required String email,
    required String telp,
  }) {
    _repository.simpan(
      _repository.profil.copyWith(
        nama: nama.trim(),
        email: email.trim(),
        telp: telp.trim(),
      ),
    );
  }
}
