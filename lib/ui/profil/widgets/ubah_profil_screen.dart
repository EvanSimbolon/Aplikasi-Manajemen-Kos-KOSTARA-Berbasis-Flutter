import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:belajar_dart/data/services/image_picker_service.dart';
import 'package:belajar_dart/ui/core/themes/app_colors.dart';
import 'package:belajar_dart/ui/core/ui/common_widgets.dart';
import 'package:belajar_dart/ui/profil/view_models/profil_view_model.dart';

// ---------- HALAMAN: UBAH PROFIL ----------
class UbahProfilScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSaved;
  const UbahProfilScreen(
      {super.key, required this.onBack, required this.onSaved});

  @override
  State<UbahProfilScreen> createState() => _UbahProfilScreenState();
}

class _UbahProfilScreenState extends State<UbahProfilScreen> {
  // Sementara untuk testing tanpa login: salin satu id dari tabel `pengguna`
  static const String _penggunaId = 'PASTE-UUID-PENGGUNA';

  final ProfilViewModel _viewModel = ProfilViewModel();
  final ImagePickerService _imagePicker = ImagePickerService();
  late final TextEditingController namaCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController telpCtrl;
  late final TextEditingController kamarCtrl;
  File? foto;
  String? fotoUrl;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    final profil = _viewModel.profil;
    namaCtrl = TextEditingController(text: profil.nama);
    emailCtrl = TextEditingController(text: profil.email);
    telpCtrl = TextEditingController(text: profil.telp);
    kamarCtrl = TextEditingController(text: profil.kamar);
    muatProfil();
  }

  Future<void> muatProfil() async {
    try {
      final row = await Supabase.instance.client
          .from('pengguna')
          .select('nama_lengkap, email, nomor_telepon, profil_pengguna(foto_url)')
          .eq('id', _penggunaId)
          .single();

      String? url;
      final profil = row['profil_pengguna'];
      if (profil is Map<String, dynamic>) {
        url = profil['foto_url'] as String?;
      } else if (profil is List && profil.isNotEmpty) {
        url = (profil.first as Map<String, dynamic>)['foto_url'] as String?;
      }

      if (!mounted) return;
      setState(() {
        namaCtrl.text = '${row['nama_lengkap'] ?? ''}';
        emailCtrl.text = '${row['email'] ?? ''}';
        telpCtrl.text = '${row['nomor_telepon'] ?? ''}';
        fotoUrl = (url != null && url.isNotEmpty) ? url : null;
      });
    } catch (e) {
      debugPrint('Gagal memuat profil: $e');
    }
  }

  Future<void> pilihFoto() async {
    final picked = await _imagePicker.pickImageFromGallery();
    if (picked != null) setState(() => foto = picked);
  }

  Future<void> simpan() async {
    if (namaCtrl.text.trim().isEmpty ||
        !emailCtrl.text.contains('@') ||
        telpCtrl.text.trim().isEmpty) {
      showSnack(context, 'Nama, email (valid), dan telepon wajib diisi');
      return;
    }

    setState(() => loading = true);
    try {
      final client = Supabase.instance.client;
      String? urlBaru;

      // 1. Upload foto kalau ada yang baru dipilih
      if (foto != null) {
        final nama = foto!.path.split(RegExp(r'[\\/]')).last;
        final ext = nama.contains('.') ? nama.split('.').last : 'jpg';
        final path =
            '$_penggunaId/${DateTime.now().millisecondsSinceEpoch}.$ext';
        await client.storage.from('foto-profil').upload(path, foto!);
        urlBaru = client.storage.from('foto-profil').getPublicUrl(path);
      }

      // 2. Update data dasar (email tidak diubah)
      await client.from('pengguna').update({
        'nama_lengkap': namaCtrl.text.trim(),
        'nomor_telepon': telpCtrl.text.trim(),
      }).eq('id', _penggunaId);

      // 3. Simpan foto di profil_pengguna
      if (urlBaru != null) {
        await client.from('profil_pengguna').upsert({
          'pengguna_id': _penggunaId,
          'foto_url': urlBaru,
        });
      }

      _viewModel.simpan(
        nama: namaCtrl.text,
        email: emailCtrl.text,
        telp: telpCtrl.text,
      );

      if (!mounted) return;
      showSnack(context, 'Profil tersimpan');
      widget.onSaved();
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    namaCtrl.dispose();
    emailCtrl.dispose();
    telpCtrl.dispose();
    kamarCtrl.dispose();
    super.dispose();
  }

  Widget field(String label, TextEditingController c,
      {TextInputType? type, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            keyboardType: type,
            readOnly: readOnly,
            style: const TextStyle(fontSize: 12),
            decoration: fieldDecoration(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? gambar;
    if (foto != null) {
      gambar = FileImage(foto!);
    } else if (fotoUrl != null) {
      gambar = NetworkImage(fotoUrl!);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          PageHeader('Ubah Profil', onBack: widget.onBack),
          SectionCard(children: [
            Center(
              child: GestureDetector(
                onTap: pilihFoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: profilPict,
                      backgroundImage: gambar,
                      child: gambar == null
                          ? const Icon(Icons.person,
                          color: Colors.white, size: 48)
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            color: Colors.black, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text('Ketuk untuk ganti foto',
                  style: TextStyle(fontSize: 10)),
            ),
            const SizedBox(height: 16),
            field('Nama Lengkap', namaCtrl),
            field('Email', emailCtrl,
                type: TextInputType.emailAddress, readOnly: true),
            field('No. Telepon', telpCtrl, type: TextInputType.phone),
            field('Nomor Kamar', kamarCtrl, readOnly: true),
          ]),
          ActionButtons(
            submitLabel: 'Simpan',
            onCancel: widget.onBack,
            onSubmit: loading ? () {} : simpan,
          ),
        ],
      ),
    );
  }
}