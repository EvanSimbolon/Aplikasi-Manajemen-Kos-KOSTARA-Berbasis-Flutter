import 'dart:io';

import 'package:flutter/material.dart';

import 'package:belajar_dart/data/services/image_picker_service.dart';
import 'package:belajar_dart/ui/profil/view_models/profil_view_model.dart';

class UbahProfilPage extends StatefulWidget {
  const UbahProfilPage({super.key});

  @override
  State<UbahProfilPage> createState() => _UbahProfilPageState();
}

class _UbahProfilPageState extends State<UbahProfilPage> {
  static const Color _background = Color(0xFFFFF7D4);
  static const Color _primaryText = Color(0xFF4C3D3D);
  static const Color _mutedText = Color(0xFF8A7C6B);
  static const Color _cardBackground = Color(0xFFFFFCF5);
  static const Color _cardBorder = Color(0xFFDEC8A3);
  static const Color _fieldBackground = Color(0xFFF8EBD2);
  static const Color _accent = Color(0xFFC07F00);
  static const Color _error = Color(0xFFED6969);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProfilViewModel _viewModel = ProfilViewModel();
  final ImagePickerService _imagePicker = ImagePickerService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  File? _foto;
  String? _fotoUrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _muatProfil();
  }

  Future<void> _muatProfil() async {
    await _viewModel.load();
    if (!mounted) return;

    setState(() {
      _nameController.text = _viewModel.profil.nama;
      _emailController.text = _viewModel.profil.email;
      _phoneController.text = _viewModel.profil.telp;
      _addressController.text = _viewModel.profil.alamat ?? '';
      _fotoUrl = _viewModel.profil.fotoUrl;
    });
  }

  Future<void> _pilihFoto() async {
    final picked = await _imagePicker.pickImageFromGallery();
    if (picked != null && mounted) setState(() => _foto = picked);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Container(
            width: 428,
            height: 926,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: _background),
            child: Stack(
              children: [
                Positioned(
                  left: 22,
                  top: 39,
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 20,
                      icon: const Icon(
                        Icons.chevron_left,
                        size: 30,
                        color: _primaryText,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
                const Positioned(
                  left: 57,
                  top: 46,
                  child: SizedBox(
                    width: 250,
                    height: 31,
                    child: Text(
                      'Ubah Profil',
                      style: TextStyle(
                        color: _primaryText,
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 110,
                  child: Container(
                    width: 396,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    decoration: BoxDecoration(
                      color: _cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: _loading ? null : _pilihFoto,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: _fieldBackground,
                                    backgroundImage: _foto != null
                                        ? FileImage(_foto!)
                                        : (_fotoUrl != null
                                              ? NetworkImage(_fotoUrl!)
                                              : null),
                                    child: _foto == null && _fotoUrl == null
                                        ? const Icon(
                                            Icons.person,
                                            size: 42,
                                            color: _accent,
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
                          const SizedBox(height: 16),
                          _buildField(
                            label: 'Nama Lengkap',
                            hint: 'Masukkan nama lengkap',
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nama tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            label: 'Email',
                            hint: 'Masukkan email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            readOnly: true,
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty || !email.contains('@')) {
                                return 'Email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            label: 'No. Telepon',
                            hint: 'Masukkan nomor telepon',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'No. telepon tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            label: 'Alamat',
                            hint: 'Masukkan alamat',
                            controller: _addressController,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Simpan Perubahan',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _primaryText,
            fontSize: 11,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          validator: validator,
          style: const TextStyle(
            color: _primaryText,
            fontSize: 13,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: _mutedText,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
            filled: true,
            fillColor: _fieldBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_loading || !_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      String? fotoUrl = _fotoUrl;
      if (_foto != null) {
        fotoUrl = await _viewModel.unggahFoto(_foto!);
        if (fotoUrl == null) {
          throw StateError(
            _viewModel.errorMessage ?? 'Gagal mengunggah foto profil.',
          );
        }
      }

      final berhasil = await _viewModel.simpan(
        nama: _nameController.text,
        email: _emailController.text,
        telp: _phoneController.text,
        alamat: _addressController.text.trim(),
        fotoUrl: fotoUrl,
      );

      if (!mounted) return;
      if (!berhasil) {
        throw StateError(_viewModel.errorMessage ?? 'Gagal menyimpan profil.');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      Navigator.of(context).maybePop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui profil: $error')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
