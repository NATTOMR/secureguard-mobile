class AppConfig {
  AppConfig._();

  // Android Emulator loopback to Host machine
  static const String emulatorApiBaseUrl = 'http://10.0.2.2:8000';
  // Standard Localhost (iOS / Desktop / Web)
  static const String localhostApiBaseUrl = 'http://127.0.0.1:8000';
  // Production SecureGuard Cloud API Endpoint
  static const String productionApiBaseUrl = 'https://api.secureguard.enterprise';

  // Active FastAPI Backend URL
  static const String defaultApiBaseUrl = emulatorApiBaseUrl;
  static String apiBaseUrl = defaultApiBaseUrl;

  // Network Timeout Configurations
  static const int connectTimeoutSeconds = 12;
  static const int receiveTimeoutSeconds = 12;
  static const int sendTimeoutSeconds = 12;

  // Feature Flags & Defaults
  static const bool enableBiometrics = true;
  static const bool enablePushNotifications = true;
  
  // Platform Execution Mode:
  // - true: Offline / Demo simulation mode (standalone operation without FastAPI)
  // - false: Production / Live API mode (requires running FastAPI backend)
  static bool isDemoMode = true;
}
