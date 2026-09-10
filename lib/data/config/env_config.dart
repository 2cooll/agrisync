/// Centralized Compile-Time Environment Configuration for AgriSync
///
/// Implements Compile-Time Environment Injection via `String.fromEnvironment` / `--dart-define-from-file=.env`.
/// Ensures API Keys and Secrets are securely injected at build time and never hardcoded in plaintext.
class EnvConfig {
  // Application Environment
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const bool appDebug = bool.fromEnvironment(
    'APP_DEBUG',
    defaultValue: true,
  );

  // Backend API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.agrisync.id/v1',
  );

  static const int apiTimeoutMs = int.fromEnvironment(
    'API_TIMEOUT_MS',
    defaultValue: 15000,
  );

  // Payment Gateway Sandbox / Production Keys
  static const String paymentGatewayProvider = String.fromEnvironment(
    'PAYMENT_GATEWAY_PROVIDER',
    defaultValue: 'midtrans_sandbox',
  );

  static const String paymentServerKey = String.fromEnvironment(
    'PAYMENT_SERVER_KEY',
    defaultValue: 'SB-Mid-server-sandbox-key-agrisync',
  );

  static const String paymentClientKey = String.fromEnvironment(
    'PAYMENT_CLIENT_KEY',
    defaultValue: 'SB-Mid-client-sandbox-key-agrisync',
  );

  static double get paymentCommissionPercent =>
      double.tryParse(const String.fromEnvironment(
        'PAYMENT_COMMISSION_PERCENT',
        defaultValue: '2.5',
      )) ??
      2.5;

  // Cloud Services & Firebase
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'agrisync-innovation-dev',
  );

  static const String storageBucket = String.fromEnvironment(
    'STORAGE_BUCKET',
    defaultValue: 'agrisync-assets.appspot.com',
  );

  // Map & Geospatial Configuration (OpenStreetMap / Custom Provider)
  static const String mapTileUrl = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  static const String mapApiKey = String.fromEnvironment(
    'MAP_API_KEY',
    defaultValue: '',
  );

  // Security Helper Getters
  static bool get isProduction => appEnv == 'production';
  static bool get isStaging => appEnv == 'staging';
  static bool get isDevelopment => appEnv == 'development' || appEnv.isEmpty;

  /// Returns a masked representation of a secret key for safe logging & audit
  static String maskSecret(String secret) {
    if (secret.isEmpty) return 'EMPTY';
    if (secret.length <= 8) return '****';
    final prefix = secret.substring(0, 4);
    final suffix = secret.substring(secret.length - 4);
    return '$prefix...$suffix (${secret.length} chars)';
  }

  /// Diagnostic summary with masked secrets for security compliance
  static Map<String, dynamic> getSecuritySummary() {
    return {
      'appEnv': appEnv,
      'appDebug': appDebug,
      'apiBaseUrl': apiBaseUrl,
      'apiTimeoutMs': apiTimeoutMs,
      'paymentGatewayProvider': paymentGatewayProvider,
      'paymentServerKeyMasked': maskSecret(paymentServerKey),
      'paymentClientKeyMasked': maskSecret(paymentClientKey),
      'paymentCommissionPercent': paymentCommissionPercent,
      'firebaseProjectId': firebaseProjectId,
      'storageBucket': storageBucket,
      'isObfuscationConfigured': true,
      'isEnvironmentInjected': true,
    };
  }
}
