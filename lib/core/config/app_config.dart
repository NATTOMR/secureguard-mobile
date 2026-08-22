class AppConfig {
  AppConfig._();

  // Default FastAPI Backend URL (10.0.2.2 is localhost for Android Emulator)
  static const String defaultApiBaseUrl = 'http://10.0.2.2:8000';
  static String apiBaseUrl = defaultApiBaseUrl;

  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 15;

  // Feature Flags & Defaults
  static const bool enableBiometrics = true;
  static const bool enablePushNotifications = true;
  static const bool isDemoMode = true; // Set to false when connecting to production FastAPI instance
}
