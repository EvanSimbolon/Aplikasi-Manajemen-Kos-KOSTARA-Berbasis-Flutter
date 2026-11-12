import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/services/kamar_service.dart';
import 'package:belajar_dart/domain/models/supabase_kamar_model.dart';

class KamarViewModel extends ChangeNotifier {
  KamarViewModel({
    KamarService? service,
  }) : _service = service ?? KamarService();

  final KamarService _service;

  String _query = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<SupabaseKamarModel> _daftarKamar = [];

  String get query => _query;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<SupabaseKamarModel> get daftarKamar {
    final keyword = _query.toLowerCase().trim();

    if (keyword.isEmpty) {
      return _daftarKamar;
    }

    return _daftarKamar.where((kamar) {
      return kamar.nomorKamar
          .toLowerCase()
          .contains(keyword) ||
          (kamar.tipeKamar ?? '')
              .toLowerCase()
              .contains(keyword);
    }).toList();
  }

  // =========================
  // READ - AMBIL DATA KAMAR
  // =========================

  Future<void> loadKamar() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _daftarKamar = await _service.getKamar();
    } catch (e) {
      _errorMessage =
      'Gagal mengambil data kamar: $e';
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // =========================
  // SEARCH
  // =========================

  void cari(String value) {
    _query = value;

    notifyListeners();
  }

  // =========================
  // DELETE - HAPUS KAMAR
  // =========================

  Future<void> hapusKamar(String id) async {
    await _service.hapusKamar(id);
  }
}