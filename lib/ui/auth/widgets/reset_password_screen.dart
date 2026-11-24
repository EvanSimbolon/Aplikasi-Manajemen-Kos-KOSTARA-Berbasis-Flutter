import 'package:flutter/material.dart';

import 'package:belajar_dart/data/services/auth_service.dart';
import 'package:belajar_dart/routing/app_routes.dart';
import 'package:belajar_dart/ui/core/themes/app_colors.dart';
import 'package:belajar_dart/ui/core/ui/common_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sandiBaru = TextEditingController();
  final _konfirmasi = TextEditingController();
  bool _memuat = false;
  bool _lihatSandi = false;

  @override
  void dispose() {
    _sandiBaru.dispose();
    _konfirmasi.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (_memuat || !_formKey.currentState!.validate()) return;

    setState(() => _memuat = true);
    try {
      await const AuthService().simpanKataSandiBaru(_sandiBaru.text);
      await const AuthService().logout();
      if (!mounted) return;
      showSnack(
        context,
        'Kata sandi berhasil diperbarui. Silakan masuk kembali.',
      );
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.landing, (route) => false);
    } catch (error) {
      if (!mounted) return;
      showSnack(context, 'Gagal memperbarui kata sandi: $error');
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _kembali();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF7D4),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                PageHeader('Kata Sandi Baru', onBack: _kembali),
                const SizedBox(height: 24),
                SectionCard(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Buat kata sandi baru untuk akun Anda.',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _sandiBaru,
                            obscureText: !_lihatSandi,
                            decoration: fieldDecoration(
                              hint: 'Kata sandi baru',
                              suffix: IconButton(
                                onPressed: () =>
                                    setState(() => _lihatSandi = !_lihatSandi),
                                icon: Icon(
                                  _lihatSandi
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 18,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if ((value ?? '').length < 6) {
                                return 'Minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _konfirmasi,
                            obscureText: !_lihatSandi,
                            decoration: fieldDecoration(
                              hint: 'Konfirmasi kata sandi baru',
                            ),
                            validator: (value) {
                              if (value != _sandiBaru.text) {
                                return 'Konfirmasi tidak sama';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: ElevatedButton(
                              onPressed: _memuat ? null : _simpan,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkOrange,
                                foregroundColor: Colors.white,
                              ),
                              child: _memuat
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Simpan Kata Sandi'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _kembali() async {
    await const AuthService().logout();
    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.landing, (route) => false);
  }
}
