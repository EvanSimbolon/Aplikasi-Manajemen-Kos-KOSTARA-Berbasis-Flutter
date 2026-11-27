import 'package:flutter/foundation.dart';
import '../../../data/repositories/pembayaran_repository.dart';
import '../../../domain/models/pembayaran.dart';

class PembayaranViewModel extends ChangeNotifier {
  final PembayaranRepository _repository;

  PembayaranViewModel({PembayaranRepository? repository})
      : _repository = repository ?? PembayaranRepository() {
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    fetchPembayaran('Semua');
  }

  List<Pembayaran> _allPembayaran = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _filter = 'Semua';
  String _keyword = '';
  int? _selectedMonth; // null = Semua Bulan, 1..12 = Januari..Desember
  late int _selectedYear;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get filter => _filter;
  String get selectedFilter => _filter;
  String get keyword => _keyword;
  int? get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  bool _cocokKeyword(Pembayaran item) {
    final q = _keyword.trim().toLowerCase();
    if (q.isEmpty) return true;
    return item.nama.toLowerCase().contains(q) ||
        item.kamar.toLowerCase().contains(q);
  }

  /// Semua item yang cocok keyword (kompatibilitas)
  List<Pembayaran> get daftarPembayaran =>
      _allPembayaran.where(_cocokKeyword).toList();

  /// Bagian 1: Request verifikasi pembayaran baru dari penghuni (menunggu_verifikasi)
  List<Pembayaran> get requestVerifikasi => _allPembayaran
      .where(
        (item) =>
            item.status.toLowerCase() == 'menunggu_verifikasi' &&
            _cocokKeyword(item),
      )
      .toList();

  /// Bagian 2: History pembayaran yang sudah diverifikasi owner, difilter per bulan
  List<Pembayaran> get riwayatTerverifikasi => _allPembayaran.where((item) {
        if (item.status.toLowerCase() != 'terverifikasi') return false;
        if (!_cocokKeyword(item)) return false;

        final dt = item.tanggalDateTime;
        if (_selectedMonth == null) {
          return dt == null || dt.year == _selectedYear;
        }
        if (dt == null) return false;
        return dt.month == _selectedMonth && dt.year == _selectedYear;
      }).toList();

  /// Mengambil data pembayaran dari repositori (sesuai kos_id pemilik)
  Future<void> fetchPembayaran([String filterStatus = 'Semua']) async {
    _isLoading = true;
    _errorMessage = null;
    _filter = filterStatus;
    notifyListeners();

    try {
      _allPembayaran = await _repository.getDaftarPembayaran(
        filterStatus: filterStatus,
      );
    } catch (e) {
      _allPembayaran = [];
      _errorMessage = 'Gagal memuat data pembayaran: $e';
      debugPrint('Error fetch pembayaran: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String newFilter) {
    _filter = newFilter;
    fetchPembayaran(newFilter);
  }

  void setMonthFilter(int? month, {int? year}) {
    _selectedMonth = month;
    if (year != null) _selectedYear = year;
    notifyListeners();
  }

  void cari(String query) {
    _keyword = query;
    notifyListeners();
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
      await fetchPembayaran('Semua');
      return true;
    } catch (e) {
      debugPrint('Error verifikasi: $e');
      return false;
    }
  }
}
