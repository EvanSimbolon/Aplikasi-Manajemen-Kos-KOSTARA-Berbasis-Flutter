import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:belajar_dart/data/services/supabase_service.dart';
import 'package:belajar_dart/routing/app_routes.dart';
import 'package:belajar_dart/ui/core/ui/floating_bottom_nav.dart';
import 'package:belajar_dart/utils/formatters.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color _background = Color(0xFFFFF7D4);
  static const Color _primaryText = Color(0xFF4C3D3D);
  static const Color _mutedText = Color(0xFF8A7C6B);
  static const Color _cardBackground = Color(0xFFFFFBF3);
  static const Color _cardBorder = Color(0xFFDEC9A4);
  static const Color _activeBadgeBackground = Color(0xFFDCE9D4);
  static const Color _activeBadgeText = Color(0xFF2E6B3E);

  int _selectedIndex = 0;

  String _namaPenghuni = 'Penghuni';
  String _nominalTagihan = 'Rp 0';
  String _jatuhTempoText = 'Tidak ada tagihan aktif';
  String _nomorKamar = '-';
  List<String> _fasilitasChips = const [];
  String? _fotoKamarUrl;
  String _statusSewa = 'Aktif';

  String _jadwalBayarDate = '-';
  String _jadwalBayarTitle = 'Belum ada jatuh tempo';
  String _jadwalMaintDate = '-';
  String _jadwalMaintTitle = 'Belum ada jadwal maintenance';

  String _aktivitasTitle = 'Belum ada laporan keluhan';
  String _aktivitasDate = '-';
  String? _aktivitasStatus;

  @override
  void initState() {
    super.initState();
    _muatDataDashboard();
  }

  Future<void> _muatDataDashboard() async {
    if (!SupabaseService.isAvailable || !SupabaseService.isAuthenticated) {
      return;
    }

    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Nama penghuni
      final pengguna = await client
          .from('pengguna')
          .select('nama_lengkap')
          .eq('id', user.id)
          .maybeSingle();

      final nama = (pengguna?['nama_lengkap']?.toString() ?? '').trim();

      // 2. Penyewaan aktif + kamar (beserta kos_id & foto_url)
      Map<String, dynamic>? penyewaan;
      try {
        penyewaan = await client
            .from('penyewaan')
            .select(
              'id, status, tanggal_mulai, harga_sewa_disepakati, '
              'kamar!inner ( id, kos_id, nomor_kamar, foto_url, '
              'fasilitas_kamar ( jenis_fasilitas ( nama_fasilitas ) ) )',
            )
            .eq('penghuni_id', user.id)
            .inFilter('status', ['aktif', 'menunggu_mulai'])
            .order('tanggal_mulai', ascending: false)
            .limit(1)
            .maybeSingle();
      } catch (_) {
        penyewaan = await client
            .from('penyewaan')
            .select(
              'id, status, tanggal_mulai, harga_sewa_disepakati, '
              'kamar!inner ( id, kos_id, nomor_kamar, '
              'fasilitas_kamar ( jenis_fasilitas ( nama_fasilitas ) ) )',
            )
            .eq('penghuni_id', user.id)
            .inFilter('status', ['aktif', 'menunggu_mulai'])
            .order('tanggal_mulai', ascending: false)
            .limit(1)
            .maybeSingle();
      }

      String nomorKamar = '-';
      List<String> fasilitasChips = const [];
      String? fotoKamarUrl;
      String statusSewa = 'Aktif';
      String nominalTagihan = 'Rp 0';
      String jatuhTempoText = 'Tidak ada tagihan aktif';
      String jadwalBayarDate = '-';
      String jadwalBayarTitle = 'Belum ada jatuh tempo';
      String? kosId;

      if (penyewaan != null) {
        final penyewaanId = penyewaan['id']?.toString();
        statusSewa = penyewaan['status'] == 'menunggu_mulai'
            ? 'Menunggu'
            : 'Aktif';
        final kamar = penyewaan['kamar'] as Map<String, dynamic>?;
        nomorKamar = kamar?['nomor_kamar']?.toString() ?? '-';
        fotoKamarUrl = kamar?['foto_url']?.toString();
        kosId = kamar?['kos_id']?.toString();

        final fkList = kamar?['fasilitas_kamar'] as List<dynamic>? ?? const [];
        fasilitasChips = fkList
            .map((e) => (e as Map?)?['jenis_fasilitas']?['nama_fasilitas'])
            .where((n) => n != null && n.toString().trim().isNotEmpty)
            .map((n) => n.toString())
            .toList();

        // 3. Tagihan belum dibayar milik penyewaan ini
        if (penyewaanId != null) {
          final tagihan = await client
              .from('tagihan')
              .select('id, tanggal_jatuh_tempo, jumlah_tagihan, status')
              .eq('penyewaan_id', penyewaanId)
              .inFilter('status', ['belum_bayar', 'terlambat'])
              .order('tanggal_jatuh_tempo', ascending: true)
              .limit(1)
              .maybeSingle();

          if (tagihan != null) {
            final jumlah = Formatters.toNumber(tagihan['jumlah_tagihan']);
            final jt = Formatters.parseDate(tagihan['tanggal_jatuh_tempo']);
            nominalTagihan = Formatters.rupiah(jumlah);
            jatuhTempoText = jt == null
                ? 'Jatuh Tempo: -'
                : 'Jatuh Tempo: ${Formatters.tanggalPanjang(jt)}';
            jadwalBayarDate = jt == null ? '-' : Formatters.tanggalPanjang(jt);
            jadwalBayarTitle = 'Jatuh Tempo Pembayaran';
          } else {
            final hargaSewa = Formatters.toNumber(
              penyewaan['harga_sewa_disepakati'],
            );
            final mulai = Formatters.parseDate(penyewaan['tanggal_mulai']);
            nominalTagihan = Formatters.rupiah(hargaSewa);
            jatuhTempoText = mulai == null
                ? 'Status: Lunas / Belum ada tagihan'
                : 'Mulai Sewa: ${Formatters.tanggalPanjang(mulai)}';
            jadwalBayarDate =
                mulai == null ? '-' : Formatters.tanggalPanjang(mulai);
            jadwalBayarTitle = 'Awal Sewa Kamar $nomorKamar';
          }
        }
      }

      // 4. Maintenance terdekat untuk kos_id terkait
      String jadwalMaintDate = '-';
      String jadwalMaintTitle = 'Belum ada jadwal maintenance';
      try {
        var maintQuery = client
            .from('maintenance')
            .select(
              'tanggal_perawatan, jenis_perawatan, kamar!inner(nomor_kamar, kos_id)',
            );
        if (kosId != null) {
          maintQuery = maintQuery.eq('kamar.kos_id', kosId);
        }
        final maint = await maintQuery
            .order('tanggal_perawatan', ascending: false)
            .limit(1)
            .maybeSingle();

        if (maint != null) {
          final tgl = Formatters.parseDate(maint['tanggal_perawatan']);
          final km = (maint['kamar'] as Map?)?['nomor_kamar']?.toString();
          final jenis = maint['jenis_perawatan']?.toString() ?? 'Maintenance';
          jadwalMaintDate = tgl == null ? '-' : Formatters.tanggalPanjang(tgl);
          jadwalMaintTitle = km != null ? '$jenis • Kamar $km' : jenis;
        }
      } catch (e) {
        debugPrint('Dashboard maintenance fetch: $e');
      }

      // 5. Aktivitas terbaru (keluhan terbaru penghuni)
      String aktivitasTitle = 'Belum ada laporan keluhan';
      String aktivitasDate = '-';
      String? aktivitasStatus;
      try {
        final keluhan = await client
            .from('laporan_kerusakan')
            .select('judul, dilaporkan_pada, status')
            .eq('pelapor_id', user.id)
            .order('dilaporkan_pada', ascending: false)
            .limit(1)
            .maybeSingle();
        if (keluhan != null) {
          final tgl = Formatters.parseDate(keluhan['dilaporkan_pada']);
          aktivitasTitle = keluhan['judul']?.toString() ?? 'Laporan Keluhan';
          aktivitasDate = tgl == null ? '-' : Formatters.tanggalPanjang(tgl);
          aktivitasStatus = keluhan['status']?.toString();
        }
      } catch (e) {
        debugPrint('Dashboard keluhan fetch: $e');
      }

      if (!mounted) return;
      setState(() {
        _namaPenghuni = nama.isNotEmpty ? nama.split(' ').first : 'Penghuni';
        _nominalTagihan = nominalTagihan;
        _jatuhTempoText = jatuhTempoText;
        _nomorKamar = nomorKamar;
        _fasilitasChips = fasilitasChips;
        _fotoKamarUrl = fotoKamarUrl;
        _statusSewa = statusSewa;
        _jadwalBayarDate = jadwalBayarDate;
        _jadwalBayarTitle = jadwalBayarTitle;
        _jadwalMaintDate = jadwalMaintDate;
        _jadwalMaintTitle = jadwalMaintTitle;
        _aktivitasTitle = aktivitasTitle;
        _aktivitasDate = aktivitasDate;
        _aktivitasStatus = aktivitasStatus;
      });
    } catch (e) {
      debugPrint('DashboardPage._muatDataDashboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF854836),
          onRefresh: _muatDataDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Sambutan
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, $_namaPenghuni',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _primaryText,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Selamat datang kembali di KOSTARA',
                            style: TextStyle(
                              color: _mutedText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.kalender),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _cardBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _cardBorder),
                        ),
                        child: const Icon(
                          Icons.notifications_rounded,
                          size: 24,
                          color: _primaryText,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Kartu Tagihan Bulan Ini
                _buildBillCard(context),

                const SizedBox(height: 22),

                // Bagian Kamar Saya
                const Text(
                  'Kamar Saya',
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                _buildRoomCard(),

                const SizedBox(height: 22),

                // Bagian Jadwal Terdekat
                Row(
                  children: [
                    const Text(
                      'Jadwal Terdekat',
                      style: TextStyle(
                        color: _primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.kalender),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF854836),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 28),
                      ),
                      child: const Text(
                        'Lihat Kalender',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildScheduleCard(
                  icon: Icons.event_available_rounded,
                  iconBg: const Color(0xFFFFE3E1),
                  iconColor: const Color(0xFFC64A4A),
                  date: _jadwalBayarDate,
                  title: _jadwalBayarTitle,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.kalender),
                ),
                const SizedBox(height: 10),
                _buildScheduleCard(
                  icon: Icons.handyman_rounded,
                  iconBg: const Color(0xFFDCE9D4),
                  iconColor: const Color(0xFF2E6B3E),
                  date: _jadwalMaintDate,
                  title: _jadwalMaintTitle,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.kalender),
                ),

                const SizedBox(height: 22),

                // Bagian Aktivitas Terbaru
                const Text(
                  'Aktivitas Terbaru',
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                _buildActivityCard(context),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: FloatingBottomNav(
        selectedIndex: _selectedIndex,
        items: const [
          FloatingNavItem(icon: Icons.home_rounded, label: 'Beranda'),
          FloatingNavItem(icon: Icons.calendar_month_rounded, label: 'Kalender'),
          FloatingNavItem(icon: Icons.report_problem_rounded, label: 'Keluhan'),
          FloatingNavItem(icon: Icons.history_rounded, label: 'Riwayat'),
          FloatingNavItem(icon: Icons.person_rounded, label: 'Profil'),
        ],
        onTap: (index) async {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 1:
              await Navigator.of(context).pushNamed(AppRoutes.kalender);
              break;
            case 2:
              await Navigator.of(context).pushNamed(AppRoutes.tenantKeluhan);
              break;
            case 3:
              await Navigator.of(context).pushNamed(AppRoutes.tenantRiwayat);
              break;
            case 4:
              await Navigator.of(context).pushNamed(AppRoutes.tenantProfil);
              break;
          }
          if (mounted) {
            setState(() => _selectedIndex = 0);
            _muatDataDashboard();
          }
        },
      ),
    );
  }

  Widget _buildBillCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE88D1E), Color(0xFF733C24)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF733C24).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Tagihan Bulan Ini',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Kamar $_nomorKamar',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _nominalTagihan,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _jatuhTempoText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).pushNamed(
                  AppRoutes.tenantBuktiPembayaran,
                );
                if (mounted) _muatDataDashboard();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B1810),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.payment_rounded, size: 18),
              label: const Text(
                'Bayar Sekarang',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _fotoKamarUrl != null && _fotoKamarUrl!.isNotEmpty
                    ? Image.network(
                        _fotoKamarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: _buildRoomImageFallback,
                      )
                    : Image.asset(
                        'assets/kamar_1_2.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: _buildRoomImageFallback,
                      ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _activeBadgeBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusSewa,
                    style: const TextStyle(
                      color: _activeBadgeText,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kamar $_nomorKamar',
                  style: const TextStyle(
                    color: Color(0xFF382017),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                if (_fasilitasChips.isEmpty)
                  const Text(
                    'Belum ada fasilitas terdaftar',
                    style: TextStyle(color: _mutedText, fontSize: 12),
                  )
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _fasilitasChips
                        .map(
                          (f) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7EEDD),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _cardBorder.withValues(alpha: 0.7),
                              ),
                            ),
                            child: Text(
                              f,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _primaryText,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
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
      alignment: Alignment.center,
      child: const Icon(Icons.bed_rounded, size: 48, color: _primaryText),
    );
  }

  Widget _buildScheduleCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String date,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _primaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _mutedText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: _mutedText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Navigator.of(context).pushNamed(AppRoutes.tenantKeluhan);
        if (mounted) _muatDataDashboard();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0C2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.report_problem_rounded,
                size: 22,
                color: Color(0xFFB54F00),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _aktivitasTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _primaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _aktivitasDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _mutedText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (_aktivitasStatus != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EEDD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _aktivitasStatus!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _primaryText,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
