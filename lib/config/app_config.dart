enum Environment { development, staging, production }

class AppConfig {
  AppConfig._();

  static Environment environment = Environment.development;

  static String get appName => 'Kostara';

  static String get apiBaseUrl {
    switch (environment) {
      case Environment.development:
        return 'https://dev-api.kostara.local';
      case Environment.staging:
        return 'https://staging-api.kostara.local';
      case Environment.production:
        return 'https://api.kostara.local';
    }
  }

  static bool get isProduction => environment == Environment.production;
}
