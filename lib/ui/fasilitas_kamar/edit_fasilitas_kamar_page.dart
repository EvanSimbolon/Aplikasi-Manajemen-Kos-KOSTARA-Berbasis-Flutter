import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/services/fasilitas_kamar_service.dart';
import '../../domain/models/jenis_fasilitas_model.dart';
import '../../domain/models/supabase_fasilitas_kamar_model.dart';
import '../../domain/models/supabase_kamar_model.dart';

class EditFasilitasKamarPage extends StatefulWidget {
  const EditFasilitasKamarPage({
    super.key,
    required this.fasilitas,
  });

  final SupabaseFasilitasKamarModel fasilitas;

  @override
  State<EditFasilitasKamarPage> createState() =>
      _EditFasilitasKamarPageState();
}

class _EditFasilitasKamarPageState
    extends State<EditFasilitasKamarPage> {
  final FasilitasKamarService _service =
  FasilitasKamarService();

  final SupabaseClient _supabase =
      Supabase.instance.client;

  final TextEditingController _jumlahController =
  TextEditingController();

  final TextEditingController _kondisiController =
  TextEditingController();

  List<SupabaseKamarModel> _daftarKamar = [];
  List<JenisFasilitasModel> _daftarJenisFasilitas = [];

  String? _selectedKamarId;
  int? _selectedJenisFasilitasId;

  DateTime? _tanggalPemasangan;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _jumlahController.text =
        widget.fasilitas.jumlah.toString();

    _kondisiController.text =
        widget.fasilitas.kondisi;

    _tanggalPemasangan =
        widget.fasilitas.tanggalPemasangan;

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final kamar = await _loadKamar();
      final jenis =
      await _service.getJenisFasilitas();

      if (!mounted) return;

      setState(() {
        _daftarKamar = kamar;
        _daftarJenisFasilitas = jenis;

        if (kamar.any(
              (item) =>
          item.id == widget.fasilitas.kamarId,
        )) {
          _selectedKamarId =
              widget.fasilitas.kamarId;
        }

        if (jenis.any(
              (item) =>
          item.id ==
              widget.fasilitas.jenisFasilitasId,
        )) {
          _selectedJenisFasilitasId =
              widget.fasilitas.jenisFasilitasId;
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Gagal mengambil data: $e',
      );
    }
  }

  Future<List<SupabaseKamarModel>> _loadKamar() async {
    final data = await _supabase
        .from('kamar')
        .select()
        .order('nomor_kamar');

    return (data as List)
        .map(
          (item) =>
          SupabaseKamarModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
    )
        .toList();
  }

  Future<void> _simpan() async {
    if (_selectedKamarId == null) {
      _showMessage(
        'Silakan pilih kamar.',
      );
      return;
    }

    if (_selectedJenisFasilitasId == null) {
      _showMessage(
        'Silakan pilih jenis fasilitas.',
      );
      return;
    }

    final jumlah = int.tryParse(
      _jumlahController.text.trim(),
    );

    if (jumlah == null || jumlah <= 0) {
      _showMessage(
        'Jumlah harus berupa angka lebih dari 0.',
      );
      return;
    }

    final kondisi =
    _kondisiController.text.trim();

    if (kondisi.isEmpty) {
      _showMessage(
        'Kondisi fasilitas harus diisi.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final fasilitas =
      SupabaseFasilitasKamarModel(
        id: widget.fasilitas.id,
        kamarId: _selectedKamarId!,
        jenisFasilitasId:
        _selectedJenisFasilitasId!,
        jumlah: jumlah,
        kondisi: kondisi,
        tanggalPemasangan:
        _tanggalPemasangan,
      );

      await _service.ubahFasilitasKamar(
        fasilitas,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Gagal mengubah fasilitas: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _pilihTanggal() async {
    final tanggal =
    await showDatePicker(
      context: context,
      initialDate:
      _tanggalPemasangan ??
          DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (tanggal != null) {
      setState(() {
        _tanggalPemasangan = tanggal;
      });
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
      DateTime? tanggal,
      ) {
    if (tanggal == null) {
      return 'Pilih tanggal pemasangan';
    }

    final day =
    tanggal.day.toString().padLeft(2, '0');

    final month =
    tanggal.month.toString().padLeft(2, '0');

    return '$day/$month/${tanggal.year}';
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _kondisiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Fasilitas Kamar',
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Fasilitas Kamar',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedKamarId,
              decoration:
              const InputDecoration(
                labelText: 'Kamar',
                border:
                OutlineInputBorder(),
              ),
              items: _daftarKamar.map(
                    (kamar) {
                  return DropdownMenuItem<String>(
                    value: kamar.id,
                    child: Text(
                      '${kamar.nomorKamar} - ${kamar.tipeKamar ?? 'Tidak ada tipe'}',
                    ),
                  );
                },
              ).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedKamarId = value;
                });
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              value:
              _selectedJenisFasilitasId,
              decoration:
              const InputDecoration(
                labelText:
                'Jenis Fasilitas',
                border:
                OutlineInputBorder(),
              ),
              items:
              _daftarJenisFasilitas.map(
                    (jenis) {
                  return DropdownMenuItem<int>(
                    value: jenis.id,
                    child: Text(
                      jenis.namaFasilitas,
                    ),
                  );
                },
              ).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedJenisFasilitasId =
                      value;
                });
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
              _jumlahController,
              keyboardType:
              TextInputType.number,
              decoration:
              const InputDecoration(
                labelText: 'Jumlah',
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
              _kondisiController,
              decoration:
              const InputDecoration(
                labelText: 'Kondisi',
                hintText:
                'Contoh: Baik',
                border:
                OutlineInputBorder(),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            InkWell(
              onTap: _pilihTanggal,
              child: InputDecorator(
                decoration:
                const InputDecoration(
                  labelText:
                  'Tanggal Pemasangan',
                  border:
                  OutlineInputBorder(),
                ),
                child: Text(
                  _formatTanggal(
                    _tanggalPemasangan,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed:
                _isSaving
                    ? null
                    : _simpan,
                child: _isSaving
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Simpan Perubahan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}