import '../../../core/config/app_config.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/app_settings_model.dart';

abstract class SettingsRepository {
  Future<AppSettingsModel> loadSettings();
  Future<void> saveSettings(AppSettingsModel settings);
  Future<void> clearLocalCache();
}

class SettingsRepositoryImpl implements SettingsRepository {
  static const String _backendUrlKey = 'sg_custom_backend_url';

  @override
  Future<AppSettingsModel> loadSettings() async {
    final customUrl = await SecureStorageService.read(_backendUrlKey);
    return AppSettingsModel(
      backendUrl: customUrl ?? AppConfig.apiBaseUrl,
      biometricAuthEnabled: true,
      pushNotificationsEnabled: true,
      criticalAlertsOnly: false,
      encryptedLocalStorage: true,
      themeMode: 'dark',
    );
  }

  @override
  Future<void> saveSettings(AppSettingsModel settings) async {
    await SecureStorageService.write(_backendUrlKey, settings.backendUrl);
    AppConfig.apiBaseUrl = settings.backendUrl;
  }

  @override
  Future<void> clearLocalCache() async {
    await SecureStorageService.delete(_backendUrlKey);
  }
}
