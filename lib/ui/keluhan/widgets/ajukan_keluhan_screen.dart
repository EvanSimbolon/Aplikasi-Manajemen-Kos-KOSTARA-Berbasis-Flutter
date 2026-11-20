import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:belajar_dart/ui/core/ui/common_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------- HALAMAN: AJUKAN KELUHAN ----------
class AjukanKeluhanScreen extends StatefulWidget {
  final VoidCallback onBack;
  const AjukanKeluhanScreen({super.key, required this.onBack});

  @override
  State<AjukanKeluhanScreen> createState() => _AjukanKeluhanScreenState();
}

class _AjukanKeluhanScreenState extends State<AjukanKeluhanScreen> {
  final kategoriList = [
    'Fasilitas Kamar',
    'Kebersihan',
    'Listrik & Air',
    'Keamanan',
    'Lainnya'
  ];
  String? kategori;
  final deskripsiCtrl = TextEditingController();
  File? foto;

  Future<void> pilihFoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => foto = File(picked.path));
  }
  bool loading = false;

  Future<void> kirimKeluhan() async {
    if (kategori == null || deskripsiCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori dan deskripsi wajib diisi')),
      );
      return;
    }

    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamu belum login')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      await client.from('laporan_kerusakan').insert({
        'pelapor_id': user.id,
        'judul': kategori,
        'deskripsi': deskripsiCtrl.text.trim(),
        'status': 'menunggu',
        // 'fasilitas_kamar_id': ...  (lihat catatan di bawah)
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keluhan berhasil dikirim')),
      );
      setState(() {
        kategori = null;
        deskripsiCtrl.clear();
        foto = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          PageHeader('Ajukan Keluhan', onBack: widget.onBack),
          SectionCard(children: [
            const Text('Kategori Keluhan', style: labelStyle),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4DF),        // warna kolom
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25), // kepekatan shadow
                    blurRadius: 6,                         // kelembutan shadow
                    offset: const Offset(0, 4),            // arah shadow (x, y)
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: kategori,
                isExpanded: true,
                dropdownColor: const Color(0xFFFFF4DF),   // warna daftar pilihan
                borderRadius: BorderRadius.circular(10),
                decoration: const InputDecoration(
                  border: InputBorder.none,               // hilangkan garis bawaan
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                icon: const Icon(Icons.keyboard_arrow_down),
                items: kategoriList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => kategori = v),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Deskripsi', style: labelStyle),
            const SizedBox(height: 6),
            TextField(
              controller: deskripsiCtrl,
              maxLines: 5,
              decoration: fieldDecoration().copyWith(fillColor: const Color(0xFFFFF4DF)),
            ),
            const SizedBox(height: 12),
            const Text('Foto (Opsional)', style: labelStyle),
            const SizedBox(height: 6),
            UploadBox(
                file: foto, highlighted: false, height: 130, onTap: pilihFoto),
          ]),
          ActionButtons(
            onCancel: () => setState(() {
              kategori = null;
              deskripsiCtrl.clear();
              foto = null;
            }),
            onSubmit: loading ? () {} : kirimKeluhan,
          ),
        ],
      ),
    );
  }
}
