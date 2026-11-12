class Pembayaran {
  const Pembayaran({
    this.id,
    required this.nama,
    required this.kamar,
    required this.nominal,
    required this.status,
  });

  final String? id;
  final String nama;
  final String kamar;
  final String nominal;
  final String status;
}
