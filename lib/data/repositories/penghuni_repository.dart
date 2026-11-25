import 'package:flutter/foundation.dart';

import 'package:belajar_dart/data/services/supabase_service.dart';
import 'package:belajar_dart/domain/models/penghuni.dart';
import 'package:belajar_dart/utils/formatters.dart';

class PenghuniRepository {
  const PenghuniRepository();

  List<Penghuni> getDemoDaftarPenghuni() {
    return const [
      Penghuni(
        nama: 'Assiya Nazrun',
        roomDetails: 'Kamar A03 - Apr 2026',
        status: 'Aktif',
      ),
      Penghuni(
        nama: 'Siti Aisyah',
        roomDetails: 'Kamar A01 - Apr 2026',
        status: 'Aktif',
      ),
      Penghuni(
        nama: 'Kamila',
        roomDetails: 'Kamar A07 - Apr 2026',
        status: 'Aktif',
      ),
      Penghuni(
        nama: 'Dini Aulia',
        roomDetails: 'Kamar B02 - Apr 2026',
        status: 'Aktif',
      ),
    ];
  }

  Future<List<String>> _ambilKosIdsPemilik() async {
    final user = SupabaseService.currentUser;
    if (user == null) return const [];

    final ids = <String>{};
    try {
      final kosList = await SupabaseService.client
          .from('kos')
          .select('id')
          .eq('pemilik_id', user.id);
      for (final row in kosList) {
        if (row['id'] != null) ids.add(row['id'].toString());
      }
    } catch (_) {}

    try {
      final anggota = await SupabaseService.client
          .from('anggota_kos')
          .select('kos_id')
          .eq('pengguna_id', user.id)
          .eq('peran', 'pemilik')
          .eq('status', 'aktif');
      for (final row in anggota) {
        if (row['kos_id'] != null) ids.add(row['kos_id'].toString());
      }
    } catch (_) {}

    return ids.toList();
  }

  /// Menghapus otomatis penyewaan & keanggotaan penghuni yang sudah tidak aktif
  /// (status berakhir/dihentikan atau tanggal_selesai sudah lewat).
  Future<void> _bersihkanPenghuniTidakAktif(List<String> kosIds) async {
    for (final kosId in kosIds) {
      try {
        await SupabaseService.client.rpc(
          'hapus_penghuni_tidak_aktif',
          params: {'p_kos_id': kosId},
        );
        continue;
      } catch (e) {
        debugPrint('RPC hapus_penghuni_tidak_aktif fallback ($kosId): $e');
      }

      // Fallback langsung dari klien jika RPC belum dideploy.
      try {
        final rows = await SupabaseService.client
            .from('penyewaan')
            .select('id, penghuni_id, status, kamar!inner(kos_id)')
            .eq('kamar.kos_id', kosId);

        final inactiveIds = <String>[];
        final inactiveUserIds = <String>{};
        final activeUserIds = <String>{};

        for (final row in rows) {
          final id = row['id']?.toString();
          final penghuniId = row['penghuni_id']?.toString();
          final status = row['status']?.toString();
          final isInactive = status != 'aktif' && status != 'menunggu_mulai';

          if (isInactive) {
            if (id != null) inactiveIds.add(id);
            if (penghuniId != null) inactiveUserIds.add(penghuniId);
          } else {
            if (penghuniId != null) activeUserIds.add(penghuniId);
          }
        }

        for (final sewaId in inactiveIds) {
          try {
            await SupabaseService.client
                .from('penyewaan')
                .delete()
                .eq('id', sewaId);
          } catch (e) {
            debugPrint('Fallback hapus penyewaan $sewaId gagal: $e');
          }
        }

        for (final uid in inactiveUserIds.difference(activeUserIds)) {
          try {
            await SupabaseService.client
                .from('anggota_kos')
                .delete()
                .eq('kos_id', kosId)
                .eq('pengguna_id', uid)
                .eq('peran', 'penghuni');
          } catch (e) {
            debugPrint('Fallback hapus anggota_kos $uid gagal: $e');
          }
        }
      } catch (e) {
        debugPrint('Fallback bersihkan penghuni tidak aktif gagal: $e');
      }
    }
  }

  /// Menghapus satu penyewaan penghuni dari database secara langsung.
  Future<void> hapusPenghuni(String penyewaanId) async {
    if (!SupabaseService.isAvailable) return;

    try {
      await SupabaseService.client.rpc(
        'hapus_penyewaan_penghuni',
        params: {'p_penyewaan_id': penyewaanId},
      );
      return;
    } catch (e) {
      debugPrint('RPC hapus_penyewaan_penghuni fallback: $e');
    }

    final sewa = await SupabaseService.client
        .from('penyewaan')
        .select('penghuni_id, kamar!inner(kos_id)')
        .eq('id', penyewaanId)
        .maybeSingle();

    await SupabaseService.client
        .from('penyewaan')
        .delete()
        .eq('id', penyewaanId);

    final penghuniId = sewa?['penghuni_id']?.toString();
    final kamar = _asMap(sewa?['kamar']);
    final kosId = kamar?['kos_id']?.toString();
    if (penghuniId != null && kosId != null) {
      await SupabaseService.client
          .from('anggota_kos')
          .delete()
          .eq('kos_id', kosId)
          .eq('pengguna_id', penghuniId)
          .eq('peran', 'penghuni');
    }
  }

  Future<List<Penghuni>> getDaftarPenghuni() async {
    if (!SupabaseService.isAvailable) return getDemoDaftarPenghuni();

    final kosIds = await _ambilKosIdsPemilik();
    if (kosIds.isNotEmpty) {
      await _bersihkanPenghuniTidakAktif(kosIds);
    }

    var query = SupabaseService.client
        .from('penyewaan')
        .select(
          'id,penghuni_id,status,tanggal_mulai,tanggal_selesai,'
          'pengguna!penyewaan_penghuni_id_fkey(nama_lengkap),'
          'kamar!inner(nomor_kamar,kos_id)',
        )
        .inFilter('status', ['aktif', 'menunggu_mulai']);

    if (kosIds.isNotEmpty) {
      query = query.inFilter('kamar.kos_id', kosIds);
    }

    final rows = await query.order('tanggal_mulai', ascending: false);

    final result = <Penghuni>[];
    final seen = <String>{};

    for (final row in rows) {
      final selesai = Formatters.parseDate(row['tanggal_selesai']);

      final penghuniId = row['penghuni_id'] as String?;
      if (penghuniId != null && !seen.add(penghuniId)) continue;

      final pengguna = _asMap(row['pengguna']);
      final kamar = _asMap(row['kamar']);
      final nomorKamar = kamar?['nomor_kamar'] as String? ?? '-';

      result.add(
        Penghuni(
          id: penghuniId ?? row['id'] as String?,
          penyewaanId: row['id'] as String?,
          nama: pengguna?['nama_lengkap'] as String? ?? '-',
          roomDetails: selesai == null
              ? 'Kamar $nomorKamar'
              : 'Kamar $nomorKamar - ${Formatters.bulanTahun(selesai)}',
          status: 'Aktif',
        ),
      );
    }

    return result;
  }

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
