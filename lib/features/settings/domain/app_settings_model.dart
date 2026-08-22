import 'package:equatable/equatable.dart';

class AppSettingsModel extends Equatable {
  final String backendUrl;
  final bool biometricAuthEnabled;
  final bool pushNotificationsEnabled;
  final bool criticalAlertsOnly;
  final bool encryptedLocalStorage;
  final String themeMode; // 'dark', 'system'

  const AppSettingsModel({
    required this.backendUrl,
    this.biometricAuthEnabled = true,
    this.pushNotificationsEnabled = true,
    this.criticalAlertsOnly = false,
    this.encryptedLocalStorage = true,
    this.themeMode = 'dark',
  });

  AppSettingsModel copyWith({
    String? backendUrl,
    bool? biometricAuthEnabled,
    bool? pushNotificationsEnabled,
    bool? criticalAlertsOnly,
    bool? encryptedLocalStorage,
    String? themeMode,
  }) {
    return AppSettingsModel(
      backendUrl: backendUrl ?? this.backendUrl,
      biometricAuthEnabled: biometricAuthEnabled ?? this.biometricAuthEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      criticalAlertsOnly: criticalAlertsOnly ?? this.criticalAlertsOnly,
      encryptedLocalStorage: encryptedLocalStorage ?? this.encryptedLocalStorage,
      themeMode: themeMode ?? this.themeMode,
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
    );
  }

  Map<String, dynamic> toJson() => {
        'backend_url': backendUrl,
        'biometric_auth_enabled': biometricAuthEnabled,
        'push_notifications_enabled': pushNotificationsEnabled,
        'critical_alerts_only': criticalAlertsOnly,
        'encrypted_local_storage': encryptedLocalStorage,
        'theme_mode': themeMode,
      };

  @override
  List<Object?> get props => [
        backendUrl,
        biometricAuthEnabled,
        pushNotificationsEnabled,
        criticalAlertsOnly,
        encryptedLocalStorage,
        themeMode,
      ];
}
