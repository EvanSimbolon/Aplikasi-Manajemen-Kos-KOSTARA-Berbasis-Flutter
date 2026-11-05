import 'package:flutter/material.dart';

import 'package:belajar_dart/routing/app_routes.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const Color _background = Color(0xFFFFF7D4);
  static const Color _primaryText = Color(0xFF4C3D3D);
  static const Color _mutedText = Color(0xFF8A7C6B);
  static const Color _cardBackground = Color(0xFFF8EBD2);
  static const Color _cardBorder = Color(0xFFD1BC96);
  static const Color _activeOrange = Color(0xFFF5A623);
  static const Color _navBorder = Color(0xFF303030);
  static const Color _activeBadgeBackground = Color(0xFFDCE9D4);
  static const Color _activeBadgeText = Color(0xFF557A45);

  static const TextStyle _headingStyle = TextStyle(
    color: _primaryText,
    fontSize: 32,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
  );

  static const TextStyle _subheadingStyle = TextStyle(
    color: _mutedText,
    fontSize: 15,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
  );

  static const TextStyle _sectionTitleStyle = TextStyle(
    color: _primaryText,
    fontSize: 20,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
  );

  static const TextStyle _cardTextStyle = TextStyle(
    color: _primaryText,
    fontSize: 9,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
  );

  static const TextStyle _whiteSmallStyle = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
  );

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
                const Positioned(
                  left: 28,
                  top: 43,
                  child: Text('HALO Penghuni', style: _headingStyle),
                ),
                const Positioned(
                  left: 28,
                  top: 80,
                  child: Text(
                    'Selamat datang kembali !',
                    style: _subheadingStyle,
                  ),
                ),
                const Positioned(
                  left: 361,
                  top: 49,
                  child: SizedBox(
                    width: 31,
                    height: 31,
                    child: Icon(
                      Icons.notifications,
                      size: 28,
                      color: _primaryText,
                    ),
                  ),
                ),
                _buildBillCard(context),
                const Positioned(
                  left: 28,
                  top: 306,
                  child: Text('Kamar Saya', style: _sectionTitleStyle),
                ),
                _buildRoomCard(),
                const Positioned(
                  left: 45,
                  top: 528,
                  child: Text(
                    'Kamar A01',
                    style: TextStyle(
                      color: Color(0xFF382017),
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Positioned(
                  left: 45,
                  top: 550,
                  child: Text(
                    'Wi-Fi · AC · Kamar mandi dalam',
                    style: TextStyle(
                      color: Color(0xFF927B6B),
                      fontSize: 11,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Positioned(
                  left: 335,
                  top: 532,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _activeBadgeBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Aktif',
                      style: TextStyle(
                        color: _activeBadgeText,
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 32,
                  top: 572,
                  child: Text('Jadwal Terdekat', style: _sectionTitleStyle),
                ),
                _buildScheduleCard(
                  left: 30,
                  top: 606,
                  icon: Icons.notifications_active,
                  date: '15 April 2026',
                  title: 'Jatuh Tempo Pembayaran',
                ),
                _buildScheduleCard(
                  left: 27,
                  top: 669,
                  icon: Icons.ac_unit,
                  date: '21 April 2026',
                  title: 'Jadwal Cuci AC',
                ),
                const Positioned(
                  left: 32,
                  top: 750,
                  child: Text('Aktivitas Terbaru', style: _sectionTitleStyle),
                ),
                _buildActivityCard(),
                _buildBottomNav(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillCard(BuildContext context) {
    return Positioned(
      left: 16,
      top: 113,
      child: Container(
        width: 396,
        height: 176,
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD98A2E), Color(0xFF6E4426)],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tagihan Bulan ini',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _whiteSmallStyle,
            ),
            const SizedBox(height: 4),
            const Text(
              'Rp 1.000.000',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                height: 1.05,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Jatuh Tempo : 15 April 2026',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _whiteSmallStyle,
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.tenantBuktiPembayaran,
              ),
              child: Container(
                width: 180,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Bayar Sekarang',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFFF7F7F7),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard() {
    return Positioned(
      left: 28,
      top: 337,
      child: SizedBox(
        width: 353,
        height: 176,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/kamar_1_2.jpg',
            fit: BoxFit.cover,
            errorBuilder: _buildRoomImageFallback,
          ),
        ),
      ),
    );
  }

  static Widget _buildRoomImageFallback(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return Container(
      color: const Color(0xFFE8DCC8),
      child: const Icon(Icons.bed, size: 48, color: _primaryText),
    );
  }

  Widget _buildScheduleCard({
    required double left,
    required double top,
    required IconData icon,
    required String date,
    required String title,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 375,
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 17),
        decoration: BoxDecoration(
          color: _cardBackground,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: _primaryText),
            const SizedBox(width: 6),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: _cardTextStyle),
                Text(title, style: _cardTextStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard() {
    return Positioned(
      left: 24,
      top: 785,
      child: Container(
        width: 375,
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 17),
        decoration: BoxDecoration(
          color: _cardBackground,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.report_problem_outlined,
              size: 24,
              color: _primaryText,
            ),
            const SizedBox(width: 6),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Laporan Kerusakan Lampu', style: _cardTextStyle),
                Text('21 Maret 2026', style: _cardTextStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Positioned(
      left: 17,
      top: 863,
      child: Container(
        width: 401,
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
              active: true,
              onTap: () => Navigator.of(context).popUntil(
                (route) => route.isFirst,
              ),
            ),
            _buildNavItem(
              icon: Icons.credit_card,
              label: 'Pembayaran',
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.kalender,
              ),
            ),
            _buildNavItem(
              icon: Icons.report_problem_outlined,
              label: 'Keluhan',
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.tenantKeluhan,
              ),
            ),
            _buildNavItem(
              icon: Icons.history,
              label: 'Riwayat',
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.tenantRiwayat,
              ),
            ),
            _buildNavItem(
              icon: Icons.person,
              label: 'Profil',
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.tenantProfil,
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
