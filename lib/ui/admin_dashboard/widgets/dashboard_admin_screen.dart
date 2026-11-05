import 'package:flutter/material.dart';
import 'package:belajar_dart/routing/app_routes.dart';
import 'package:belajar_dart/ui/core/themes/app_theme.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 100.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Admin
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'HALO ADMIN',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF333333),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Selamat datang kembali !',
                    style: TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Card Total Penghuni
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE88D1E), Color(0xFF733C24)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Penghuni',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: const [
                              Text(
                                '24 ',
                                style: TextStyle(
                                  color: Color(0xFF2B1810),
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'Orang',
                                style: TextStyle(
                                  color: Color(0xFF2B1810),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              'Cek Sekarang',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/kamar_1_2.jpg',
                        width: 135,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/kamar_1_2.png',
                            width: 135,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (context, e, st) => Container(
                              width: 135,
                              height: 110,
                              color: Colors.black26,
                              child: const Icon(Icons.image, color: Colors.white54, size: 36),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Card Ringkasan Bulan ini
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan bulan ini',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.primaryDark),
                    ),
                    const SizedBox(height: 2),
                    const Text('Pembayaran masuk', style: TextStyle(fontSize: 11, color: Colors.black54)),
                    const SizedBox(height: 4),
                    const Text('Rp 18.500.000', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFB54F00))),
                    const SizedBox(height: 10),
                    CustomPaint(
                      size: const Size(double.infinity, 25),
                      painter: WavePainter(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Judul Menu Cepat
              const Text(
                'Menu Cepat',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4A3427),
                ),
              ),
              const SizedBox(height: 14),

              // Grid Menu Cepat
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.6,
                children: [
                  _buildMenuItem(
                    Icons.home_rounded,
                    'Kamar Tersedia',
                    () => Navigator.pushNamed(context, AppRoutes.dataKamar),
                  ),
                  _buildMenuItem(
                    Icons.group_rounded,
                    'Kamar Terisi',
                    () => Navigator.pushNamed(context, AppRoutes.dataKamar),
                  ),

                  // IKON BELUM DIBAYAR DIGANTI SESUAI GAMBAR ACUAN
                  _buildMenuItem(
                    Icons.credit_card_rounded,
                    'Belum Dibayar',
                    () => Navigator.pushNamed(context, AppRoutes.dataPembayaran),
                  ),

                  _buildMenuItem(
                    Icons.add_home_rounded,
                    'Kamar',
                    () => Navigator.pushNamed(context, AppRoutes.dataKamar),
                  ),
                  _buildMenuItem(
                    Icons.calendar_month_rounded,
                    'Kalender',
                    () => Navigator.pushNamed(context, AppRoutes.kalender),
                  ),
                  _buildMenuItem(
                    Icons.person_rounded,
                    'Penghuni',
                    () => Navigator.pushNamed(context, AppRoutes.dataPenghuni),
                  ),
                  _buildMenuItem(
                    Icons.history,
                    'Riwayat Pembayaran',
                    () => Navigator.pushNamed(context, AppRoutes.dataPembayaran),
                  ),
                  _buildMenuItem(
                    Icons.handyman_rounded,
                    'Maintenance',
                    () => Navigator.pushNamed(context, AppRoutes.maintenance),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // Floating Bottom Navigation Bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryDark,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, 'Beranda'),
            _buildNavItem(1, Icons.domain_add_rounded, 'Kamar'),
            _buildNavItem(2, Icons.credit_card_rounded, 'Pembayaran'),
            _buildNavItem(3, Icons.handyman_rounded, 'Maintenance'),
            _buildNavItem(4, Icons.person_rounded, 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () async {
        setState(() {
          _selectedIndex = index;
        });
        switch (index) {
          case 1:
            await Navigator.pushNamed(context, AppRoutes.dataKamar);
            break;
          case 2:
            await Navigator.pushNamed(context, AppRoutes.dataPembayaran);
            break;
          case 3:
            await Navigator.pushNamed(context, AppRoutes.maintenance);
            break;
          case 4:
            await Navigator.pushNamed(context, AppRoutes.profil);
            break;
        }
        if (mounted) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7EEDD),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD3C3AD),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF6B4226),
              size: 38,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A3427),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color(0xFFE88000)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    var path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.1, size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.9, size.width, size.height * 0.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}