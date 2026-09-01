import '../core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/network/websocket_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/offline_queue_service.dart';
import '../features/ai/data/ai_repository.dart';
import '../features/alerts/data/alerts_repository.dart';
import '../features/alerts/data/wazuh_repository.dart';
import '../features/alerts/domain/alert_model.dart';
import '../features/alerts/domain/wazuh_models.dart';
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

// Core Network & Infrastructure Providers
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  client.initToken();
  return client;
});

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final ws = WebSocketService();
  ref.onDispose(() => ws.dispose());
  return ws;
});

final webSocketStatusStreamProvider = StreamProvider<WebSocketStatus>((ref) {
  final ws = ref.watch(webSocketServiceProvider);
  return ws.statusStream;
});

final offlineQueueServiceProvider = Provider<OfflineQueueService>((ref) {
  final service = OfflineQueueService.instance;
  service.attachApiClient(ref.watch(apiClientProvider));
  return service;
});

final pendingMutationsStreamProvider = StreamProvider<List<OfflineMutation>>((ref) {
  final queue = ref.watch(offlineQueueServiceProvider);
  return queue.queueStream;
});

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

final wazuhRepositoryProvider = Provider<WazuhRepository>((ref) {
  return WazuhRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl();
});

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  return ScanRepository(apiClient: ref.watch(apiClientProvider));
});

final findingRepositoryProvider = Provider<FindingRepository>((ref) {
  return FindingRepository(apiClient: ref.watch(apiClientProvider));
});

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
  final WebSocketService _ws;

  AuthStateNotifier(this._repo, this._ws) : super(const AuthState());

  Future<void> loginWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.login(email: email, password: password);
      state = state.copyWith(user: user, isLoading: false);
      if (!AppConfig.isDemoMode) {
        _ws.connect();
      }
    } catch (e) {
      if (AppConfig.isDemoMode) {
        final demo = await _repo.getDemoUser();
        state = state.copyWith(user: demo, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: e.toString());
        rethrow;
      }
    }
  }

  Future<void> loginWithGithub() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.loginWithGitHub();
      state = state.copyWith(user: user, isLoading: false);
      if (!AppConfig.isDemoMode) {
        _ws.connect();
      }
    } catch (e) {
      if (AppConfig.isDemoMode) {
        final demo = await _repo.getDemoUser();
        state = state.copyWith(user: demo, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: e.toString());
        rethrow;
      }
    }
  }

  Future<void> loginOffline() async {
    state = state.copyWith(isLoading: true, error: null);
    final demo = await _repo.getDemoUser();
    state = state.copyWith(user: demo, isLoading: false);
  }

  Future<void> logout() async {
    await _ws.disconnect();
    await _repo.logout();
    state = const AuthState(user: null);
  }
}

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(webSocketServiceProvider),
  );
});

// Execution Mode State Provider
final isDemoModeProvider = StateProvider<bool>((ref) => AppConfig.isDemoMode);

// Real-Time Live Alerts StateNotifier
class LiveAlertsNotifier extends StateNotifier<AsyncValue<List<AlertModel>>> {
  final AlertsRepository _repo;
  final WebSocketService _ws;
  final NotificationService _notifications;
  StreamSubscription? _eventSub;
  StreamSubscription? _pushSub;

  LiveAlertsNotifier(this._repo, this._ws, this._notifications) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await refresh();
    _eventSub?.cancel();
    _pushSub?.cancel();
    _eventSub = _ws.eventStream.listen(_handleWebSocketEvent);
    _pushSub = _notifications.onNotificationReceived.listen(_handlePushEvent);

