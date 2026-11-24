import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:belajar_dart/config/app_config.dart';
import 'package:belajar_dart/routing/app_router.dart';
import 'package:belajar_dart/routing/app_routes.dart';
import 'package:belajar_dart/ui/core/themes/app_theme.dart';

class KostaraApp extends StatefulWidget {
  const KostaraApp({super.key});

  @override
  State<KostaraApp> createState() => _KostaraAppState();
}

class _KostaraAppState extends State<KostaraApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<AuthState>? _authSubscription;
  bool _resetDibuka = false;

  @override
  void initState() {
    super.initState();
    try {
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange
          .listen((state) {
            if (state.event == AuthChangeEvent.passwordRecovery) {
              _bukaResetPassword();
            }
          });
      unawaited(_tanganiTautanAwal());
    } catch (_) {
      // Supabase belum dikonfigurasi (mis. saat widget test).
    }
  }

  Future<void> _tanganiTautanAwal() async {
    try {
      final uri = await AppLinks().getInitialLink();
      if (uri == null ||
          uri.scheme != 'kostara' ||
          uri.host != 'reset-password') {
        return;
      }

      try {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
      } catch (_) {
        // Tautan mungkin sudah diproses oleh observer bawaan Supabase.
      }
      _bukaResetPassword();
    } catch (_) {
      // Deep link tidak tersedia pada platform/test ini.
    }
  }

  void _bukaResetPassword() {
    if (_resetDibuka) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_resetDibuka) return;
      final navigator = _navigatorKey.currentState;
      if (navigator == null) return;
      _resetDibuka = true;
      navigator.pushNamed(AppRoutes.resetPassword);
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      theme: AppTheme.themeData,
      initialRoute: AppRoutes.landing,
      routes: AppRouter.routes,
    );
  }
}
