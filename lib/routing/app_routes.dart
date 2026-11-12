class AppRoutes {
  const AppRoutes._();

  static const String landing = '/landing';
  static const String login = '/login';

  static const String dashboard = '/';
  static const String maintenance = '/maintenance';
  static const String kalender = '/kalender';
  static const String profil = '/profil';
  static const String ubahProfil = '/ubah-profil';
  static const String pengaturan = '/pengaturan';

  // =========================
  // ADMIN
  // =========================

  static const String adminDashboard = '/admin';
  static const String dataKamar = '/admin/kamar';
  static const String dataFasilitasKamar =
      '/admin/fasilitas-kamar';
  static const String dataPembayaran =
      '/admin/pembayaran';
  static const String dataPenghuni =
      '/admin/penghuni';
  static const String formPenghuni =
      '/admin/tambah-penghuni';
  static const String verifPembayaran =
      '/admin/verif-pembayaran';

  // =========================
  // PENGHUNI
  // =========================

  static const String tenantKeluhan =
      '/penghuni/keluhan';
  static const String tenantRiwayat =
      '/penghuni/riwayat';
  static const String tenantBuktiPembayaran =
      '/penghuni/bukti-pembayaran';
  static const String tenantProfil =
      '/penghuni/profil';
  static const String tenantUbahProfil =
      '/penghuni/ubah-profil';
  static const String tenantPengaturan =
      '/penghuni/pengaturan';
}