import 'package:shared_preferences/shared_preferences.dart';

class TokenSessionService {
  static const _key = 'token_penghuni_terakhir';

  Future<void> simpan(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token.trim());
  }

  Future<String?> baca() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> hapus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
