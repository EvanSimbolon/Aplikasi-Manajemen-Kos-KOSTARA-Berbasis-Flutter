import 'package:flutter/material.dart';

import 'package:belajar_dart/data/services/auth_service.dart';
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

  bool _googleLoading = false;

  Future<void> _masukDenganGoogle() async {
    if (_googleLoading) return;
    setState(() => _googleLoading = true);
    try {
      await const AuthService().loginOwnerDenganGoogle();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_pesanRamah(error))),
      );
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _daftar() async {
    final namaCtrl = TextEditingController();
    final kosCtrl = TextEditingController();
    final emailCtrl = TextEditingController(
      text: _identifierController.text.trim(),
    );
    final sandiCtrl = TextEditingController();
    final konfirmasiCtrl = TextEditingController();
    var memuat = false;
    String? pesanError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Daftar Akun Pemilik'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buat akun pemilik kos baru menggunakan email Anda sendiri.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: namaCtrl,
                  decoration: const InputDecoration(hintText: 'Nama lengkap'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: kosCtrl,
                  decoration: const InputDecoration(hintText: 'Nama kos'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'Email pemilik'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: sandiCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Kata sandi (min. 6 karakter)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: konfirmasiCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Konfirmasi kata sandi',
                  ),
                ),
                if (pesanError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    pesanError!,
                    style: const TextStyle(
                      color: Color(0xFFB3261E),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: memuat ? null : () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: memuat
                  ? null
                  : () async {
                      if (namaCtrl.text.trim().isEmpty ||
                          kosCtrl.text.trim().isEmpty ||
                          emailCtrl.text.trim().isEmpty) {
                        setDialogState(
                          () => pesanError = 'Semua kolom wajib diisi.',
                        );
                        return;
                      }
                      if (sandiCtrl.text.length < 6 ||
                          sandiCtrl.text != konfirmasiCtrl.text) {
                        setDialogState(
                          () => pesanError =
                              'Kata sandi minimal 6 karakter dan harus sama.',
                        );
                        return;
                      }

                      setDialogState(() {
                        memuat = true;
                        pesanError = null;
                      });
                      try {
                        final langsungMasuk =
                            await const AuthService().daftarOwner(
                          nama: namaCtrl.text,
                          namaKos: kosCtrl.text,
                          email: emailCtrl.text,
                          password: sandiCtrl.text,
                        );
                        if (!mounted || !ctx.mounted) return;
                        Navigator.pop(ctx);
                        if (langsungMasuk) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.adminDashboard,
                            (route) => false,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Pendaftaran berhasil! Periksa email untuk konfirmasi lalu masuk.',
                              ),
                            ),
                          );
                        }
                      } catch (error) {
                        if (!ctx.mounted) return;
                        setDialogState(() {
                          memuat = false;
                          pesanError = _pesanRamah(error);
                        });
                      }
                    },
              child: memuat
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Daftar'),
            ),
          ],
        ),
      ),
    );

    namaCtrl.dispose();
    kosCtrl.dispose();
    emailCtrl.dispose();
    sandiCtrl.dispose();
    konfirmasiCtrl.dispose();
  }

  String _pesanRamah(Object error) {
    final teks = error.toString();
    final pesan = teks.replaceFirst(RegExp(r'^[A-Za-z]+Exception:\s*'), '');
    if (pesan.isEmpty) return 'Terjadi kesalahan. Silakan coba lagi.';
    return pesan[0].toUpperCase() + pesan.substring(1);
  }

  Future<void> _lupaSandi() async {
    final email = TextEditingController(
      text: _identifierController.text.trim(),
    );
    var memuat = false;
    String? pesanError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Lupa Kata Sandi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan email admin. Tautan untuk membuat kata sandi baru '
                'akan dikirim ke email tersebut.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Email admin'),
              ),
              if (pesanError != null) ...[
                const SizedBox(height: 12),
                Text(
                  pesanError!,
                  style: const TextStyle(
                    color: Color(0xFFB3261E),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: memuat ? null : () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: memuat
                  ? null
                  : () async {
                      if (email.text.trim().isEmpty) {
                        setDialogState(
                          () => pesanError = 'Email admin wajib diisi',
                        );
                        return;
                      }

                      setDialogState(() {
                        memuat = true;
                        pesanError = null;
                      });
                      try {
                        await const AuthService().kirimEmailResetKataSandi(
                          email.text.trim(),
                        );
                        if (!mounted || !ctx.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Tautan reset dikirim. Periksa kotak masuk email.',
                            ),
                          ),
                        );
                      } catch (error) {
                        if (!ctx.mounted) return;
                        setDialogState(() {
                          memuat = false;
                          pesanError = _pesanRamah(error);
                        });
                      }
                    },
              child: memuat
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Kirim'),
            ),
          ],
        ),
      ),
    );

    email.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.isAdmin;
    final identifierLabel = isAdmin ? 'Email' : 'Email / No. HP';
    final identifierHint = isAdmin
        ? 'Masukkan email'
        : 'Masukkan email atau nomor HP terdaftar';
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
                  keyboardType:
                      isAdmin ? TextInputType.emailAddress : TextInputType.text,
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
              if (isAdmin) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _viewModel.isLoading ? null : _lupaSandi,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryDark,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text(
                      'Lupa kata sandi?',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
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
                    onPressed: (_viewModel.isLoading || _googleLoading)
                        ? null
                        : _daftar,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryDark,
                      side: const BorderSide(color: AppTheme.primaryDark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Daftar dengan Email',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppTheme.primaryDark.withValues(alpha: 0.25),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'atau',
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppTheme.primaryDark.withValues(alpha: 0.25),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (_viewModel.isLoading || _googleLoading)
                        ? null
                        : _masukDenganGoogle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2B1810),
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFD8C8AE)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: _googleLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.g_mobiledata_rounded,
                            size: 26,
                            color: Color(0xFFDB4437),
                          ),
                    label: const Text(
                      'Masuk / Daftar dengan Google',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
