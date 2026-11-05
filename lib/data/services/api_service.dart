import 'package:belajar_dart/config/app_config.dart';

class ApiService {
  const ApiService();

  String get baseUrl => AppConfig.apiBaseUrl;

  Future<void> delay() {
    return Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
