import 'package:flutter/material.dart';
import 'package:belajar_dart/data/services/undangan_service.dart';
import 'package:belajar_dart/routing/app_routes.dart';
import 'package:belajar_dart/ui/core/themes/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.isAdmin = false});

  final bool isAdmin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _service = UndanganService();
  final _identifierController = TextEditingController();
  final _tokenController = TextEditingController();

  bool _memproses = false;
  String? _error;

  @override
  void dispose() {
    _identifierController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    // Login admin belum memakai Supabase Auth — admin hanya membuka dashboard
    // dan penulisan data tetap lewat Edge Function.
    if (widget.isAdmin) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.adminDashboard, (route) => false);
      return;
    }

    final identifier = _identifierController.text.trim();
    final token = _tokenController.text.trim();

    if (identifier.isEmpty) {
      setState(() => _error = 'Email / No. HP wajib diisi');
      return;
    }
    if (token.isEmpty) {
      setState(() => _error = 'Token wajib diisi');
      return;
    }

    setState(() {
      _memproses = true;
      _error = null;
    });

    try {
      // Verifikasi token ke server lalu buat sesi Supabase Auth.
      await _service.masukDenganToken(identifier: identifier, token: token);
      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
    } on UndanganException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.pesan);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Gagal masuk: $e');
    } finally {
      if (mounted) setState(() => _memproses = false);
    }
  }

  InputDecoration _dekorasi(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
      filled: true,
      fillColor: AppTheme.inputColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _bungkus(Widget child) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 36.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 120),

              Center(
                child: Image.asset(
                  'assets/logo_kostara.png',
                  height: 90,
                  fit: BoxFit.contain,
                ),
              ),
              // ==========================================

              const SizedBox(height: 24),
              const Text(
                'Email / No. HP',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 6),
              _bungkus(
                TextField(
                  controller: _identifierController,
                  enabled: !_memproses,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _dekorasi('Masukkan email atau nomor HP'),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Token',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 6),
              _bungkus(
                TextField(
                  controller: _tokenController,
                  enabled: !_memproses,
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  decoration: _dekorasi('Masukkan token dari admin'),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _memproses ? null : _masuk,
                  child: _memproses
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryDark,
                          ),
                        )
                      : const Text(
                          'Masuk',
                          style: TextStyle(
                            color: AppTheme.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
