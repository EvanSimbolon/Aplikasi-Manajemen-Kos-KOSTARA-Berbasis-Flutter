import 'package:flutter/foundation.dart';
import '../../../data/repositories/pembayaran_repository.dart';
import '../../../domain/models/pembayaran.dart';

class PembayaranViewModel extends ChangeNotifier {
  final PembayaranRepository _repository;

  PembayaranViewModel({PembayaranRepository? repository})
      : _repository = repository ?? PembayaranRepository() {
    // Otomatis muat data saat ViewModel pertama kali dibuat
    fetchPembayaran('Semua');
  }

  List<Pembayaran> _allPembayaran = [];
  List<Pembayaran> _filteredPembayaran = [];
  bool _isLoading = false;
  String _filter = 'Semua';
  String _keyword = '';

  // Getter yang dibutuhkan oleh UI (pembayaran_screen.dart)
  List<Pembayaran> get daftarPembayaran => _filteredPembayaran;
  bool get isLoading => _isLoading;
  String get filter => _filter;
  String get selectedFilter => _filter;
  String get keyword => _keyword;

  /// Mengambil data pembayaran dari repositori
  Future<void> fetchPembayaran([String filterStatus = 'Semua']) async {
    _isLoading = true;
    _filter = filterStatus;
    _allPembayaran = [];
    _filteredPembayaran = [];
    notifyListeners();

    try {
      _allPembayaran = await _repository.getDaftarPembayaran(filterStatus: filterStatus);
      _applyFilterAndSearch();
    } catch (e) {
      _allPembayaran = [];
      _filteredPembayaran = [];
      debugPrint('Error fetch pembayaran: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memfilter berdasarkan tab status ('Semua', 'Belum Dibayar', 'Menunggu', 'Lunas')
  void setFilter(String newFilter) {
    _filter = newFilter;
    fetchPembayaran(newFilter);
  }

  /// Melakukan pencarian kata kunci (nama / nomor kamar)
  void cari(String query) {
    _keyword = query;
    _applyFilterAndSearch();
    notifyListeners();
  }

  void _applyFilterAndSearch() {
    if (_keyword.isEmpty) {
      _filteredPembayaran = List.from(_allPembayaran);
    } else {
      _filteredPembayaran = _allPembayaran.where((item) {
        final matchNama = item.nama.toLowerCase().contains(_keyword.toLowerCase());
        final matchKamar = item.kamar.toLowerCase().contains(_keyword.toLowerCase());
        return matchNama || matchKamar;
      }).toList();
    }
  }

  /// Verifikasi status pembayaran oleh Admin
  Future<bool> verifikasi({
    required String pembayaranId,
    required String tagihanId,
    required String adminId,
    required bool statusSetuju,
  }) async {
    try {
      await _repository.verifikasiPembayaran(
        pembayaranId: pembayaranId,
        tagihanId: tagihanId,
        adminId: adminId,
        statusSetuju: statusSetuju,
      );
      await fetchPembayaran(_filter);
      return true;
    } catch (e) {
      debugPrint('Error verifikasi: $e');
      return false;
    }
  }
}
