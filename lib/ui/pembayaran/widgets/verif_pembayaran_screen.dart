import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:belajar_dart/domain/models/pembayaran.dart';
import 'package:belajar_dart/ui/pembayaran/view_models/pembayaran_view_model.dart';

// Class verif_pembayaran disesuaikan dengan rujukan di AppRouter (lowercase)
class verif_pembayaran extends StatefulWidget {
  const verif_pembayaran({super.key});

  @override
  State<verif_pembayaran> createState() => _VerifPembayaranState();
}

class _VerifPembayaranState extends State<verif_pembayaran> {
  bool _isProcessing = false;

  /// Memproses aksi Tolak / Terima pembayaran melalui PembayaranViewModel
  Future<void> _prosesVerifikasi(
      BuildContext context, {
        required Pembayaran item,
        required bool statusSetuju,
      }) async {
    setState(() {
      _isProcessing = true;
    });

    final viewModel = context.read<PembayaranViewModel>();

    final success = await viewModel.verifikasi(
      pembayaranId: item.id,
      tagihanId: item.tagihanId,
      adminId: 'admin',
      statusSetuju: statusSetuju,
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            statusSetuju
                ? 'Pembayaran berhasil diterima'
                : 'Pembayaran telah ditolak',
          ),
          backgroundColor: statusSetuju ? Colors.green : Colors.red,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memproses verifikasi pembayaran'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Mengambil nama berkas dari URL bukti transfer
  String _ekstrakNamaBerkas(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last;
      }
    } catch (_) {}
    return 'bukti_transfer.jpg';
  }

  @override
  Widget build(BuildContext context) {
    // Membaca argumen data Pembayaran yang dikirim dari halaman sebelumnya
    final item = ModalRoute.of(context)?.settings.arguments as Pembayaran?;

    if (item == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF8E7),
        appBar: AppBar(
          title: const Text(
            'Verifikasi Pembayaran',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF854836),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text('Data pembayaran tidak ditemukan'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header bertema cokelat dengan hiasan lingkaran kuning
            _buildHeader(),

            // Card Utama Konten Verifikasi (Overlap ke atas)
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildMainCard(item),
                    const SizedBox(height: 24),
                    // Tombol Tolak dan Terima (atau indikator loading saat diproses)
                    if (item.status == 'menunggu_verifikasi') ...[
                      if (_isProcessing)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: CircularProgressIndicator(
                            color: Color(0xFF854836),
                          ),
                        )
                      else
                        _buildActionButtons(item),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      height: 140 + statusBarHeight,
      decoration: const BoxDecoration(
        color: Color(0xFF854836),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            // Hiasan Lingkaran Kuning/Oranye di Pojok Kanan Atas
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFB22C),
                    width: 32,
                  ),
                ),
              ),
            ),

            // Tombol Kembali dan Judul Halaman di bawah Status Bar
            Positioned(
              top: statusBarHeight + 10,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.maybePop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Verifikasi Pembayaran',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kartu Putih Utama dengan Data Penyewa, Rincian, dan Bukti Transfer dari Model
  Widget _buildMainCard(Pembayaran item) {
    final hasBukti =
        item.buktiTransfer != null && item.buktiTransfer!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFDEC9A4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profil Penyewa
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFC07F00),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nama,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kamar ${item.kamar}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC07F00),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Judul Rincian Pembayaran
          Text(
            'Rincian Pembayaran',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFCCCCCC), thickness: 2),
          const SizedBox(height: 8),

          // Detail Tabel Rincian Dinamis
          _buildDetailRow('Nominal Tagihan', item.nominalFormatted),
          _buildDetailRow('Tanggal Transaksi', item.tanggalFormatted),
          _buildDetailRow('Status Saat Ini', item.statusFormatted),
          if (item.catatan != null && item.catatan!.trim().isNotEmpty)
            _buildDetailRow('Catatan', item.catatan!),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFFCCCCCC), thickness: 2),
          const SizedBox(height: 16),

          // Judul Bukti Pembayaran
          Text(
            'Bukti Pembayaran',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFCCCCCC), thickness: 2),
          const SizedBox(height: 12),

          // Container Lampiran Bukti Transfer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFECE6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0x60D3A46F),
                width: 1,
              ),
            ),
            child: hasBukti
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gambar Bukti Pembayaran dari Network (Supabase)
                GestureDetector(
                  onTap: () =>
                      _showImagePreviewDialog(item.buktiTransfer!),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          item.buktiTransfer!,
                          width: 110,
                          height: 140,
                          fit: BoxFit.cover,
                          loadingBuilder:
                              (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 110,
                              height: 140,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF854836),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 110,
                              height: 140,
                              color: Colors.grey[300],
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Gagal memuat\ngambar',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        // Overlay icon zoom
                        Positioned(
                          right: 6,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.zoom_in_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Detail Nama File & Petunjuk Zoom
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _ekstrakNamaBerkas(item.buktiTransfer!),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4C3D3D),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ketuk gambar untuk memperbesar',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
                : SizedBox(
              width: double.infinity,
              height: 110,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image_not_supported,
                    size: 36,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada foto bukti pembayaran',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog untuk memperbesar gambar bukti transfer dari URL
  void _showImagePreviewDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: screenSize.width * 0.85,
                constraints: BoxConstraints(
                  maxHeight: screenSize.height * 0.7,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        color: Colors.white,
                        child: const Text('Gagal memuat gambar bukti transfer.'),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper untuk Baris Rincian Pembayaran
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 155,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xD94C3D3D),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF222222),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tombol Tolak (Outline) dan Terima (Kuning Solid)
  Widget _buildActionButtons(Pembayaran item) {
    return Row(
      children: [
        // Tombol Tolak
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () => _prosesVerifikasi(
                context,
                item: item,
                statusSetuju: false,
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFC07F00), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Tolak',
                style: GoogleFonts.inter(
                  color: const Color(0xFFFFB22C),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Tombol Terima
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => _prosesVerifikasi(
                context,
                item: item,
                statusSetuju: true,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB22C),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Terima',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
