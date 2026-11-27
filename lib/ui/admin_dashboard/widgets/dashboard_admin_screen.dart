import 'dart:async';

import 'package:flutter/material.dart';
import 'package:belajar_dart/data/services/notification_service.dart';
import 'package:belajar_dart/routing/app_routes.dart';
import 'package:belajar_dart/ui/core/themes/app_theme.dart';
import 'package:belajar_dart/ui/core/ui/floating_bottom_nav.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  int _selectedIndex = 0;

  final supabase = Supabase.instance.client;

  int totalPenghuni = 0;
  double totalPembayaran = 0; // pembayaran terverifikasi bulan ini
  double totalMenunggu = 0; // pembayaran menunggu verifikasi bulan ini
  int jumlahMenunggu = 0; // jumlah request pembayaran menunggu verifikasi
  List<Map<String, dynamic>> daftarMenunggu = [];
  bool loadingPenghuni = true;
  bool loadingPembayaran = true;
  String? pesanError;

  StreamSubscription<List<Map<String, dynamic>>>? _penghuniSub;
  StreamSubscription<List<Map<String, dynamic>>>? _pembayaranSub;

  @override
  void initState() {
    super.initState();
    debugPrint('DASH: initState versi baru jalan');
    final user = supabase.auth.currentUser;
    if (user != null) {
      NotificationService().listenToNotifikasi(user.id);
    }
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
    final pendingList = <Map<String, dynamic>>[];

    for (final row in rows) {
      final status = row['status']?.toString();
      if (status == 'menunggu_verifikasi') {
        pendingList.add(row);
      }

      final dibayar = DateTime.tryParse(
        row['dibayar_pada']?.toString() ?? '',
      )?.toLocal();
      if (dibayar == null ||
          dibayar.isBefore(awalBulan) ||
          !dibayar.isBefore(awalBulanDepan)) {
        continue;
      }

      final jumlah = double.tryParse(row['jumlah_pembayaran'].toString()) ?? 0;

      if (status == 'terverifikasi') {
        verifikasi += jumlah;
      } else if (status == 'menunggu_verifikasi') {
        menunggu += jumlah;
      }
    }

    if (!mounted) return;
    setState(() {
      totalPembayaran = verifikasi;
      totalMenunggu = menunggu;
      jumlahMenunggu = pendingList.length;
      daftarMenunggu = pendingList;
      loadingPembayaran = false;
    });
  }

  /// Mengambil daftar kos_id yang dimiliki oleh admin/pemilik yang sedang login.
  Future<List<String>> _ambilKosIdsPemilik() async {
    final user = supabase.auth.currentUser;
    if (user == null) return const [];

    final ids = <String>{};
    try {
      final kosList = await supabase
          .from('kos')
          .select('id')
          .eq('pemilik_id', user.id);
      for (final r in kosList) {
        if (r['id'] != null) ids.add(r['id'].toString());
      }
    } catch (_) {}

    try {
      final anggota = await supabase
          .from('anggota_kos')
          .select('kos_id')
          .eq('pengguna_id', user.id)
          .eq('peran', 'pemilik')
          .eq('status', 'aktif');
      for (final r in anggota) {
        if (r['kos_id'] != null) ids.add(r['kos_id'].toString());
      }
    } catch (_) {}

    return ids.toList();
  }

  /// Pengambilan data awal (select biasa) sesuai kos_id pemilik -> tetap jalan walau realtime gagal
  Future<void> _muatAwal() async {
    final kosIds = await _ambilKosIdsPemilik();

    try {
      final query = supabase
          .from('penyewaan')
          .select('id, penghuni_id, status, tanggal_mulai, tanggal_selesai, kamar!inner ( kos_id )');
      final data = kosIds.isNotEmpty
          ? await query.inFilter('kamar.kos_id', kosIds)
          : await query;
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
      final raw = await supabase
          .from('pembayaran')
          .select(
            'id, jumlah_pembayaran, dibayar_pada, status, '
            'pengguna!pembayaran_pembayar_id_fkey ( nama_lengkap ), '
            'tagihan ( penyewaan ( kamar ( nomor_kamar, kos_id ) ) )',
          )
          .order('dibayar_pada', ascending: false);

      final kosSet = kosIds.toSet();
      final filtered = List<Map<String, dynamic>>.from(raw).where((row) {
        if (kosSet.isEmpty) return true;
        final kamar =
            ((row['tagihan'] as Map?)?['penyewaan'] as Map?)?['kamar'] as Map?;
        final kosId = kamar?['kos_id']?.toString();
        return kosId == null || kosSet.contains(kosId);
      }).toList();

      debugPrint('DASH pembayaran select: ${filtered.length} baris');
      _hitungPembayaran(filtered);
    } catch (e) {
      debugPrint('DASH pembayaran select ERROR: $e');
      if (!mounted) return;
      setState(() {
        loadingPembayaran = false;
        pesanError = 'pembayaran: $e';
      });
    }
  }

  /// Realtime penyewaan (re-fetch terfilter kos_id saat ada perubahan)
  void _listenPenghuni() {
    _penghuniSub =
        supabase.from('penyewaan').stream(primaryKey: ['id']).listen(
              (_) => _muatAwal(),
          onError: (e) => debugPrint('DASH penyewaan stream ERROR: $e'),
        );
  }

  /// Realtime pembayaran (re-fetch terfilter kos_id saat ada perubahan)
  void _listenPembayaran() {
    _pembayaranSub =
        supabase.from('pembayaran').stream(primaryKey: ['id']).listen(
              (_) => _muatAwal(),
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

  void _tampilkanNotifikasiAdmin() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFFFFBF3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.notifications_active_rounded,
                    color: Color(0xFF854836),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Notifikasi Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A3427),
                    ),
                  ),
                  const Spacer(),
                  if (jumlahMenunggu > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB22C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$jumlahMenunggu Menunggu',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3E2212),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (daftarMenunggu.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'Semua pembayaran sudah diverifikasi.',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: daftarMenunggu.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final row = daftarMenunggu[i];
                      final nama =
                          (row['pengguna'] as Map?)?['nama_lengkap']
                              ?.toString() ??
                          'Penghuni';
                      final kamar =
                          ((row['tagihan'] as Map?)?['penyewaan']
                                  as Map?)?['kamar']?['nomor_kamar']
                              ?.toString() ??
                          '-';
                      final nominal =
                          double.tryParse(
                            row['jumlah_pembayaran'].toString(),
                          ) ??
                          0;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFF0C2),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: Color(0xFF854836),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          '$nama (Kamar $kamar)',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Sudah bayar ${_formatRupiah(nominal)} • Menunggu verifikasi',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.pushNamed(
                            context,
                            AppRoutes.dataPembayaran,
                          ).then((_) => _muatAwal());
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 100.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Admin + Lonceng Notifikasi
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                  ),
                  InkWell(
                    onTap: _tampilkanNotifikasiAdmin,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7EEDD),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD3C3AD)),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(
                            Icons.notifications_rounded,
                            color: Color(0xFF4A3427),
                            size: 24,
                          ),
                          if (jumlahMenunggu > 0)
                            Positioned(
                              right: -5,
                              top: -5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD32F2F),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$jumlahMenunggu',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (!loadingPembayaran && jumlahMenunggu > 0) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.dataPembayaran,
                  ).then((_) => _muatAwal()),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0C2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE88D1E)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_active_rounded,
                          color: Color(0xFFB54F00),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$jumlahMenunggu penghuni sudah bayar dan menunggu verifikasi Anda.',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4A3427),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFFB54F00),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.dataPenghuni,
                            ),
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
                              child: const Icon(Icons.image,
                                  color: Colors.white54, size: 36),
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

              // Grid Menu Cepat (tanpa redundansi)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.6,
                children: [
                  _buildMenuItem(
                    Icons.bed_rounded,
                    'Kelola Kamar',
                    () => Navigator.pushNamed(context, AppRoutes.dataKamar),
                  ),
                  _buildMenuItem(
                    Icons.person_rounded,
                    'Penghuni',
                    () => Navigator.pushNamed(context, AppRoutes.dataPenghuni),
                  ),
                  _buildMenuItem(
                    Icons.credit_card_rounded,
                    'Pembayaran',
                    () =>
                        Navigator.pushNamed(context, AppRoutes.dataPembayaran),
                  ),
                  _buildMenuItem(
                    Icons.handyman_rounded,
                    'Maintenance',
                    () => Navigator.pushNamed(context, AppRoutes.maintenance),
                  ),
                  _buildMenuItem(
                    Icons.calendar_month_rounded,
                    'Kalender',
                    () => Navigator.pushNamed(context, AppRoutes.kalender),
                  ),
                  _buildMenuItem(
                    Icons.report_problem_rounded,
                    'Daftar Keluhan',
                    () => Navigator.pushNamed(context, AppRoutes.adminKeluhan),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // Floating Bottom Navigation Bar seragam
      bottomNavigationBar: FloatingBottomNav(
        selectedIndex: _selectedIndex,
        items: const [
          FloatingNavItem(icon: Icons.home_rounded, label: 'Beranda'),
          FloatingNavItem(icon: Icons.bed_rounded, label: 'Kamar'),
          FloatingNavItem(icon: Icons.credit_card_rounded, label: 'Pembayaran'),
          FloatingNavItem(icon: Icons.handyman_rounded, label: 'Maintenance'),
          FloatingNavItem(icon: Icons.person_rounded, label: 'Profil'),
        ],
        onTap: (index) async {
          setState(() => _selectedIndex = index);
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
            setState(() => _selectedIndex = 0);
            _muatAwal();
          }
        },
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
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.1,
        size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.9, size.width, size.height * 0.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
