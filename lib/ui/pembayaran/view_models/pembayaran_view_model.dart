import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/repositories/pembayaran_repository.dart';
import 'package:belajar_dart/domain/models/pembayaran.dart';

class PembayaranViewModel extends ChangeNotifier {
  PembayaranViewModel({
    PembayaranRepository repository = const PembayaranRepository(),
  }) : _repository = repository;

  final PembayaranRepository _repository;

  String _filter = 'Semua';
  String _keyword = '';

  String get filter => _filter;
  String get keyword => _keyword;

  List<Pembayaran> get daftarPembayaran {
    final keyword = _keyword.toLowerCase().trim();
    return _repository.getDaftarPembayaran().where((item) {
      final matchesFilter = _filter == 'Semua' || item.status == _filter;
      final matchesSearch = item.nama.toLowerCase().contains(keyword) ||
          item.kamar.toLowerCase().contains(keyword);
      return matchesFilter && matchesSearch;
    }).toList();
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
