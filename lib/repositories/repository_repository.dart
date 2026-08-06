import '../models/models.dart';

class RepositoryRepository {
  Future<List<RepositoryModel>> getRepositories() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    return [
      RepositoryModel(
        id: 'repo_01',
        name: 'secureguard-backend-api',
        owner: 'secureguard-corp',
        primaryLanguage: 'Go / Python',
        criticalCount: 0,
        highCount: 2,
        mediumCount: 5,
        lowCount: 12,
        securityHealthScore: 'A',
        lastScannedAt: now.subtract(const Duration(hours: 2)),
      ),
      RepositoryModel(
        id: 'repo_02',
        name: 'secureguard-mobile',
        owner: 'secureguard-corp',
        primaryLanguage: 'Dart (Flutter)',
        criticalCount: 0,
        highCount: 0,
        mediumCount: 1,
        lowCount: 3,
        securityHealthScore: 'A+',
        lastScannedAt: now.subtract(const Duration(minutes: 45)),
      ),
      RepositoryModel(
        id: 'repo_03',
        name: 'auth-gateway-service',
        owner: 'secureguard-corp',
        primaryLanguage: 'Rust',
        criticalCount: 1,
        highCount: 3,
        mediumCount: 4,
        lowCount: 8,
        securityHealthScore: 'B-',
        lastScannedAt: now.subtract(const Duration(hours: 5)),
      ),
      RepositoryModel(
        id: 'repo_04',
        name: 'payment-processor-vault',
        owner: 'fintech-secure',
        primaryLanguage: 'TypeScript',
        criticalCount: 2,
        highCount: 4,
        mediumCount: 7,
        lowCount: 15,
        securityHealthScore: 'C+',
        lastScannedAt: now.subtract(const Duration(hours: 12)),
      ),
    ];
  }
}
