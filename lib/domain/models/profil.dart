class Profil {
  const Profil({
    required this.nama,
    required this.email,
    required this.telp,
    required this.kamar,
  });

  final String nama;
  final String email;
  final String telp;
  final String kamar;

  Profil copyWith({
    String? nama,
    String? email,
    String? telp,
    String? kamar,
  }) {
    return Profil(
      nama: nama ?? this.nama,
      email: email ?? this.email,
      telp: telp ?? this.telp,
      kamar: kamar ?? this.kamar,
    );
  }
}
