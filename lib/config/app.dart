import 'package:flutter/material.dart';

import 'package:belajar_dart/config/app_config.dart';
import 'package:belajar_dart/routing/app_router.dart';
import 'package:belajar_dart/routing/app_routes.dart';
import 'package:belajar_dart/ui/core/themes/app_theme.dart';

class KostaraApp extends StatelessWidget {
  const KostaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      theme: AppTheme.themeData,
      initialRoute: AppRoutes.landing,
      routes: AppRouter.routes,
    );
  }
}
