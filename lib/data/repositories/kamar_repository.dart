import 'package:belajar_dart/domain/models/kamar.dart';

class KamarRepository {
  const KamarRepository();

  List<Kamar> getDaftarKamar() {
    return const [
      Kamar(
        nomor: 'Kamar A02',
        tipe: 'Standar',
        harga: 'Rp. 1.000.000',
        tersedia: true,
        gambar: 'assets/img/kamar_standar.png',
      ),
      Kamar(
        nomor: 'Kamar A04',
        tipe: 'Standar',
        harga: 'Rp. 1.000.000',
        tersedia: true,
        gambar: 'assets/img/kamar_standar.png',
      ),
      Kamar(
        nomor: 'Kamar B02',
        tipe: 'Deluxe',
        harga: 'Rp. 1.500.000',
        tersedia: true,
        gambar: 'assets/img/kamar_deluxe.png',
      ),
      Kamar(
        nomor: 'Kamar B07',
        tipe: 'Deluxe',
        harga: 'Rp. 1.500.000',
        tersedia: true,
        gambar: 'assets/img/kamar_deluxe.png',
      ),
      Kamar(
        nomor: 'Kamar B08',
        tipe: 'Deluxe',
        harga: 'Rp. 1.500.000',
        tersedia: true,
        gambar: 'assets/img/kamar_deluxe.png',
      ),
      Kamar(
        nomor: 'Kamar A01',
        tipe: 'Standar',
        harga: 'Rp. 1.000.000',
        tersedia: false,
        gambar: 'assets/img/kamar_standar.png',
      ),
      Kamar(
        nomor: 'Kamar A03',
        tipe: 'Standar',
        harga: 'Rp. 1.000.000',
        tersedia: false,
        gambar: 'assets/img/kamar_standar.png',
      ),
      Kamar(
        nomor: 'Kamar A05',
        tipe: 'Standar',
        harga: 'Rp. 1.000.000',
        tersedia: false,
        gambar: 'assets/img/kamar_standar.png',
      ),
    ];
  }
}
