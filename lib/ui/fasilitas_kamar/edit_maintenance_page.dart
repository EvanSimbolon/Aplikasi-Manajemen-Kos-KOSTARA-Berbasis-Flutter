import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/services/maintenance_service.dart';
import '../../domain/models/supabase_kamar_model.dart';
import '../../domain/models/supabase_maintenance_model.dart';

class EditMaintenancePage extends StatefulWidget {
  final SupabaseMaintenanceModel maintenance;

  const EditMaintenancePage({
    super.key,
    required this.maintenance,
  });

  @override
  State<EditMaintenancePage> createState() =>
      _EditMaintenancePageState();
}

class _EditMaintenancePageState
    extends State<EditMaintenancePage> {
  final MaintenanceService _service =
  MaintenanceService();

  final TextEditingController _teknisiController =
  TextEditingController();

  final TextEditingController _catatanController =
  TextEditingController();

  List<SupabaseKamarModel> _daftarKamar = [];

  String? _kamarId;

  late String _jenisPerawatan;
  late String _status;
  late DateTime _tanggalPerawatan;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _kamarId = widget.maintenance.kamarId;

    _jenisPerawatan =
        widget.maintenance.jenisPerawatan;

    _status = widget.maintenance.status;

    _tanggalPerawatan =
        widget.maintenance.tanggalPerawatan;

    _teknisiController.text =
        widget.maintenance.teknisi ?? '';

    _catatanController.text =
        widget.maintenance.catatan ?? '';

    _loadKamar();
  }

  @override
  void dispose() {
    _teknisiController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _loadKamar() async {
    try {
      final data = await Supabase.instance.client
          .from('kamar')
          .select()
          .order('nomor_kamar');

      final kamar = (data as List)
          .map(
            (item) => SupabaseKamarModel.fromMap(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();

      if (!mounted) return;

      setState(() {
        _daftarKamar = kamar;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _pesan(
        'Gagal mengambil data kamar: $e',
      );
    }
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggalPerawatan,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (hasil != null) {
      setState(() {
        _tanggalPerawatan = hasil;
      });
    }
  }

  Future<void> _simpan() async {
    if (_kamarId == null) {
      _pesan('Silakan pilih kamar.');
      return;
    }

    if (_jenisPerawatan.trim().isEmpty) {
      _pesan('Silakan pilih jenis perawatan.');
      return;
    }

    if (_status.trim().isEmpty) {
      _pesan('Silakan pilih status.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final data = SupabaseMaintenanceModel(
        id: widget.maintenance.id,
        kamarId: _kamarId!,
        jenisPerawatan:
        _jenisPerawatan.trim(),
        tanggalPerawatan:
        _tanggalPerawatan,
        teknisi:
        _teknisiController.text.trim().isEmpty
            ? null
            : _teknisiController.text.trim(),
        status: _status.trim(),
        catatan:
        _catatanController.text.trim().isEmpty
            ? null
            : _catatanController.text.trim(),
      );

      await _service.ubahMaintenance(data);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Maintenance berhasil diperbarui.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _pesan(
        'Gagal memperbarui data:\n$e',
      );
    }
  }

  void _pesan(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFFFF8D8),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                16,
                20,
                16,
                20,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF753924),
                borderRadius: BorderRadius.only(
                  bottomLeft:
                  Radius.circular(30),
                  bottomRight:
                  Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Edit Maintenance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                child:
                CircularProgressIndicator(),
              )
                  : _buildForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    final bool kamarMasihAda =
    _daftarKamar.any(
          (kamar) => kamar.id == _kamarId,
    );

    final String? selectedKamar =
    kamarMasihAda ? _kamarId : null;

    /*
     * FIX UTAMA:
     *
     * Data lama bisa saja berisi:
     * "service ac"
     *
     * sedangkan daftar pilihan awal hanya:
     * AC
     * Kipas Angin
     * Listrik
     * Lainnya
     *
     * Flutter akan error jika value tidak ada
     * di dalam items.
     *
     * Jadi nilai lama otomatis ditambahkan
     * ke daftar pilihan.
     */
    final List<String> jenisPerawatanOptions = [
      'AC',
      'Kipas Angin',
      'Listrik',
      'Lainnya',
    ];

    if (_jenisPerawatan.trim().isNotEmpty &&
        !jenisPerawatanOptions.contains(
          _jenisPerawatan,
        )) {
      jenisPerawatanOptions.insert(
        0,
        _jenisPerawatan,
      );
    }

    final List<String> statusOptions = [
      'Terjadwal',
      'Berlangsung',
      'Selesai',
      'Dibatalkan',
    ];

    if (_status.trim().isNotEmpty &&
        !statusOptions.contains(_status)) {
      statusOptions.insert(
        0,
        _status,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _label('Kamar'),
          const SizedBox(height: 8),

          _dropdownContainer(
            icon: Icons.meeting_room_rounded,
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedKamar,
              underline: const SizedBox(),
              hint: const Text(
                'Pilih kamar',
              ),
              items: _daftarKamar
                  .map(
                    (kamar) =>
                    DropdownMenuItem<String>(
                      value: kamar.id,
                      child: Text(
                        '${kamar.nomorKamar} - ${kamar.tipeKamar ?? 'Tanpa tipe'}',
                      ),
                    ),
              )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _kamarId = value;
                });
              },
            ),
          ),

          const SizedBox(height: 18),

          _label('Jenis Perawatan'),
          const SizedBox(height: 8),

          _dropdownContainer(
            icon: Icons.build_rounded,
            child: DropdownButton<String>(
              isExpanded: true,
              value: _jenisPerawatan,
              underline: const SizedBox(),
              hint: const Text(
                'Pilih jenis perawatan',
              ),
              items: jenisPerawatanOptions
                  .map(
                    (jenis) =>
                    DropdownMenuItem<String>(
                      value: jenis,
                      child: Text(jenis),
                    ),
              )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _jenisPerawatan =
                        value;
                  });
                }
              },
            ),
          ),

          const SizedBox(height: 18),

          _label('Tanggal Perawatan'),
          const SizedBox(height: 8),

          InkWell(
            onTap: _pilihTanggal,
            child: InputDecorator(
              decoration: _decoration(
                'Tanggal',
                Icons.calendar_month,
              ),
              child: Text(
                '${_tanggalPerawatan.day}/${_tanggalPerawatan.month}/${_tanggalPerawatan.year}',
              ),
            ),
          ),

          const SizedBox(height: 18),

          _label('Teknisi'),
          const SizedBox(height: 8),

          TextField(
            controller: _teknisiController,
            decoration: _decoration(
              'Nama teknisi',
              Icons.person_outline,
            ),
          ),

          const SizedBox(height: 18),

          _label('Status'),
          const SizedBox(height: 8),

          _dropdownContainer(
            icon: Icons.flag_outlined,
            child: DropdownButton<String>(
              isExpanded: true,
              value: _status,
              underline: const SizedBox(),
              hint: const Text(
                'Pilih status',
              ),
              items: statusOptions
                  .map(
                    (status) =>
                    DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    ),
              )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _status = value;
                  });
                }
              },
            ),
          ),

          const SizedBox(height: 18),

          _label('Catatan'),
          const SizedBox(height: 8),

          TextField(
            controller: _catatanController,
            maxLines: 4,
            decoration: _decoration(
              'Catatan',
              Icons.notes_outlined,
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
              _isSaving ? null : _simpan,
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF753924),
                foregroundColor:
                Colors.white,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                width: 24,
                height: 24,
                child:
                CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                'Simpan Perubahan',
                style: TextStyle(
                  fontWeight:
                  FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _dropdownContainer({
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFBDBDBD),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
            const Color(0xFFB57514),
          ),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight:
        FontWeight.bold,
        color:
        Color(0xFF753924),
        fontSize: 16,
      ),
    );
  }

  InputDecoration _decoration(
      String hint,
      IconData icon,
      ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color:
        const Color(0xFFB57514),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFBDBDBD),
        ),
      ),
      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFBDBDBD),
        ),
      ),
      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF753924),
          width: 2,
        ),
      ),
    );
  }
}