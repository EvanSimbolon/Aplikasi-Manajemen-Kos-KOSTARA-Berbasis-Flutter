import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:belajar_dart/domain/models/riwayat_pembayaran.dart';

class RiwayatPembayaranRepository {
  const RiwayatPembayaranRepository();

  Future<List<RiwayatPembayaran>> getRiwayat() async {
    final rows = await Supabase.instance.client
        .from('pembayaran')
        .select(
        'id, jumlah_pembayaran, status, dibayar_pada, tagihan(periode_mulai)')
        .order('dibayar_pada', ascending: false);

    return (rows as List)
        .map((e) => RiwayatPembayaran.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}