import 'dart:io';
import 'package:flutter/material.dart';
import 'package:belajar_dart/ui/core/themes/app_colors.dart';

// ---------- KOMPONEN BERSAMA ----------
class PageHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final Color color;
  const PageHeader(this.title,
      {super.key, required this.onBack, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.arrow_back_ios_new, size: 20, color: color),
            ),
          ),
          const SizedBox(width: 6),
          Text(title,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final List<Widget> children;
  const SectionCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCream),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class UploadBox extends StatelessWidget {
  final File? file;
  final bool highlighted;
  final double height;
  final VoidCallback onTap;

  const UploadBox({
    super.key,
    required this.file,
    required this.highlighted,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: uploadGray,
          borderRadius: BorderRadius.circular(10),
          border: highlighted ? Border.all(color: selectedBlue, width: 3) : null,
        ),
        child: file != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(file!, fit: BoxFit.cover),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 36),
                  SizedBox(height: 8),
                  Text('Pilih Foto Bukti Pembayaran',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('atau unggah dari galeri',
                      style: TextStyle(fontSize: 11)),
                ],
              ),
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final String submitLabel;
  const ActionButtons({
    super.key,
    required this.onCancel,
    required this.onSubmit,
    this.submitLabel = 'Kirim',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: orange,
                side: const BorderSide(color: borderCream),
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Batal',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: darkOrange,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(submitLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration fieldDecoration({String? hint, Widget? suffix}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11),
      suffixIcon: suffix,
      filled: true,
      fillColor: fieldCream,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderCream),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderCream),
      ),
    );

const labelStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.bold);

void showSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));
}
