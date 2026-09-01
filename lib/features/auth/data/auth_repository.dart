import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/services/github_oauth_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> loginWithGitHub();
  Future<UserModel> loginWithBiometrics();
  Future<UserModel> getDemoUser();
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;

  AuthRepositoryImpl({required this.apiClient});

  @override
  Future<UserModel> login({required String email, required String password}) async {
    // If Demo simulation mode is explicitly enabled, return demo analyst session
    if (AppConfig.isDemoMode) {
      return getDemoUser();
    }

    // Real API mode: dispatch authentication request to FastAPI backend
    final response = await apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    if (response is Map<String, dynamic>) {
      final token = (response['token'] ?? response['access_token']) as String?;
      if (token != null && token.isNotEmpty) {
        await SecureStorageService.saveToken(token);
        apiClient.setAuthToken(token);
      }

      final userData = response['user'] is Map<String, dynamic>
          ? response['user'] as Map<String, dynamic>
          : response;

      return UserModel.fromJson(userData);
    }

    throw Exception('Unexpected authentication response format from FastAPI backend');
  }

  @override
  Future<UserModel> loginWithGitHub() async {
    if (AppConfig.isDemoMode) {
      return getDemoUser();
    }

    // 1. Trigger external browser OAuth flow and await callback code
    final code = await GithubOAuthService.instance.startOAuthFlow();

    // 2. Exchange authorization code with FastAPI backend
    final response = await apiClient.post(
      ApiEndpoints.githubAuth,
      data: {'code': code},
    );

    if (response is Map<String, dynamic>) {
      final token = (response['token'] ?? response['access_token']) as String?;
      if (token != null && token.isNotEmpty) {
        await SecureStorageService.saveToken(token);
        apiClient.setAuthToken(token);
      }

      final userData = response['user'] is Map<String, dynamic>
          ? response['user'] as Map<String, dynamic>
          : response;

      return UserModel.fromJson(userData);
    }

    throw Exception('Unexpected response format during GitHub authentication');
  }

  @override
  Future<UserModel> loginWithBiometrics() async {
    if (AppConfig.isDemoMode) {
      return getDemoUser();
    }

    // Check if a valid JWT exists in hardware-backed secure storage
    final savedToken = await SecureStorageService.getToken();
    if (savedToken != null && savedToken.isNotEmpty) {
      apiClient.setAuthToken(savedToken);
      try {
        final response = await apiClient.get(ApiEndpoints.me);
        if (response is Map<String, dynamic>) {
          return UserModel.fromJson(response);
        }
      } catch (_) {
        // Token expired or invalid, fallback to demo or re-auth
      }
    }
    return getDemoUser();
  }

  @override
  Future<UserModel> getDemoUser() async {
    return const UserModel(
      id: 'usr_sec_01',
      email: 'analyst@securepulse.enterprise',
      name: 'Alex Vance',
      role: 'Principal Security Analyst',
      organization: 'Global Cybersecurity Ops',
      mfaEnabled: true,
    );
  }

  @override
  Future<void> logout() async {
    await SecureStorageService.deleteToken();
    apiClient.clearAuthToken();
  }
}
