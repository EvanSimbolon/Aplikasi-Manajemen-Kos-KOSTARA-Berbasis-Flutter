import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/repositories/kamar_repository.dart';
import 'package:belajar_dart/domain/models/kamar.dart';

class KamarViewModel extends ChangeNotifier {
  KamarViewModel({KamarRepository repository = const KamarRepository()})
      : _repository = repository;

  final KamarRepository _repository;

  String _query = '';

  String get query => _query;

  List<Kamar> get daftarKamar {
    final keyword = _query.toLowerCase().trim();
    return _repository.getDaftarKamar().where((kamar) {
      return kamar.nomor.toLowerCase().contains(keyword);
    }).toList();
  }

  void cari(String value) {
    _query = value;
    notifyListeners();
  }
}
