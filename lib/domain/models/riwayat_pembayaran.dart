class RiwayatPembayaran {
  const RiwayatPembayaran({
    required this.bulan,
    required this.nominal,
    required this.tanggal,
    required this.status,
  });

  final String bulan;
  final String nominal;
  final String tanggal;
  final String status;

  bool get berhasil => status == 'Berhasil';
}
