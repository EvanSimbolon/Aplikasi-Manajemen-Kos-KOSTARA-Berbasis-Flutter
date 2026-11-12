import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:belajar_dart/config/app.dart';
import 'package:belajar_dart/config/app_config.dart';
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
