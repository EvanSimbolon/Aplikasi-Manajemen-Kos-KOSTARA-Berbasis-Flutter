class Penghuni {
  const Penghuni({
    required this.nama,
    required this.roomDetails,
    required this.status,
    this.fotoUrl,
  });

  final String nama;
  final String roomDetails;
  final String status;
  final String? fotoUrl;

  factory Penghuni.fromMap(Map<String, dynamic> m) {
    final telepon = m['nomor_telepon'] as String?;
    final email = m['email'] as String?;

    // relasi bisa datang sebagai Map atau List, tangani keduanya
    final profil = m['profil_pengguna'];
    String? foto;
    if (profil is Map<String, dynamic>) {
      foto = profil['foto_url'] as String?;
    } else if (profil is List && profil.isNotEmpty) {
      foto = (profil.first as Map<String, dynamic>)['foto_url'] as String?;
    }

    return Penghuni(
      nama: '${m['nama_lengkap'] ?? '-'}',
      roomDetails: (telepon != null && telepon.isNotEmpty)
          ? telepon
          : '${email ?? '-'}',
      status: m['aktif'] == true ? 'Aktif' : 'Tidak Aktif',
      fotoUrl: (foto != null && foto.isNotEmpty) ? foto : null,
    );
  }
}