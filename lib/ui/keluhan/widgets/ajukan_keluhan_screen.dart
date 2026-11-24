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
    'Lainnya',
  ];
  String? kategori;
  List<Map<String, dynamic>> fasilitasList = [];
  final fasilitasCtrl = TextEditingController();
  final deskripsiCtrl = TextEditingController();
  File? foto;
  bool memuatFasilitas = true;

  @override
  void initState() {
    super.initState();
    _muatFasilitas();
  }

  @override
  void dispose() {
    fasilitasCtrl.dispose();
    deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _muatFasilitas() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => memuatFasilitas = false);
      return;
    }

    try {
      final penyewaan = await client
          .from('penyewaan')
          .select('kamar_id')
          .eq('penghuni_id', user.id)
          .inFilter('status', ['aktif', 'menunggu_mulai'])
          .order('tanggal_mulai', ascending: false)
          .limit(1)
          .maybeSingle();

      final kamarId = penyewaan?['kamar_id'] as String?;
      if (kamarId == null) return;

      final fasilitas = await client
          .from('fasilitas_kamar')
          .select('id, jenis_fasilitas (nama_fasilitas)')
          .eq('kamar_id', kamarId)
          .order('id');

      if (!mounted) return;
      setState(() {
        fasilitasList = fasilitas
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      });
    } catch (error) {
      debugPrint('Gagal memuat fasilitas keluhan: $error');
    } finally {
      if (mounted) setState(() => memuatFasilitas = false);
    }
  }

  String _namaFasilitas(Map<String, dynamic> item) {
    final jenis = item['jenis_fasilitas'];
    if (jenis is Map && jenis['nama_fasilitas'] != null) {
      return jenis['nama_fasilitas'].toString();
    }
    return 'Fasilitas kamar';
  }

  String? _fasilitasIdUntukNama(String nama) {
    final dicari = nama.trim().toLowerCase();
    for (final item in fasilitasList) {
      if (_namaFasilitas(item).trim().toLowerCase() == dicari) {
        return item['id'] as String?;
      }
    }
    return null;
  }

  Future<void> pilihFoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => foto = File(picked.path));
  }

  bool loading = false;

  Future<void> kirimKeluhan() async {
    final fasilitasNama = fasilitasCtrl.text.trim();
    if (kategori == null ||
        fasilitasNama.isEmpty ||
        deskripsiCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kategori, fasilitas, dan deskripsi wajib diisi'),
        ),
      );
      return;
    }

    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Kamu belum login')));
      return;
    }

    final fasilitasId = _fasilitasIdUntukNama(fasilitasNama);

    setState(() => loading = true);
    try {
      await client.from('laporan_kerusakan').insert({
        'pelapor_id': user.id,
        'fasilitas_kamar_id': fasilitasId,
        if (fasilitasId == null) 'fasilitas_nama': fasilitasNama,
        'judul': kategori,
        'deskripsi': deskripsiCtrl.text.trim(),
        'status': 'dilaporkan',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Keluhan berhasil dikirim')));
      setState(() {
        kategori = null;
        fasilitasCtrl.clear();
        deskripsiCtrl.clear();
        foto = null;
      });
    } catch (e) {
      if (!mounted) return;
      final pesan = e is PostgrestException ? e.message : e.toString();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal mengirim: $pesan')));
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
          SectionCard(
            children: [
              const Text('Kategori Keluhan', style: labelStyle),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4DF), // warna kolom
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25), // kepekatan shadow
                      blurRadius: 6, // kelembutan shadow
                      offset: const Offset(0, 4), // arah shadow (x, y)
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: kategori,
                  isExpanded: true,
                  dropdownColor: const Color(
                    0xFFFFF4DF,
                  ), // warna daftar pilihan
                  borderRadius: BorderRadius.circular(10),
                  decoration: const InputDecoration(
                    border: InputBorder.none, // hilangkan garis bawaan
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: kategoriList
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => kategori = v),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Fasilitas Terkait', style: labelStyle),
              const SizedBox(height: 6),
              TextField(
                controller: fasilitasCtrl,
                style: const TextStyle(fontSize: 12),
                decoration: fieldDecoration(
                  hint: 'Contoh: AC kamar, kran bocor, lampu mati',
                ).copyWith(fillColor: const Color(0xFFFFF4DF)),
              ),
              if (memuatFasilitas)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: LinearProgressIndicator(),
                )
              else if (fasilitasList.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Belum ada fasilitas terdaftar. Tuliskan fasilitas secara manual.',
                    style: TextStyle(fontSize: 10),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Fasilitas terdaftar: '
                    '${fasilitasList.map(_namaFasilitas).join(', ')}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              const SizedBox(height: 12),
              const Text('Deskripsi', style: labelStyle),
              const SizedBox(height: 6),
              TextField(
                controller: deskripsiCtrl,
                maxLines: 5,
                decoration: fieldDecoration().copyWith(
                  fillColor: const Color(0xFFFFF4DF),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Foto (Opsional)', style: labelStyle),
              const SizedBox(height: 6),
              UploadBox(
                file: foto,
                highlighted: false,
                height: 130,
                onTap: pilihFoto,
              ),
            ],
          ),
          ActionButtons(
            onCancel: () => setState(() {
              kategori = null;
              fasilitasCtrl.clear();
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
