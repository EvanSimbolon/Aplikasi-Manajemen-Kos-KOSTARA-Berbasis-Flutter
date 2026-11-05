import 'package:flutter/material.dart';

import 'package:belajar_dart/routing/app_routes.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  static const Color _background = Color(0xFFFFF7D4);
  static const Color _headerBrown = Color(0xFF854836);
  static const Color _primaryText = Color(0xFF4C3D3D);
  static const Color _accentText = Color(0xFFC07F00);
  static const Color _cardBackground = Color(0xFFFFFCF5);
  static const Color _cardBorder = Color(0xFFDEC8A3);
  static const Color _avatarBackground = Color(0xFFF3E4D2);
  static const Color _activeOrange = Color(0xFFF5A623);
  static const Color _navBorder = Color(0xFF303030);
  static const Color _logoutRed = Color(0xFFED6969);

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
                    height: 233,
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
                      'Profil',
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
                  left: 29,
                  top: 151,
                  child: Container(
                    width: 367,
                    height: 317,
                    decoration: BoxDecoration(
                      color: _cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _cardBorder),
                    ),
                  ),
                ),
                Positioned(
                  left: 44,
                  top: 194,
                  child: Container(
                    width: 68,
                    height: 68,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _avatarBackground,
                      shape: BoxShape.circle,
                      border: Border.all(color: _accentText, width: 2),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 38,
                      color: _accentText,
                    ),
                  ),
                ),
                const Positioned(
                  left: 131,
                  top: 212,
                  child: SizedBox(
                    width: 124,
                    height: 20,
                    child: Text(
                      'Dion Prayoga',
                      style: TextStyle(
                        color: _primaryText,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 93,
                  top: 231,
                  child: SizedBox(
                    width: 117,
                    height: 16,
                    child: Text(
                      'Admin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _accentText,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                _buildInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: 'dionprayoga@gmail.com',
                  labelLeft: 80,
                  valueLeft: 218,
                  top: 315,
                ),
                _buildInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'No. Telepon',
                  value: '0811-2233-4455',
                  labelLeft: 79,
                  valueLeft: 262,
                  top: 336,
                ),
                _buildMenuRow(
                  icon: Icons.person_outline,
                  label: 'Ubah Profil',
                  labelLeft: 78,
                  top: 375,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.ubahProfil,
                  ),
                ),
                _buildMenuRow(
                  icon: Icons.settings_outlined,
                  label: 'Pengaturan',
                  labelLeft: 77,
                  top: 405,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.pengaturan,
                  ),
                ),
                Positioned(
                  left: 138,
                  top: 489,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.landing,
                      (route) => false,
                    ),
                    child: Container(
                      width: 150,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _logoutRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Keluar',
                        style: TextStyle(
                          color: _primaryText,
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                _buildBottomNav(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required double labelLeft,
    required double valueLeft,
    required double top,
  }) {
    return Stack(
      children: [
        Positioned(
          left: 46,
          top: top - 1,
          child: Icon(icon, size: 15, color: _primaryText),
        ),
        Positioned(
          left: labelLeft,
          top: top,
          child: Text(
            label,
            style: const TextStyle(
              color: _primaryText,
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Positioned(
          left: valueLeft,
          top: top,
          child: Text(
            value,
            style: const TextStyle(
              color: _primaryText,
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuRow({
    required IconData icon,
    required String label,
    required double labelLeft,
    required double top,
    VoidCallback? onTap,
  }) {
    return Positioned(
      left: 29,
      top: top - 4,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 367,
          height: 30,
          child: Stack(
            children: [
              Positioned(
                left: 17,
                top: 6,
                child: Icon(icon, size: 15, color: _primaryText),
              ),
              Positioned(
                left: labelLeft - 29,
                top: 7,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Positioned(
                right: 12,
                top: 4,
                child: Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: _primaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Positioned(
      left: 16,
      top: 863,
      child: Container(
        width: 395,
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: ShapeDecoration(
          color: Colors.black,
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
              onTap: () => Navigator.of(context).popUntil(
                (route) => route.isFirst,
              ),
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
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.maintenance,
              ),
            ),
            _buildNavItem(
              icon: Icons.person,
              label: 'Profil',
              active: true,
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
