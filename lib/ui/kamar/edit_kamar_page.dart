import 'package:flutter/material.dart';

import 'package:belajar_dart/data/services/kamar_service.dart';
import 'package:belajar_dart/domain/models/supabase_kamar_model.dart';

class EditKamarPage extends StatefulWidget {
  final SupabaseKamarModel kamar;

  const EditKamarPage({
    super.key,
    required this.kamar,
  });

  @override
  State<EditKamarPage> createState() => _EditKamarPageState();
}

class _EditKamarPageState extends State<EditKamarPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nomorController;
  late final TextEditingController hargaController;
  late final TextEditingController deskripsiController;

  final KamarService _service = KamarService();

  late String tipeKamar;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    nomorController = TextEditingController(
      text: widget.kamar.nomorKamar,
    );

    hargaController = TextEditingController(
      text: widget.kamar.hargaSewaBulanan
          .toStringAsFixed(0),
    );

    deskripsiController = TextEditingController(
      text: widget.kamar.deskripsi ?? '',
    );

    tipeKamar = widget.kamar.tipeKamar ?? 'Standar';
  }

  @override
  void dispose() {
    nomorController.dispose();
    hargaController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  Future<void> simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final harga = double.tryParse(
        hargaController.text
            .replaceAll('.', '')
            .replaceAll(',', ''),
      );

      if (harga == null) {
        throw Exception('Harga sewa tidak valid.');
      }

      final kamarBaru = SupabaseKamarModel(
        id: widget.kamar.id,
        kosId: widget.kamar.kosId,
        nomorKamar: nomorController.text.trim(),
        tipeKamar: tipeKamar,
        hargaSewaBulanan: harga,
        deskripsi: deskripsiController.text.trim().isEmpty
            ? null
            : deskripsiController.text.trim(),
        dibuatPada: widget.kamar.dibuatPada,
        diperbaruiPada: widget.kamar.diperbaruiPada,
      );

      await _service.ubahKamar(kamarBaru);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data kamar berhasil diperbarui.'),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memperbarui kamar: $e',
          ),
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
          'Edit Kamar',
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
              'Edit Informasi Kamar',
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
                if (value == null ||
                    value.trim().isEmpty) {
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
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Harga sewa wajib diisi.';
                }

                final harga = double.tryParse(
                  value
                      .replaceAll('.', '')
                      .replaceAll(',', ''),
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
                hintText:
                'Contoh: Kamar standar dengan fasilitas dasar',
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
                      foregroundColor:
                      const Color(0xFF753924),
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
                    onPressed:
                    isSaving ? null : simpanPerubahan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFFFFB22C),
                      foregroundColor:
                      const Color(0xFF5A2A06),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Simpan Perubahan',
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