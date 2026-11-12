import 'package:flutter/material.dart';

import '../../data/services/maintenance_service.dart';
import '../../domain/models/supabase_kamar_model.dart';
import '../../domain/models/supabase_maintenance_model.dart';

class TambahMaintenancePage extends StatefulWidget {
  const TambahMaintenancePage({
    super.key,
  });

  @override
  State<TambahMaintenancePage> createState() =>
      _TambahMaintenancePageState();
}

class _TambahMaintenancePageState
    extends State<TambahMaintenancePage> {
  final MaintenanceService _service =
  MaintenanceService();

  final TextEditingController _jenisController =
  TextEditingController();

  final TextEditingController _teknisiController =
  TextEditingController();

  final TextEditingController _catatanController =
  TextEditingController();

  List<SupabaseKamarModel> _daftarKamar = [];

  String? _selectedKamarId;
  String _selectedStatus = 'Terjadwal';

  DateTime _tanggalPerawatan =
  DateTime.now();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadKamar();
  }

  Future<void> _loadKamar() async {
    try {
      final kamar =
      await _service.getKamar();

      if (!mounted) return;

      setState(() {
        _daftarKamar = kamar;
        _isLoading = false;

        if (kamar.isNotEmpty) {
          _selectedKamarId =
              kamar.first.id;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Gagal mengambil data kamar: $e',
      );
    }
  }

  Future<void> _pilihTanggal() async {
    final tanggal =
    await showDatePicker(
      context: context,
      initialDate:
      _tanggalPerawatan,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (tanggal != null) {
      setState(() {
        _tanggalPerawatan =
            tanggal;
      });
    }
  }

  Future<void> _simpan() async {
    if (_selectedKamarId == null) {
      _showMessage(
        'Silakan pilih kamar.',
      );
      return;
    }

    final jenis =
    _jenisController.text.trim();

    if (jenis.isEmpty) {
      _showMessage(
        'Jenis perawatan harus diisi.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final maintenance =
      SupabaseMaintenanceModel(
        id: '',
        kamarId:
        _selectedKamarId!,
        jenisPerawatan:
        jenis,
        tanggalPerawatan:
        _tanggalPerawatan,
        teknisi:
        _teknisiController.text
            .trim()
            .isEmpty
            ? null
            : _teknisiController
            .text
            .trim(),
        status:
        _selectedStatus,
        catatan:
        _catatanController
            .text
            .trim()
            .isEmpty
            ? null
            : _catatanController
            .text
            .trim(),
      );

      await _service
          .tambahMaintenance(
        maintenance,
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Gagal menambahkan maintenance: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String _formatTanggal(
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
  void dispose() {
    _jenisController.dispose();
    _teknisiController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Tambah Maintenance',
          ),
        ),
        body: const Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Maintenance',
        ),
      ),
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .stretch,
          children: [
            DropdownButtonFormField<String>(
              value:
              _selectedKamarId,
              decoration:
              const InputDecoration(
                labelText: 'Kamar',
                border:
                OutlineInputBorder(),
              ),
              items:
              _daftarKamar.map(
                    (kamar) {
                  return DropdownMenuItem<
                      String>(
                    value: kamar.id,
                    child: Text(
                      '${kamar.nomorKamar} - ${kamar.tipeKamar ?? '-'}',
                    ),
                  );
                },
              ).toList(),
              onChanged:
                  (value) {
                setState(() {
                  _selectedKamarId =
                      value;
                });
              },
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
              _jenisController,
              decoration:
              const InputDecoration(
                labelText:
                'Jenis Perawatan',
                hintText:
                'Contoh: Servis AC',
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            InkWell(
              onTap:
              _pilihTanggal,
              child:
              InputDecorator(
                decoration:
                const InputDecoration(
                  labelText:
                  'Tanggal Perawatan',
                  border:
                  OutlineInputBorder(),
                ),
                child:
                Text(
                  _formatTanggal(
                    _tanggalPerawatan,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
              _teknisiController,
              decoration:
              const InputDecoration(
                labelText:
                'Teknisi',
                hintText:
                'Nama teknisi',
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            DropdownButtonFormField<String>(
              value:
              _selectedStatus,
              decoration:
              const InputDecoration(
                labelText:
                'Status',
                border:
                OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value:
                  'Terjadwal',
                  child:
                  Text(
                    'Terjadwal',
                  ),
                ),
                DropdownMenuItem(
                  value:
                  'Proses',
                  child:
                  Text(
                    'Proses',
                  ),
                ),
                DropdownMenuItem(
                  value:
                  'Selesai',
                  child:
                  Text(
                    'Selesai',
                  ),
                ),
                DropdownMenuItem(
                  value:
                  'Dibatalkan',
                  child:
                  Text(
                    'Dibatalkan',
                  ),
                ),
              ],
              onChanged:
                  (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedStatus =
                      value;
                });
              },
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
              _catatanController,
              maxLines: 3,
              decoration:
              const InputDecoration(
                labelText:
                'Catatan',
                hintText:
                'Catatan maintenance',
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            SizedBox(
              height: 50,
              child:
              ElevatedButton(
                onPressed:
                _isSaving
                    ? null
                    : _simpan,
                child:
                _isSaving
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child:
                  CircularProgressIndicator(
                    strokeWidth:
                    2,
                  ),
                )
                    : const Text(
                  'Simpan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}