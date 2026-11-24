import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:belajar_dart/data/services/supabase_service.dart';
import 'package:belajar_dart/routing/app_routes.dart';
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
  static const Color _cardBackground = Color(0xFFF8EBD2);
  static const Color _cardBorder = Color(0xFFD1BC96);
  static const Color _activeOrange = Color(0xFFF5A623);
  static const Color _navBorder = Color(0xFF303030);
  static const Color _activeBadgeBackground = Color(0xFFDCE9D4);
  static const Color _activeBadgeText = Color(0xFF557A45);

  static const TextStyle _headingStyle = TextStyle(
    color: _primaryText,
    fontSize: 30,
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
    fontSize: 10,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
  );

  static const TextStyle _whiteSmallStyle = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
  );

  String _namaPenghuni = 'Penghuni';
  String _nominalTagihan = 'Rp 0';
  String _jatuhTempoText = 'Tidak ada tagihan aktif';
  String _nomorKamar = '-';
  String _fasilitasText = '-';
  String? _fotoKamarUrl;
  String _statusSewa = 'Aktif';

  String _jadwalBayarDate = '-';
  String _jadwalBayarTitle = 'Belum ada jatuh tempo';
  String _jadwalMaintDate = '-';
  String _jadwalMaintTitle = 'Belum ada jadwal maintenance';

  String _aktivitasTitle = 'Belum ada laporan keluhan';
  String _aktivitasDate = '-';

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
        // Fallback jika kolom foto_url belum ada
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
      String fasilitasText = 'Belum ada fasilitas terdaftar';
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
        final namaFasilitas = fkList
            .map((e) => (e as Map?)?['jenis_fasilitas']?['nama_fasilitas'])
            .where((n) => n != null && n.toString().trim().isNotEmpty)
            .map((n) => n.toString())
            .toList();
        if (namaFasilitas.isNotEmpty) {
          fasilitasText = namaFasilitas.join(' · ');
        }

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
                ? 'Jatuh Tempo : -'
                : 'Jatuh Tempo : ${Formatters.tanggalPanjang(jt)}';
            jadwalBayarDate = jt == null ? '-' : Formatters.tanggalPanjang(jt);
            jadwalBayarTitle = 'Jatuh Tempo Pembayaran';
          } else {
            final hargaSewa = Formatters.toNumber(
              penyewaan['harga_sewa_disepakati'],
            );
            final mulai = Formatters.parseDate(penyewaan['tanggal_mulai']);
            nominalTagihan = Formatters.rupiah(hargaSewa);
            jatuhTempoText = mulai == null
                ? 'Status : Lunas / Belum ada tagihan'
                : 'Mulai Sewa : ${Formatters.tanggalPanjang(mulai)}';
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
          jadwalMaintTitle = km != null ? '$jenis (Kamar $km)' : jenis;
        }
      } catch (e) {
        debugPrint('Dashboard maintenance fetch: $e');
      }

      // 5. Aktivitas terbaru (keluhan terbaru penghuni)
      String aktivitasTitle = 'Belum ada laporan keluhan';
      String aktivitasDate = '-';
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
          aktivitasTitle =
              'Keluhan: ${keluhan['judul'] ?? '-'} (${keluhan['status'] ?? '-'})';
          aktivitasDate = tgl == null ? '-' : Formatters.tanggalPanjang(tgl);
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
        _fasilitasText = fasilitasText;
        _fotoKamarUrl = fotoKamarUrl;
        _statusSewa = statusSewa;
        _jadwalBayarDate = jadwalBayarDate;
        _jadwalBayarTitle = jadwalBayarTitle;
        _jadwalMaintDate = jadwalMaintDate;
        _jadwalMaintTitle = jadwalMaintTitle;
        _aktivitasTitle = aktivitasTitle;
        _aktivitasDate = aktivitasDate;
      });
    } catch (e) {
      debugPrint('DashboardPage._muatDataDashboard: $e');
    }
  }

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
                  left: 28,
                  top: 43,
                  right: 80,
                  child: Text(
                    'HALO $_namaPenghuni',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _headingStyle,
                  ),
                ),
                const Positioned(
                  left: 28,
                  top: 80,
                  child: Text(
                    'Selamat datang kembali !',
                    style: _subheadingStyle,
                  ),
                ),
                Positioned(
                  left: 361,
                  top: 49,
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.kalender),
                    child: const SizedBox(
                      width: 31,
                      height: 31,
                      child: Icon(
                        Icons.notifications,
                        size: 28,
                        color: _primaryText,
                      ),
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
                Positioned(
                  left: 45,
                  top: 528,
                  child: Text(
                    'Kamar $_nomorKamar',
                    style: const TextStyle(
                      color: Color(0xFF382017),
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Positioned(
                  left: 45,
                  top: 550,
                  right: 100,
                  child: Text(
                    _fasilitasText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
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
                    child: Text(
                      _statusSewa,
                      style: const TextStyle(
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
                  date: _jadwalBayarDate,
                  title: _jadwalBayarTitle,
                ),
                _buildScheduleCard(
                  left: 27,
                  top: 669,
                  icon: Icons.build_circle_outlined,
                  date: _jadwalMaintDate,
                  title: _jadwalMaintTitle,
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
            Text(
              _nominalTagihan,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                height: 1.05,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _jatuhTempoText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _whiteSmallStyle,
            ),
            const Spacer(),
            GestureDetector(
              onTap: () async {
                await Navigator.of(context).pushNamed(
                  AppRoutes.tenantBuktiPembayaran,
                );
                if (mounted) _muatDataDashboard();
              },
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
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _cardTextStyle,
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _cardTextStyle,
                  ),
                ],
              ),
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
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _aktivitasTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _cardTextStyle,
                  ),
                  Text(
                    _aktivitasDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _cardTextStyle,
                  ),
                ],
              ),
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
              onTap: () async {
                await Navigator.of(context).pushNamed(
                  AppRoutes.tenantKeluhan,
                );
                if (mounted) _muatDataDashboard();
              },
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
