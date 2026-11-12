import 'package:flutter/material.dart';
import 'package:belajar_dart/config/app.dart';
import 'package:belajar_dart/config/app_config.dart';
import 'package:belajar_dart/data/services/kamar_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mengatur environment aplikasi
  AppConfig.environment = Environment.production;

  // Menghubungkan aplikasi dengan Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabasePublishableKey,
  );

  // Menjalankan aplikasi Kostara
  runApp(const KostaraApp());

  // Tes mengambil data kamar dari Supabase
  try {
    final kamarService = KamarService();
    await kamarService.testKamar();

    debugPrint('====================================');
    debugPrint('KONEKSI SUPABASE BERHASIL');
    debugPrint('DATA KAMAR BERHASIL DIAMBIL');
    debugPrint('====================================');
  } catch (e) {
    debugPrint('====================================');
    debugPrint('GAGAL MENGAMBIL DATA KAMAR');
    debugPrint('ERROR: $e');
    debugPrint('====================================');
  }
}