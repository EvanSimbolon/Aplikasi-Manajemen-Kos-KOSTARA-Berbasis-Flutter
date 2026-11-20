import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/repositories/kamar_repository.dart';
import 'package:belajar_dart/domain/models/kamar.dart';

class KamarViewModel extends ChangeNotifier {
  KamarViewModel({KamarRepository repository = const KamarRepository()})
    : _repository = repository,
      _items = repository.getDemoKamar();

  final KamarRepository _repository;

  List<Kamar> _items;
  String _query = '';
  bool _isLoading = false;
  String? _errorMessage;

  String get query => _query;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Kamar> get daftarKamar {
    final keyword = _query.toLowerCase().trim();
    return _items.where((kamar) {
      return kamar.nomor.toLowerCase().contains(keyword);
    }).toList();
  }

  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repository.getDaftarKamar();
    } catch (error) {
      _errorMessage = 'Gagal memuat data kamar.';
      debugPrint('KamarViewModel.load: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void cari(String value) {
    _query = value;
    notifyListeners();
  }
}
