import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  static const List<String> _tipeOptions = ['Standar', 'Deluxe'];
  String tipeKamar = 'Standar';
  File? _fotoDipilih;
  bool isSaving = false;

  @override
  void dispose() {
    nomorController.dispose();
    hargaController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pilihFoto() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null && mounted) {
        setState(() => _fotoDipilih = File(picked.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih foto: $e')),
      );
    }
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

      final kosId = await _service.getOwnerKosId();

      String? fotoUrl;
      if (_fotoDipilih != null) {
        fotoUrl = await _service.uploadFotoKamar(_fotoDipilih!, kosId);
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
        fotoUrl: fotoUrl,
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
          style: TextStyle(fontWeight: FontWeight.bold),
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

            const SizedBox(height: 16),

            // FOTO KAMAR
            const Text(
              'Foto Kamar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: isSaving ? null : _pilihFoto,
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDEC9A4)),
                ),
                clipBehavior: Clip.antiAlias,
                child: _fotoDipilih != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_fotoDipilih!, fit: BoxFit.cover),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                onPressed: () =>
                                    setState(() => _fotoDipilih = null),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 36,
                            color: Color(0xFF753924),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Ketuk untuk tambah foto kamar',
                            style: TextStyle(
                              color: Color(0xFF753924),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 18),

            // NOMOR KAMAR
            const Text(
              'Nomor Kamar',
              style: TextStyle(fontWeight: FontWeight.w600),
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
              style: TextStyle(fontWeight: FontWeight.w600),
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
              items: _tipeOptions
                  .map(
                    (tipe) => DropdownMenuItem(value: tipe, child: Text(tipe)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => tipeKamar = value);
                }
              },
            ),

            const SizedBox(height: 18),

            // HARGA
            const Text(
              'Harga Sewa Bulanan',
              style: TextStyle(fontWeight: FontWeight.w600),
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
              style: TextStyle(fontWeight: FontWeight.w600),
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
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF753924),
                      side: const BorderSide(color: Color(0xFF753924)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Simpan',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
