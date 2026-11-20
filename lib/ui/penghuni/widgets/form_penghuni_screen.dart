import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:belajar_dart/data/services/undangan_service.dart';
import 'package:belajar_dart/ui/core/themes/app_theme.dart';

class FormPenghuniScreen extends StatefulWidget {
  const FormPenghuniScreen({super.key});

  @override
  State<FormPenghuniScreen> createState() => _FormPenghuniScreenState();
}

class _FormPenghuniScreenState extends State<FormPenghuniScreen> {
  final _service = UndanganService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tglMulaiController = TextEditingController();

  DateTime? _tanggalMulai;
  bool _aktif = true;

  // Daftar kamar kosong yang benar-benar ada di database.
  List<KamarTersedia> _kamarList = const [];
  KamarTersedia? _selectedKamar;
  bool _memuatKamar = true;
  String? _errorKamar;

  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _muatKamar();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hpController.dispose();
    _emailController.dispose();
    _tglMulaiController.dispose();
    super.dispose();
  }

  Future<void> _muatKamar() async {
    setState(() {
      _memuatKamar = true;
      _errorKamar = null;
    });
    try {
      final daftar = await _service.daftarKamarTersedia();
      if (!mounted) return;
      setState(() {
        _kamarList = daftar;
        _memuatKamar = false;
        if (_selectedKamar != null &&
            !daftar.any((k) => k.id == _selectedKamar!.id)) {
          _selectedKamar = null;
        }
      });
    } on UndanganException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorKamar = e.pesan;
        _memuatKamar = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalMulai ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _tanggalMulai = picked;
        _tglMulaiController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final kamar = _selectedKamar;
    if (kamar == null) {
      _tampilkanError('Pilih kamar yang masih kosong terlebih dahulu');
      return;
    }
    if (_tanggalMulai == null) {
      _tampilkanError('Tanggal mulai sewa wajib dipilih');
      return;
    }

    setState(() => _menyimpan = true);

    try {
      // Edge Function membuat akun login + menulis undangan ke
      // tabel undangan_penghuni, lalu mengembalikan token untuk penghuni.
      final hasil = await _service.buatUndangan(
        nama: _namaController.text.trim(),
        telepon: _hpController.text.trim(),
        email: _emailController.text.trim(),
        kamar: kamar,
        tanggalMulai: _tanggalMulai!,
        aktif: _aktif,
      );

      if (!mounted) return;
      await _dialogToken(hasil);

      if (!mounted) return;
      Navigator.pop(context, true); // true -> halaman daftar refresh
    } on UndanganException catch (e) {
      _tampilkanError(e.pesan);
    } catch (e) {
      debugPrint('Tambah penghuni gagal: $e');
      _tampilkanError('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  void _tampilkanError(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), backgroundColor: Colors.red.shade700),
    );
  }

  /// Token undangan untuk diserahkan admin ke penghuni.
  Future<void> _dialogToken(HasilUndangan hasil) {
    final berlaku = hasil.berlakuSampai == null
        ? null
        : DateFormat('dd/MM/yyyy HH:mm').format(hasil.berlakuSampai!);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Undangan berhasil dibuat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Berikan data berikut kepada penghuni:'),
            const SizedBox(height: 12),
            const Text('Nama', style: TextStyle(fontWeight: FontWeight.bold)),
            SelectableText(hasil.nama),
            const SizedBox(height: 8),
            const Text(
              'Email / No. HP login',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SelectableText(hasil.email),
            const SizedBox(height: 8),
            const Text('Token', style: TextStyle(fontWeight: FontWeight.bold)),
            SelectableText(
              hasil.token,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: AppTheme.primaryOrange,
              ),
            ),
            if (berlaku != null) ...[
              const SizedBox(height: 8),
              Text(
                'Berlaku sampai $berlaku',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
            const SizedBox(height: 8),
            const Text(
              'Token hanya ditampilkan sekali ini.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Clipboard.setData(
              ClipboardData(
                text: 'Email: ${hasil.email}\nToken: ${hasil.token}',
              ),
            ),
            child: const Text('Salin'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Navigasi Atas (AppBar) Ukuran Besar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppTheme.primaryDark,
              size: 24,
            ),
            onPressed: _menyimpan ? null : () => Navigator.pop(context),
          ),
          title: const Text(
            'Tambah Penghuni',
            style: TextStyle(
              color: AppTheme.primaryDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Nama Lengkap'),
              _buildInputField(
                controller: _namaController,
                hint: 'Masukkan nama lengkap',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),

              const SizedBox(height: 16),
              _buildLabel('No. HP / WhatsApp'),
              _buildInputField(
                controller: _hpController,
                hint: 'Masukkan nomor HP',
                keyboardType: TextInputType.phone,
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Nomor HP wajib diisi';
                  if (!RegExp(r'^[0-9+]{9,15}$').hasMatch(t)) {
                    return 'Nomor HP tidak valid';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              _buildLabel('Email'),
              _buildInputField(
                controller: _emailController,
                hint: 'Untuk akun login penghuni',
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Email wajib diisi';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              _buildLabel('Pilih Kamar Kosong'),
              _buildKamarField(),

              const SizedBox(height: 16),
              _buildLabel('Tanggal Mulai Sewa'),
              GestureDetector(
                onTap: _menyimpan ? null : () => _selectDate(context),
                child: AbsorbPointer(
                  child: _buildInputField(
                    controller: _tglMulaiController,
                    hint: 'dd/mm/yyyy',
                    suffixIcon: const Icon(
                      Icons.calendar_month,
                      color: AppTheme.primaryDark,
                      size: 22,
                    ),
                    validator: (v) => _tanggalMulai == null
                        ? 'Tanggal mulai wajib dipilih'
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              _buildLabel('Status Penghuni'),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.inputColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: Text(
                    _aktif ? 'Aktif' : 'Nonaktif',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  value: _aktif,
                  activeColor: AppTheme.primaryOrange,
                  onChanged: _menyimpan
                      ? null
                      : (v) => setState(() => _aktif = v),
                ),
              ),

              const SizedBox(height: 36),

              // Tombol Batal & Simpan
              Row(
                children: [
                  // Tombol Batal
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFFFAF7F2),
                        side: const BorderSide(
                          color: AppTheme.primaryOrange,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _menyimpan
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: AppTheme.primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Tombol Simpan
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppTheme.primaryOrange,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _menyimpan ? null : _simpan,
                      child: _menyimpan
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryDark,
                              ),
                            )
                          : const Text(
                              'Simpan',
                              style: TextStyle(
                                color: AppTheme.primaryDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKamarField() {
    if (_memuatKamar) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              'Memuat kamar kosong...',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    if (_errorKamar != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _errorKamar!,
            style: TextStyle(fontSize: 12, color: Colors.red.shade700),
          ),
          TextButton.icon(
            onPressed: _menyimpan ? null : _muatKamar,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Muat ulang'),
          ),
        ],
      );
    }

    if (_kamarList.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tidak ada kamar kosong saat ini.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          TextButton.icon(
            onPressed: _menyimpan ? null : _muatKamar,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Muat ulang'),
          ),
        ],
      );
    }

    final rupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedKamar?.id,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppTheme.primaryDark,
        ),
        style: const TextStyle(
          fontSize: 13,
          color: AppTheme.primaryDark,
          fontFamily: 'Inter',
        ),
        decoration: InputDecoration(
          hintText: 'Pilih kamar',
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          filled: true,
          fillColor: AppTheme.inputColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        items: _kamarList.map((kamar) {
          final tipe = (kamar.tipeKamar ?? '').trim();
          final label = tipe.isEmpty
              ? '${kamar.nomorKamar} • ${rupiah.format(kamar.hargaSewaBulanan)}'
              : '${kamar.nomorKamar} • $tipe • ${rupiah.format(kamar.hargaSewaBulanan)}';
          return DropdownMenuItem(value: kamar.id, child: Text(label));
        }).toList(),
        validator: (v) => v == null ? 'Kamar wajib dipilih' : null,
        onChanged: _menyimpan
            ? null
            : (id) {
                if (id == null) return;
                setState(() {
                  _selectedKamar = _kamarList.firstWhere(
                    (kamar) => kamar.id == id,
                  );
                });
              },
      ),
    );
  }

  Widget _buildLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: AppTheme.primaryDark,
        ),
      ),
    );
  }

  Widget _buildInputField({
    TextEditingController? controller,
    required String hint,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: !_menyimpan,
        validator: validator,
        style: const TextStyle(fontSize: 13, color: AppTheme.primaryDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          filled: true,
          fillColor: AppTheme.inputColor,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
