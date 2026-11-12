import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/repositories/riwayat_pembayaran_repository.dart';
import 'package:belajar_dart/domain/models/riwayat_pembayaran.dart';

class RiwayatPembayaranViewModel extends ChangeNotifier {
  RiwayatPembayaranViewModel({
    RiwayatPembayaranRepository repository =
    const RiwayatPembayaranRepository(),
  }) : _repository = repository;

  final RiwayatPembayaranRepository _repository;

  List<RiwayatPembayaran> _semua = [];
  bool _loading = true;
  String? _error;

  String _filter = 'Semua';
  String _query = '';

  bool get loading => _loading;
  String? get error => _error;
  String get filter => _filter;
  String get query => _query;

  List<RiwayatPembayaran> get hasil {
    return _semua.where((item) {
      final cocokStatus = _filter == 'Semua' || item.status == _filter;
      final cocokCari =
      item.bulan.toLowerCase().contains(_query.toLowerCase().trim());
      return cocokStatus && cocokCari;
    }).toList();
  }

  Future<void> muat() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _semua = await _repository.getRiwayat();
    } catch (e) {
      debugPrint('Gagal memuat riwayat: $e');
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