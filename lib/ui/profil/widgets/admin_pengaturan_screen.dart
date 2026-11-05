import 'package:flutter/material.dart';

class PengaturanPage extends StatelessWidget {
  const PengaturanPage({super.key});

  static const Color _background = Color(0xFFFFF7D4);
  static const Color _headerBrown = Color(0xFF854836);
  static const Color _primaryText = Color(0xFF4C3D3D);
  static const Color _cardBackground = Color(0xFFFFFCF5);
  static const Color _cardBorder = Color(0xFFDEC8A3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Container(
            width: 428,
            height: 926,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: _background),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: -8,
                  child: Container(
                    width: 428,
                    height: 120,
                    color: _headerBrown,
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 42,
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 20,
                      icon: const Icon(
                        Icons.chevron_left,
                        size: 30,
                        color: Color(0xFFF7F7F7),
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
                const Positioned(
                  left: 46,
                  top: 49,
                  child: SizedBox(
                    width: 250,
                    height: 31,
                    child: Text(
                      'Pengaturan',
                      style: TextStyle(
                        color: Color(0xFFF7F7F7),
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 140,
                  child: Container(
                    width: 396,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSettingItem(
                          context,
                          icon: Icons.notifications_outlined,
                          title: 'Notifikasi',
                          subtitle: 'Atur pemberitahuan aplikasi',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pengaturan Notifikasi')),
                            );
                          },
                        ),
                        const Divider(height: 24, color: _cardBorder),
                        _buildSettingItem(
                          context,
                          icon: Icons.language_outlined,
                          title: 'Bahasa',
                          subtitle: 'Indonesia',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Bahasa: Indonesia')),
                            );
                          },
                        ),
                        const Divider(height: 24, color: _cardBorder),
                        _buildSettingItem(
                          context,
                          icon: Icons.lock_outline,
                          title: 'Keamanan',
                          subtitle: 'Ubah kata sandi akun',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pengaturan Keamanan')),
                            );
                          },
                        ),
                        const Divider(height: 24, color: _cardBorder),
                        _buildSettingItem(
                          context,
                          icon: Icons.info_outline,
                          title: 'Tentang Aplikasi',
                          subtitle: 'Versi 1.0.0',
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'BELAJAR DART',
                              applicationVersion: '1.0.0',
                              applicationLegalese: '© 2026 Pemrograman Aplikasi Bergerak',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8EBD2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: _primaryText),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _primaryText,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF8A7C6B),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: _primaryText,
            ),
          ],
        ),
      ),
    );
  }
}
