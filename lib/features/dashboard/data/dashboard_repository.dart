import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/dashboard_model.dart';

abstract class DashboardRepository {
  Future<DashboardModel> getDashboardSummary();
}

class DashboardRepositoryImpl implements DashboardRepository {
  final ApiClient apiClient;

  DashboardRepositoryImpl({required this.apiClient});

  @override
  Future<DashboardModel> getDashboardSummary() async {
    // 1. OFFLINE / DEMO SIMULATION MODE
    if (AppConfig.isDemoMode) {
      return _getMockDashboardSummary();
    }

    // 2. REAL FASTAPI BACKEND MODE
    final response = await apiClient.get(ApiEndpoints.dashboard);
    if (response is Map<String, dynamic>) {
      return DashboardModel.fromJson(response);
    }
    throw Exception('Invalid telemetry payload received from FastAPI /v1/dashboard/summary');
  }

  // -------------------------------------------------------------
  // CLEARLY MARKED DEMO / MOCK DATA FOR OFFLINE DEVELOPMENT
  // -------------------------------------------------------------
  DashboardModel _getMockDashboardSummary() {
    return DashboardModel(
      postureScore: 88,
      postureStatus: 'Secure',
      totalRepositories: 28,
      totalScansToday: 142,
      criticalCount: 3,
      highCount: 12,
      mediumCount: 24,
      lowCount: 58,
      activeAlertsCount: 7,
      systemStatuses: [
        SystemStatusModel(name: 'FastAPI Backend Engine', status: 'operational', latencyMs: 18),
        SystemStatusModel(name: 'GitHub App Webhook', status: 'operational', latencyMs: 34),
        SystemStatusModel(name: 'Semgrep SAST Engine', status: 'operational', latencyMs: 42),
        SystemStatusModel(name: 'Wazuh SOC Connector', status: 'operational', latencyMs: 22),
        SystemStatusModel(name: 'Splunk / Sentinel Bridge', status: 'operational', latencyMs: 51),
      ],
      recentEvents: [
        SecurityEventSummary(
          id: 'evt_001',
          title: 'Wazuh: Multiple SSH authentication failures detected from external IP',
          source: 'Wazuh SOC',
          severity: 'Critical',
          timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
        SecurityEventSummary(
          id: 'evt_002',
          title: 'Semgrep: Hardcoded JWT secret key identified in auth_service.py',
          source: 'Semgrep SAST',
          severity: 'High',
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
        SecurityEventSummary(
          id: 'evt_003',
          title: 'GitHub App: Pull request #412 merged without required SAST signoff',
          source: 'GitHub App',
          severity: 'Medium',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        SecurityEventSummary(
          id: 'evt_004',
          title: 'Elastic Security: Outdated TLS 1.0 handshake attempted on API gateway',
          source: 'Elastic',
          severity: 'Low',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ],
      recentScans: [
        RecentScanSummary(
          id: 'scn_101',
          target: 'secureguard-backend (main)',
          scanType: 'Semgrep SAST',
          status: 'Passed',
          findingsCount: 0,
          duration: '18s',
          timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        ),
        RecentScanSummary(
          id: 'scn_102',
          target: 'payments-microservice (v2.1)',
          scanType: 'Secret Scanning',
          status: 'Failed',
          findingsCount: 2,
          duration: '11s',
          timestamp: DateTime.now().subtract(const Duration(minutes: 48)),
        ),
        RecentScanSummary(
          id: 'scn_103',
          target: 'auth-gateway-docker (latest)',
          scanType: 'Container Scan',
          status: 'Passed',
          findingsCount: 1,
          duration: '32s',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
    );
  }
}
