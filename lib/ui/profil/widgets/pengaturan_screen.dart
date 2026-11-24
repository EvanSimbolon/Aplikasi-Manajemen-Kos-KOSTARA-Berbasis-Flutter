import 'package:flutter/material.dart';

import 'package:belajar_dart/data/services/token_session_service.dart';
import 'package:belajar_dart/ui/core/themes/app_colors.dart';
import 'package:belajar_dart/ui/core/ui/common_widgets.dart';
import 'package:belajar_dart/ui/profil/view_models/profil_view_model.dart';

// ---------- HALAMAN: PENGATURAN ----------
class PengaturanScreen extends StatefulWidget {
  final VoidCallback onBack;
  const PengaturanScreen({super.key, required this.onBack});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  final ProfilViewModel _viewModel = ProfilViewModel();
  bool notifPembayaran = true;
  bool notifKeluhan = true;
  bool notifPengumuman = false;
  bool _infoTerlihat = false;
  bool _memuatInfo = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onProfilChanged);
    _muatInfo();
  }

  void _onProfilChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _muatInfo() async {
    await _viewModel.load();
    final token = await TokenSessionService().baca();
    if (!mounted) return;
    setState(() {
      _token = token;
      _memuatInfo = false;
    });
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onProfilChanged);
    _viewModel.dispose();
    super.dispose();
  }

  Widget switchRow(
    String label,
    String sub,
    bool value,
    ValueChanged<bool> on,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                Text(sub, style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: on,
            activeThumbColor: orange,
            activeTrackColor: orange.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget menuRow(IconData icon, String label, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(label, style: labelStyle),
          const Spacer(),
          const Icon(Icons.chevron_right, size: 18),
        ],
      ),
    ),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    ),
  );

  String _maskNomor(String nilai) {
    final digits = nilai.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return nilai;
    if (digits.length <= 2) return digits;
    return '${'*' * (digits.length - 2)}${digits.substring(digits.length - 2)}';
  }

  String _maskEmail(String email) {
    final at = email.indexOf('@');
    if (at <= 0) return '********';
    final local = email.substring(0, at);
    final domain = email.substring(at);
    final awal = local.length <= 2
        ? local.substring(0, 1)
        : local.substring(0, 2);
    return '$awal******$domain';
  }

  String _maskToken(String? token) {
    if (token == null || token.isEmpty) return 'Belum tersimpan';
    return '••••••';
  }

  bool _cocokEmpatDigitTerakhir(String masukan) {
    final telp = _viewModel.profil.telp.replaceAll(RegExp(r'[^0-9]'), '');
    final input = masukan.replaceAll(RegExp(r'[^0-9]'), '');
    if (telp.length < 4 || input.length != 4) return false;
    return telp.endsWith(input);
  }

  Future<void> _toggleInfo() async {
    if (_infoTerlihat) {
      setState(() => _infoTerlihat = false);
      return;
    }

    final controller = TextEditingController();
    final cocok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardCream,
        title: const Text('Verifikasi Nomor HP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Masukkan 4 digit terakhir nomor HP untuk menampilkan '
              'informasi akun.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: fieldDecoration(hint: '4 digit terakhir'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () =>
                Navigator.pop(ctx, _cocokEmpatDigitTerakhir(controller.text)),
            child: const Text('Tampilkan'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (!mounted) return;
    if (cocok == true) {
      setState(() => _infoTerlihat = true);
    } else if (cocok == false) {
      showSnack(context, '4 digit terakhir nomor HP tidak cocok');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profil = _viewModel.profil;
    final nomor = _infoTerlihat ? profil.telp : _maskNomor(profil.telp);
    final email = _infoTerlihat ? profil.email : _maskEmail(profil.email);
    final token = _infoTerlihat
        ? (_token ?? 'Belum tersimpan')
        : _maskToken(_token);

    return SingleChildScrollView(
      child: Column(
        children: [
          PageHeader('Pengaturan', onBack: widget.onBack),
          SectionCard(
            children: [
              Row(
                children: [
                  const Text(
                    'Informasi Akun',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: _infoTerlihat ? 'Sembunyikan' : 'Tampilkan',
                    onPressed: _memuatInfo ? null : _toggleInfo,
                    icon: Icon(
                      _infoTerlihat ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _infoRow('No. HP', nomor),
              _infoRow('Email', email),
              _infoRow('Token', token),
              if (_memuatInfo)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SectionCard(
            children: [
              const Text(
                'Notifikasi',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              switchRow(
                'Pembayaran',
                'Pengingat tagihan & status bayar',
                notifPembayaran,
                (v) => setState(() => notifPembayaran = v),
              ),
              switchRow(
                'Keluhan',
                'Update status keluhan',
                notifKeluhan,
                (v) => setState(() => notifKeluhan = v),
              ),
              switchRow(
                'Pengumuman',
                'Info dari pengelola kost',
                notifPengumuman,
                (v) => setState(() => notifPengumuman = v),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SectionCard(
            children: [
              const Text(
                'Akun',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 1, color: borderCream),
              menuRow(Icons.info_outline, 'Tentang Aplikasi', () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Kost Tujuh Belas',
                  applicationVersion: '1.0.0',
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
