import 'package:flutter/material.dart';

import 'package:belajar_dart/config/app.dart';
import 'package:belajar_dart/config/app_config.dart';
import 'package:belajar_dart/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.environment = Environment.production;
  await SupabaseConfig.initialize();
  runApp(const KostaraApp());
}
