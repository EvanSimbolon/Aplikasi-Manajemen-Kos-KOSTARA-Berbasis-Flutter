class Pembayaran {
  final String id;
  final String tagihanId;
  final String nama;
  final String kamar;
  final String nominal;
  final String tanggal;
  final String status;
  final String? buktiTransfer;
  final String? catatan;

  const Pembayaran({
    required this.id,
    this.tagihanId = '',
    required this.nama,
    required this.kamar,
    required this.nominal,
    required this.tanggal,
    required this.status,
    this.buktiTransfer,
    this.catatan,
  });

  String get nominalFormatted {
    final angka = double.tryParse(nominal)?.toInt() ?? 0;
    final ribuan = angka.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    );
    return 'Rp $ribuan';
  }

  String get tanggalFormatted {
    final dt = DateTime.tryParse(tanggal)?.toLocal();
    if (dt == null) return tanggal;

    const bulanIndo = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    return '${dt.day} ${bulanIndo[dt.month - 1]} ${dt.year}';
  }

  String get statusFormatted {
    final cleanStatus = status.trim().toLowerCase();
    if (cleanStatus.isEmpty) return '-';
    if (cleanStatus == 'terverifikasi') return 'Lunas';
    if (cleanStatus == 'menunggu_verifikasi') return 'Menunggu';

    return status
        .split('_')
        .where((kata) => kata.isNotEmpty)
        .map((kata) => kata[0].toUpperCase() + kata.substring(1).toLowerCase())
        .join(' ');
  }

  factory Pembayaran.fromJson(Map<String, dynamic> json) {
    // 1. Mengambil data relasi pengguna -> nama_lengkap
    final pengguna = json['pengguna'] as Map<String, dynamic>?;

    // 2. Mengambil data relasi bertingkat tagihan -> penyewaan -> kamar -> nomor_kamar
    final tagihan = json['tagihan'] as Map<String, dynamic>?;
    final penyewaan = tagihan?['penyewaan'] as Map<String, dynamic>?;
    final kamar = penyewaan?['kamar'] as Map<String, dynamic>?;

    // 3. Mengambil data relasi one-to-many bukti_pembayaran -> lokasi_berkas
    final listBukti = json['bukti_pembayaran'] as List<dynamic>?;
    String? urlBukti;
    if (listBukti != null && listBukti.isNotEmpty) {
      final buktiPertama = listBukti.first as Map<String, dynamic>;
      urlBukti = buktiPertama['lokasi_berkas']?.toString();
    }

    return Pembayaran(
      id: json['id']?.toString() ?? '',
      tagihanId: json['tagihan_id']?.toString() ?? '',
      nama: pengguna?['nama_lengkap']?.toString() ?? '-',
      kamar: kamar?['nomor_kamar']?.toString() ?? '-',
      nominal: json['jumlah_pembayaran']?.toString() ?? '0',
      tanggal: json['dibayar_pada']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      buktiTransfer: urlBukti,
      catatan: json['catatan']?.toString(),
    );
  }

  factory Pembayaran.fromTagihanJson(Map<String, dynamic> json) {
    final penyewaan = json['penyewaan'] as Map<String, dynamic>?;
    final pengguna = penyewaan?['pengguna'] as Map<String, dynamic>?;
    final kamar = penyewaan?['kamar'] as Map<String, dynamic>?;

    final namaLengkap = pengguna?['nama_lengkap']?.toString().trim() ?? '';
    final nomorKamar = kamar?['nomor_kamar']?.toString().trim() ?? '';

    return Pembayaran(
      id: json['id']?.toString() ?? '',
      nama: namaLengkap.isNotEmpty ? namaLengkap : 'Tanpa Nama',
      kamar: nomorKamar.isNotEmpty ? nomorKamar : '-',
      // Sesuaikan key 'jumlah_tagihan' & 'jatuh_tempo' dengan kolom di tabel tagihan Anda
      nominal: (json['jumlah_tagihan'] ?? json['nominal'] ?? json['total_tagihan'] ?? 0).toString(),
      tanggal: (json['jatuh_tempo'] ?? json['created_at'] ?? '').toString(),
      status: json['status']?.toString() ?? 'belum_bayar',
      buktiTransfer: null,
      catatan: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jumlah_pembayaran': nominal,
      'dibayar_pada': tanggal,
      'status': status,
      'catatan': catatan,
    };
  }
}
