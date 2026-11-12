import 'package:flutter/material.dart';
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

  runApp(const KostaraApp());
}

final supabase = Supabase.instance.client;