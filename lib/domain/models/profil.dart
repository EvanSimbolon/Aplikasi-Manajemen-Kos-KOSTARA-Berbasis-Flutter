class Profil {
  const Profil({
    this.id,
    required this.nama,
    required this.email,
    required this.telp,
    required this.kamar,
    this.fotoUrl,
    this.alamat,
  });

  final String? id;
  final String nama;
  final String email;
  final String telp;
  final String kamar;
  final String? fotoUrl;
  final String? alamat;

  Profil copyWith({
    String? id,
    String? nama,
    String? email,
    String? telp,
    String? kamar,
    String? fotoUrl,
    String? alamat,
  }) {
    return Profil(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      telp: telp ?? this.telp,
      kamar: kamar ?? this.kamar,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      alamat: alamat ?? this.alamat,
    );
  }
}
