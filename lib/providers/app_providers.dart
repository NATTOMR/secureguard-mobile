import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/ai_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/finding_repository.dart';
import '../repositories/repository_repository.dart';
import '../repositories/scan_repository.dart';
import '../repositories/soc_repository.dart';

// Repository Providers
final authRepositoryProvider = Provider((ref) => AuthRepository());
final dashboardRepositoryProvider = Provider((ref) => DashboardRepository());
final repositoryRepositoryProvider = Provider((ref) => RepositoryRepository());
final scanRepositoryProvider = Provider((ref) => ScanRepository());
final findingRepositoryProvider = Provider((ref) => FindingRepository());
final socRepositoryProvider = Provider((ref) => SocRepository());
final aiRepositoryProvider = Provider((ref) => AiRepository());

// User Auth State Notifier
class AuthStateNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repo;

  AuthStateNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> loginWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.loginWithEmail(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loginWithGithub() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.loginWithGithub();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loginOffline() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.loginOffline();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void logout() {
    state = const AsyncValue.data(null);
  }
}

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthStateNotifier(ref.watch(authRepositoryProvider));
});

// Data Future Providers
final dashboardSummaryProvider = FutureProvider((ref) async {
  return ref.watch(dashboardRepositoryProvider).getDashboardSummary();
});

final repositoriesListProvider = FutureProvider((ref) async {
  return ref.watch(repositoryRepositoryProvider).getRepositories();
});

final scansListProvider = FutureProvider((ref) async {
  return ref.watch(scanRepositoryProvider).getScans();
});

final findingsListProvider = FutureProvider((ref) async {
  return ref.watch(findingRepositoryProvider).getFindings();
});

final socAlertsListProvider = FutureProvider((ref) async {
  return ref.watch(socRepositoryProvider).getAlerts();
});
