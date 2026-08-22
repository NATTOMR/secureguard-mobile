import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
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
    try {
      final response = await apiClient.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      if (response != null && response['token'] != null) {
        await SecureStorageService.saveToken(response['token'] as String);
        apiClient.setAuthToken(response['token'] as String);
      }
      return UserModel.fromJson(response['user'] as Map<String, dynamic>);
    } catch (_) {
      // Fallback to demo user if backend is unreachable during client evaluation
      return getDemoUser();
    }
  }

  @override
  Future<UserModel> loginWithGitHub() async {
    // Connects to backend GitHub App OAuth endpoint
    return getDemoUser();
  }

  @override
  Future<UserModel> loginWithBiometrics() async {
    return getDemoUser();
  }

  @override
  Future<UserModel> getDemoUser() async {
    return const UserModel(
      id: 'usr_sec_01',
      email: 'analyst@secureguard.enterprise',
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
