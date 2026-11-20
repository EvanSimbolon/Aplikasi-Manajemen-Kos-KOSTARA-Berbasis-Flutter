import 'package:flutter/material.dart';

import 'package:belajar_dart/ui/kamar/view_models/kamar_view_model.dart';

class DataKamarPage extends StatefulWidget {
  const DataKamarPage({super.key});

  @override
  State<DataKamarPage> createState() => _DataKamarPageState();
}

class _DataKamarPageState extends State<DataKamarPage> {
  final TextEditingController searchController = TextEditingController();
  final KamarViewModel _viewModel = KamarViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.load();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kamarDitampilkan = _viewModel.daftarKamar;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8D8),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // HEADER
            SizedBox(
              height: 140,
              child: Stack(
                children: [
                  Container(
                    height: 115,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF753924),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                  ),

                  Positioned(
                    top: -30,
                    right: -20,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7A61E),
                        shape: BoxShape.circle,
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
                          'Data Kamar',
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
                    child: Row(
                      children: [
                        // PENCARIAN
                        Expanded(
                          child: Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
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
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: searchController,
                                    onChanged: _viewModel.cari,
                                    decoration: const InputDecoration(
                                      hintText: 'Cari Nomor Kamar',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF888888),
                                        fontSize: 13,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // TOMBOL TAMBAH
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Fitur tambah kamar akan dikembangkan.',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB22C),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '+ Tambah',
                              style: TextStyle(
                                color: Color(0xFF5A2A06),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // DAFTAR KAMAR
            Expanded(
              child: kamarDitampilkan.isEmpty
                  ? const Center(
                      child: Text(
                        'Kamar tidak ditemukan',
                        style: TextStyle(color: Color(0xFF753924)),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      itemCount: kamarDitampilkan.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 9),
                      itemBuilder: (context, index) {
                        final item = kamarDitampilkan[index];
                        final bool isTersedia = item.tersedia;

                        return Container(
                          height: 66,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFDF8),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: const Color(0xFFE5DECD)),
                          ),
                          child: Row(
                            children: [
                              // FOTO KAMAR DI SEBELAH KIRI
                              ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: Image.asset(
                                  item.gambar,
                                  width: 66,
                                  height: 54,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 66,
                                      height: 54,
                                      color: const Color(0xFFF3E7CF),
                                      child: const Icon(
                                        Icons.bed,
                                        color: Color(0xFFB57514),
                                        size: 27,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(width: 7),

                              // INFORMASI KAMAR
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item.nomor,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF261914),
                                      ),
                                    ),

                                    const SizedBox(height: 2),

                                    Text(
                                      'Tipe : ${item.tipe} - ${item.harga}',
                                      style: const TextStyle(
                                        fontSize: 6.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFB57514),
                                      ),
                                    ),

                                    const SizedBox(height: 3),

                                    // STATUS KAMAR
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isTersedia
                                            ? const Color(0xFFA5E8BE)
                                            : const Color(0xFFEC5E53),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        isTersedia ? 'Tersedia' : 'Terisi',
                                        style: TextStyle(
                                          fontSize: 5.5,
                                          fontWeight: FontWeight.bold,
                                          color: isTersedia
                                              ? const Color(0xFF1B6533)
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
