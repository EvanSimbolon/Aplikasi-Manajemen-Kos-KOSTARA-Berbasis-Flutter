import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:belajar_dart/domain/models/penghuni.dart';
import 'package:belajar_dart/routing/app_routes.dart';
import 'package:belajar_dart/ui/penghuni/view_models/penghuni_view_model.dart';

class data_penghuni extends StatelessWidget {
  const data_penghuni({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TenantDataScreen();
  }
}

class TenantDataScreen extends StatefulWidget {
  const TenantDataScreen({Key? key}) : super(key: key);

  @override
  State<TenantDataScreen> createState() => _TenantDataScreenState();
}

class _TenantDataScreenState extends State<TenantDataScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PenghuniViewModel _viewModel = PenghuniViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTenants = _viewModel.daftarPenghuni;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFC07F00),
        foregroundColor: Colors.white,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.formPenghuni),
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 0),
          _buildFilterTabs(),
          const SizedBox(height: 16),
          Expanded(
            child: filteredTenants.isEmpty
                ? Center(
              child: Text(
                'Tidak ada data penghuni',
                style: GoogleFonts.inter(color: Colors.black54),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: filteredTenants.length,
              itemBuilder: (context, index) {
                return _buildTenantCard(filteredTenants[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // Background Header Gradien Cokelat Keemasan dengan Sudut Bawah Melengkung
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16), // Ruang untuk pencarian melayang
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFB22C), // Brownish Orange Top (Sesuai Desain Asli)
                Color(0xFF854836), // Deeper Warm Brown Bottom
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
          ),
          padding: EdgeInsets.only(
            top: statusBarHeight + 10,
            left: 12,
            right: 16,
            bottom: 86, // Jarak ekstra di bawah teks judul untuk search bar melayang
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
                'Data Penghuni',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Search Bar Melayang Menumpuk di Bawah Header
        Positioned(
          left: 16,
          right: 16,
          bottom: 25,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E6), // Warna krem sesuai gambar
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFDEC9A4),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _viewModel.cari,
              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF222222)),
              decoration: InputDecoration(
                hintText: 'Cari Nama / Nomor Kamar',
                hintStyle: GoogleFonts.inter(color: const Color(0xFF9E8E78), fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.black87, size: 24),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['Aktif', 'Tidak Aktif'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filterText) {
          final isSelected = _viewModel.filter == filterText;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => _viewModel.setFilter(filterText),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF854836) : const Color(0xFFFFF0D4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF854836).withOpacity(0.5)),
                ),
                child: Text(
                  filterText,
                  style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : const Color(0xFF000000),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTenantCard(Penghuni tenant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDEC9A4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFC07F00),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tenant.nama,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tenant.roomDetails,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFC07F00),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tenant.status,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}