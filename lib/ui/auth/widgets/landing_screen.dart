import 'package:flutter/material.dart';

import 'package:belajar_dart/data/repositories/auth_repository.dart';
import 'package:belajar_dart/data/services/supabase_service.dart';
import 'package:belajar_dart/routing/app_routes.dart';
import 'package:belajar_dart/ui/core/themes/app_theme.dart';

import 'login_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    _cekSesi();
  }

  Future<void> _cekSesi() async {
    if (!SupabaseService.isAvailable || !SupabaseService.isAuthenticated) {
      return;
    }

    try {
      final role = await const AuthRepository().currentRole();
      if (!mounted || role == null) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        role == 'pemilik' ? AppRoutes.adminDashboard : AppRoutes.dashboard,
        (route) => false,
      );
    } catch (_) {
      // Biarkan pengguna tetap di halaman masuk jika sesi tidak valid.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Image.asset(
                'assets/logo_kostara.png',
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              const Text(
                'Selamat datang di KOSTARA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Masuk Sebagai',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(isAdmin: false),
                      ),
                    );
                  },
                  child: const Text(
                    'Penghuni Kos',
                    style: TextStyle(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(isAdmin: true),
                      ),
                    );
                  },
                  child: const Text(
                    'Admin',
                    style: TextStyle(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
