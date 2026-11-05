import 'package:flutter/material.dart';
import 'package:belajar_dart/ui/core/themes/app_theme.dart';
import 'login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Jarak dari atas ke logo
              const SizedBox(height: 60),

              // Logo Gambar Kostara
              Image.asset(
                'assets/logo_kostara.png', // Sesuaikan ekstensi file Anda (.png / .jpg)
                height: 120,               // Sesuaikan tinggi logo jika perlu
                fit: BoxFit.contain,
              ),

              // Jarak dari logo ke teks sambutan (Dibuat rapat)
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

              // =========================================================
              // UBAH JARAK DI SINI: Diganti dari Spacer ke SizedBox(height: 24)
              // Agar tulisan "Masuk Sebagai" rapat ke tombol di bawahnya
              // =========================================================
              const SizedBox(height: 24),

              // Tombol Penghuni Kos
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

              // Tombol Admin
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