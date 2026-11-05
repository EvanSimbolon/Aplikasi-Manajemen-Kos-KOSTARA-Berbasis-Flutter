import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:belajar_dart/ui/core/themes/app_theme.dart';

class FormPenghuniScreen extends StatefulWidget {
  const FormPenghuniScreen({super.key});

  @override
  State<FormPenghuniScreen> createState() => _FormPenghuniScreenState();
}

class _FormPenghuniScreenState extends State<FormPenghuniScreen> {
  final TextEditingController _tglMulaiController = TextEditingController();

  // Variable state untuk menyimpan status yang dipilih
  String _selectedStatus = 'Aktif';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _tglMulaiController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
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
            onPressed: () => Navigator.pop(context),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Nama Lengkap'),
            _buildInputField(hint: 'Masukkan nama lengkap'),

            const SizedBox(height: 16),
            _buildLabel('No. HP / WhatsApp'),
            _buildInputField(hint: 'Masukkan nomor HP', keyboardType: TextInputType.phone),

            const SizedBox(height: 16),
            _buildLabel('Pilih Kamar'),
            _buildInputField(hint: 'Contoh: Kamar 102'),

            const SizedBox(height: 16),
            _buildLabel('Tanggal Mulai Sewa'),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: _buildInputField(
                  controller: _tglMulaiController,
                  hint: 'dd/mm/yyyy',
                  suffixIcon: const Icon(Icons.calendar_month, color: AppTheme.primaryDark, size: 22),
                ),
              ),
            ),

            const SizedBox(height: 16),
            _buildLabel('Status'),

            // Dropdown Pilih Status (Aktif / Non-Aktif)
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedStatus,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryDark),
                style: const TextStyle(fontSize: 13, color: AppTheme.primaryDark, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.inputColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Aktif',
                    child: Text('Aktif'),
                  ),
                  DropdownMenuItem(
                    value: 'Non-Aktif',
                    child: Text('Non-Aktif'),
                  ),
                ],
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedStatus = newValue;
                    });
                  }
                },
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
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
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: AppTheme.primaryDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          filled: true,
          fillColor: AppTheme.inputColor,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}