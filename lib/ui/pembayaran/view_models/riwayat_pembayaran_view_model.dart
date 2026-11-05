import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/repositories/riwayat_pembayaran_repository.dart';
import 'package:belajar_dart/domain/models/riwayat_pembayaran.dart';

class RiwayatPembayaranViewModel extends ChangeNotifier {
  RiwayatPembayaranViewModel({
    RiwayatPembayaranRepository repository =
        const RiwayatPembayaranRepository(),
  }) : _repository = repository;

  final RiwayatPembayaranRepository _repository;

  String _filter = 'Semua';
  String _query = '';

  String get filter => _filter;
  String get query => _query;

  List<RiwayatPembayaran> get hasil {
    return _repository.getRiwayat().where((item) {
      final cocokStatus = _filter == 'Semua' || item.status == _filter;
      final cocokCari =
          item.bulan.toLowerCase().contains(_query.toLowerCase().trim());
      return cocokStatus && cocokCari;
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
