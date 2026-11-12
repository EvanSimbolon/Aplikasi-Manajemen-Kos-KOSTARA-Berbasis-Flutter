import 'package:flutter/material.dart';

import '../../data/services/maintenance_service.dart';
import '../../domain/models/supabase_kamar_model.dart';
import '../../domain/models/supabase_maintenance_model.dart';

import 'tambah_maintenance_page.dart';
import '../fasilitas_kamar/edit_maintenance_page.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({
    super.key,
  });

  @override
  State<MaintenancePage> createState() =>
      _MaintenancePageState();
}

class _MaintenancePageState
    extends State<MaintenancePage> {
  final MaintenanceService _service =
  MaintenanceService();

  bool _isLoading = true;
  String? _errorMessage;

  List<SupabaseMaintenanceModel>
  _daftarMaintenance = [];

  List<SupabaseKamarModel>
  _daftarKamar = [];

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
      final maintenance =
      await _service.getMaintenance();

      final kamar =
      await _service.getKamar();

      if (!mounted) return;

      setState(() {
        _daftarMaintenance =
            maintenance;
        _daftarKamar = kamar;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
        'Gagal mengambil data maintenance: $e';
      });
    }
  }

  String namaKamar(String kamarId) {
    for (final kamar in _daftarKamar) {
      if (kamar.id == kamarId) {
        return kamar.nomorKamar;
      }
    }

    return 'Kamar tidak diketahui';
  }

  Future<void> _tambahMaintenance() async {
    final result =
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const TambahMaintenancePage(),
      ),
    );

    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _editMaintenance(
      SupabaseMaintenanceModel maintenance,
      ) async {
    final result =
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditMaintenancePage(
              maintenance: maintenance,
            ),
      ),
    );

    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _hapusMaintenance(
      String id,
      ) async {
    final konfirmasi =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Hapus Maintenance',
          ),
          content: const Text(
            'Apakah data maintenance ini ingin dihapus?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                    context,
                    false,
                  ),
              child: const Text(
                'Batal',
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(
                    context,
                    true,
                  ),
              child: const Text(
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
          .hapusMaintenance(id);

      await _loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Data maintenance berhasil dihapus.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus data: $e',
          ),
        ),
      );
    }
  }

  String statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'terjadwal':
        return 'Terjadwal';

      case 'proses':
        return 'Proses';

      case 'selesai':
        return 'Selesai';

      case 'dibatalkan':
        return 'Dibatalkan';

      default:
        return status;
    }
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green;

      case 'proses':
        return Colors.orange;

      case 'dibatalkan':
        return Colors.red;

      default:
        return Colors.blue;
    }
  }

  String formatTanggal(
      DateTime tanggal,
      ) {
    final day =
    tanggal.day
        .toString()
        .padLeft(2, '0');

    final month =
    tanggal.month
        .toString()
        .padLeft(2, '0');

    return '$day/$month/${tanggal.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jadwal Maintenance',
        ),
      ),
      floatingActionButton:
      FloatingActionButton.extended(
        onPressed:
        _tambahMaintenance,
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Tambah',
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding:
          const EdgeInsets.all(20),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
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
                height: 16,
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

    if (_daftarMaintenance.isEmpty) {
      return RefreshIndicator(
        onRefresh:
        _loadData,
        child: ListView(
          children: const [
            SizedBox(
              height: 180,
            ),
            Icon(
              Icons.build_outlined,
              size: 60,
            ),
            SizedBox(
              height: 16,
            ),
            Center(
              child: Text(
                'Belum ada jadwal maintenance.',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
      _loadData,
      child: ListView.builder(
        padding:
        const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          100,
        ),
        itemCount:
        _daftarMaintenance.length,
        itemBuilder:
            (context, index) {
          final item =
          _daftarMaintenance[index];

          return Card(
            margin:
            const EdgeInsets.only(
              bottom: 12,
            ),
            child: Padding(
              padding:
              const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          namaKamar(
                            item.kamarId,
                          ),
                          style:
                          const TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration:
                        BoxDecoration(
                          color:
                          statusColor(
                            item.status,
                          ).withValues(
                            alpha: 0.12,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            20,
                          ),
                        ),
                        child: Text(
                          statusLabel(
                            item.status,
                          ),
                          style: TextStyle(
                            color:
                            statusColor(
                              item.status,
                            ),
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    'Jenis perawatan: ${item.jenisPerawatan}',
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    'Tanggal: ${formatTanggal(item.tanggalPerawatan)}',
                  ),

                  if (item.teknisi !=
                      null &&
                      item.teknisi!
                          .trim()
                          .isNotEmpty) ...[
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      'Teknisi: ${item.teknisi}',
                    ),
                  ],

                  if (item.catatan !=
                      null &&
                      item.catatan!
                          .trim()
                          .isNotEmpty) ...[
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      'Catatan: ${item.catatan}',
                    ),
                  ],

                  const SizedBox(
                    height: 12,
                  ),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed:
                            () =>
                            _editMaintenance(
                              item,
                            ),
                        icon:
                        const Icon(
                          Icons.edit,
                        ),
                        label:
                        const Text(
                          'Edit',
                        ),
                      ),
                      TextButton.icon(
                        onPressed:
                            () =>
                            _hapusMaintenance(
                              item.id,
                            ),
                        icon:
                        const Icon(
                          Icons.delete,
                        ),
                        label:
                        const Text(
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