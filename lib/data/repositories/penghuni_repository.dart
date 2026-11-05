import 'package:belajar_dart/domain/models/penghuni.dart';

class PenghuniRepository {
  const PenghuniRepository();

  List<Penghuni> getDaftarPenghuni() {
    return const [
      Penghuni(
        nama: 'Assiya Nazrun',
        roomDetails: 'Kamar A03 - Apr 2026',
        status: 'Aktif',
      ),
      Penghuni(
        nama: 'Siti Aisyah',
        roomDetails: 'Kamar A01 - Apr 2026',
        status: 'Aktif',
      ),
      Penghuni(
        nama: 'Kamila',
        roomDetails: 'Kamar A07 - Apr 2026',
        status: 'Aktif',
      ),
      Penghuni(
        nama: 'Dini Aulia',
        roomDetails: 'Kamar B02 - Apr 2026',
        status: 'Aktif',
      ),
      Penghuni(
        nama: 'Zahra Natashya',
        roomDetails: 'Kamar B06 - Apr 2026',
        status: 'Tidak Aktif',
      ),
      Penghuni(
        nama: 'Ayuna',
        roomDetails: 'Kamar A06 - Apr 2026',
        status: 'Tidak Aktif',
      ),
      Penghuni(
        nama: 'Rina Rahmawati',
        roomDetails: 'Kamar C01 - Jan 2026',
        status: 'Tidak Aktif',
      ),
    ];
  }
}
