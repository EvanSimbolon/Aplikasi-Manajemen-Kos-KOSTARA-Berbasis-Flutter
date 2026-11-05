import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class verif_pembayaran extends StatelessWidget {
  const verif_pembayaran({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PaymentVerificationScreen();
  }
}

// Diubah dari StatelessWidget menjadi StatefulWidget agar 'context' bisa diakses dengan aman di mana saja
class PaymentVerificationScreen extends StatefulWidget {
  const PaymentVerificationScreen({Key? key}) : super(key: key);

  @override
  State<PaymentVerificationScreen> createState() => _PaymentVerificationScreenState();
}

class _PaymentVerificationScreenState extends State<PaymentVerificationScreen> {
  // Path ke file gambar di dalam aset proyek lokal kamu
  final String localImagePath = 'assets/img/bukti_transfer.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      // Menggunakan Column + Expanded SingleChildScrollView agar layout presisi di batas layar
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header bertema cokelat
            _buildHeader(),

            // Card Utama Konten Verifikasi (Overlap ke atas)
            Transform.translate(
              offset: const Offset(0, -40), // Dikurangi dari -60 ke -40 agar tidak terlalu naik
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildMainCard(),
                    const SizedBox(height: 24),
                    // Tombol Tolak dan Terima
                    _buildActionButtons(),
                    const SizedBox(height: 24), // Margin bawah agar tidak terpotong saat di-scroll
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
    // Mengambil tinggi status bar perangkat secara dinamis
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      // Tinggi disesuaikan: 140px untuk konten + tinggi status bar HP
      height: 140 + statusBarHeight,
      decoration: const BoxDecoration(
        color: Color(0xFF854836), // Cokelat khas UI
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
              top: statusBarHeight + 10, // Menyesuaikan jarak persis dari bawah Status Bar
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

  // Kartu Putih Utama dengan Data Penyewa, Rincian, dan Bukti Transfer
  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      padding:EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:Color(0xFFFFFBF3), // Cream/Off-white
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:Color(0xFFDEC9A4), // Border oranye soft
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset:Offset(0, 4),
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
                decoration:BoxDecoration(
                  color: Color(0xFFC07F00),
                  shape: BoxShape.circle,
                ),
                child:Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zahra Natashya',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Kamar B06',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC07F00),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 20),

          // Judul Rincian Pembayaran
          Text(
            'Rincian Pembayaran',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF000000),
            ),
          ),
          SizedBox(height: 8),
          Divider(color: Color(0xFFCCCCCC), thickness: 2),
          SizedBox(height: 8),

          // Detail Tabel Rincian
          _buildDetailRow('Nominal Tagihan', 'Rp 1.500.000'),
          _buildDetailRow('Periode', 'April 2026'),
          _buildDetailRow('Tanggal Transaksi', '10 April 2026'),
          _buildDetailRow('Metode Pembayaran', 'Transfer Bank'),

          SizedBox(height: 12),
          Divider(color: Color(0xFFCCCCCC), thickness: 2),
          SizedBox(height: 16),

          // Judul Bukti Pembayaran
          Text(
            'Bukti Pembayaran',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF000000),
            ),
          ),
          SizedBox(height: 8),
          Divider(color: Color(0xFFCCCCCC), thickness: 2),
          SizedBox(height: 12),

          // Container Lampiran Bukti Transfer dengan Kotak Berwarna & Border
          Container(
            padding: const EdgeInsets.all(16), // Padding di dalam kotak
            decoration: BoxDecoration(
              color: const Color(0xFFEFECE6), // Warna latar belakang kotak (krem/abu-abu soft)
              borderRadius: BorderRadius.circular(16), // Sudut melengkung
              border: Border.all(
                color: const Color(0x60D3A46F), // Warna garis tepi/border (opsional)
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center, // Memposisikan gambar & teks di tengah secara vertikal
              children: [
                // Gambar Bukti Pembayaran
                GestureDetector(
                  onTap: () => _showImagePreviewDialog(localImagePath),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          localImagePath,
                          width: 110,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 110,
                              height: 140,
                              color: Colors.grey[300],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.broken_image, color: Colors.grey),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Asset tidak\nditemukan',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
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
                              color: Colors.black.withOpacity(0.6),
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

                // Detail Nama File & Ukuran File di Sebelah Kanan Gambar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'bukti_transfer.jpg',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '220 kb',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dialog untuk memperbesar gambar lokal saat diklik
  void _showImagePreviewDialog(String imageAssetPath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              // Kontainer Gambar dengan Batasan Ukuran (Constraints)
              Container(
                width: screenSize.width * 0.85, // Lebar 85% layar
                constraints: BoxConstraints(
                  maxHeight: screenSize.height * 0.7, // DITULIS DI SINI (Maksimal tinggi 70% layar)
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.asset(
                    imageAssetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding:EdgeInsets.all(20),
                        color: Colors.white,
                        child:Text('Gagal memuat gambar dari asset.'),
                      );
                    },
                  ),
                ),
              ),
              // Tombol Tutup (Close)
              Padding(
                padding:EdgeInsets.all(8.0),
                child: IconButton(
                  icon:Icon(Icons.close, color: Colors.white, size: 30),
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
        children: [
          // Memberikan lebar tetap (fixed width) pada label agar teks sebelah kanan terikat pada satu garis vertikal yang sama
          SizedBox(
            width: 200, // Sesuaikan lebar label sesuai kebutuhan
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
              textAlign: TextAlign.left, // Teks kanan sekarang sejajar rata kiri
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
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Tombol Tolak
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pembayaran Ditolak')),
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side:BorderSide(color: Color(0xFFC07F00), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:Text(
                'Tolak',
                style: GoogleFonts.inter(
                  color: Color(0xFFFFB22C),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: 16),

        // Tombol Terima
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pembayaran Diterima')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:Color(0xFFFFB22C), // Yellow/Orange solid
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:Text(
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