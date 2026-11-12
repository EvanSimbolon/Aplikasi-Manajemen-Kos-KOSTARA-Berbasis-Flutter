class RiwayatPembayaran {
  const RiwayatPembayaran({
    this.id,
    required this.bulan,
    required this.nominal,
    required this.tanggal,
    required this.status,
  });

  final String? id;
  final String bulan;
  final String nominal;
  final String tanggal;
  final String status;

  bool get berhasil => status == 'Berhasil';
}
