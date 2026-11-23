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
  const UbahProfilScreen({
    super.key,
    required this.onBack,
    required this.onSaved,
  });

  @override
  State<UbahProfilScreen> createState() => _UbahProfilScreenState();
}

class _UbahProfilScreenState extends State<UbahProfilScreen> {
  final ProfilViewModel _viewModel = ProfilViewModel();
  final ImagePickerService _imagePicker = ImagePickerService();
  late final TextEditingController namaCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController telpCtrl;
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
    _muatProfil();
  }

  Future<void> _muatProfil() async {
    await _viewModel.load();
    if (!mounted) return;

    setState(() {
      namaCtrl.text = _viewModel.profil.nama;
      emailCtrl.text = _viewModel.profil.email;
      telpCtrl.text = _viewModel.profil.telp;
      fotoUrl = _viewModel.profil.fotoUrl;
    });
  }

  Future<void> pilihFoto() async {
    final picked = await _imagePicker.pickImageFromGallery();
    if (picked != null) setState(() => foto = picked);
  }

  Future<void> simpan() async {
    if (loading) return;
    if (namaCtrl.text.trim().isEmpty ||
        !emailCtrl.text.contains('@') ||
        telpCtrl.text.trim().isEmpty) {
      showSnack(context, 'Nama, email (valid), dan telepon wajib diisi');
      return;
    }

    setState(() => loading = true);
    try {
      final userId =
          _viewModel.profil.id ??
          Supabase.instance.client.auth.currentUser?.id;

      String? urlBaru;
      if (foto != null && userId != null) {
        final client = Supabase.instance.client;
        final namaFile = foto!.path.split(RegExp(r'[\\/]')).last;
        final ekstensi = namaFile.contains('.')
            ? namaFile.split('.').last
            : 'jpg';
        final path = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ekstensi';

        await client.storage.from('foto-profil').upload(path, foto!);
        urlBaru = client.storage.from('foto-profil').getPublicUrl(path);
        await client
            .from('profil_pengguna')
            .update({'foto_url': urlBaru})
            .eq('pengguna_id', userId);
      }

      final berhasil = await _viewModel.simpan(
        nama: namaCtrl.text,
        email: emailCtrl.text,
        telp: telpCtrl.text,
      );

      if (!mounted) return;
      if (berhasil) {
        setState(() {
          foto = null;
          fotoUrl = urlBaru ?? fotoUrl;
        });
        widget.onSaved();
      } else {
        showSnack(context, _viewModel.errorMessage ?? 'Gagal menyimpan profil');
      }
    } catch (error) {
      if (mounted) {
        showSnack(context, 'Gagal menyimpan profil: $error');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    namaCtrl.dispose();
    emailCtrl.dispose();
    telpCtrl.dispose();
    super.dispose();
  }

  Widget field(
    String label,
    TextEditingController c, {
    TextInputType? type,
    bool readOnly = false,
  }) {
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
    final gambar = foto != null
        ? FileImage(foto!) as ImageProvider
        : (fotoUrl != null ? NetworkImage(fotoUrl!) : null);

    return SingleChildScrollView(
      child: Column(
        children: [
          PageHeader('Ubah Profil', onBack: widget.onBack),
          SectionCard(
            children: [
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
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 48,
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Ketuk untuk ganti foto',
                  style: TextStyle(fontSize: 10),
                ),
              ),
              const SizedBox(height: 16),
              field('Nama Lengkap', namaCtrl),
              field(
                'Email',
                emailCtrl,
                type: TextInputType.emailAddress,
                readOnly: true,
              ),
              field('No. Telepon', telpCtrl, type: TextInputType.phone),
              field(
                'Nomor Kamar',
                TextEditingController(text: _viewModel.profil.kamar),
                readOnly: true,
              ),
            ],
          ),
          ActionButtons(
            submitLabel: 'Simpan',
            onCancel: widget.onBack,
            onSubmit: simpan,
          ),
        ],
      ),
    );
  }
}
