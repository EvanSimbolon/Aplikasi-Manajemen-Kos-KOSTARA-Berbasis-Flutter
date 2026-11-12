import 'package:flutter/material.dart';

import 'package:belajar_dart/routing/app_routes.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() =>
      _DashboardAdminScreenState();
}

class _DashboardAdminScreenState
    extends State<DashboardAdminScreen> {
  int _selectedIndex = 0;

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