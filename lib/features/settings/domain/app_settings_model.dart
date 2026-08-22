import 'package:equatable/equatable.dart';

class AppSettingsModel extends Equatable {
  final String backendUrl;
  final bool biometricAuthEnabled;
  final bool pushNotificationsEnabled;
  final bool criticalAlertsOnly;
  final bool encryptedLocalStorage;
  final String themeMode; // 'dark', 'system'
  final bool isDemoMode;
  final bool githubConnected;
  final bool wazuhConnected;
  final bool dailyDigestEnabled;
  final bool soundHapticsEnabled;

  const AppSettingsModel({
    required this.backendUrl,
    this.biometricAuthEnabled = true,
    this.pushNotificationsEnabled = true,
    this.criticalAlertsOnly = false,
    this.encryptedLocalStorage = true,
    this.themeMode = 'dark',
    this.isDemoMode = true,
    this.githubConnected = true,
    this.wazuhConnected = true,
    this.dailyDigestEnabled = true,
    this.soundHapticsEnabled = false,
  });

  AppSettingsModel copyWith({
    String? backendUrl,
    bool? biometricAuthEnabled,
    bool? pushNotificationsEnabled,
    bool? criticalAlertsOnly,
    bool? encryptedLocalStorage,
    String? themeMode,
    bool? isDemoMode,
    bool? githubConnected,
    bool? wazuhConnected,
    bool? dailyDigestEnabled,
    bool? soundHapticsEnabled,
  }) {
    return AppSettingsModel(
      backendUrl: backendUrl ?? this.backendUrl,
      biometricAuthEnabled: biometricAuthEnabled ?? this.biometricAuthEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      criticalAlertsOnly: criticalAlertsOnly ?? this.criticalAlertsOnly,
      encryptedLocalStorage: encryptedLocalStorage ?? this.encryptedLocalStorage,
      themeMode: themeMode ?? this.themeMode,
      isDemoMode: isDemoMode ?? this.isDemoMode,
      githubConnected: githubConnected ?? this.githubConnected,
      wazuhConnected: wazuhConnected ?? this.wazuhConnected,
      dailyDigestEnabled: dailyDigestEnabled ?? this.dailyDigestEnabled,
      soundHapticsEnabled: soundHapticsEnabled ?? this.soundHapticsEnabled,
    );
  }

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      backendUrl: json['backend_url'] as String? ?? 'http://10.0.2.2:8000',
      biometricAuthEnabled: json['biometric_auth_enabled'] as bool? ?? true,
      pushNotificationsEnabled: json['push_notifications_enabled'] as bool? ?? true,
      criticalAlertsOnly: json['critical_alerts_only'] as bool? ?? false,
      encryptedLocalStorage: json['encrypted_local_storage'] as bool? ?? true,
      themeMode: json['theme_mode'] as String? ?? 'dark',
      isDemoMode: json['is_demo_mode'] as bool? ?? true,
      githubConnected: json['github_connected'] as bool? ?? true,
      wazuhConnected: json['wazuh_connected'] as bool? ?? true,
      dailyDigestEnabled: json['daily_digest_enabled'] as bool? ?? true,
      soundHapticsEnabled: json['sound_haptics_enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'backend_url': backendUrl,
        'biometric_auth_enabled': biometricAuthEnabled,
        'push_notifications_enabled': pushNotificationsEnabled,
        'critical_alerts_only': criticalAlertsOnly,
        'encrypted_local_storage': encryptedLocalStorage,
        'theme_mode': themeMode,
        'is_demo_mode': isDemoMode,
        'github_connected': githubConnected,
        'wazuh_connected': wazuhConnected,
        'daily_digest_enabled': dailyDigestEnabled,
        'sound_haptics_enabled': soundHapticsEnabled,
      };

  @override
  List<Object?> get props => [
        backendUrl,
        biometricAuthEnabled,
        pushNotificationsEnabled,
        criticalAlertsOnly,
        encryptedLocalStorage,
        themeMode,
        isDemoMode,
        githubConnected,
        wazuhConnected,
        dailyDigestEnabled,
        soundHapticsEnabled,
      ];
}
