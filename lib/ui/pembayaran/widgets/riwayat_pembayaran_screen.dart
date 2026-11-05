import 'package:flutter/material.dart';
import 'package:belajar_dart/domain/models/riwayat_pembayaran.dart';
import 'package:belajar_dart/ui/core/themes/app_colors.dart';
import 'package:belajar_dart/ui/core/ui/common_widgets.dart';
import 'package:belajar_dart/ui/pembayaran/view_models/riwayat_pembayaran_view_model.dart';

// ---------- HALAMAN: RIWAYAT PEMBAYARAN ----------
class RiwayatPembayaranScreen extends StatefulWidget {
  final VoidCallback onBack;
  const RiwayatPembayaranScreen({super.key, required this.onBack});

  @override
  State<RiwayatPembayaranScreen> createState() =>
      _RiwayatPembayaranScreenState();
}

class _RiwayatPembayaranScreenState extends State<RiwayatPembayaranScreen> {
  final RiwayatPembayaranViewModel _viewModel = RiwayatPembayaranViewModel();

  final filters = const ['Semua', 'Menunggu', 'Berhasil'];

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _viewModel.hasil;
    return Column(
      children: [
        PageHeader('Riwayat Pembayaran', onBack: widget.onBack),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: cardCream,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              onChanged: _viewModel.cari,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.black),
                hintText: 'Cari Bulan Pembayaran',
                hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: filters.map((f) {
              final active = f == _viewModel.filter;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _viewModel.setFilter(f),
                  child: Container(
                    margin: EdgeInsets.only(right: f == filters.last ? 0 : 10),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? profileBrown : fieldCream,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderCream),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : Colors.black87,
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
          child: data.isEmpty
              ? const Center(
                  child: Text('Tidak ada data', style: TextStyle(fontSize: 12)))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: data.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => RiwayatCard(data[i]),
                ),
        ),
      ],
    );
  }
}

class RiwayatCard extends StatelessWidget {
  final RiwayatPembayaran p;
  const RiwayatCard(this.p, {super.key});

  @override
  Widget build(BuildContext context) {
    final berhasil = p.berhasil;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCream),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.bulan,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(p.nominal,
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: profilPict)),
              const SizedBox(height: 10),
              Text(p.tanggal, style: const TextStyle(fontSize: 8)),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: berhasil ? successGreen : pendingYellow,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(p.status,
                  style: const TextStyle(
                      fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
