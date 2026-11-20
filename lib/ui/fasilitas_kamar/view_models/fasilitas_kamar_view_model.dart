import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/services/fasilitas_kamar_service.dart';
import 'package:belajar_dart/domain/models/jenis_fasilitas_model.dart';
import 'package:belajar_dart/domain/models/supabase_fasilitas_kamar_model.dart';

class FasilitasKamarViewModel extends ChangeNotifier {
  FasilitasKamarViewModel({
    FasilitasKamarService? service,
  }) : _service =
      service ?? FasilitasKamarService();

  final FasilitasKamarService _service;

  bool _isLoading = false;
  String? _errorMessage;

  List<SupabaseFasilitasKamarModel>
  _daftarFasilitasKamar = [];

  List<JenisFasilitasModel>
  _daftarJenisFasilitas = [];

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<SupabaseFasilitasKamarModel>
  get daftarFasilitasKamar =>
      _daftarFasilitasKamar;

  List<JenisFasilitasModel>
  get daftarJenisFasilitas =>
      _daftarJenisFasilitas;

  // =========================
  // LOAD DATA
  // =========================

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final hasilFasilitas =
      await _service.getFasilitasKamar();

      final hasilJenis =
      await _service.getJenisFasilitas();

      _daftarFasilitasKamar =
          hasilFasilitas;

      _daftarJenisFasilitas =
          hasilJenis;
    } catch (e) {
      _errorMessage =
      'Gagal mengambil data fasilitas: $e';
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // =========================
  // TAMBAH FASILITAS
  // =========================

  Future<void> tambahFasilitas(
      SupabaseFasilitasKamarModel fasilitas,
      ) async {
    await _service.tambahFasilitasKamar(
      fasilitas,
    );

    await loadData();
  }

  // =========================
  // EDIT FASILITAS
  // =========================

  Future<void> ubahFasilitas(
      SupabaseFasilitasKamarModel fasilitas,
      ) async {
    await _service.ubahFasilitasKamar(
      fasilitas,
    );

    await loadData();
  }

  // =========================
  // HAPUS FASILITAS
  // =========================

  Future<void> hapusFasilitas(
      String id,
      ) async {
    await _service.hapusFasilitasKamar(id);

    await loadData();
  }

  // =========================
  // CARI NAMA FASILITAS
  // =========================

  String namaJenisFasilitas(
      int jenisFasilitasId,
      ) {
    final jenis =
    _daftarJenisFasilitas.where(
          (item) =>
      item.id == jenisFasilitasId,
    );

    if (jenis.isEmpty) {
      return 'Fasilitas tidak diketahui';
    }

    return jenis.first.namaFasilitas;
  }
}