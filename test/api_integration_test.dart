import 'package:flutter_test/flutter_test.dart';
import 'package:securepulse_mobile/core/config/app_config.dart';
import 'package:securepulse_mobile/core/error/api_exception.dart';
import 'package:securepulse_mobile/core/network/api_client.dart';
import 'package:securepulse_mobile/core/network/api_endpoints.dart';
import 'package:securepulse_mobile/core/network/websocket_service.dart';
import 'package:securepulse_mobile/features/ai/data/ai_repository.dart';
import 'package:securepulse_mobile/features/alerts/data/alerts_repository.dart';
import 'package:securepulse_mobile/features/auth/data/auth_repository.dart';
import 'package:securepulse_mobile/features/dashboard/data/dashboard_repository.dart';
import 'package:securepulse_mobile/features/repositories/data/repository_repository.dart';

void main() {
  group('ApiClient & Network Architecture Tests', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient(baseUrl: 'http://10.0.2.2:8000');
    });

    test('ApiClient initializes with correct default headers and base URL', () {
      expect(apiClient.baseUrl, equals('http://10.0.2.2:8000'));
      expect(apiClient.hasAuthToken, isFalse);
    });

    test('Auth token header is correctly set and cleared', () {
      apiClient.setAuthToken('test_jwt_token_12345');
      expect(apiClient.hasAuthToken, isTrue);

      apiClient.clearAuthToken();
      expect(apiClient.hasAuthToken, isFalse);
    });

    test('Base URL can be dynamically updated for environment switching', () {
      apiClient.updateBaseUrl('https://api.securepulse.enterprise');
      expect(apiClient.baseUrl, equals('https://api.securepulse.enterprise'));
    });

    test('ApiEndpoints contract verification', () {
      expect(ApiEndpoints.health, equals('/health'));
      expect(ApiEndpoints.login, equals('/v1/auth/login'));
      expect(ApiEndpoints.me, equals('/v1/auth/me'));
      expect(ApiEndpoints.dashboard, equals('/v1/dashboard/summary'));
      expect(ApiEndpoints.repositories, equals('/v1/repositories'));
      expect(ApiEndpoints.alerts, equals('/v1/soc/alerts'));
      expect(ApiEndpoints.aiChat, equals('/v1/ai/chat'));
      expect(ApiEndpoints.scans, equals('/v1/scans'));
      expect(ApiEndpoints.findings, equals('/v1/findings'));
      expect(ApiEndpoints.reports, equals('/v1/reports'));
    });

    test('ApiException error classification checks', () {
      const authErr = ApiException(
        message: 'Unauthorized',
        statusCode: 401,
        errorType: ApiErrorType.unauthorized,
      );
      expect(authErr.isAuthError, isTrue);
      expect(authErr.isNetworkError, isFalse);
      expect(authErr.toString(), contains('HTTP 401'));

      const netErr = ApiException(
        message: 'Connection timed out',
        errorType: ApiErrorType.connectionTimeout,
      );
      expect(netErr.isAuthError, isFalse);
      expect(netErr.isNetworkError, isTrue);
    });
  });

  group('Demo Mode vs Live Mode Isolation Tests', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient(baseUrl: 'http://10.0.2.2:8000');
    });

    test('AuthRepository returns demo user when isDemoMode is true', () async {
      AppConfig.isDemoMode = true;
      final authRepo = AuthRepositoryImpl(apiClient: apiClient);

      final user = await authRepo.login(
        email: 'analyst@securepulse.enterprise',
        password: 'Password123!',
      );

      expect(user.id, equals('usr_sec_01'));
      expect(user.name, equals('Alex Vance'));
      expect(user.role, equals('Principal Security Analyst'));
    });

    test('DashboardRepository returns structured demo telemetry when isDemoMode is true', () async {
      AppConfig.isDemoMode = true;
      final dashboardRepo = DashboardRepositoryImpl(apiClient: apiClient);

      final summary = await dashboardRepo.getDashboardSummary();
      expect(summary.postureScore, equals(88));
      expect(summary.totalRepositories, equals(28));
      expect(summary.recentEvents.isNotEmpty, isTrue);
      expect(summary.systemStatuses.isNotEmpty, isTrue);
    });

    test('RepositoryRepository returns mock codebases when isDemoMode is true', () async {
      AppConfig.isDemoMode = true;
      final repoRepo = RepositoryRepositoryImpl(apiClient: apiClient);

      final repos = await repoRepo.getRepositories();
      expect(repos.length, equals(5));
      expect(repos.first.name, equals('secureguard-backend'));
      expect(repos.first.primaryLanguage, equals('Python'));
    });

    test('AlertsRepository returns mock SIEM incidents when isDemoMode is true', () async {
      AppConfig.isDemoMode = true;
      final alertsRepo = AlertsRepositoryImpl(apiClient: apiClient);

      final alerts = await alertsRepo.getAlerts();
      expect(alerts.length, equals(6));
      expect(alerts.first.source, equals('Wazuh SOC'));
    });

    test('AiRepository generates local security advice when isDemoMode is true', () async {
      AppConfig.isDemoMode = true;
      final aiRepo = AiRepositoryImpl(apiClient: apiClient);

      final response = await aiRepo.sendSecurityPrompt('How do I fix CVE-2024-3094 in XZ?');
      expect(response.content, contains('CVE-2024-3094'));
      expect(response.content, contains('xz-utils'));
    });

    test('Live API mode is active when isDemoMode is false', () {
      AppConfig.isDemoMode = false;
      expect(AppConfig.isDemoMode, isFalse);
    });
  });

  group('WebSocket Real-Time URL Conversion & Architecture Tests', () {
    test('WebSocketService correctly converts http to ws for local emulator', () {
      AppConfig.apiBaseUrl = 'http://10.0.2.2:8000';
      final ws = WebSocketService();
      final uri = ws.getWebSocketUri('test_token_123');

      expect(uri.scheme, equals('ws'));
      expect(uri.host, equals('10.0.2.2'));
      expect(uri.port, equals(8000));
      expect(uri.path, equals('/ws/alerts'));
      expect(uri.queryParameters['token'], equals('test_token_123'));
    });

    test('WebSocketService correctly converts https to wss for Render cloud', () {
      AppConfig.apiBaseUrl = 'https://secureguard-backend-7eqm.onrender.com';
      final ws = WebSocketService();
      final uri = ws.getWebSocketUri('test_jwt_secure');

      expect(uri.scheme, equals('wss'));
      expect(uri.host, equals('secureguard-backend-7eqm.onrender.com'));
      expect(uri.path, equals('/ws/alerts'));
      expect(uri.queryParameters['token'], equals('test_jwt_secure'));
    });

    test('WebSocketService stays disconnected when Demo Mode is active', () async {
      AppConfig.isDemoMode = true;
      final ws = WebSocketService();
      await ws.connect(explicitToken: 'mock_token');

      expect(ws.currentStatus, equals(WebSocketStatus.disconnected));
      ws.dispose();
    });
  });
}
