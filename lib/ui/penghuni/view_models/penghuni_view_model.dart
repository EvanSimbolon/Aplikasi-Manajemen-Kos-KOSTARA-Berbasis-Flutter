import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/repositories/penghuni_repository.dart';
import 'package:belajar_dart/domain/models/penghuni.dart';

class PenghuniViewModel extends ChangeNotifier {
  PenghuniViewModel({
    PenghuniRepository repository = const PenghuniRepository(),
  }) : _repository = repository,
       _items = repository.getDemoDaftarPenghuni();

  final PenghuniRepository _repository;

  List<Penghuni> _items;
  String _filter = 'Aktif';
  String _query = '';
  bool _isLoading = false;
  String? _errorMessage;

  String get filter => _filter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Penghuni> get daftarPenghuni {
    final keyword = _query.toLowerCase().trim();
    return _items.where((penghuni) {
      final matchesFilter = penghuni.status == _filter;
      final matchesSearch =
          penghuni.nama.toLowerCase().contains(keyword) ||
          penghuni.roomDetails.toLowerCase().contains(keyword);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repository.getDaftarPenghuni();
    } catch (error) {
      _errorMessage = 'Gagal memuat data penghuni.';
      debugPrint('PenghuniViewModel.load: $error');
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
    _query = value;
    notifyListeners();
  }
}
