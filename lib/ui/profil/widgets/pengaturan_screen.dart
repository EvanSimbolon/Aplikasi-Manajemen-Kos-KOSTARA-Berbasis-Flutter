import 'package:flutter/material.dart';
import 'package:belajar_dart/ui/core/themes/app_colors.dart';
import 'package:belajar_dart/ui/core/ui/common_widgets.dart';

// ---------- HALAMAN: PENGATURAN ----------
class PengaturanScreen extends StatefulWidget {
  final VoidCallback onBack;
  const PengaturanScreen({super.key, required this.onBack});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  bool notifPembayaran = true;
  bool notifKeluhan = true;
  bool notifPengumuman = false;

  Widget switchRow(String label, String sub, bool value, ValueChanged<bool> on) {
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
            activeColor: Colors.white,
            activeTrackColor: orange,
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

  void ubahSandi() {
    final lama = TextEditingController();
    final baru = TextEditingController();
    final konfirmasi = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardCream,
        title: const Text('Ubah Kata Sandi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: lama,
                obscureText: true,
                decoration: fieldDecoration(hint: 'Kata sandi lama')),
            const SizedBox(height: 8),
            TextField(
                controller: baru,
                obscureText: true,
                decoration: fieldDecoration(hint: 'Kata sandi baru')),
            const SizedBox(height: 8),
            TextField(
                controller: konfirmasi,
                obscureText: true,
                decoration: fieldDecoration(hint: 'Konfirmasi kata sandi baru')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: orange, foregroundColor: Colors.white),
            onPressed: () {
              if (baru.text.length < 6 || baru.text != konfirmasi.text) {
                showSnack(ctx, 'Sandi baru min. 6 karakter dan harus sama');
                return;
              }
              // TODO: kirim ke server
              Navigator.pop(ctx);
              showSnack(context, 'Kata sandi berhasil diubah');
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          PageHeader('Pengaturan', onBack: widget.onBack),
          SectionCard(children: [
            const Text('Notifikasi',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            switchRow('Pembayaran', 'Pengingat tagihan & status bayar',
                notifPembayaran, (v) => setState(() => notifPembayaran = v)),
            switchRow('Keluhan', 'Update status keluhan',
                notifKeluhan, (v) => setState(() => notifKeluhan = v)),
            switchRow('Pengumuman', 'Info dari pengelola kost',
                notifPengumuman, (v) => setState(() => notifPengumuman = v)),
          ]),
          const SizedBox(height: 12),
          SectionCard(children: [
            const Text('Akun',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            menuRow(Icons.lock_outline, 'Ubah Kata Sandi', ubahSandi),
            const Divider(height: 1, color: borderCream),
            menuRow(Icons.info_outline, 'Tentang Aplikasi', () {
              showAboutDialog(
                context: context,
                applicationName: 'Kost Tujuh Belas',
                applicationVersion: '1.0.0',
              );
            }),
          ]),
        ],
      ),
    );
  }
}
