import 'package:flutter/material.dart';

import 'package:belajar_dart/routing/app_routes.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  static const Color _background = Color(0xFFFFF7D4);
  static const Color _cardBackground = Color(0xFFFFFCF2);
  static const Color _cardBorder = Color(0xFFF1E6C6);
  static const Color _primaryText = Color(0xFF4C3D3D);
  static const Color _accentText = Color(0xFFC07F00);
  static const Color _navBackground = Colors.black;
  static const Color _navBorder = Color(0xFF303030);
  static const Color _activeOrange = Color(0xFFF5A623);

  static const Color _badgeYellow = Color(0xFFF5E5A6);
  static const Color _badgeBlue = Color(0xFFCFE3F0);
  static const Color _badgeGreen = Color(0xFFC9E7C3);

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
                  left: 22,
                  top: 39,
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 20,
                      icon: const Icon(
                        Icons.chevron_left,
                        size: 30,
                        color: _primaryText,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
                const Positioned(
                  left: 57,
                  top: 46,
                  child: SizedBox(
                    width: 185,
                    height: 31,
                    child: Text(
                      'Maintenance',
                      style: TextStyle(
                        color: _primaryText,
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                _buildCard(
                  top: 96,
                  title: '#001 - AC Bocor',
                  subtitle: 'Kamar A03 - 12 Apr 2026',
                  status: 'Status : Dalam Proses',
                  statusColor: _badgeYellow,
                ),
                _buildCard(
                  top: 209,
                  title: '#002 - Lampu Mati',
                  subtitle: 'Kamar A05 - 13 Apr 2026',
                  status: 'Status : Dilaporkan',
                  statusColor: _badgeBlue,
                ),
                _buildCard(
                  top: 322,
                  title: '#003 - Kipas Mati',
                  subtitle: 'Kamar B05 - 13 Apr 2026',
                  status: 'Status : Selesai',
                  statusColor: _badgeGreen,
                ),
                Positioned(
                  left: 16,
                  top: 863,
                  child: Container(
                    width: 395,
                    height: 58,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: ShapeDecoration(
                      color: _navBackground,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: _navBorder),
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildNavItem(
                          icon: Icons.home,
                          label: 'Beranda',
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                        _buildNavItem(
                          icon: Icons.bed,
                          label: 'Kamar',
                        ),
                        _buildNavItem(
                          icon: Icons.credit_card,
                          label: 'Pembayaran',
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.kalender,
                          ),
                        ),
                        _buildNavItem(
                          icon: Icons.build,
                          label: 'Maintenance',
                          active: true,
                        ),
                        _buildNavItem(
                          icon: Icons.person,
                          label: 'Profil',
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.profil,
                          ),
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

  Widget _buildCard({
    required double top,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
  }) {
    return Positioned(
      left: 16,
      top: top,
      child: Container(
        width: 396,
        height: 102,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
        decoration: BoxDecoration(
          color: _cardBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _primaryText,
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _accentText,
                fontSize: 10,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: _primaryText,
                  fontSize: 9,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    bool active = false,
    VoidCallback? onTap,
  }) {
    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.white),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    return Expanded(
      child: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: active
                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 5)
                : EdgeInsets.zero,
            decoration: active
                ? BoxDecoration(
                    color: _activeOrange,
                    borderRadius: BorderRadius.circular(10),
                  )
                : null,
            child: content,
          ),
        ),
      ),
    );
  }
}
