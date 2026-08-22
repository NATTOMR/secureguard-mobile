import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../features/ai/data/ai_repository.dart';
import '../features/alerts/data/alerts_repository.dart';
import '../features/alerts/domain/alert_model.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/domain/user_model.dart';
import '../features/dashboard/data/dashboard_repository.dart';
import '../features/dashboard/domain/dashboard_model.dart';
import '../features/repositories/data/repository_repository.dart';
import '../features/repositories/domain/repository_model.dart';
import '../features/settings/data/settings_repository.dart';
import '../features/settings/domain/app_settings_model.dart';
import '../repositories/finding_repository.dart';
import '../repositories/scan_repository.dart';

// Core Network Provider
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Repository Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final repositoryRepositoryProvider = Provider<RepositoryRepository>((ref) {
  return RepositoryRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  return AlertsRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl();
});

final scanRepositoryProvider = Provider((ref) => ScanRepository());
final findingRepositoryProvider = Provider((ref) => FindingRepository());

// Authentication State
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthStateNotifier(this._repo) : super(const AuthState());

  Future<void> loginWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.login(email: email, password: password);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      final demo = await _repo.getDemoUser();
      state = state.copyWith(user: demo, isLoading: false);
    }
  }

  Future<void> loginWithGithub() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.loginWithGitHub();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      final demo = await _repo.getDemoUser();
      state = state.copyWith(user: demo, isLoading: false);
    }
  }

  Future<void> loginOffline() async {
    state = state.copyWith(isLoading: true, error: null);
    final demo = await _repo.getDemoUser();
    state = state.copyWith(user: demo, isLoading: false);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(user: null);
  }
}

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref.watch(authRepositoryProvider));
});

// Telemetry & Data Future Providers
final dashboardDataProvider = FutureProvider<DashboardModel>((ref) async {
  return ref.watch(dashboardRepositoryProvider).getDashboardSummary();
});

final repositoriesDataProvider = FutureProvider<List<RepositoryModel>>((ref) async {
  return ref.watch(repositoryRepositoryProvider).getRepositories();
});

final alertsDataProvider = FutureProvider<List<AlertModel>>((ref) async {
  return ref.watch(alertsRepositoryProvider).getAlerts();
});

final appSettingsProvider = FutureProvider<AppSettingsModel>((ref) async {
  return ref.watch(settingsRepositoryProvider).loadSettings();
});

final scansListProvider = FutureProvider((ref) async {
  return ref.watch(scanRepositoryProvider).getScans();
});

final findingsListProvider = FutureProvider((ref) async {
  return ref.watch(findingRepositoryProvider).getFindings();
});
