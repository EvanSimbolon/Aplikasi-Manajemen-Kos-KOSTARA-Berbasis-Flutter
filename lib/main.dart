import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:belajar_dart/config/app.dart';
import 'package:belajar_dart/config/app_config.dart';
import 'package:belajar_dart/config/supabase_config.dart';
import 'package:belajar_dart/ui/pembayaran/view_models/pembayaran_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.environment = Environment.production;

  await SupabaseConfig.initialize();
  if (!SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
    );
  }

  await initializeDateFormatting('id_ID');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PembayaranViewModel()),
      ],
      child: const KostaraApp(),
    ),
  );
}
