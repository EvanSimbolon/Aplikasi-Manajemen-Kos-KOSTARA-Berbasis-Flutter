import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:belajar_dart/domain/models/pembayaran.dart';
import 'package:belajar_dart/routing/app_routes.dart';
import 'package:belajar_dart/ui/pembayaran/view_models/pembayaran_view_model.dart';

class DataPembayaranPage extends StatefulWidget {
  const DataPembayaranPage({super.key});

  @override
  State<DataPembayaranPage> createState() => _DataPembayaranPageState();
}

class _DataPembayaranPageState extends State<DataPembayaranPage> {
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _namaBulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PembayaranViewModel>().fetchPembayaran('Semua');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _bukaVerifikasi(Pembayaran item) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.verifPembayaran,
      arguments: item,
    );
    if (mounted) {
      context.read<PembayaranViewModel>().fetchPembayaran('Semua');
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PembayaranViewModel>();
    final requestList = viewModel.requestVerifikasi;
    final historyList = viewModel.riwayatTerverifikasi;
    final currentYear = DateTime.now().year;
    final years = [currentYear - 1, currentYear, currentYear + 1];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7D4),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ================= HEADER GRADASI & INPUT SEARCH =================
            SizedBox(
              height: 140,
              child: Stack(
                children: [
                  Container(
                    height: 115,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFB22C), Color(0xFF854836)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 45,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Data Pembayaran',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => viewModel.fetchPembayaran('Semua'),
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 16,
                    right: 16,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: Color(0xFF333333),
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => viewModel.cari(val),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Cari Nama / Nomor Kamar',
                                hintStyle: TextStyle(
                                  color: Color(0xFF888888),
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (viewModel.keyword.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                viewModel.cari('');
                              },
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ================= KONTEN 2 BAGIAN =================
            Expanded(
              child: viewModel.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF854836),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => viewModel.fetchPembayaran('Semua'),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        children: [
                          // ---------- BAGIAN 1: REQUEST VERIFIKASI BARU ----------
                          Row(
                            children: [
                              const Icon(
                                Icons.pending_actions_rounded,
                                color: Color(0xFF854836),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Request Verifikasi Pembayaran',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4A3428),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: requestList.isEmpty
                                      ? const Color(0xFFE8DFCE)
                                      : const Color(0xFFFFB22C),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${requestList.length} Baru',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3E2212),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (requestList.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFDF9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE2D9C8),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Tidak ada request verifikasi pembayaran baru.',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...requestList.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: GestureDetector(
                                  onTap: () => _bukaVerifikasi(item),
                                  child: _buildCardPembayaran(item),
                                ),
                              ),
                            ),

                          const SizedBox(height: 20),
                          const Divider(color: Color(0xFFDEC9A4), thickness: 1.2),
                          const SizedBox(height: 12),

                          // ---------- BAGIAN 2: HISTORY TERVERIFIKASI + FILTER BULAN ----------
                          Row(
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                color: Color(0xFF2E8B57),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Riwayat Terverifikasi',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4A3428),
                                  ),
                                ),
                              ),
                              Text(
                                '${historyList.length} data',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF854836),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Menu Filter Bulan & Tahun
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  height: 42,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFDF9),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFC7B8A2),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int?>(
                                      value: viewModel.selectedMonth,
                                      isExpanded: true,
                                      icon: const Icon(
                                        Icons.calendar_month_rounded,
                                        size: 18,
                                        color: Color(0xFF854836),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4A3428),
                                      ),
                                      items: [
                                        const DropdownMenuItem<int?>(
                                          value: null,
                                          child: Text('Semua Bulan'),
                                        ),
                                        ...List.generate(
                                          12,
                                          (i) => DropdownMenuItem<int?>(
                                            value: i + 1,
                                            child: Text(_namaBulan[i]),
                                          ),
                                        ),
                                      ],
                                      onChanged: (month) =>
                                          viewModel.setMonthFilter(month),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 42,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFDF9),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFC7B8A2),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: years.contains(viewModel.selectedYear)
                                          ? viewModel.selectedYear
                                          : currentYear,
                                      isExpanded: true,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4A3428),
                                      ),
                                      items: years
                                          .map(
                                            (y) => DropdownMenuItem<int>(
                                              value: y,
                                              child: Text('$y'),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (year) {
                                        if (year != null) {
                                          viewModel.setMonthFilter(
                                            viewModel.selectedMonth,
                                            year: year,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          if (historyList.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFDF9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE2D9C8),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  viewModel.selectedMonth == null
                                      ? 'Belum ada pembayaran terverifikasi di tahun ${viewModel.selectedYear}.'
                                      : 'Tidak ada pembayaran terverifikasi pada ${_namaBulan[viewModel.selectedMonth! - 1]} ${viewModel.selectedYear}.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...historyList.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: GestureDetector(
                                  onTap: () => _bukaVerifikasi(item),
                                  child: _buildCardPembayaran(item),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPembayaran(Pembayaran item) {
    Color badgeBg;
    Color badgeText;

    if (item.status == 'belum_bayar' ||
        item.status == 'terlambat' ||
        item.status == 'ditolak') {
      badgeBg = const Color(0xFFEC5E53);
      badgeText = const Color(0xFF221313);
    } else if (item.status == 'menunggu_verifikasi') {
      badgeBg = const Color(0xFFE0EC7F);
      badgeText = const Color(0xFF35300F);
    } else {
      badgeBg = const Color(0xFF7BD768);
      badgeText = const Color(0xFF133210);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2D9C8)),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFB88225),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 80),
                      child: Text(
                        item.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF241810),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kamar ${item.kamar} • ${item.tanggalFormatted}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9E6E1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.nominalFormatted,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF241810),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.statusFormatted,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: badgeText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
