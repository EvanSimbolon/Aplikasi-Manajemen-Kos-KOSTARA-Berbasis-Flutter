import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/repositories/pembayaran_repository.dart';
import 'package:belajar_dart/domain/models/pembayaran.dart';

class PembayaranViewModel extends ChangeNotifier {
  PembayaranViewModel({
    PembayaranRepository repository = const PembayaranRepository(),
  }) : _repository = repository,
       _items = repository.getDemoDaftarPembayaran();

  final PembayaranRepository _repository;

  List<Pembayaran> _items;
  String _filter = 'Semua';
  String _keyword = '';
  bool _isLoading = false;
  String? _errorMessage;

  String get filter => _filter;
  String get keyword => _keyword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Pembayaran> get daftarPembayaran {
    final keyword = _keyword.toLowerCase().trim();
    return _items.where((item) {
      final matchesFilter = _filter == 'Semua' || item.status == _filter;
      final matchesSearch =
          item.nama.toLowerCase().contains(keyword) ||
          item.kamar.toLowerCase().contains(keyword);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repository.getDaftarPembayaran();
    } catch (error) {
      _errorMessage = 'Gagal memuat data pembayaran.';
      debugPrint('PembayaranViewModel.load: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String value) {
    _filter = value;
    notifyListeners();
  }

  void cari(String value) {
    _keyword = value;
    notifyListeners();
  }
}
