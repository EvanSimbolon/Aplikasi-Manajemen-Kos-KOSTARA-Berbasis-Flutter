import 'package:flutter/material.dart';
import 'package:belajar_dart/routing/app_routes.dart';
import 'package:belajar_dart/ui/admin_dashboard/widgets/dashboard_admin_screen.dart';
import 'package:belajar_dart/ui/auth/widgets/landing_screen.dart';
import 'package:belajar_dart/ui/auth/widgets/login_screen.dart';
import 'package:belajar_dart/ui/dashboard/widgets/dashboard_screen.dart';
import 'package:belajar_dart/ui/kalender/widgets/kalender_screen.dart';
import 'package:belajar_dart/ui/kamar/widgets/kamar_screen.dart';
import 'package:belajar_dart/ui/keluhan/widgets/ajukan_keluhan_screen.dart';
import 'package:belajar_dart/ui/maintenance/widgets/maintenance_screen.dart';
import 'package:belajar_dart/ui/pembayaran/widgets/bukti_pembayaran_screen.dart';
import 'package:belajar_dart/ui/pembayaran/widgets/pembayaran_screen.dart';
import 'package:belajar_dart/ui/pembayaran/widgets/riwayat_pembayaran_screen.dart';
import 'package:belajar_dart/ui/pembayaran/widgets/verif_pembayaran_screen.dart';
import 'package:belajar_dart/ui/penghuni/widgets/form_penghuni_screen.dart';
import 'package:belajar_dart/ui/penghuni/widgets/penghuni_screen.dart';
import 'package:belajar_dart/ui/profil/widgets/admin_pengaturan_screen.dart';
import 'package:belajar_dart/ui/profil/widgets/admin_profil_screen.dart';
import 'package:belajar_dart/ui/profil/widgets/admin_ubah_profil_screen.dart';
import 'package:belajar_dart/ui/profil/widgets/pengaturan_screen.dart';
import 'package:belajar_dart/ui/profil/widgets/profil_screen.dart';
import 'package:belajar_dart/ui/profil/widgets/ubah_profil_screen.dart';

class AppRouter {
  static const Color _background = Color(0xFFFFF7D4);

  static Widget _shell(Widget child) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(child: child),
    );
  }

  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.landing: (context) => const LandingScreen(),
        AppRoutes.login: (context) => const LoginScreen(),

        // ---------- Penghuni ----------
        AppRoutes.dashboard: (context) => const DashboardPage(),
        AppRoutes.kalender: (context) => const KalenderPage(),
        AppRoutes.tenantKeluhan: (context) => _shell(
              AjukanKeluhanScreen(
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),
        AppRoutes.tenantRiwayat: (context) => _shell(
              RiwayatPembayaranScreen(
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),
        AppRoutes.tenantBuktiPembayaran: (context) => _shell(
              BuktiPembayaranScreen(
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),
        AppRoutes.tenantProfil: (context) => _shell(
              ProfilScreen(
                onBack: () => Navigator.of(context).maybePop(),
                onUbahProfil: () => Navigator.of(context).pushNamed(
                  AppRoutes.tenantUbahProfil,
                ),
                onPengaturan: () => Navigator.of(context).pushNamed(
                  AppRoutes.tenantPengaturan,
                ),
              ),
            ),
        AppRoutes.tenantUbahProfil: (context) => _shell(
              UbahProfilScreen(
                onBack: () => Navigator.of(context).maybePop(),
                onSaved: () => Navigator.of(context).maybePop(),
              ),
            ),
        AppRoutes.tenantPengaturan: (context) => _shell(
              PengaturanScreen(
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),

        // ---------- Admin ----------
        AppRoutes.adminDashboard: (context) => const DashboardAdminScreen(),
        AppRoutes.dataKamar: (context) => const DataKamarPage(),
        AppRoutes.dataPembayaran: (context) => const DataPembayaranPage(),
        AppRoutes.dataPenghuni: (context) => const data_penghuni(),
        AppRoutes.formPenghuni: (context) => const FormPenghuniScreen(),
        AppRoutes.verifPembayaran: (context) => const verif_pembayaran(),

        // ---------- Profil admin yang sudah ada ----------
        AppRoutes.maintenance: (context) => const MaintenancePage(),
        AppRoutes.profil: (context) => const ProfilPage(),
        AppRoutes.ubahProfil: (context) => const UbahProfilPage(),
        AppRoutes.pengaturan: (context) => const PengaturanPage(),
      };
}
