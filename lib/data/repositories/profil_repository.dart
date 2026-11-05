import 'package:belajar_dart/domain/models/profil.dart';

class ProfilRepository {
  ProfilRepository._();

  static final ProfilRepository instance = ProfilRepository._();

  Profil _profil = const Profil(
    nama: 'Siti Aisyah',
    email: 'aisyahsiti12@gmail.com',
    telp: '0811-2233-4455',
    kamar: 'A05',
  );

  Profil get profil => _profil;

  void simpan(Profil profil) {
    _profil = profil;
  }
}
