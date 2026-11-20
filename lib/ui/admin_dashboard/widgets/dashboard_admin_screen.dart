import 'dart:async';

import 'package:flutter/material.dart';

import 'package:belajar_dart/routing/app_routes.dart';
import 'package:belajar_dart/ui/core/themes/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() =>
      _DashboardAdminScreenState();
}

class _DashboardAdminScreenState
    extends State<DashboardAdminScreen> {
  int _selectedIndex = 0;

  final supabase = Supabase.instance.client;

  int totalPenghuni = 0;
  double totalPembayaran = 0; // pembayaran terverifikasi bulan ini
  double totalMenunggu = 0; // pembayaran menunggu verifikasi bulan ini
  bool loadingPenghuni = true;
  bool loadingPembayaran = true;
  String? pesanError;

  StreamSubscription<List<Map<String, dynamic>>>? _penghuniSub;
  StreamSubscription<List<Map<String, dynamic>>>? _pembayaranSub;

  @override
  void initState() {
    super.initState();
    debugPrint('DASH: initState versi baru jalan');
    _muatAwal();
    _listenPenghuni();
    _listenPembayaran();
  }

  @override
  void dispose() {
    _penghuniSub?.cancel();
    _pembayaranSub?.cancel();
    super.dispose();
  }

  /// Penghuni dihitung jika status 'aktif', atau 'menunggu_mulai'
  /// tetapi tanggal_mulai sudah tiba/lewat. Dihitung unik per penghuni_id.
  void _hitungPenghuni(List<Map<String, dynamic>> rows) {
    final now = DateTime.now();
    final hariIni = DateTime(now.year, now.month, now.day);

    final unik = rows.where((r) {
      final status = r['status'];
      if (status == 'aktif') return true;

      if (status == 'menunggu_mulai') {
        final mulai = DateTime.tryParse(r['tanggal_mulai']?.toString() ?? '');
        return mulai != null && !mulai.isAfter(hariIni);
      }
      return false;
    }).map((r) => r['penghuni_id']).toSet();

    if (!mounted) return;
    setState(() {
      totalPenghuni = unik.length;
      loadingPenghuni = false;
    });
  }

  /// Ringkasan pembayaran bulan ini (terverifikasi & menunggu verifikasi)
  void _hitungPembayaran(List<Map<String, dynamic>> rows) {
    final now = DateTime.now();
    final awalBulan = DateTime(now.year, now.month, 1);
    final awalBulanDepan = DateTime(now.year, now.month + 1, 1);

    double verifikasi = 0;
    double menunggu = 0;

    for (final row in rows) {
      final dibayar =
      DateTime.tryParse(row['dibayar_pada']?.toString() ?? '')?.toLocal();
      if (dibayar == null ||
          dibayar.isBefore(awalBulan) ||
          !dibayar.isBefore(awalBulanDepan)) {
        continue;
      }

      final jumlah = double.tryParse(row['jumlah_pembayaran'].toString()) ?? 0;

      if (row['status'] == 'terverifikasi') {
        verifikasi += jumlah;
      } else if (row['status'] == 'menunggu_verifikasi') {
        menunggu += jumlah;
      }
    }

    if (!mounted) return;
    setState(() {
      totalPembayaran = verifikasi;
      totalMenunggu = menunggu;
      loadingPembayaran = false;
    });
  }

  /// Pengambilan data awal (select biasa) -> tetap jalan walau realtime gagal
  Future<void> _muatAwal() async {
    try {
      final data = await supabase.from('penyewaan').select();
      debugPrint('DASH penyewaan select: ${data.length} baris');
      _hitungPenghuni(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint('DASH penyewaan select ERROR: $e');
      if (!mounted) return;
      setState(() {
        loadingPenghuni = false;
        pesanError = 'penyewaan: $e';
      });
    }

    try {
      final data = await supabase.from('pembayaran').select();
      debugPrint('DASH pembayaran select: ${data.length} baris');
      _hitungPembayaran(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      debugPrint('DASH pembayaran select ERROR: $e');
      if (!mounted) return;
      setState(() {
        loadingPembayaran = false;
        pesanError = 'pembayaran: $e';
      });
    }
  }

  /// Realtime penyewaan
  void _listenPenghuni() {
    _penghuniSub =
        supabase.from('penyewaan').stream(primaryKey: ['id']).listen(
              (rows) {
            debugPrint('DASH penyewaan stream: ${rows.length} baris');
            _hitungPenghuni(rows);
          },
          onError: (e) => debugPrint('DASH penyewaan stream ERROR: $e'),
        );
  }

  /// Realtime pembayaran
  void _listenPembayaran() {
    _pembayaranSub =
        supabase.from('pembayaran').stream(primaryKey: ['id']).listen(
              (rows) {
            debugPrint('DASH pembayaran stream: ${rows.length} baris');
            _hitungPembayaran(rows);
          },
          onError: (e) => debugPrint('DASH pembayaran stream ERROR: $e'),
        );
  }

  /// 1200000 -> "Rp 1.200.000"
  String _formatRupiah(double nilai) {
    final angka = nilai.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => '.',
    );
    return 'Rp $angka';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7D4),

      body: SafeArea(
        child: Column(
          children: [
            // =========================
            // HEADER
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                24,
                28,
                24,
                30,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF753924),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: const Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'HALO ADMIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Kelola Kostara dengan mudah',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // =========================
            // ISI DASHBOARD
            // =========================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
              if (pesanError != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Gagal memuat data -> $pesanError',
                  style: const TextStyle(color: Colors.red, fontSize: 11),
                ),
              ],
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
                    // =========================
                    // TOTAL PENGHUNI
                    // =========================
                    Container(
                      width: double.infinity,
                      padding:
                      const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(20),
                        border: Border.all(
                          color:
                          const Color(0xFFE5DECD),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration:
                            BoxDecoration(
                              color:
                              const Color(
                                0xFFF3E7CF,
                              ),
                              borderRadius:
                              BorderRadius
                                  .circular(16),
                            ),
                            child: const Icon(
                              Icons.people_alt_rounded,
                              color:
                              Color(0xFFB57514),
                              size: 30,
                            ),
                          ),

                          const SizedBox(width: 16),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  'Total Penghuni',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                    Colors.black54,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '24 Orang',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight:
                                    FontWeight.bold,
                                    color:
                                    Color(
                                      0xFF753924,
                                    ),
                                  ),
                                ),
                              ],
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                loadingPenghuni ? '...' : '$totalPenghuni ',
                                style: const TextStyle(
                                  color: Color(0xFF2B1810),
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Text(
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
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
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =========================
                    // RINGKASAN BULAN INI
                    // =========================
                    const Text(
                      'Ringkasan Bulan Ini',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color:
                        Color(0xFF753924),
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
                              child: const Icon(Icons.image,
                                  color: Colors.white54, size: 36),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child:
                          _buildSummaryCard(
                            icon: Icons
                                .payments_rounded,
                            title: 'Pembayaran',
                            value: '18',
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child:
                          _buildSummaryCard(
                            icon: Icons
                                .meeting_room_rounded,
                            title: 'Kamar Terisi',
                            value: '18',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // =========================
                    // MENU CEPAT
                    // =========================
                    const Text(
                      'Menu Cepat',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color:
                        Color(0xFF753924),
                      ),
                    ),

                    const SizedBox(height: 12),

                    GridView.count(
                      shrinkWrap: true,
                      physics:
                      const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.35,
                      children: [
                        // =========================
                        // KAMAR TERSEDIA
                        // =========================
                        _buildMenuItem(
                          Icons
                              .meeting_room_rounded,
                          'Kamar Tersedia',
                              () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.dataKamar,
                            );
                          },
                        ),

                        // =========================
                        // KAMAR TERISI
                        // =========================
                        _buildMenuItem(
                          Icons.home_rounded,
                          'Kamar Terisi',
                              () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.dataKamar,
                            );
                          },
                        ),

                        // =========================
                        // BELUM DIBAYAR
                        // =========================
                        _buildMenuItem(
                          Icons
                              .account_balance_wallet_rounded,
                          'Belum Dibayar',
                              () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes
                                  .dataPembayaran,
                            );
                          },
                        ),

                        // =========================
                        // KAMAR
                        // =========================
                        _buildMenuItem(
                          Icons
                              .meeting_room_outlined,
                          'Kamar',
                              () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.dataKamar,
                            );
                          },
                        ),

                        // =========================
                        // KALENDER
                        // =========================
                        _buildMenuItem(
                          Icons
                              .calendar_month_rounded,
                          'Kalender',
                              () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.kalender,
                            );
                          },
                        ),

                        // =========================
                        // PENGHUNI
                        // =========================
                        _buildMenuItem(
                          Icons.people_alt_rounded,
                          'Penghuni',
                              () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes
                                  .dataPenghuni,
                            );
                          },
                        ),

                        // =========================
                        // RIWAYAT PEMBAYARAN
                        // =========================
                        _buildMenuItem(
                          Icons.history_rounded,
                          'Riwayat Pembayaran',
                              () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes
                                  .dataPembayaran,
                            );
                          },
                        ),

                        // =========================
                        // MAINTENANCE
                        // =========================
                        _buildMenuItem(
                          Icons.build_rounded,
                          'Maintenance',
                              () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.maintenance,
                            );
                          },
                        ),

                        // =========================
                        // FASILITAS KAMAR
                        // =========================
                        _buildMenuItem(
                          Icons
                              .home_repair_service_outlined,
                          'Fasilitas Kamar',
                              () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes
                                  .dataFasilitasKamar,
                            );
                          },
                        ),
                      ],
                      'Ringkasan bulan ini',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppTheme.primaryDark),
                    ),
                    const SizedBox(height: 2),
                    const Text('Pembayaran masuk',
                        style: TextStyle(fontSize: 11, color: Colors.black54)),
                    Text(
                      loadingPembayaran
                          ? 'Memuat...'
                          : _formatRupiah(totalPembayaran),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB54F00),
                      ),
                    ),
                    if (!loadingPembayaran && totalMenunggu > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Menunggu verifikasi: ${_formatRupiah(totalMenunggu)}',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black54),
                      ),
                    ],
                    const SizedBox(height: 10),
                    CustomPaint(
                      size: const Size(double.infinity, 25),
                      painter: WavePainter(),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // =========================
      // BOTTOM NAVIGATION
      // =========================
      bottomNavigationBar:
      BottomNavigationBar(
        currentIndex: _selectedIndex,
        type:
        BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor:
        const Color(0xFF753924),
        unselectedItemColor:
        Colors.grey,

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 1) {
            Navigator.pushNamed(
              context,
              AppRoutes.dataKamar,
            );
          }

          if (index == 2) {
            Navigator.pushNamed(
              context,
              AppRoutes.dataPembayaran,
            );
          }

          if (index == 3) {
            Navigator.pushNamed(
              context,
              AppRoutes.maintenance,
            );
          }

          if (index == 4) {
            Navigator.pushNamed(
              context,
              AppRoutes.profil,
            );
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_rounded,
            ),
            label: 'Beranda',
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
                  _buildMenuItem(
                    Icons.credit_card_rounded,
                    'Belum Dibayar',
                        () =>
                        Navigator.pushNamed(context, AppRoutes.dataPembayaran),
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
                        () =>
                        Navigator.pushNamed(context, AppRoutes.dataPembayaran),
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

          BottomNavigationBarItem(
            icon: Icon(
              Icons.meeting_room_rounded,
            ),
            label: 'Kamar',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.payments_rounded,
            ),
            label: 'Pembayaran',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.build_rounded,
            ),
            label: 'Maintenance',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_rounded,
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // =========================
  // SUMMARY CARD
  // =========================
  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5DECD),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFFB57514),
            size: 28,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF753924),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // MENU ITEM
  // =========================
  Widget _buildMenuItem(
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE5DECD),
          ),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color:
                const Color(0xFFF3E7CF),
                borderRadius:
                BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color:
                const Color(0xFFB57514),
                size: 24,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              maxLines: 2,
              overflow:
              TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight:
                FontWeight.bold,
                color:
                Color(0xFF261914),
              ),
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
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.1,
        size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.9, size.width, size.height * 0.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}