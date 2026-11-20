import 'package:flutter/material.dart';

import '../../data/services/fasilitas_kamar_service.dart';
import '../../domain/models/supabase_fasilitas_kamar_model.dart';
import '../../domain/models/jenis_fasilitas_model.dart';
import 'tambah_fasilitas_kamar_page.dart';
import 'edit_fasilitas_kamar_page.dart';

class FasilitasKamarPage
    extends StatefulWidget {
  const FasilitasKamarPage({
    super.key,
  });

  @override
  State<FasilitasKamarPage>
  createState() =>
      _FasilitasKamarPageState();
}

class _FasilitasKamarPageState
    extends State<FasilitasKamarPage> {
  final FasilitasKamarService
  _service =
  FasilitasKamarService();

  List<SupabaseFasilitasKamarModel>
  _data = [];

  List<JenisFasilitasModel>
  _jenis = [];

  bool _isLoading = true;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data =
      await _service
          .getFasilitasKamar();

      final jenis =
      await _service
          .getJenisFasilitas();

      if (!mounted) return;

      setState(() {
        _data = data;
        _jenis = jenis;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
        'Gagal mengambil data fasilitas.\n\n$e';
      });
    }
  }

  String _namaFasilitas(
      int id,
      ) {
    for (final item
    in _jenis) {
      if (item.id == id) {
        return item.namaFasilitas;
      }
    }

    return 'Tidak diketahui';
  }

  Future<void> _tambah() async {
    final hasil =
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const TambahFasilitasKamarPage(),
      ),
    );

    if (hasil == true) {
      _loadData();
    }
  }

  Future<void> _edit(
      SupabaseFasilitasKamarModel
      fasilitas,
      ) async {
    final hasil =
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditFasilitasKamarPage(
              fasilitas:
              fasilitas,
            ),
      ),
    );

    if (hasil == true) {
      _loadData();
    }
  }

  Future<void> _hapus(
      SupabaseFasilitasKamarModel
      fasilitas,
      ) async {
    final nama =
    _namaFasilitas(
      fasilitas
          .jenisFasilitasId,
    );

    final konfirmasi =
    await showDialog<bool>(
      context: context,
      builder:
          (context) {
        return AlertDialog(
          title:
          const Text(
            'Hapus Fasilitas',
          ),
          content:
          Text(
            'Hapus $nama dari data fasilitas kamar?',
          ),
          actions: [
            TextButton(
              onPressed:
                  () =>
                  Navigator.pop(
                    context,
                    false,
                  ),
              child:
              const Text(
                'Batal',
              ),
            ),
            ElevatedButton(
              onPressed:
                  () =>
                  Navigator.pop(
                    context,
                    true,
                  ),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                Colors.red,
                foregroundColor:
                Colors.white,
              ),
              child:
              const Text(
                'Hapus',
              ),
            ),
          ],
        );
      },
    );

    if (konfirmasi != true) {
      return;
    }

    try {
      await _service
          .hapusFasilitasKamar(
        fasilitas.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
          Text(
            'Fasilitas berhasil dihapus.',
          ),
        ),
      );

      _loadData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
          Text(
            'Gagal menghapus data: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(
        0xFFFFF8D8,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width:
              double.infinity,
              padding:
              const EdgeInsets.fromLTRB(
                18,
                22,
                18,
                22,
              ),
              decoration:
              const BoxDecoration(
                color:
                Color(
                  0xFF753924,
                ),
                borderRadius:
                BorderRadius.only(
                  bottomLeft:
                  Radius.circular(
                    30,
                  ),
                  bottomRight:
                  Radius.circular(
                    30,
                  ),
                ),
              ),
              child:
              Row(
                children: [
                  IconButton(
                    onPressed:
                        () =>
                        Navigator.pop(
                          context,
                        ),
                    icon:
                    const Icon(
                      Icons
                          .arrow_back_ios_new,
                      color:
                      Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  const Expanded(
                    child:
                    Text(
                      'Fasilitas Kamar',
                      style:
                      TextStyle(
                        color:
                        Colors.white,
                        fontSize:
                        21,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed:
                    _tambah,
                    icon:
                    const Icon(
                      Icons.add,
                      color:
                      Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child:
              _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    if (_errorMessage !=
        null) {
      return Center(
        child:
        Padding(
          padding:
          const EdgeInsets.all(
            24,
          ),
          child:
          Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
                color:
                Color(
                  0xFFB3261E,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                _errorMessage!,
                textAlign:
                TextAlign.center,
              ),
              const SizedBox(
                height: 18,
              ),
              ElevatedButton(
                onPressed:
                _loadData,
                child:
                const Text(
                  'Coba Lagi',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_data.isEmpty) {
      return Center(
        child:
        Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .home_repair_service_outlined,
              size: 70,
              color:
              Color(
                0xFFB57514,
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            const Text(
              'Belum ada fasilitas kamar.',
              style:
              TextStyle(
                fontSize: 16,
                fontWeight:
                FontWeight.bold,
                color:
                Color(
                  0xFF753924,
                ),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            ElevatedButton.icon(
              onPressed:
              _tambah,
              icon:
              const Icon(
                Icons.add,
              ),
              label:
              const Text(
                'Tambah Fasilitas',
              ),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                const Color(
                  0xFF753924,
                ),
                foregroundColor:
                Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
      _loadData,
      child:
      ListView.builder(
        padding:
        const EdgeInsets.all(
          18,
        ),
        itemCount:
        _data.length,
        itemBuilder:
            (context, index) {
          final item =
          _data[index];

          return Card(
            color:
            Colors.white,
            margin:
            const EdgeInsets.only(
              bottom: 14,
            ),
            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(
                18,
              ),
            ),
            child:
            Padding(
              padding:
              const EdgeInsets.all(
                16,
              ),
              child:
              Row(
                children: [
                  Container(
                    width:
                    48,
                    height:
                    48,
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFFFFE9A8,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        14,
                      ),
                    ),
                    child:
                    const Icon(
                      Icons
                          .home_repair_service_rounded,
                      color:
                      Color(
                        0xFF753924,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child:
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          _namaFasilitas(
                            item.jenisFasilitasId,
                          ),
                          style:
                          const TextStyle(
                            fontSize:
                            16,
                            fontWeight:
                            FontWeight
                                .bold,
                            color:
                            Color(
                              0xFF753924,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Jumlah: ${item.jumlah}',
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          'Kondisi: ${item.kondisi}',
                          style:
                          const TextStyle(
                            color:
                            Colors.black54,
                          ),
                        ),
                        if (item
                            .tanggalPemasangan !=
                            null)
                          Text(
                            'Pemasangan: ${item.tanggalPemasangan!.day}/${item.tanggalPemasangan!.month}/${item.tanggalPemasangan!.year}',
                            style:
                            const TextStyle(
                              color:
                              Colors.black54,
                              fontSize:
                              12,
                            ),
                          ),
                      ],
                    ),
                  ),

                  PopupMenuButton<
                      String>(
                    onSelected:
                        (value) {
                      if (value ==
                          'edit') {
                        _edit(
                          item,
                        );
                      }

                      if (value ==
                          'hapus') {
                        _hapus(
                          item,
                        );
                      }
                    },
                    itemBuilder:
                        (context) =>
                    const [
                      PopupMenuItem(
                        value:
                        'edit',
                        child:
                        Text(
                          'Edit',
                        ),
                      ),
                      PopupMenuItem(
                        value:
                        'hapus',
                        child:
                        Text(
                          'Hapus',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}