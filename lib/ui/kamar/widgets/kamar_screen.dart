import 'package:flutter/material.dart';

import 'package:belajar_dart/domain/models/supabase_kamar_model.dart';
import 'package:belajar_dart/ui/kamar/edit_kamar_page.dart';
import 'package:belajar_dart/ui/kamar/tambah_kamar_page.dart';
import 'package:belajar_dart/ui/kamar/view_models/kamar_view_model.dart';

class DataKamarPage extends StatefulWidget {
  const DataKamarPage({super.key});

  @override
  State<DataKamarPage> createState() => _DataKamarPageState();
}

class _DataKamarPageState extends State<DataKamarPage> {
  final TextEditingController searchController =
  TextEditingController();

  final KamarViewModel _viewModel = KamarViewModel();

  @override
  void initState() {
    super.initState();

    _viewModel.addListener(_onViewModelChanged);
    _viewModel.loadKamar();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    searchController.dispose();
    super.dispose();
  }

  // =========================
  // TAMBAH KAMAR
  // =========================

  Future<void> bukaTambahKamar() async {
    final berhasil = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TambahKamarPage(),
      ),
    );

    if (berhasil == true) {
      await _viewModel.loadKamar();
    }
  }

  // =========================
  // EDIT KAMAR
  // =========================

  Future<void> bukaEditKamar(
      SupabaseKamarModel kamar,
      ) async {
    final berhasil = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditKamarPage(
          kamar: kamar,
        ),
      ),
    );

    if (berhasil == true) {
      await _viewModel.loadKamar();
    }
  }

  // =========================
  // HAPUS KAMAR
  // =========================

  Future<void> hapusKamar(
      SupabaseKamarModel kamar,
      ) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Hapus Kamar?',
            style: TextStyle(
              color: Color(0xFF753924),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus kamar ${kamar.nomorKamar}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Color(0xFF753924),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB3261E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (konfirmasi != true) {
      return;
    }

    try {
      await _viewModel.hapusKamar(kamar.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kamar ${kamar.nomorKamar} berhasil dihapus.',
          ),
        ),
      );

      await _viewModel.loadKamar();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus kamar: $e',
          ),
        ),
      );
    }
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

            // =========================
            // HEADER
            // =========================

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
                          onTap: () =>
                              Navigator.of(context).maybePop(),
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

                  // SEARCH + TAMBAH
                  Positioned(
                    bottom: 0,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [

                        Expanded(
                          child: Container(
                            height: 46,
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: 0.08,
                                  ),
                                  blurRadius: 4,
                                  offset:
                                  const Offset(0, 2),
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
                                    controller:
                                    searchController,
                                    onChanged:
                                    _viewModel.cari,
                                    decoration:
                                    const InputDecoration(
                                      hintText:
                                      'Cari Nomor Kamar',
                                      hintStyle:
                                      TextStyle(
                                        color:
                                        Color(0xFF888888),
                                        fontSize: 13,
                                      ),
                                      border:
                                      InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        GestureDetector(
                          onTap: bukaTambahKamar,
                          child: Container(
                            height: 44,
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB22C),
                              borderRadius:
                              BorderRadius.circular(10),
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

            // =========================
            // LOADING
            // =========================

            if (_viewModel.isLoading)

              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )

            // =========================
            // ERROR
            // =========================

            else if (_viewModel.errorMessage != null)

              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF753924),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              )

            // =========================
            // DATA KOSONG
            // =========================

            else if (kamarDitampilkan.isEmpty)

                const Expanded(
                  child: Center(
                    child: Text(
                      'Kamar tidak ditemukan',
                      style: TextStyle(
                        color: Color(0xFF753924),
                      ),
                    ),
                  ),
                )

              // =========================
              // LIST KAMAR
              // =========================

              else

                Expanded(
                  child: ListView.separated(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    itemCount:
                    kamarDitampilkan.length,
                    separatorBuilder:
                        (context, index) =>
                    const SizedBox(height: 9),
                    itemBuilder:
                        (context, index) {

                      final item =
                      kamarDitampilkan[index];

                      return Container(
                        height: 66,
                        padding:
                        const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color:
                          const Color(0xFFFFFDF8),
                          borderRadius:
                          BorderRadius.circular(15),
                          border: Border.all(
                            color:
                            const Color(0xFFE5DECD),
                          ),
                        ),
                        child: Row(
                          children: [

                            // =========================
                            // AREA EDIT
                            // =========================

                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    bukaEditKamar(item),
                                child: Row(
                                  children: [

                                    Container(
                                      width: 66,
                                      height: 54,
                                      decoration:
                                      BoxDecoration(
                                        color:
                                        const Color(
                                          0xFFF3E7CF,
                                        ),
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                          9,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.bed,
                                        color:
                                        Color(
                                          0xFFB57514,
                                        ),
                                        size: 27,
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 7,
                                    ),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                        children: [

                                          Text(
                                            item.nomorKamar,
                                            style:
                                            const TextStyle(
                                              fontSize: 9,
                                              fontWeight:
                                              FontWeight
                                                  .bold,
                                              color:
                                              Color(
                                                0xFF261914,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 2,
                                          ),

                                          Text(
                                            'Tipe : ${item.tipeKamar ?? '-'} - ${formatHarga(item.hargaSewaBulanan)}',
                                            style:
                                            const TextStyle(
                                              fontSize: 6.5,
                                              fontWeight:
                                              FontWeight
                                                  .w600,
                                              color:
                                              Color(
                                                0xFFB57514,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 3,
                                          ),

                                          Container(
                                            padding:
                                            const EdgeInsets
                                                .symmetric(
                                              horizontal: 7,
                                              vertical: 2,
                                            ),
                                            decoration:
                                            BoxDecoration(
                                              color:
                                              const Color(
                                                0xFFA5E8BE,
                                              ),
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                3,
                                              ),
                                            ),
                                            child:
                                            const Text(
                                              'Tersedia',
                                              style:
                                              TextStyle(
                                                fontSize: 5.5,
                                                fontWeight:
                                                FontWeight
                                                    .bold,
                                                color:
                                                Color(
                                                  0xFF1B6533,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const Icon(
                                      Icons
                                          .edit_outlined,
                                      color:
                                      Color(0xFF753924),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // =========================
                            // TOMBOL HAPUS
                            // =========================

                            const SizedBox(width: 5),

                            GestureDetector(
                              onTap: () =>
                                  hapusKamar(item),
                              child: Container(
                                width: 40,
                                height: 54,
                                decoration:
                                BoxDecoration(
                                  color:
                                  const Color(
                                    0xFFFFE4E1,
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(
                                    9,
                                  ),
                                ),
                                child: const Icon(
                                  Icons
                                      .delete_outline,
                                  color:
                                  Color(0xFFB3261E),
                                  size: 21,
                                ),
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

  // =========================
  // FORMAT HARGA
  // =========================

  String formatHarga(double harga) {
    final nilai = harga.toStringAsFixed(0);

    final buffer = StringBuffer();

    for (int i = 0; i < nilai.length; i++) {
      if (i > 0 &&
          (nilai.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(nilai[i]);
    }

    return 'Rp$buffer';
  }
}