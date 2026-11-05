import 'package:belajar_dart/domain/models/kamar.dart';

class KamarModel {
  const KamarModel({
    required this.nomor,
    required this.tipe,
    required this.harga,
    required this.tersedia,
    required this.gambar,
  });

  final String nomor;
  final String tipe;
  final String harga;
  final bool tersedia;
  final String gambar;

  factory KamarModel.fromJson(Map<String, dynamic> json) {
    return KamarModel(
      nomor: json['nomor'] as String? ?? '',
      tipe: json['tipe'] as String? ?? '',
      harga: json['harga'] as String? ?? '',
      tersedia: json['tersedia'] as bool? ?? false,
      gambar: json['gambar'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nomor': nomor,
      'tipe': tipe,
      'harga': harga,
      'tersedia': tersedia,
      'gambar': gambar,
    };
  }

  Kamar toDomain() {
    return Kamar(
      nomor: nomor,
      tipe: tipe,
      harga: harga,
      tersedia: tersedia,
      gambar: gambar,
    );
  }
}
