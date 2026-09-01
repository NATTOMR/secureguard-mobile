class AppConfig {
  AppConfig._();

  // Android Emulator loopback to Host machine
  static const String emulatorApiBaseUrl = 'http://10.0.2.2:8000';
  // Standard Localhost (iOS / Desktop / Web)
  static const String localhostApiBaseUrl = 'http://127.0.0.1:8000';
  // Live Render Cloud API Endpoint
  static const String cloudRenderApiBaseUrl = 'https://secureguard-backend-7eqm.onrender.com';
  static const String productionApiBaseUrl = cloudRenderApiBaseUrl;

  // Active FastAPI Backend URL (Defaults to Render Cloud for seamless mobile phone connectivity)
  static const String defaultApiBaseUrl = cloudRenderApiBaseUrl;
  static String apiBaseUrl = defaultApiBaseUrl;

  // Network Timeout Configurations
  static const int connectTimeoutSeconds = 12;
  static const int receiveTimeoutSeconds = 12;
  static const int sendTimeoutSeconds = 12;

  // Feature Flags & Defaults
  static const bool enableBiometrics = true;
  static const bool enablePushNotifications = true;
  
  // GitHub OAuth2 App Configuration
  static const String githubClientId = 'Ov23liSecurePulseApp'; // Replace with production GitHub OAuth App Client ID
  static const String githubOAuthScopes = 'read:user,user:email,repo';
  static const String githubCallbackScheme = 'securepulse';
  static const String githubCallbackHost = 'oauth';
  static const String githubCallbackPath = '/callback';
  static const String githubCallbackUrl = '$githubCallbackScheme://$githubCallbackHost$githubCallbackPath';
  static const String githubAuthorizeUrl = 'https://github.com/login/oauth/authorize';

  // Platform Execution Mode:
  // - true: Offline / Demo simulation mode (standalone operation without FastAPI)
  // - false: Production / Live API mode (requires running FastAPI backend)
  static bool isDemoMode = true;
}
