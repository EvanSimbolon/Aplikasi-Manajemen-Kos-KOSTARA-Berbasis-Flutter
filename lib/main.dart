import 'package:flutter/material.dart';
import 'package:belajar_dart/config/app.dart';
import 'package:belajar_dart/config/app_config.dart';
import 'package:belajar_dart/data/services/kamar_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:belajar_dart/config/app.dart';
import 'package:belajar_dart/config/app_config.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.environment = Environment.production;

  await Supabase.initialize(
    url: 'https://cbvhufmufcredviwguko.supabase.co',
    anonKey: 'ISI_ANON_KEY_DI_SINI',
  );

  await initializeDateFormatting('id_ID');

import 'package:belajar_dart/config/app.dart';
import 'package:belajar_dart/config/app_config.dart';
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

  await Supabase.initialize(
    url: 'https://cbvhufmufcredviwguko.supabase.co',
    // Key format baru (bukan JWT). Jangan pernah menaruh secret key di sini.
    publishableKey: 'sb_publishable_PcNyzyod-QXvavBeHbsLpA_9hevDLkw',
  );

import 'package:belajar_dart/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.environment = Environment.production;
  await SupabaseConfig.initialize();
  runApp(const KostaraApp());
import 'data/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'ui/pembayaran/view_models/pembayaran_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.environment = Environment.production;

  await Supabase.initialize(
    url: 'https://cbvhufmufcredviwguko.supabase.co',
    publishableKey: 'sb_publishable_PcNyzyod-QXvavBeHbsLpA_9hevDLkw',
  );

  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PembayaranViewModel()),
      ],
      child: const KostaraApp(),
    ),
  );
}

final supabase = Supabase.instance.client;