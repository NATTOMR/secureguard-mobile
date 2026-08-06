import '../models/models.dart';

class SocRepository {
  Future<List<SocAlertModel>> getAlerts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    return [
      SocAlertModel(
        id: 'soc_alt_901',
        title: 'Brute Force SSH Login Attempt Detected',
        sourceIp: '198.51.100.42 (Rostov, RU)',
        targetHost: 'auth-edge-01.us-east.secureguard.net',
        severity: SeverityLevel.critical,
        eventType: 'AUTHENTICATION_FAILURE_FLOOD',
        timestamp: now.subtract(const Duration(minutes: 8)),
        isAcknowledged: false,
      ),
      SocAlertModel(
        id: 'soc_alt_902',
        title: 'Anomalous Data Egress via Port 443',
        sourceIp: '10.0.4.12 (Internal Database Slave)',
        targetHost: 'unknown-external-bucket.s3.amazonaws.com',
        severity: SeverityLevel.high,
        eventType: 'DATA_EXFILTRATION_SUSPECT',
        timestamp: now.subtract(const Duration(minutes: 24)),
        isAcknowledged: false,
      ),
      SocAlertModel(
        id: 'soc_alt_903',
        title: 'Unauthorized IAM Privilege Escalation',
        sourceIp: '10.0.1.99 (K8s Service Account)',
        targetHost: 'AWS IAM Role: AdminAccess',
        severity: SeverityLevel.high,
        eventType: 'IAM_POLICY_MUTATION',
        timestamp: now.subtract(const Duration(hours: 1)),
        isAcknowledged: true,
      ),
      SocAlertModel(
        id: 'soc_alt_904',
        title: 'Port Scan Sweep from Unknown Subnet',
        sourceIp: '203.0.113.195',
        targetHost: 'perimeter-firewall-02',
        severity: SeverityLevel.medium,
        eventType: 'NETWORK_RECONNAISSANCE',
        timestamp: now.subtract(const Duration(hours: 3)),
        isAcknowledged: true,
      ),
    ];
  }
}
