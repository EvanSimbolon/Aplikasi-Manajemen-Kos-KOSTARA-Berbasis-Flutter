class JenisFasilitasModel {
  final int id;
  final String namaFasilitas;
  final String? deskripsi;

  const JenisFasilitasModel({
    required this.id,
    required this.namaFasilitas,
    this.deskripsi,
  });

  factory JenisFasilitasModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return JenisFasilitasModel(
      id: (map['id'] as num).toInt(),
      namaFasilitas:
      map['nama_fasilitas'] as String,
      deskripsi:
      map['deskripsi'] as String?,
    );
  }
}