    if (!AppConfig.isDemoMode) {
      _ws.connect();
    } else {
      _ws.disconnect();
    }
  }

  Future<void> refresh() async {
    try {
      final alerts = await _repo.getAlerts();
      state = AsyncValue.data(alerts);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  void _handlePushEvent(Map<String, dynamic> payload) {
    try {
      final title = payload['title'] as String? ?? 'Security Alert';
      final body = payload['body'] as String? ?? '';
      final source = payload['source'] as String? ?? 'FCM Push';
      final sevStr = (payload['severity'] as String? ?? 'critical').toLowerCase();
      
      AlertSeverity severity = AlertSeverity.medium;
      if (sevStr == 'critical') severity = AlertSeverity.critical;
      if (sevStr == 'high') severity = AlertSeverity.high;
      if (sevStr == 'low') severity = AlertSeverity.low;

      final newAlert = AlertModel(
        id: 'fcm_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: body,
        severity: severity,
        source: source,
        timestamp: DateTime.now(),
        status: AlertStatus.active,
        remediationRecommendation: 'Investigate incident details and apply mitigation patch.',
      );

      state.whenData((list) {
        state = AsyncValue.data([newAlert, ...list]);
      });
    } catch (_) {}
  }

  void _handleWebSocketEvent(Map<String, dynamic> event) {
    final type = event['type'] as String?;
    if (type == 'security_alert' && event['alert'] != null) {
      try {
        final newAlert = AlertModel.fromJson(event['alert'] as Map<String, dynamic>);
        state.whenData((list) {
          // Avoid duplicate additions
          final updated = [newAlert, ...list.where((a) => a.id != newAlert.id)];
          state = AsyncValue.data(updated);
        });
      } catch (_) {}
    } else if ((type == 'alert_updated' || type == 'alert_resolved') && event['alert'] != null) {
      try {
        final updatedAlert = AlertModel.fromJson(event['alert'] as Map<String, dynamic>);
        state.whenData((list) {
          final updated = list.map((a) => a.id == updatedAlert.id ? updatedAlert : a).toList();
          state = AsyncValue.data(updated);
        });
      } catch (_) {}
    } else if (type == 'telemetry_sync' && event['alerts'] is List) {
      try {
        final alerts = (event['alerts'] as List)
            .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
            .toList();
        state = AsyncValue.data(alerts);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _pushSub?.cancel();
    super.dispose();
  }
}

final liveAlertsNotifierProvider = StateNotifierProvider<LiveAlertsNotifier, AsyncValue<List<AlertModel>>>((ref) {
  ref.watch(isDemoModeProvider);
  return LiveAlertsNotifier(
    ref.watch(alertsRepositoryProvider),
    ref.watch(webSocketServiceProvider),
    ref.watch(notificationServiceProvider),
  );
});

// Real-Time Live Dashboard StateNotifier
class LiveDashboardNotifier extends StateNotifier<AsyncValue<DashboardModel>> {
  final DashboardRepository _repo;
  final WebSocketService _ws;
  StreamSubscription? _eventSub;

  LiveDashboardNotifier(this._repo, this._ws) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await refresh();
    _eventSub?.cancel();
    _eventSub = _ws.eventStream.listen(_handleWebSocketEvent);
  }

  Future<void> refresh() async {
    try {
      final summary = await _repo.getDashboardSummary();
      state = AsyncValue.data(summary);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  void _handleWebSocketEvent(Map<String, dynamic> event) {
    final type = event['type'] as String?;
    if (type == 'security_alert' && event['alert'] != null) {
      try {
        final alertMap = event['alert'] as Map<String, dynamic>;
        final sev = (alertMap['severity'] as String? ?? '').toLowerCase();
        state.whenData((dashboard) {
          final isCrit = sev == 'critical';
          final isHigh = sev == 'high';
          final newEvent = SecurityEventSummary(
            id: alertMap['id'] as String? ?? 'evt_${DateTime.now().millisecondsSinceEpoch}',
            title: alertMap['title'] as String? ?? 'Security Incident',
            source: alertMap['source'] as String? ?? 'Wazuh SOC',
            severity: sev.isNotEmpty ? '${sev[0].toUpperCase()}${sev.substring(1)}' : 'Medium',
            timestamp: DateTime.tryParse(alertMap['timestamp'] as String? ?? '') ?? DateTime.now(),
          );

          state = AsyncValue.data(
            dashboard.copyWith(
              activeAlertsCount: dashboard.activeAlertsCount + 1,
              criticalCount: isCrit ? dashboard.criticalCount + 1 : dashboard.criticalCount,
              highCount: isHigh ? dashboard.highCount + 1 : dashboard.highCount,
              recentEvents: [newEvent, ...dashboard.recentEvents.take(9)],
            ),
          );
        });
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }
}

final liveDashboardNotifierProvider = StateNotifierProvider<LiveDashboardNotifier, AsyncValue<DashboardModel>>((ref) {
  ref.watch(isDemoModeProvider);
  ref.watch(authStateProvider);
  return LiveDashboardNotifier(
    ref.watch(dashboardRepositoryProvider),
    ref.watch(webSocketServiceProvider),
  );
});

// Telemetry & Data Future Providers
final dashboardDataProvider = Provider<AsyncValue<DashboardModel>>((ref) {
  return ref.watch(liveDashboardNotifierProvider);
});

final repositoriesDataProvider = FutureProvider<List<RepositoryModel>>((ref) async {
  ref.watch(isDemoModeProvider);
  ref.watch(authStateProvider);
  return ref.watch(repositoryRepositoryProvider).getRepositories();
});

final alertsDataProvider = Provider<AsyncValue<List<AlertModel>>>((ref) {
  return ref.watch(liveAlertsNotifierProvider);
});

final appSettingsProvider = FutureProvider<AppSettingsModel>((ref) async {
  ref.watch(isDemoModeProvider);
  ref.watch(authStateProvider);
  return ref.watch(settingsRepositoryProvider).loadSettings();
});

final scansListProvider = FutureProvider((ref) async {
  ref.watch(isDemoModeProvider);
  ref.watch(authStateProvider);
  return ref.watch(scanRepositoryProvider).getScans();
});

final findingsListProvider = FutureProvider((ref) async {
  ref.watch(isDemoModeProvider);
  ref.watch(authStateProvider);
  return ref.watch(findingRepositoryProvider).getFindings();
});

final wazuhAgentsProvider = FutureProvider<List<WazuhAgentModel>>((ref) async {
  ref.watch(isDemoModeProvider);
  ref.watch(authStateProvider);
  return ref.watch(wazuhRepositoryProvider).getAgents();
});

final wazuhDaemonsProvider = FutureProvider<List<WazuhDaemonModel>>((ref) async {
  ref.watch(isDemoModeProvider);
  ref.watch(authStateProvider);
  return ref.watch(wazuhRepositoryProvider).getDaemons();
});



// Dynamic App Theme StateNotifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsRepository _settingsRepo;

  ThemeModeNotifier(this._settingsRepo) : super(ThemeMode.dark) {
    _init();
  }

  Future<void> _init() async {
    try {
      final settings = await _settingsRepo.loadSettings();
      switch (settings.themeMode.toLowerCase()) {
        case 'light':
          state = ThemeMode.light;
          AppColors.isDark = false;
          break;
        case 'system':
          state = ThemeMode.system;
          AppColors.isDark = true;
          break;
        case 'dark':
        default:
          state = ThemeMode.dark;
          AppColors.isDark = true;
          break;
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    AppColors.isDark = mode != ThemeMode.light;
    try {
      final current = await _settingsRepo.loadSettings();
      String modeStr = 'dark';
      if (mode == ThemeMode.light) modeStr = 'light';
      if (mode == ThemeMode.system) modeStr = 'system';
      await _settingsRepo.saveSettings(current.copyWith(themeMode: modeStr));
    } catch (_) {}
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(settingsRepositoryProvider));
});
