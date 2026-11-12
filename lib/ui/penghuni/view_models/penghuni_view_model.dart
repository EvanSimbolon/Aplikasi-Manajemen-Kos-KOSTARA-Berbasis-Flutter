import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/repositories/penghuni_repository.dart';
import 'package:belajar_dart/domain/models/penghuni.dart';

class PenghuniViewModel extends ChangeNotifier {
  PenghuniViewModel({
    PenghuniRepository repository = const PenghuniRepository(),
  }) : _repository = repository;

  final PenghuniRepository _repository;

  List<Penghuni> _semua = [];
  bool _loading = true;
  String? _error;

  String _filter = 'Aktif';
  String _query = '';

  bool get loading => _loading;
  String? get error => _error;
  String get filter => _filter;
  String get query => _query;

  List<Penghuni> get daftarPenghuni {
    final q = _query.toLowerCase().trim();
    return _semua.where((p) {
      final cocokStatus = p.status == _filter;
      final cocokCari = p.nama.toLowerCase().contains(q) ||
          p.roomDetails.toLowerCase().contains(q);
      return cocokStatus && cocokCari;
    }).toList();
  }

  Future<void> muat() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _semua = await _repository.getPenghuni();
    } catch (e) {
      debugPrint('Gagal memuat penghuni: $e');
      _error = e.toString();
      _semua = [];
    }
    _loading = false;
    notifyListeners();
  }

  void setFilter(String value) {
    _filter = value;
    notifyListeners();
  }

  void cari(String value) {
    _query = value;
    notifyListeners();
  }
}