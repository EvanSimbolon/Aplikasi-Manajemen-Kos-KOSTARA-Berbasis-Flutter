class Kamar {
  const Kamar({
    this.id,
    this.kosId,
    required this.nomor,
    required this.tipe,
    required this.harga,
    required this.tersedia,
    required this.gambar,
  });

  final String? id;
  final String? kosId;
  final String nomor;
  final String tipe;
  final String harga;
  final bool tersedia;
  final String gambar;
}
