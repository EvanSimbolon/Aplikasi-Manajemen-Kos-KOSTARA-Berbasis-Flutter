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

  @override
  void initState() {
    super.initState();
    // Memanggil fetching data saat screen pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PembayaranViewModel>().fetchPembayaran('Semua');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PembayaranViewModel>();
    final filteredList = viewModel.daftarPembayaran;

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
                          const Icon(Icons.search, color: Color(0xFF333333), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => viewModel.cari(val),
                              style: const TextStyle(fontSize: 13, color: Colors.black),
                              decoration: const InputDecoration(
                                hintText: 'Cari Nama / Nomor Kamar',
                                hintStyle: TextStyle(color: Color(0xFF888888), fontSize: 13),
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
                              child: const Icon(Icons.close, size: 18, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ================= TOMBOL FILTER RESPONSIP (TAB) =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterTab(context, 'Semua'),
                  const SizedBox(width: 8),
                  _buildFilterTab(context, 'Belum Dibayar'),
                  const SizedBox(width: 8),
                  _buildFilterTab(context, 'Menunggu'),
                  const SizedBox(width: 8),
                  _buildFilterTab(context, 'Lunas'),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ================= LIST TRANSAKSI RESPONSIP =================
            Expanded(
              child: viewModel.isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF854836),
                ),
              )
                  : filteredList.isEmpty
                  ? const Center(
                child: Text(
                  'Tidak ada data pembayaran',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: filteredList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = filteredList[index];
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.verifPembayaran,
                      arguments: item,
                    ),
                    child: _buildCardPembayaran(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Tab Filter yang terhubung langsung ke ViewModel
  Widget _buildFilterTab(BuildContext context, String label) {
    final viewModel = context.watch<PembayaranViewModel>();
    final bool isActive = viewModel.filter == label;

    return Expanded(
      child: GestureDetector(
        onTap: () => viewModel.setFilter(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF6B3A24) : const Color(0xFFF9EEDD),
            borderRadius: BorderRadius.circular(8),
            border: isActive ? null : Border.all(color: const Color(0xFFC7B8A2)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF4A3428),
            ),
          ),
        ),
      ),
    );
  }

  // Widget Card Pembayaran Kustom dengan Avatar & Badge Warna
  // Widget Card Pembayaran Kustom dengan Avatar & Badge Warna
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
      // Untuk status 'terverifikasi' / 'lunas'
      badgeBg = const Color(0xFF7BD768);
      badgeText = const Color(0xFF133210);
    }

    return Container(
      height: 95,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2D9C8)),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              // Avatar Bulat Cokelat Emas
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
              // Nama, Kamar, Harga
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.nama,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF241810),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.kamar,
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
            ],
          ),
          // Badge Status
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
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
