import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:belajar_dart/ui/core/ui/common_widgets.dart';
import 'package:belajar_dart/utils/formatters.dart';

// ---------- HALAMAN: BUKTI PEMBAYARAN ----------
class BuktiPembayaranScreen extends StatefulWidget {
  final VoidCallback onBack;
  const BuktiPembayaranScreen({super.key, required this.onBack});

  @override
  State<BuktiPembayaranScreen> createState() => _BuktiPembayaranScreenState();
}

class _BuktiPembayaranScreenState extends State<BuktiPembayaranScreen> {
  static const String _bucket = 'bukti-pembayaran';

  File? foto;
  final tanggalCtrl = TextEditingController();
  DateTime _tanggalDipilih = DateTime.now();

  bool _memuatTagihan = true;
  bool loading = false;
  String? _errorTagihan;

  String? _tagihanId;
  double _nominalTagihan = 0;
  String _periodeText = '-';
  String _nomorKamar = '-';
  String _metode = 'Transfer Bank';

  @override
  void initState() {
    super.initState();
    tanggalCtrl.text = DateFormat('dd/MM/yyyy').format(_tanggalDipilih);
    _muatTagihanAktif();
  }

  @override
  void dispose() {
    tanggalCtrl.dispose();
    super.dispose();
  }

  Future<void> _muatTagihanAktif() async {
    setState(() {
      _memuatTagihan = true;
      _errorTagihan = null;
    });

    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) {
        setState(() {
          _errorTagihan = 'Sesi login tidak ditemukan.';
          _memuatTagihan = false;
        });
        return;
      }

      final penyewaan = await client
          .from('penyewaan')
          .select(
            'id, harga_sewa_disepakati, tanggal_mulai, '
            'kamar!inner ( nomor_kamar, kos_id )',
          )
          .eq('penghuni_id', user.id)
          .inFilter('status', ['aktif', 'menunggu_mulai'])
          .order('tanggal_mulai', ascending: false)
          .limit(1)
          .maybeSingle();

      if (penyewaan == null) {
        if (!mounted) return;
        setState(() {
          _errorTagihan = 'Data penyewaan aktif belum ditemukan.';
          _memuatTagihan = false;
        });
        return;
      }

      final penyewaanId = penyewaan['id']?.toString();
      final kamar = penyewaan['kamar'] as Map<String, dynamic>?;
      final nomorKamar = kamar?['nomor_kamar']?.toString() ?? '-';

      // Cari tagihan aktif (belum_bayar / terlambat) milik penyewaan ini
      final tagihan = await client
          .from('tagihan')
          .select(
            'id, periode_mulai, periode_selesai, tanggal_jatuh_tempo, '
            'jumlah_tagihan, status',
          )
          .eq('penyewaan_id', penyewaanId!)
          .inFilter('status', ['belum_bayar', 'terlambat', 'dibayar_sebagian'])
          .order('tanggal_jatuh_tempo', ascending: true)
          .limit(1)
          .maybeSingle();

      if (!mounted) return;
      if (tagihan == null) {
        setState(() {
          _tagihanId = null;
          _nomorKamar = nomorKamar;
          _nominalTagihan =
              double.tryParse(penyewaan['harga_sewa_disepakati'].toString()) ??
              0;
          _periodeText = 'Tidak ada tagihan aktif';
          _errorTagihan =
              'Saat ini tidak ada tagihan yang belum dibayar. Hubungi pemilik kos jika tagihan belum diterbitkan.';
          _memuatTagihan = false;
        });
        return;
      }

      final periodeMulai = Formatters.parseDate(tagihan['periode_mulai']);
      final jatuhTempo = Formatters.parseDate(tagihan['tanggal_jatuh_tempo']);

      setState(() {
        _tagihanId = tagihan['id']?.toString();
        _nomorKamar = nomorKamar;
        _nominalTagihan =
            double.tryParse(tagihan['jumlah_tagihan'].toString()) ?? 0;
        _periodeText = periodeMulai != null
            ? Formatters.bulanTahun(periodeMulai)
            : (jatuhTempo != null ? Formatters.bulanTahun(jatuhTempo) : '-');
        _memuatTagihan = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorTagihan = 'Gagal memuat tagihan: $e';
        _memuatTagihan = false;
      });
    }
  }

  Future<void> pilihFoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => foto = File(picked.path));
  }

  Future<void> pilihTanggal() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _tanggalDipilih,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _tanggalDipilih = date;
        tanggalCtrl.text = DateFormat('dd/MM/yyyy').format(date);
      });
    }
  }

  Future<void> kirimBukti() async {
    if (_tagihanId == null || _tagihanId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _errorTagihan ?? 'Tidak ada tagihan aktif untuk dibayar.',
          ),
        ),
      );
      return;
    }

    if (foto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih foto bukti pembayaran dulu')),
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
      // 1. Buat baris pembayaran dengan status menunggu_verifikasi
      final pembayaranRow = await client
          .from('pembayaran')
          .insert({
            'tagihan_id': _tagihanId,
            'pembayar_id': user.id,
            'jumlah_pembayaran': _nominalTagihan > 0 ? _nominalTagihan : 1,
            'metode_pembayaran': _metode,
            'dibayar_pada': _tanggalDipilih.toIso8601String(),
            'status': 'menunggu_verifikasi',
          })
          .select('id')
          .single();

      final pembayaranId = pembayaranRow['id'].toString();

      // 2. Upload foto ke bucket bukti-pembayaran/<pembayaranId>/<timestamp>.<ext>
      // Format folder pertama = pembayaranId sesuai RLS policy storage.objects.
      final namaFile = foto!.path.split(RegExp(r'[\\/]')).last;
      final ext = namaFile.contains('.') ? namaFile.split('.').last : 'jpg';
      final path = '$pembayaranId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await client.storage.from(_bucket).upload(path, foto!);
      final url = client.storage.from(_bucket).getPublicUrl(path);

      // 3. Simpan ke tabel bukti_pembayaran
      await client.from('bukti_pembayaran').insert({
        'pembayaran_id': pembayaranId,
        'lokasi_berkas': url,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bukti pembayaran terkirim dan menunggu verifikasi pemilik kos',
          ),
        ),
      );
      setState(() {
        foto = null;
      });
      widget.onBack();
    } catch (e) {
      if (!mounted) return;
      final pesan = e is PostgrestException ? e.message : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim: $pesan')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11)),
            Text(
              value,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          PageHeader('Bukti Pembayaran', onBack: widget.onBack),
          if (_memuatTagihan)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
          else ...[
            SectionCard(
              children: [
                infoRow(
                  'Nominal Tagihan',
                  Formatters.rupiah(_nominalTagihan),
                ),
                infoRow('Periode', _periodeText),
                infoRow('No. Kamar', _nomorKamar),
                infoRow('Metode Pembayaran', _metode),
                if (_errorTagihan != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorTagihan!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFB3261E),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            SectionCard(
              children: [
                UploadBox(
                  file: foto,
                  highlighted: true,
                  height: 120,
                  onTap: pilihFoto,
                ),
                const SizedBox(height: 16),
                const Text('Tanggal Pembayaran', style: labelStyle),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4DF),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
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
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ActionButtons(
              onCancel: () => setState(() {
                foto = null;
              }),
              onSubmit: (loading || _tagihanId == null) ? () {} : kirimBukti,
            ),
          ],
        ],
      ),
    );
  }
}
