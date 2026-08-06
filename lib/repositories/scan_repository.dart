import '../models/models.dart';

class ScanRepository {
  Future<List<ScanModel>> getScans() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    return [
      ScanModel(
        id: 'scan_101',
        targetName: 'auth-gateway-service (main)',
        type: ScanType.sast,
        status: ScanStatus.completed,
        findingsCount: 8,
        startedAt: now.subtract(const Duration(hours: 1)),
        completedAt: now.subtract(const Duration(minutes: 48)),
        triggerBy: 'GitHub Actions workflow #4102',
      ),
      ScanModel(
        id: 'scan_102',
        targetName: 'secureguard-mobile (PR #84)',
        type: ScanType.dependency,
        status: ScanStatus.inProgress,
        findingsCount: 0,
        startedAt: now.subtract(const Duration(minutes: 5)),
        triggerBy: 'DevSecOps CLI',
      ),
      ScanModel(
        id: 'scan_103',
        targetName: 'payment-vault-container:v2.1',
        type: ScanType.container,
        status: ScanStatus.completed,
        findingsCount: 14,
        startedAt: now.subtract(const Duration(hours: 4)),
        completedAt: now.subtract(const Duration(hours: 3, minutes: 40)),
        triggerBy: 'Trivy Scanner Engine',
      ),
      ScanModel(
        id: 'scan_104',
        targetName: 'api.secureguard.enterprise',
        type: ScanType.dast,
        status: ScanStatus.completed,
        findingsCount: 3,
        startedAt: now.subtract(const Duration(days: 1)),
        completedAt: now.subtract(const Duration(days: 1, hours: -1)),
        triggerBy: 'OWASP ZAP Automated Daemon',
      ),
    ];
  }
}
