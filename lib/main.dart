import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/storage/hive_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER_ERROR: ${details.exceptionAsString()}');
    debugPrint('FLUTTER_STACK: ${details.stack}');
  };

  // Initialize Encrypted Hive Offline Storage
  await HiveStorageService.init();

  // Initialize SharedPreferences & Backend Connectivity Default
  try {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('sg_custom_backend_url')) {
      final savedUrl = prefs.getString('sg_custom_backend_url');
      if (savedUrl != null && savedUrl.isNotEmpty) {
        AppConfig.apiBaseUrl = savedUrl;
      }
    }
    if (prefs.containsKey('sg_is_demo_mode')) {
      AppConfig.isDemoMode = prefs.getBool('sg_is_demo_mode') ?? false;
    } else {
      // First Launch: probe live FastAPI backend at http://10.0.2.2:8000
      final testClient = ApiClient();
      final health = await testClient.checkHealth().timeout(
        const Duration(milliseconds: 1500),
        onTimeout: () => (isReachable: false, statusCode: 0, latencyMs: 0, message: 'timeout'),
      );
      if (health.isReachable) {
        AppConfig.isDemoMode = false;
        await prefs.setBool('sg_is_demo_mode', false);
      } else {
        AppConfig.isDemoMode = true;
      }
    }
  } catch (_) {}

  // Enforce Status Bar & System Navigation Styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F172A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: SecureGuardApp(),
    ),
  );
}
