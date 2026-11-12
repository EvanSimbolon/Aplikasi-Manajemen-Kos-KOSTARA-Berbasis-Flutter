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
    anonKey: 'sb_secret_UTpTg47LZEvB654EaongmQ_N7PyVtDu',
  );

  await initializeDateFormatting('id_ID');

  runApp(const KostaraApp());
}

final supabase = Supabase.instance.client;