import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/repositories/penghuni_repository.dart';
import 'package:belajar_dart/domain/models/penghuni.dart';

class PenghuniViewModel extends ChangeNotifier {
  PenghuniViewModel({
    PenghuniRepository repository = const PenghuniRepository(),
  }) : _repository = repository,
       _items = const [];

  final PenghuniRepository _repository;

  List<Penghuni> _items;
  String _query = '';
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Penghuni> get daftarPenghuni {
    final keyword = _query.toLowerCase().trim();
    return _items.where((penghuni) {
      if (penghuni.status != 'Aktif') return false;
      if (keyword.isEmpty) return true;
      return penghuni.nama.toLowerCase().contains(keyword) ||
          penghuni.roomDetails.toLowerCase().contains(keyword);
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

  Future<bool> hapusPenghuni(Penghuni penghuni) async {
    final sewaId = penghuni.penyewaanId;
    if (sewaId == null || sewaId.isEmpty) return false;

    try {
      await _repository.hapusPenghuni(sewaId);
      _items = _items.where((e) => e.penyewaanId != sewaId).toList();
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('PenghuniViewModel.hapusPenghuni: $error');
      return false;
    }
  }

  void cari(String value) {
    _query = value;
    notifyListeners();
  }
}
