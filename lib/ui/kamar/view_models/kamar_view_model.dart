import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:belajar_dart/data/services/kamar_service.dart';
import 'package:belajar_dart/domain/models/supabase_kamar_model.dart';

class KamarViewModel extends ChangeNotifier {
  KamarViewModel({
    KamarService? service,
  }) : _service = service ?? KamarService();

  final KamarService _service;

  String _query = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<SupabaseKamarModel> _daftarKamar = [];
  StreamSubscription<List<Map<String, dynamic>>>? _penyewaanSub;
  StreamSubscription<List<Map<String, dynamic>>>? _kamarSub;
  bool _realtimeStarted = false;

  String get query => _query;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<SupabaseKamarModel> get daftarKamar {
    final keyword = _query.toLowerCase().trim();

    if (keyword.isEmpty) {
      return _daftarKamar;
    }

    return _daftarKamar.where((kamar) {
      return kamar.nomorKamar.toLowerCase().contains(keyword) ||
          (kamar.tipeKamar ?? '').toLowerCase().contains(keyword);
    }).toList();
  }

  /// Mendengarkan perubahan realtime pada tabel `penyewaan` dan `kamar`
  /// agar status Terisi/Tersedia selalu sinkron dengan database.
  void mulaiRealtime() {
    if (_realtimeStarted) return;
    _realtimeStarted = true;

    final supabase = Supabase.instance.client;
    _penyewaanSub = supabase
        .from('penyewaan')
        .stream(primaryKey: ['id'])
        .listen(
          (_) => _refreshSilent(),
          onError: (e) => debugPrint('KamarViewModel penyewaan stream: $e'),
        );

    _kamarSub = supabase
        .from('kamar')
        .stream(primaryKey: ['id'])
        .listen(
          (_) => _refreshSilent(),
          onError: (e) => debugPrint('KamarViewModel kamar stream: $e'),
        );
  }

  Future<void> _refreshSilent() async {
    try {
      _daftarKamar = await _service.getKamar();
      notifyListeners();
    } catch (e) {
      debugPrint('KamarViewModel _refreshSilent: $e');
    }
  }

  // =========================
  // READ - AMBIL DATA KAMAR
  // =========================

  Future<void> loadKamar() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _daftarKamar = await _service.getKamar();
      mulaiRealtime();
    } catch (e) {
      _errorMessage = 'Gagal mengambil data kamar: $e';
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // =========================
  // SEARCH
  // =========================

  void cari(String value) {
    _query = value;

    notifyListeners();
  }

  // =========================
  // DELETE - HAPUS KAMAR
  // =========================

  Future<void> hapusKamar(String id) async {
    await _service.hapusKamar(id);
  }

  @override
  void dispose() {
    _penyewaanSub?.cancel();
    _kamarSub?.cancel();
    super.dispose();
  }
}
