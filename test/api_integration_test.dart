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

import 'package:securepulse_mobile/core/services/github_oauth_service.dart';
import 'package:securepulse_mobile/core/services/offline_queue_service.dart';
import 'package:securepulse_mobile/core/services/report_pdf_service.dart';
import 'package:securepulse_mobile/features/alerts/data/wazuh_repository.dart';
import 'package:securepulse_mobile/features/alerts/domain/wazuh_models.dart';

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
      expect(ApiEndpoints.githubAuth, equals('/v1/auth/github'));
      expect(ApiEndpoints.dashboard, equals('/v1/dashboard/summary'));
      expect(ApiEndpoints.repositories, equals('/v1/repositories'));
      expect(ApiEndpoints.alerts, equals('/v1/soc/alerts'));
      expect(ApiEndpoints.wazuhAgents, equals('/v1/wazuh/agents'));
      expect(ApiEndpoints.wazuhDaemons, equals('/v1/wazuh/daemons'));
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

    test('AuthRepository loginWithGitHub returns demo user when isDemoMode is true', () async {
      AppConfig.isDemoMode = true;
      final authRepo = AuthRepositoryImpl(apiClient: apiClient);

      final user = await authRepo.loginWithGitHub();
      expect(user.id, equals('usr_sec_01'));
      expect(user.name, equals('Alex Vance'));
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

  group('GitHub OAuth2 Deep-Linking & Security Tests', () {
    final oauthService = GithubOAuthService.instance;

    test('GithubOAuthService generates high-entropy random state', () {
      final state1 = oauthService.generateState();
      final state2 = oauthService.generateState();

      expect(state1.length, equals(32));
      expect(state2.length, equals(32));
      expect(state1, isNot(equals(state2)));
    });

    test('GithubOAuthService builds well-formed authorization URI', () {
      const state = 'secure_test_state_12345';
      final uri = oauthService.buildAuthorizationUri(
        state: state,
        clientId: 'test_client_id_999',
        redirectUri: 'securepulse://oauth/callback',
        scopes: 'read:user,repo',
      );

      expect(uri.scheme, equals('https'));
      expect(uri.host, equals('github.com'));
      expect(uri.path, equals('/login/oauth/authorize'));
      expect(uri.queryParameters['client_id'], equals('test_client_id_999'));
      expect(uri.queryParameters['redirect_uri'], equals('securepulse://oauth/callback'));
      expect(uri.queryParameters['scope'], equals('read:user,repo'));
      expect(uri.queryParameters['state'], equals(state));
    });

    test('GithubOAuthService extracts valid code from callback URI', () {
      const state = 'expected_state_abc';
      final uri = Uri.parse('securepulse://oauth/callback?code=gh_auth_code_9876&state=expected_state_abc');

      final code = oauthService.extractCodeFromUri(uri, state);
      expect(code, equals('gh_auth_code_9876'));
    });

    test('GithubOAuthService rejects callback URI with mismatched state (CSRF mitigation)', () {
      const state = 'expected_state_abc';
      final uri = Uri.parse('securepulse://oauth/callback?code=gh_auth_code_9876&state=attacker_state_xyz');

      expect(
        () => oauthService.extractCodeFromUri(uri, state),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('CSRF'))),
      );
    });

    test('GithubOAuthService ignores unrelated deep links gracefully', () {
      const state = 'expected_state_abc';
      final uri = Uri.parse('securepulse://dashboard/view');

      final result = oauthService.extractCodeFromUri(uri, state);
      expect(result, isNull);
    });
  });

  group('Cryptographic PDF Audit Stamping Tests', () {
    test('ReportPdfService computes deterministic 64-char hex SHA-256 digest', () {
      final digest = ReportPdfService.computeAuditDigest(
        auditId: 'SEC-AUD-887910',
        framework: 'SOC 2 Type II',
        postureScore: 94,
        timestamp: 'September 01, 2026 • 12:00:00 UTC',
      );

      expect(digest.length, equals(64));
      expect(RegExp(r'^[a-f0-9]{64}$').hasMatch(digest), isTrue);
    });

    test('Audit digest exhibits cryptographic avalanche effect on data change', () {
      final digest1 = ReportPdfService.computeAuditDigest(
        auditId: 'SEC-AUD-887910',
        framework: 'SOC 2 Type II',
        postureScore: 94,
        timestamp: 'September 01, 2026 • 12:00:00 UTC',
      );

      final digest2 = ReportPdfService.computeAuditDigest(
        auditId: 'SEC-AUD-887910',
        framework: 'SOC 2 Type II',
        postureScore: 93, // Different score
        timestamp: 'September 01, 2026 • 12:00:00 UTC',
      );

      final digest3 = ReportPdfService.computeAuditDigest(
        auditId: 'SEC-AUD-887911', // Different audit ID
        framework: 'SOC 2 Type II',
        postureScore: 94,
        timestamp: 'September 01, 2026 • 12:00:00 UTC',
      );

      expect(digest1, isNot(equals(digest2)));
      expect(digest1, isNot(equals(digest3)));
    });

    test('ReportPdfService builds valid PDF document bytes containing %PDF header', () async {
      TestWidgetsFlutterBinding.ensureInitialized();

      final pdfBytes = await ReportPdfService.buildSecurityReportPdf(
        framework: 'ISO 27001',
        reportTitle: 'ISO 27001 Compliance Audit',
        postureScore: 92,
        healthGrade: 'A',
      );

      expect(pdfBytes.isNotEmpty, isTrue);
      // PDF Magic Header %PDF- (0x25, 0x50, 0x44, 0x46, 0x2D)
      expect(pdfBytes[0], equals(0x25));
      expect(pdfBytes[1], equals(0x50));
      expect(pdfBytes[2], equals(0x44));
      expect(pdfBytes[3], equals(0x46));
      expect(pdfBytes[4], equals(0x2D));
    });
  });

  group('Wazuh SIEM Connector & Manager API Tests', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient(baseUrl: 'http://10.0.2.2:8000');
    });

    test('WazuhRepository returns structured agent inventory in Demo Mode', () async {
      AppConfig.isDemoMode = true;
      final wazuhRepo = WazuhRepositoryImpl(apiClient: apiClient);

      final agents = await wazuhRepo.getAgents();
      expect(agents.length, equals(4));
      expect(agents.first.id, equals('001'));
      expect(agents.first.name, equals('prod-api-gateway-01'));
      expect(agents.first.osName, equals('Ubuntu'));
      expect(agents.first.status, equals(WazuhAgentStatus.active));
      expect(agents.any((a) => a.osName == 'Windows Server'), isTrue);
    });

    test('WazuhRepository returns cluster daemon statuses in Demo Mode', () async {
      AppConfig.isDemoMode = true;
      final wazuhRepo = WazuhRepositoryImpl(apiClient: apiClient);

      final daemons = await wazuhRepo.getDaemons();
      expect(daemons.length, equals(5));
      expect(daemons.any((d) => d.daemonName == 'wazuh-analysisd'), isTrue);
      expect(daemons.any((d) => d.daemonName == 'wazuh-remoted'), isTrue);
      expect(daemons.every((d) => d.isRunning), isTrue);
    });

    test('WazuhRepository restartAgent and restartDaemon actions succeed in Demo Mode', () async {
      AppConfig.isDemoMode = true;
      final wazuhRepo = WazuhRepositoryImpl(apiClient: apiClient);

      final agentRestart = await wazuhRepo.restartAgent('001');
      final daemonRestart = await wazuhRepo.restartDaemon('wazuh-analysisd');

      expect(agentRestart, isTrue);
      expect(daemonRestart, isTrue);
    });

    test('WazuhAgentModel serialization and deserialization validation', () {
      final agent = WazuhAgentModel(
        id: '101',
        name: 'test-node-101',
        ip: '192.168.1.50',
        status: WazuhAgentStatus.active,
        osName: 'Alpine',
        osVersion: '3.19',
        version: 'Wazuh v4.7.2',
        group: 'containers',
        lastKeepAlive: DateTime.parse('2026-09-01T12:00:00Z'),
      );

      final json = agent.toJson();
      final deserialized = WazuhAgentModel.fromJson(json);

      expect(deserialized.id, equals('101'));
      expect(deserialized.name, equals('test-node-101'));
      expect(deserialized.osName, equals('Alpine'));
      expect(deserialized.status, equals(WazuhAgentStatus.active));
      expect(deserialized, equals(agent));
    });

    test('WazuhDaemonModel serialization and deserialization validation', () {
      const daemon = WazuhDaemonModel(
        daemonName: 'wazuh-authd',
        description: 'Agent enrollment daemon',
        isRunning: true,
        pid: 18402,
        uptime: '99.99%',
      );

      final json = daemon.toJson();
      final deserialized = WazuhDaemonModel.fromJson(json);

      expect(deserialized.daemonName, equals('wazuh-authd'));
      expect(deserialized.pid, equals(18402));
      expect(deserialized.isRunning, isTrue);
      expect(deserialized, equals(daemon));
    });
  });

  group('Offline Action & Mutation Queue Architecture Tests', () {
    test('OfflineMutation model serialization and deserialization validation', () {
      final mutation = OfflineMutation(
        id: 'mut_test_001',
        type: MutationType.updateAlertStatus,
        endpoint: '/v1/soc/alerts/alt_001/status',
        method: 'PUT',
        payload: const {'status': 'resolved'},
        createdAt: DateTime.parse('2026-09-01T12:00:00Z'),
        retryCount: 1,
      );

      final json = mutation.toJson();
      final deserialized = OfflineMutation.fromJson(json);

      expect(deserialized.id, equals('mut_test_001'));
      expect(deserialized.type, equals(MutationType.updateAlertStatus));
      expect(deserialized.endpoint, equals('/v1/soc/alerts/alt_001/status'));
      expect(deserialized.method, equals('PUT'));
      expect(deserialized.payload['status'], equals('resolved'));
      expect(deserialized.retryCount, equals(1));
      expect(deserialized, equals(mutation));
    });

    test('OfflineQueueService enqueues, queries, and removes mutations properly', () async {
      final queueService = OfflineQueueService.instance;
      await queueService.clear();

      expect(queueService.pendingCount, equals(0));

      final mutation = OfflineMutation(
        id: 'mut_queue_01',
        type: MutationType.triggerScan,
        endpoint: '/v1/repositories/repo_1/scan',
        method: 'POST',
        payload: const {'branch': 'main'},
        createdAt: DateTime.now(),
      );

      await queueService.enqueue(mutation);
      expect(queueService.pendingCount, equals(1));
      expect(queueService.pendingMutations.first.id, equals('mut_queue_01'));

      await queueService.remove('mut_queue_01');
      expect(queueService.pendingCount, equals(0));
    });

    test('OfflineQueueService flushQueue handles empty queue gracefully', () async {
      final queueService = OfflineQueueService.instance;
      await queueService.clear();

      final client = ApiClient(baseUrl: 'http://10.0.2.2:8000');
      final flushed = await queueService.flushQueue(client);

      expect(flushed, equals(0));
    });

    test('OfflineMutation copyWith creates modified clones correctly', () {
      final m1 = OfflineMutation(
        id: 'mut_01',
        type: MutationType.restartAgent,
        endpoint: '/v1/wazuh/agents/001/restart',
        method: 'POST',
        payload: const {},
        createdAt: DateTime.now(),
      );

      final m2 = m1.copyWith(retryCount: 3);
      expect(m2.id, equals('mut_01'));
      expect(m2.retryCount, equals(3));
      expect(m1.retryCount, equals(0));
    });
  });
}
