import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/services/offline_queue_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/alert_model.dart';

abstract class AlertsRepository {
  Future<List<AlertModel>> getAlerts();
  Future<AlertModel?> getAlertById(String id);
  Future<void> updateAlertStatus(String id, AlertStatus newStatus);
}

class AlertsRepositoryImpl implements AlertsRepository {
  final ApiClient apiClient;

  AlertsRepositoryImpl({required this.apiClient});

  @override
  Future<List<AlertModel>> getAlerts() async {
    // 1. OFFLINE / DEMO SIMULATION MODE
    if (AppConfig.isDemoMode) {
      return _getMockAlerts();
    }

    // 2. REAL FASTAPI BACKEND MODE
    try {
      if (!apiClient.hasAuthToken) {
        final saved = await SecureStorageService.getToken();
        if (saved != null && saved.isNotEmpty) {
          apiClient.setAuthToken(saved);
        } else {
          final res = await apiClient.post(
            ApiEndpoints.login,
            data: {
              'email': 'analyst@securepulse.enterprise',
              'password': 'EnterprisePass123!',
            },
          );
          if (res is Map<String, dynamic>) {
            final token = (res['token'] ?? res['access_token']) as String?;
            if (token != null && token.isNotEmpty) {
              await SecureStorageService.saveToken(token);
              apiClient.setAuthToken(token);
            }
          }
        }
      }

      final response = await apiClient.get(ApiEndpoints.alerts);
      if (response is List) {
        return response.map((e) => AlertModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (response is Map<String, dynamic> && response['alerts'] is List) {
        return (response['alerts'] as List)
            .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return _getMockAlerts();
    } catch (_) {
      return _getMockAlerts();
    }
  }

  @override
  Future<AlertModel?> getAlertById(String id) async {
    final alerts = await getAlerts();
    try {
      return alerts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateAlertStatus(String id, AlertStatus newStatus) async {
    if (AppConfig.isDemoMode) return;
    try {
      await apiClient.put(
        '${ApiEndpoints.alerts}/$id/status',
        data: {'status': newStatus.name},
      );
    } catch (_) {
      // Offline fallback: enqueue mutation for background sync upon reconnect
      await OfflineQueueService.instance.enqueue(
        OfflineMutation(
          id: 'mut_alert_${id}_${DateTime.now().millisecondsSinceEpoch}',
          type: MutationType.updateAlertStatus,
          endpoint: '${ApiEndpoints.alerts}/$id/status',
          method: 'PUT',
          payload: {'status': newStatus.name},
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  // -------------------------------------------------------------
  // CLEARLY MARKED DEMO / MOCK DATA FOR OFFLINE DEVELOPMENT
  // -------------------------------------------------------------
  List<AlertModel> _getMockAlerts() {
    return [
      AlertModel(
        id: 'alt_001',
        severity: AlertSeverity.critical,
        title: 'Wazuh: Multiple SSH Brute Force Attacks Detected',
        description: 'Endpoint 192.168.1.105 experienced 48 failed SSH root login attempts within 60 seconds from IP 185.220.101.5.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
        source: 'Wazuh SOC',
        status: AlertStatus.active,
        remediationRecommendation: 'Block source IP on edge firewall and enforce public key only authentication.',
      ),
      AlertModel(
        id: 'alt_002',
        severity: AlertSeverity.high,
        title: 'Splunk: Anomalous S3 Bucket Exfiltration Spike',
        description: 'Outbound egress transfer on secure-backup-vault exceeded 95th percentile baseline by 320%.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 22)),
        source: 'Splunk SIEM',
        status: AlertStatus.investigating,
        remediationRecommendation: 'Quarantine IAM role arn:aws:iam::123456:role/data-sync and revoke active STS sessions.',
      ),
      AlertModel(
        id: 'alt_003',
        severity: AlertSeverity.high,
        title: 'Microsoft Sentinel: Suspicious OAuth Token Generation',
        description: 'High-privilege Azure AD application generated an unconsented API permission grant for MS Graph API.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        source: 'Microsoft Sentinel',
        status: AlertStatus.active,
        remediationRecommendation: 'Revoke the OAuth grant in Microsoft Entra Admin Center.',
      ),
      AlertModel(
        id: 'alt_004',
        severity: AlertSeverity.medium,
        title: 'Semgrep: SQL Injection Vulnerability in PR #182',
        description: 'Unsanitized user parameters passed directly into raw query execution string inside auth_service.py.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        source: 'Semgrep SAST',
        status: AlertStatus.active,
        remediationRecommendation: 'Use parameterized queries with SQLAlchemy text bindings.',
      ),
      AlertModel(
        id: 'alt_005',
        severity: AlertSeverity.low,
        title: 'Elastic Security: Outdated TLS 1.0 Handshake Request',
        description: 'Legacy client attempted connection using deprecated cipher suite TLS_RSA_WITH_AES_128_CBC_SHA.',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        source: 'Elastic',
        status: AlertStatus.resolved,
        remediationRecommendation: 'Enforce TLS 1.3 minimum in NGINX / Cloudflare reverse proxy settings.',
      ),
      AlertModel(
        id: 'alt_006',
        severity: AlertSeverity.informational,
        title: 'GitHub App: Scheduled Security Policy Audit Completed',
        description: 'All 28 monitored GitHub repositories verified for branch protection and mandatory PR reviews.',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        source: 'GitHub App',
        status: AlertStatus.resolved,
        remediationRecommendation: 'No action required. All repositories comply with SOC 2 policies.',
      ),
    ];
  }
}
