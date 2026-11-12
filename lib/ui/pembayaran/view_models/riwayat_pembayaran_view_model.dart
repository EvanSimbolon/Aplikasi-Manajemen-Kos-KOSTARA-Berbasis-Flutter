import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/repositories/riwayat_pembayaran_repository.dart';
import 'package:belajar_dart/domain/models/riwayat_pembayaran.dart';

class RiwayatPembayaranViewModel extends ChangeNotifier {
  RiwayatPembayaranViewModel({
    RiwayatPembayaranRepository repository =
        const RiwayatPembayaranRepository(),
  }) : _repository = repository,
       _items = repository.getDemoRiwayat();

  final RiwayatPembayaranRepository _repository;

  List<RiwayatPembayaran> _items;
  String _filter = 'Semua';
  String _query = '';
  bool _isLoading = false;
  String? _errorMessage;

  String get filter => _filter;
  String get query => _query;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<RiwayatPembayaran> get hasil {
    return _items.where((item) {
      final cocokStatus = _filter == 'Semua' || item.status == _filter;
      final cocokCari = item.bulan.toLowerCase().contains(
        _query.toLowerCase().trim(),
      );
      return cocokStatus && cocokCari;
    }).toList();
  }

  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repository.getRiwayat();
    } catch (error) {
      _errorMessage = 'Gagal memuat riwayat pembayaran.';
      debugPrint('RiwayatPembayaranViewModel.load: $error');
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
