class KamarModel {
  final String id;
  final String kosId;
  final String nomorKamar;
  final String? tipeKamar;
  final double hargaSewaBulanan;
  final String? deskripsi;
  final DateTime? dibuatPada;
  final DateTime? diperbaruiPada;

  const KamarModel({
    required this.id,
    required this.kosId,
    required this.nomorKamar,
    this.tipeKamar,
    required this.hargaSewaBulanan,
    this.deskripsi,
    this.dibuatPada,
    this.diperbaruiPada,
  });

  factory KamarModel.fromMap(Map<String, dynamic> map) {
    return KamarModel(
      id: map['id'] as String,
      kosId: map['kos_id'] as String,
      nomorKamar: map['nomor_kamar'] as String,
      tipeKamar: map['tipe_kamar'] as String?,
      hargaSewaBulanan:
      (map['harga_sewa_bulanan'] as num?)?.toDouble() ?? 0,
      deskripsi: map['deskripsi'] as String?,
      dibuatPada: map['dibuat_pada'] != null
          ? DateTime.parse(map['dibuat_pada'] as String)
          : null,
      diperbaruiPada: map['diperbarui_pada'] != null
          ? DateTime.parse(map['diperbarui_pada'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kos_id': kosId,
      'nomor_kamar': nomorKamar,
      'tipe_kamar': tipeKamar,
      'harga_sewa_bulanan': hargaSewaBulanan,
      'deskripsi': deskripsi,
      'dibuat_pada': dibuatPada?.toIso8601String(),
      'diperbarui_pada': diperbaruiPada?.toIso8601String(),
    };
  }
}