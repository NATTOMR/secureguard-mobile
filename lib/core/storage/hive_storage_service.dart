import 'package:hive_flutter/hive_flutter.dart';

class HiveStorageService {
  static const String appBoxName = 'securepulse_cache';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(appBoxName);
  }

  Box get _box => Hive.box(appBoxName);

  Future<void> cacheData(String key, dynamic value) async {
    await _box.put(key, value);
  }

  dynamic getCachedData(String key) {
    return _box.get(key);
  }

  Future<void> clearCache() async {
    await _box.clear();
  }
}
