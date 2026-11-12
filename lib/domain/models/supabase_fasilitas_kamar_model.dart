class SupabaseFasilitasKamarModel {
  final String id;
  final String kamarId;
  final int jenisFasilitasId;
  final int jumlah;
  final String kondisi;
  final DateTime? tanggalPemasangan;

  const SupabaseFasilitasKamarModel({
    required this.id,
    required this.kamarId,
    required this.jenisFasilitasId,
    required this.jumlah,
    required this.kondisi,
    this.tanggalPemasangan,
  });

  factory SupabaseFasilitasKamarModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return SupabaseFasilitasKamarModel(
      id: map['id'] as String,
      kamarId: map['kamar_id'] as String,
      jenisFasilitasId:
      (map['jenis_fasilitas_id'] as num).toInt(),
      jumlah: (map['jumlah'] as num?)?.toInt() ?? 0,
      kondisi: map['kondisi'] as String? ?? '',
      tanggalPemasangan:
      map['tanggal_pemasangan'] != null
          ? DateTime.parse(
        map['tanggal_pemasangan'] as String,
      )
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kamar_id': kamarId,
      'jenis_fasilitas_id': jenisFasilitasId,
      'jumlah': jumlah,
      'kondisi': kondisi,
      'tanggal_pemasangan':
      tanggalPemasangan?.toIso8601String(),
    };
  }
}