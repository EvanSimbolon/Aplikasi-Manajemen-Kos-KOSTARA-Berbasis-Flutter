import 'package:flutter/material.dart';

import 'package:belajar_dart/config/app.dart';
import 'package:belajar_dart/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cbvhufmufcredviwguko.supabase.co',
    // Key format baru (bukan JWT). Jangan pernah menaruh secret key di sini.
    publishableKey: 'sb_publishable_PcNyzyod-QXvavBeHbsLpA_9hevDLkw',
  );

  runApp(const KostaraApp());
}
