import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:belajar_dart/ui/core/ui/common_widgets.dart';

// ---------- HALAMAN: BUKTI PEMBAYARAN ----------
class BuktiPembayaranScreen extends StatefulWidget {
  final VoidCallback onBack;
  const BuktiPembayaranScreen({super.key, required this.onBack});

  @override
  State<BuktiPembayaranScreen> createState() => _BuktiPembayaranScreenState();
}

class _BuktiPembayaranScreenState extends State<BuktiPembayaranScreen> {
  File? foto;
  final tanggalCtrl = TextEditingController();

  Future<void> pilihFoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => foto = File(picked.path));
  }

  Future<void> pilihTanggal() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      tanggalCtrl.text = DateFormat('dd/MM/yyyy').format(date);
    }
  }

  Widget infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11)),
            Text(value,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          PageHeader('Bukti Pembayaran', onBack: widget.onBack),
          SectionCard(children: [
            infoRow('Nominal Tagihan', 'Rp 1.000.000'),
            infoRow('Periode', 'April 2026'),
            infoRow('No. Kamar', 'A05'),
            infoRow('Metode Pembayaran', 'Transfer Bank'),
          ]),
          const SizedBox(height: 12),
          SectionCard(children: [
            UploadBox(
                file: foto, highlighted: true, height: 120, onTap: pilihFoto),
            const SizedBox(height: 16),
            const Text('Tanggal Pembayaran', style: labelStyle),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4DF),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: tanggalCtrl,
                readOnly: true,
                onTap: pilihTanggal,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  hintText: 'dd/mm/yyyy',
                  hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
                  suffixIcon: Icon(Icons.calendar_month),
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
          ]),
          ActionButtons(
            onCancel: () => setState(() {
              foto = null;
              tanggalCtrl.clear();
            }),
            onSubmit: () {
              // TODO: kirim ke server
            },
          ),
        ],
      ),
    );
  }
}
