import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminKeluhanScreen extends StatefulWidget {
  const AdminKeluhanScreen({super.key});

  @override
  State<AdminKeluhanScreen> createState() => _AdminKeluhanScreenState();
}

class _AdminKeluhanScreenState extends State<AdminKeluhanScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const List<String> _filters = [
    'Semua',
    'dilaporkan',
    'diproses',
    'selesai',
  ];

  String _selectedFilter = 'Semua';
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _muatKeluhan();
  }

  Future<List<String>> _ambilKosIdsPemilik() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return const [];

    final ids = <String>{};
    try {
      final kosList = await _supabase
          .from('kos')
          .select('id')
          .eq('pemilik_id', user.id);
      for (final row in kosList) {
        final id = row['id']?.toString();
        if (id != null && id.isNotEmpty) ids.add(id);
      }
    } catch (_) {}

    try {
      final anggota = await _supabase
          .from('anggota_kos')
          .select('kos_id')
          .eq('pengguna_id', user.id)
          .eq('peran', 'pemilik')
          .eq('status', 'aktif');
      for (final row in anggota) {
        final id = row['kos_id']?.toString();
        if (id != null && id.isNotEmpty) ids.add(id);
      }
    } catch (_) {}

    return ids.toList();
  }

  Future<void> _muatKeluhan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final kosIds = await _ambilKosIdsPemilik();

      // Peta pelapor_id -> nomor kamar & kos_id dari penyewaan aktif
      final kamarByPelapor = <String, String>{};
      final pelaporDiKosPemilik = <String>{};
      if (kosIds.isNotEmpty) {
        try {
          final sewaRows = await _supabase
              .from('penyewaan')
              .select('penghuni_id, status, kamar!inner ( nomor_kamar, kos_id )')
              .inFilter('kamar.kos_id', kosIds)
              .order('tanggal_mulai', ascending: false);

          for (final row in sewaRows) {
            final pid = row['penghuni_id']?.toString();
            final kamar = row['kamar'] as Map<String, dynamic>?;
            final nomor = kamar?['nomor_kamar']?.toString();
            if (pid != null) {
              pelaporDiKosPemilik.add(pid);
              if (nomor != null && !kamarByPelapor.containsKey(pid)) {
                kamarByPelapor[pid] = nomor;
              }
            }
          }
        } catch (e) {
          debugPrint('AdminKeluhanScreen penyewaan lookup: $e');
        }
      }

      List<dynamic> rows;
      try {
        rows = await _supabase
            .from('laporan_kerusakan')
            .select(
              'id, pelapor_id, fasilitas_kamar_id, fasilitas_nama, '
              'judul, deskripsi, status, dilaporkan_pada, diselesaikan_pada, '
              'pengguna!laporan_kerusakan_pelapor_id_fkey ( nama_lengkap ), '
              'fasilitas_kamar ( kamar ( nomor_kamar, kos_id ), '
              'jenis_fasilitas ( nama_fasilitas ) )',
            )
            .order('dilaporkan_pada', ascending: false);
      } catch (_) {
        // Fallback jika kolom fasilitas_nama belum ditambahkan di DB.
        rows = await _supabase
            .from('laporan_kerusakan')
            .select(
              'id, pelapor_id, fasilitas_kamar_id, '
              'judul, deskripsi, status, dilaporkan_pada, diselesaikan_pada, '
              'pengguna!laporan_kerusakan_pelapor_id_fkey ( nama_lengkap ), '
              'fasilitas_kamar ( kamar ( nomor_kamar, kos_id ), '
              'jenis_fasilitas ( nama_fasilitas ) )',
            )
            .order('dilaporkan_pada', ascending: false);
      }

      final parsed = <Map<String, dynamic>>[];
      for (final raw in rows) {
        final row = Map<String, dynamic>.from(raw as Map);
        final pelaporId = row['pelapor_id']?.toString() ?? '';
        final pengguna = row['pengguna'] as Map<String, dynamic>?;
        final fk = row['fasilitas_kamar'] as Map<String, dynamic>?;
        final fkKamar = fk?['kamar'] as Map<String, dynamic>?;
        final fkJenis = fk?['jenis_fasilitas'] as Map<String, dynamic>?;

        final fkKosId = fkKamar?['kos_id']?.toString();
        if (kosIds.isNotEmpty) {
          final cocokKos =
              (fkKosId != null && kosIds.contains(fkKosId)) ||
              pelaporDiKosPemilik.contains(pelaporId);
          if (!cocokKos) continue;
        }

        final nomorKamar =
            fkKamar?['nomor_kamar']?.toString() ??
            kamarByPelapor[pelaporId] ??
            '-';
        final fasilitasNama =
            fkJenis?['nama_fasilitas']?.toString() ??
            row['fasilitas_nama']?.toString() ??
            '-';

        parsed.add({
          'id': row['id']?.toString() ?? '',
          'judul': row['judul']?.toString() ?? 'Keluhan',
          'deskripsi': row['deskripsi']?.toString() ?? '-',
          'status': (row['status']?.toString() ?? 'dilaporkan').toLowerCase(),
          'pelapor': pengguna?['nama_lengkap']?.toString() ?? 'Penghuni',
          'kamar': nomorKamar,
          'fasilitas': fasilitasNama,
          'dilaporkan_pada': row['dilaporkan_pada']?.toString() ?? '',
        });
      }

      if (!mounted) return;
      setState(() {
        _items = parsed;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat daftar keluhan: $e';
      });
    }
  }

  Future<void> _ubahStatus(Map<String, dynamic> item, String statusBaru) async {
    try {
      await _supabase
          .from('laporan_kerusakan')
          .update({
            'status': statusBaru,
            'diselesaikan_pada': statusBaru == 'selesai'
                ? DateTime.now().toIso8601String()
                : null,
          })
          .eq('id', item['id']);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Status keluhan diubah menjadi ${_labelStatus(statusBaru)}',
          ),
        ),
      );
      await _muatKeluhan();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status: $e')),
      );
    }
  }

  void _tampilkanPilihanStatus(Map<String, dynamic> item) {
    final statusSaatIni = item['status'] as String;
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
              Text(
                'Ubah Status Keluhan',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A3427),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item['judul']} • Kamar ${item['kamar']}',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              for (final st in ['dilaporkan', 'diproses', 'selesai'])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    st == statusSaatIni
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: _warnaStatus(st),
                  ),
                  title: Text(
                    _labelStatus(st),
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (st != statusSaatIni) {
                      _ubahStatus(item, st);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _labelStatus(String status) {
    return switch (status.toLowerCase()) {
      'dilaporkan' => 'Dilaporkan',
      'diproses' => 'Diproses',
      'selesai' => 'Selesai',
      'ditolak' => 'Ditolak',
      _ => status,
    };
  }

  Color _warnaStatus(String status) {
    return switch (status.toLowerCase()) {
      'dilaporkan' => const Color(0xFFD9534F),
      'diproses' => const Color(0xFFE69500),
      'selesai' => const Color(0xFF2E8B57),
      _ => Colors.grey,
    };
  }

  Color _bgStatus(String status) {
    return switch (status.toLowerCase()) {
      'dilaporkan' => const Color(0xFFFFE3E1),
      'diproses' => const Color(0xFFFFF0C2),
      'selesai' => const Color(0xFFD9F3DF),
      _ => const Color(0xFFEDEDED),
    };
  }

  String _formatTanggal(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '-';
    const bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
  }

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedFilter == 'Semua') return _items;
    return _items.where((e) => e['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final list = _filteredItems;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFB22C), Color(0xFF854836)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            padding: EdgeInsets.only(
              top: statusBarHeight + 10,
              left: 12,
              right: 16,
              bottom: 20,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Daftar Keluhan',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _muatKeluhan,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _filters.map((filter) {
                final selected = _selectedFilter == filter;
                final label = filter == 'Semua'
                    ? 'Semua'
                    : _labelStatus(filter);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF854836)
                            : const Color(0xFFFFF0D4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF854836).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        label,
                        style: GoogleFonts.inter(
                          color: selected
                              ? Colors.white
                              : const Color(0xFF4A3427),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF854836)),
                  )
                : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: Colors.red),
                      ),
                    ),
                  )
                : list.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada keluhan',
                      style: GoogleFonts.inter(color: Colors.black54),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _muatKeluhan,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _buildKeluhanCard(list[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeluhanCard(Map<String, dynamic> item) {
    final status = item['status'] as String;
    return InkWell(
      onTap: () => _tampilkanPilihanStatus(item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDEC9A4), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item['judul'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2B1810),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _bgStatus(status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _labelStatus(status),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _warnaStatus(status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.meeting_room_outlined,
                      size: 14,
                      color: Color(0xFF854836),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Kamar ${item['kamar']}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF854836),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.build_outlined,
                      size: 14,
                      color: Color(0xFFC07F00),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Fasilitas: ${item['fasilitas']}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFC07F00),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item['deskripsi'] as String,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF3A2D28),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${item['pelapor']} • ${_formatTanggal(item['dilaporkan_pada'] as String)}',
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.black54),
                ),
                const Spacer(),
                Text(
                  'Ketuk untuk ubah status',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF854836),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
