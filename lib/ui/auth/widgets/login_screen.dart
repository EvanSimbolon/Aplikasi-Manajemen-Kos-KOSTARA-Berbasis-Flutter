import 'package:flutter/material.dart';

import 'package:belajar_dart/routing/app_routes.dart';
import 'package:belajar_dart/ui/auth/view_models/login_view_model.dart';
import 'package:belajar_dart/ui/core/themes/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.isAdmin = false});

  final bool isAdmin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final LoginViewModel _viewModel = LoginViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _identifierController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    final berhasil = await _viewModel.login(
      identifier: _identifierController.text,
      token: _tokenController.text,
      isAdmin: widget.isAdmin,
    );

    if (!mounted || !berhasil) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      widget.isAdmin ? AppRoutes.adminDashboard : AppRoutes.dashboard,
      (route) => false,
    );
  }

  void _daftar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Halaman pendaftaran akun admin belum tersedia.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.isAdmin;
    final identifierLabel = isAdmin ? 'Email' : 'No. HP';
    final identifierHint = isAdmin
        ? 'Masukkan email'
        : 'Masukkan nomor HP terdaftar';
    final tokenLabel = isAdmin ? 'Kata Sandi' : 'Token';
    final tokenHint = isAdmin
        ? 'Masukkan kata sandi'
        : 'Masukkan token dari pemilik kos';

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
              const SizedBox(height: 24),
              Text(
                identifierLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _identifierController,
                  keyboardType: isAdmin
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: identifierHint,
                    hintStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: AppTheme.inputColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tokenLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _tokenController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _masuk(),
                  decoration: InputDecoration(
                    hintText: tokenHint,
                    hintStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: AppTheme.inputColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              if (_viewModel.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _viewModel.errorMessage!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFD32F2F),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _viewModel.isLoading ? null : _masuk,
                  child: _viewModel.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
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
              if (isAdmin) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _viewModel.isLoading ? null : _daftar,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryDark,
                      side: const BorderSide(color: AppTheme.primaryDark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Daftar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
