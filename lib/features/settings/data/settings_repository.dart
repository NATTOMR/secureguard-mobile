import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_config.dart';
import '../../../core/storage/hive_storage_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/app_settings_model.dart';

abstract class SettingsRepository {
  Future<AppSettingsModel> loadSettings();
  Future<void> saveSettings(AppSettingsModel settings);
  Future<void> clearLocalCache();
}

class SettingsRepositoryImpl implements SettingsRepository {
  static const String _settingsKey = 'sg_app_settings_json';
  static const String _backendUrlKey = 'sg_custom_backend_url';
  static const String _isDemoModeKey = 'sg_is_demo_mode';

  @override
  Future<AppSettingsModel> loadSettings() async {
    bool? savedDemoMode;
    String? savedBackendUrl;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(_isDemoModeKey)) {
        savedDemoMode = prefs.getBool(_isDemoModeKey);
      }
      if (prefs.containsKey(_backendUrlKey)) {
        savedBackendUrl = prefs.getString(_backendUrlKey);
      }
      if (prefs.containsKey(_settingsKey)) {
        final jsonStr = prefs.getString(_settingsKey);
        if (jsonStr != null && jsonStr.isNotEmpty) {
          final Map<String, dynamic> data = jsonDecode(jsonStr);
          final model = AppSettingsModel.fromJson(data);
          if (savedDemoMode != null) {
            AppConfig.isDemoMode = savedDemoMode;
          }
          if (savedBackendUrl != null && savedBackendUrl.isNotEmpty) {
            AppConfig.apiBaseUrl = savedBackendUrl;
          }
          return model.copyWith(
            isDemoMode: savedDemoMode ?? model.isDemoMode,
            backendUrl: savedBackendUrl ?? model.backendUrl,
          );
        }
      }
    } catch (_) {}

    try {
      final jsonStr = await SecureStorageService.read(_settingsKey).timeout(
        const Duration(milliseconds: 300),
        onTimeout: () => null,
      );
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        final model = AppSettingsModel.fromJson(data);
        if (savedDemoMode != null) {
          AppConfig.isDemoMode = savedDemoMode;
        }
        return model.copyWith(isDemoMode: savedDemoMode ?? model.isDemoMode);
      }
    } catch (_) {}

    try {
      if (Hive.isBoxOpen(HiveStorageService.appBoxName)) {
        final box = Hive.box(HiveStorageService.appBoxName);
        final cached = box.get(_settingsKey);
        if (cached != null && cached is String && cached.isNotEmpty) {
          final Map<String, dynamic> data = jsonDecode(cached);
          final model = AppSettingsModel.fromJson(data);
          if (savedDemoMode != null) {
            AppConfig.isDemoMode = savedDemoMode;
          }
          return model.copyWith(isDemoMode: savedDemoMode ?? model.isDemoMode);
        }
      }
    } catch (_) {}

    final effectiveDemoMode = savedDemoMode ?? AppConfig.isDemoMode;
    AppConfig.isDemoMode = effectiveDemoMode;

    return AppSettingsModel(
      backendUrl: savedBackendUrl ?? AppConfig.apiBaseUrl,
      biometricAuthEnabled: true,
      pushNotificationsEnabled: true,
      criticalAlertsOnly: false,
      encryptedLocalStorage: true,
      themeMode: 'dark',
      isDemoMode: effectiveDemoMode,
      githubConnected: true,
      wazuhConnected: true,
      dailyDigestEnabled: true,
      soundHapticsEnabled: false,
    );
  }

  @override
  Future<void> saveSettings(AppSettingsModel settings) async {
    final encoded = jsonEncode(settings.toJson());
    AppConfig.apiBaseUrl = settings.backendUrl;
    AppConfig.isDemoMode = settings.isDemoMode;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isDemoModeKey, settings.isDemoMode);
      await prefs.setString(_backendUrlKey, settings.backendUrl);
      await prefs.setString(_settingsKey, encoded);
    } catch (_) {}

    try {
      await SecureStorageService.write(_settingsKey, encoded).timeout(
        const Duration(milliseconds: 300),
        onTimeout: () {},
      );
      await SecureStorageService.write(_backendUrlKey, settings.backendUrl).timeout(
        const Duration(milliseconds: 300),
        onTimeout: () {},
      );
    } catch (_) {}

    try {
      if (Hive.isBoxOpen(HiveStorageService.appBoxName)) {
        final box = Hive.box(HiveStorageService.appBoxName);
        await box.put(_settingsKey, encoded);
        await box.put(_backendUrlKey, settings.backendUrl);
      }
    } catch (_) {}
  }

  @override
  Future<void> clearLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_settingsKey);
      await prefs.remove(_backendUrlKey);
      await prefs.remove(_isDemoModeKey);
    } catch (_) {}

    try {
      await SecureStorageService.delete(_settingsKey).timeout(
        const Duration(milliseconds: 300),
        onTimeout: () {},
      );
      await SecureStorageService.delete(_backendUrlKey).timeout(
        const Duration(milliseconds: 300),
        onTimeout: () {},
      );
    } catch (_) {}

    try {
      if (Hive.isBoxOpen(HiveStorageService.appBoxName)) {
        final box = Hive.box(HiveStorageService.appBoxName);
        await box.clear();
      }
    } catch (_) {}
  }
}

