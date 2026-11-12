import 'package:flutter/material.dart';

import 'package:belajar_dart/data/services/kamar_service.dart';
import 'package:belajar_dart/domain/models/supabase_kamar_model.dart';

class TambahKamarPage extends StatefulWidget {
  const TambahKamarPage({super.key});

  @override
  State<TambahKamarPage> createState() => _TambahKamarPageState();
}

class _TambahKamarPageState extends State<TambahKamarPage> {
  final _formKey = GlobalKey<FormState>();

  final nomorController = TextEditingController();
  final hargaController = TextEditingController();
  final deskripsiController = TextEditingController();

  final KamarService _service = KamarService();

  String tipeKamar = 'Standar';
  bool isSaving = false;

  // ID kos yang sedang digunakan.
  // Untuk sementara menggunakan kos_id yang sudah terbukti
  // memiliki data A01-A04 di Supabase.
  final String kosId = '57529c5c-d679-4bed-bcad-d21cd076113c';

  @override
  void dispose() {
    nomorController.dispose();
    hargaController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  Future<void> simpanKamar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final harga = double.tryParse(
        hargaController.text.replaceAll('.', '').replaceAll(',', ''),
      );

      if (harga == null) {
        throw Exception('Harga sewa tidak valid.');
      }

      final kamar = SupabaseKamarModel(
        id: '',
        kosId: kosId,
        nomorKamar: nomorController.text.trim(),
        tipeKamar: tipeKamar,
        hargaSewaBulanan: harga,
        deskripsi: deskripsiController.text.trim().isEmpty
            ? null
            : deskripsiController.text.trim(),
      );

      await _service.tambahKamar(kamar);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kamar berhasil ditambahkan.'),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan kamar: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8D8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF753924),
        foregroundColor: Colors.white,
        title: const Text(
          'Tambah Kamar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Informasi Kamar',
              style: TextStyle(
                color: Color(0xFF753924),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // NOMOR KAMAR
            const Text(
              'Nomor Kamar',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextFormField(
              controller: nomorController,
              decoration: InputDecoration(
                hintText: 'Contoh: A05',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nomor kamar wajib diisi.';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // TIPE KAMAR
            const Text(
              'Tipe Kamar',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: tipeKamar,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Standar',
                  child: Text('Standar'),
                ),
                DropdownMenuItem(
                  value: 'Deluxe',
                  child: Text('Deluxe'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    tipeKamar = value;
                  });
                }
              },
            ),

            const SizedBox(height: 18),

            // HARGA
            const Text(
              'Harga Sewa Bulanan',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextFormField(
              controller: hargaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Contoh: 1000000',
                prefixText: 'Rp ',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Harga sewa wajib diisi.';
                }

                final harga = double.tryParse(
                  value.replaceAll('.', '').replaceAll(',', ''),
                );

                if (harga == null || harga < 0) {
                  return 'Masukkan harga yang valid.';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            // DESKRIPSI
            const Text(
              'Deskripsi',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextFormField(
              controller: deskripsiController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Contoh: Kamar standar dengan fasilitas dasar',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // TOMBOL
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSaving
                        ? null
                        : () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF753924),
                      side: const BorderSide(
                        color: Color(0xFF753924),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: isSaving ? null : simpanKamar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB22C),
                      foregroundColor: const Color(0xFF5A2A06),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Simpan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
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
}