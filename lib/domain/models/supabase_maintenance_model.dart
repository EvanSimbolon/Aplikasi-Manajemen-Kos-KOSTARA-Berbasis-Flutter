class SupabaseMaintenanceModel {
  final String id;
  final String kamarId;
  final String jenisPerawatan;
  final DateTime tanggalPerawatan;
  final String? teknisi;
  final String status;
  final String? catatan;

  const SupabaseMaintenanceModel({
    required this.id,
    required this.kamarId,
    required this.jenisPerawatan,
    required this.tanggalPerawatan,
    this.teknisi,
    required this.status,
    this.catatan,
  });

  factory SupabaseMaintenanceModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return SupabaseMaintenanceModel(
      id: map['id'] as String,
      kamarId: map['kamar_id'] as String,
      jenisPerawatan:
      map['jenis_perawatan'] as String? ?? '',
      tanggalPerawatan:
      DateTime.parse(
        map['tanggal_perawatan'] as String,
      ),
      teknisi:
      map['teknisi'] as String?,
      status:
      map['status'] as String? ?? 'Terjadwal',
      catatan:
      map['catatan'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kamar_id': kamarId,
      'jenis_perawatan': jenisPerawatan,
      'tanggal_perawatan':
      tanggalPerawatan
          .toIso8601String()
          .split('T')
          .first,
      'teknisi': teknisi,
      'status': status,
      'catatan': catatan,
    };
  }
}