import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/services/fasilitas_kamar_service.dart';
import '../../domain/models/jenis_fasilitas_model.dart';
import '../../domain/models/supabase_fasilitas_kamar_model.dart';
import '../../domain/models/supabase_kamar_model.dart';

class TambahFasilitasKamarPage extends StatefulWidget {
  const TambahFasilitasKamarPage({super.key});

  @override
  State<TambahFasilitasKamarPage> createState() =>
      _TambahFasilitasKamarPageState();
}

class _TambahFasilitasKamarPageState
    extends State<TambahFasilitasKamarPage> {
  final FasilitasKamarService _service =
  FasilitasKamarService();

  final TextEditingController _jumlahController =
  TextEditingController(text: '1');

  final TextEditingController _kondisiController =
  TextEditingController();

  List<SupabaseKamarModel> _daftarKamar = [];
  List<JenisFasilitasModel> _daftarJenisFasilitas = [];

  String? _kamarId;
  int? _jenisFasilitasId;

  String _kondisi = 'Baik';

  DateTime? _tanggalPemasangan;

  bool _isLoading = true;
  bool _isSaving = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _kondisiController.dispose();
    super.dispose();
  }

  // ==========================================================
  // LOAD DATA KAMAR + JENIS FASILITAS
  // ==========================================================

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;

      final kamarData = await supabase
          .from('kamar')
          .select()
          .order('nomor_kamar');

      final kamar = (kamarData as List)
          .map(
            (item) => SupabaseKamarModel.fromMap(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();

      final jenis =
      await _service.getJenisFasilitas();

      if (!mounted) return;

      setState(() {
        _daftarKamar = kamar;
        _daftarJenisFasilitas = jenis;

        if (_daftarKamar.isNotEmpty) {
          _kamarId = _daftarKamar.first.id;
        }

        if (_daftarJenisFasilitas.isNotEmpty) {
          _jenisFasilitasId =
              _daftarJenisFasilitas.first.id;
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
        'Gagal mengambil data kamar dan fasilitas.\n\n$e';
      });
    }
  }

  // ==========================================================
  // SIMPAN
  // ==========================================================

  Future<void> _simpan() async {
    if (_kamarId == null) {
      _tampilkanPesan(
        'Silakan pilih kamar terlebih dahulu.',
      );
      return;
    }

    if (_jenisFasilitasId == null) {
      _tampilkanPesan(
        'Silakan pilih jenis fasilitas terlebih dahulu.',
      );
      return;
    }

    final jumlah = int.tryParse(
      _jumlahController.text.trim(),
    );

    if (jumlah == null || jumlah <= 0) {
      _tampilkanPesan(
        'Jumlah harus berupa angka lebih dari 0.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final fasilitas =
      SupabaseFasilitasKamarModel(
        id: '',
        kamarId: _kamarId!,
        jenisFasilitasId:
        _jenisFasilitasId!,
        jumlah: jumlah,
        kondisi: _kondisi,
        tanggalPemasangan:
        _tanggalPemasangan,
      );

      await _service.tambahFasilitasKamar(
        fasilitas,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Fasilitas berhasil ditambahkan.',
          ),
          backgroundColor:
          Color(0xFF2E7D32),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _tampilkanPesan(
        'Gagal menyimpan fasilitas:\n$e',
      );
    }
  }

  // ==========================================================
  // PILIH TANGGAL
  // ==========================================================

  Future<void> _pilihTanggal() async {
    final sekarang = DateTime.now();

    final hasil = await showDatePicker(
      context: context,
      initialDate:
      _tanggalPemasangan ?? sekarang,
      firstDate: DateTime(2000),
      lastDate:
      DateTime(sekarang.year + 5),
    );

    if (hasil != null) {
      setState(() {
        _tanggalPemasangan = hasil;
      });
    }
  }

  // ==========================================================
  // SNACKBAR
  // ==========================================================

  void _tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(pesan),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFFFF8D8),

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.fromLTRB(
                16,
                20,
                16,
                20,
              ),
              decoration:
              const BoxDecoration(
                color: Color(0xFF753924),
                borderRadius:
                BorderRadius.only(
                  bottomLeft:
                  Radius.circular(30),
                  bottomRight:
                  Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons
                          .arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 4),

                  const Expanded(
                    child: Text(
                      'Tambah Fasilitas Kamar',
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

            // ==================================================
            // CONTENT
            // ==================================================

            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding:
          const EdgeInsets.all(24),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 55,
                color: Color(0xFFB3261E),
              ),

              const SizedBox(height: 12),

              Text(
                _errorMessage!,
                textAlign:
                TextAlign.center,
                style: const TextStyle(
                  color:
                  Color(0xFF753924),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 18),

              ElevatedButton(
                onPressed: _loadData,
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF753924),
                  foregroundColor:
                  Colors.white,
                ),
                child:
                const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_daftarKamar.isEmpty) {
      return const Center(
        child: Padding(
          padding:
          EdgeInsets.all(24),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Icon(
                Icons
                    .meeting_room_outlined,
                size: 60,
                color: Color(0xFFB57514),
              ),

              SizedBox(height: 12),

              Text(
                'Belum ada data kamar.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.bold,
                  color:
                  Color(0xFF753924),
                ),
              ),

              SizedBox(height: 6),

              Text(
                'Tambahkan data kamar terlebih dahulu sebelum menambahkan fasilitas.',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color:
                  Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding:
      const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // ==================================================
          // KAMAR
          // ==================================================

          _buildLabel('Kamar'),

          const SizedBox(height: 8),

          DropdownButtonFormField<
              String>(
            value: _kamarId,
            decoration:
            _inputDecoration(
              'Pilih kamar',
              Icons
                  .meeting_room_rounded,
            ),
            items: _daftarKamar
                .map(
                  (kamar) =>
                  DropdownMenuItem<
                      String>(
                    value:
                    kamar.id,
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

          const SizedBox(height: 18),

          // ==================================================
          // JENIS FASILITAS
          // ==================================================

          _buildLabel(
            'Jenis Fasilitas',
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<
              int>(
            value:
            _jenisFasilitasId,
            decoration:
            _inputDecoration(
              'Pilih fasilitas',
              Icons
                  .home_repair_service_outlined,
            ),
            items:
            _daftarJenisFasilitas
                .map(
                  (jenis) =>
                  DropdownMenuItem<
                      int>(
                    value:
                    jenis.id,
                    child: Text(
                      jenis.namaFasilitas,
                    ),
                  ),
            )
                .toList(),
            onChanged: (value) {
              setState(() {
                _jenisFasilitasId =
                    value;
              });
            },
          ),

          const SizedBox(height: 18),

          // ==================================================
          // JUMLAH
          // ==================================================

          _buildLabel('Jumlah'),

          const SizedBox(height: 8),

          TextField(
            controller:
            _jumlahController,
            keyboardType:
            TextInputType.number,
            decoration:
            _inputDecoration(
              'Contoh: 1',
              Icons
                  .format_list_numbered,
            ),
          ),

          const SizedBox(height: 18),

          // ==================================================
          // KONDISI
          // ==================================================

          _buildLabel('Kondisi'),

          const SizedBox(height: 8),

          DropdownButtonFormField<
              String>(
            value: _kondisi,
            decoration:
            _inputDecoration(
              'Pilih kondisi',
              Icons
                  .build_circle_outlined,
            ),
            items: const [
              DropdownMenuItem(
                value: 'Baik',
                child: Text('Baik'),
              ),
              DropdownMenuItem(
                value: 'Rusak Ringan',
                child:
                Text('Rusak Ringan'),
              ),
              DropdownMenuItem(
                value: 'Rusak Berat',
                child:
                Text('Rusak Berat'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _kondisi = value;
                });
              }
            },
          ),

          const SizedBox(height: 18),

          // ==================================================
          // TANGGAL PEMASANGAN
          // ==================================================

          _buildLabel(
            'Tanggal Pemasangan',
          ),

          const SizedBox(height: 8),

          InkWell(
            onTap: _pilihTanggal,
            borderRadius:
            BorderRadius.circular(14),
            child: InputDecorator(
              decoration:
              _inputDecoration(
                'Pilih tanggal',
                Icons
                    .calendar_month_rounded,
              ),
              child: Text(
                _tanggalPemasangan ==
                    null
                    ? 'Belum dipilih'
                    : '${_tanggalPemasangan!.day}/'
                    '${_tanggalPemasangan!.month}/'
                    '${_tanggalPemasangan!.year}',
                style: TextStyle(
                  color:
                  _tanggalPemasangan ==
                      null
                      ? Colors.grey
                      : Colors.black87,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // ==================================================
          // SIMPAN
          // ==================================================

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
              _isSaving
                  ? null
                  : _simpan,
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                const Color(
                  0xFF753924,
                ),
                foregroundColor:
                Colors.white,
                disabledBackgroundColor:
                Colors.grey,
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
                width: 22,
                height: 22,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color:
                  Colors.white,
                ),
              )
                  : const Text(
                'Simpan Fasilitas',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ==========================================================
  // LABEL
  // ==========================================================

  Widget _buildLabel(
      String text,
      ) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight:
        FontWeight.bold,
        color:
        Color(0xFF753924),
      ),
    );
  }

  // ==========================================================
  // INPUT DECORATION
  // ==========================================================

  InputDecoration _inputDecoration(
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
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      border:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide:
        const BorderSide(
          color:
          Color(0xFFE5DECD),
        ),
      ),
      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide:
        const BorderSide(
          color:
          Color(0xFFE5DECD),
        ),
      ),
      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide:
        const BorderSide(
          color:
          Color(0xFF753924),
          width: 1.5,
        ),
      ),
    );
  }
}