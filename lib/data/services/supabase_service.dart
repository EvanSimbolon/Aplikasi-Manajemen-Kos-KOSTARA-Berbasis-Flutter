import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  static Session? get currentSession => client.auth.currentSession;

  static User? get currentUser => client.auth.currentUser;

  static bool get isAuthenticated => currentSession != null;
}
