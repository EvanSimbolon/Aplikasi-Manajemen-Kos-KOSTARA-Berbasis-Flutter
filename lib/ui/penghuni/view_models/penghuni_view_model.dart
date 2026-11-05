import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/repositories/penghuni_repository.dart';
import 'package:belajar_dart/domain/models/penghuni.dart';

class PenghuniViewModel extends ChangeNotifier {
  PenghuniViewModel({PenghuniRepository repository = const PenghuniRepository()})
      : _repository = repository;

  final PenghuniRepository _repository;

  String _filter = 'Aktif';
  String _query = '';

  String get filter => _filter;

  List<Penghuni> get daftarPenghuni {
    final keyword = _query.toLowerCase().trim();
    return _repository.getDaftarPenghuni().where((penghuni) {
      final matchesFilter = penghuni.status == _filter;
      final matchesSearch =
          penghuni.nama.toLowerCase().contains(keyword) ||
              penghuni.roomDetails.toLowerCase().contains(keyword);
      return matchesFilter && matchesSearch;
    }).toList();
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
