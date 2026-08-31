import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/repository_model.dart';

abstract class RepositoryRepository {
  Future<List<RepositoryModel>> getRepositories();
  Future<RepositoryModel?> getRepositoryById(String id);
}

class RepositoryRepositoryImpl implements RepositoryRepository {
  final ApiClient apiClient;

  RepositoryRepositoryImpl({required this.apiClient});

  @override
  Future<List<RepositoryModel>> getRepositories() async {
    // 1. OFFLINE / DEMO SIMULATION MODE OR NO AUTH TOKEN
    if (AppConfig.isDemoMode || !apiClient.hasAuthToken) {
      return _getMockRepositories();
    }

    // 2. REAL FASTAPI BACKEND MODE
    try {
      final response = await apiClient.get(ApiEndpoints.repositories);
      if (response is List) {
        return response.map((e) => RepositoryModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (response is Map<String, dynamic> && response['repositories'] is List) {
        return (response['repositories'] as List)
            .map((e) => RepositoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return _getMockRepositories();
    } catch (_) {
      return _getMockRepositories();
    }
  }

  @override
  Future<RepositoryModel?> getRepositoryById(String id) async {
    final repos = await getRepositories();
    try {
      return repos.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // -------------------------------------------------------------
  // CLEARLY MARKED DEMO / MOCK DATA FOR OFFLINE DEVELOPMENT
  // -------------------------------------------------------------
  List<RepositoryModel> _getMockRepositories() {
    return [
      RepositoryModel(
        id: 'repo_01',
        name: 'secureguard-backend',
        owner: 'enterprise-security-org',
        primaryLanguage: 'Python',
        branch: 'main',
        isPrivate: true,
        securityStatus: 'Secure',
        criticalCount: 0,
        highCount: 1,
        mediumCount: 3,
        lowCount: 5,
        secretFindings: 0,
        sastFindings: 4,
        securityHealthScore: 'A',
        lastScannedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      RepositoryModel(
        id: 'repo_02',
        name: 'payment-gateway-service',
        owner: 'enterprise-security-org',
        primaryLanguage: 'Go',
        branch: 'main',
        isPrivate: true,
        securityStatus: 'Critical Risk',
        criticalCount: 2,
        highCount: 4,
        mediumCount: 7,
        lowCount: 12,
        secretFindings: 2,
        sastFindings: 11,
        securityHealthScore: 'F',
        lastScannedAt: DateTime.now().subtract(const Duration(minutes: 42)),
      ),
      RepositoryModel(
        id: 'repo_03',
        name: 'auth-identity-provider',
        owner: 'enterprise-security-org',
        primaryLanguage: 'TypeScript',
        branch: 'production',
        isPrivate: true,
        securityStatus: 'Warning',
        criticalCount: 1,
        highCount: 3,
        mediumCount: 6,
        lowCount: 9,
        secretFindings: 1,
        sastFindings: 8,
        securityHealthScore: 'B',
        lastScannedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      RepositoryModel(
        id: 'repo_04',
        name: 'cloud-infrastructure-terraform',
        owner: 'enterprise-security-org',
        primaryLanguage: 'HCL',
        branch: 'main',
        isPrivate: true,
        securityStatus: 'Secure',
        criticalCount: 0,
        highCount: 0,
        mediumCount: 2,
        lowCount: 4,
        secretFindings: 0,
        sastFindings: 2,
        securityHealthScore: 'A',
        lastScannedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      RepositoryModel(
        id: 'repo_05',
        name: 'customer-web-portal',
        owner: 'enterprise-security-org',
        primaryLanguage: 'Vue',
        branch: 'main',
        isPrivate: false,
        securityStatus: 'Warning',
        criticalCount: 0,
        highCount: 4,
        mediumCount: 6,
        lowCount: 18,
        secretFindings: 0,
        sastFindings: 10,
        securityHealthScore: 'B',
        lastScannedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }
}
