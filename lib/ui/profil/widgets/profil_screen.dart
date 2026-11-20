import 'package:flutter/material.dart';

import 'package:belajar_dart/data/services/auth_service.dart';
import 'package:belajar_dart/routing/app_routes.dart';
import 'package:belajar_dart/ui/core/themes/app_colors.dart';
import 'package:belajar_dart/ui/core/ui/common_widgets.dart';
import 'package:belajar_dart/ui/profil/view_models/profil_view_model.dart';

class ProfilScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onUbahProfil;
  final VoidCallback onPengaturan;

  const ProfilScreen({
    super.key,
    required this.onBack,
    required this.onUbahProfil,
    required this.onPengaturan,
  });

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final ProfilViewModel _viewModel = ProfilViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.load();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  Widget infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, size: 14),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  Widget menuRow(IconData icon, String label, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, size: 18),
        ],
      ),
    ),
  );

  void konfirmasiKeluar(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop();
              await const AuthService().logout();
              navigator.pushNamedAndRemoveUntil(
                AppRoutes.landing,
                (route) => false,
              );
            },
            child: const Text('Keluar', style: TextStyle(color: redLogout)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profil = _viewModel.profil;

    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final s = constraints.maxWidth / 343;
            return ClipRect(
              child: SizedBox(
                height: 190 * s,
                width: double.infinity,
                child: Stack(
                  children: [
                    Container(color: profileBrown),
                    Positioned(
                      left: -110 * s,
                      top: -110 * s,
                      child: Container(
                        width: 280 * s,
                        height: 150 * s,
                        decoration: const BoxDecoration(
                          color: orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 215 * s,
                      top: -162 * s,
                      child: Container(
                        width: 304 * s,
                        height: 304 * s,
                        decoration: const BoxDecoration(
                          color: orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: PageHeader(
                  'Profil',
                  onBack: widget.onBack,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardCream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE3CFA3), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: profilPict,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profil.nama,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Penghuni',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: profilPict,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    infoRow(Icons.email, 'Email', profil.email),
                    infoRow(Icons.phone, 'No. Telepon', profil.telp),
                    infoRow(Icons.home_outlined, 'Nomor Kamar', profil.kamar),
                    if (_viewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _viewModel.errorMessage!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: redLogout,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    menuRow(Icons.person, 'Ubah Profil', widget.onUbahProfil),
                    menuRow(Icons.settings, 'Pengaturan', widget.onPengaturan),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 120,
                height: 36,
                child: ElevatedButton(
                  onPressed: () => konfirmasiKeluar(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: redLogout,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Keluar',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
