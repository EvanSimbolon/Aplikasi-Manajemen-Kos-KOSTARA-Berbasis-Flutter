import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static bool _initialized = false;

  static String get url {
    const fromDefine = String.fromEnvironment('SUPABASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String get publishableKey {
    const fromDefine = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;
    return dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';
  }

  static bool get isConfigured =>
      url.trim().isNotEmpty && publishableKey.trim().isNotEmpty;

  static Future<void> loadEnvironment() async {
    try {
      await dotenv.load();
    } catch (error) {
      debugPrint(
        'Supabase environment file (.env) could not be loaded: $error',
      );
    }
  }

  static Future<void> initialize() async {
    await loadEnvironment();
    if (!isConfigured) {
      debugPrint(
        'Supabase is not configured. Set SUPABASE_URL and '
        'SUPABASE_PUBLISHABLE_KEY in .env or via --dart-define.',
      );
      return;
    }
    if (_initialized) return;
    await Supabase.initialize(url: url, publishableKey: publishableKey);
    _initialized = true;
  }
}
