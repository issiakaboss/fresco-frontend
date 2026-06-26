// lib/app/utils/helpers/storage_helper.dart
import 'package:get_storage/get_storage.dart';

class StorageHelper {
  static final GetStorage _storage = GetStorage();

  // Generic methods
  static Future<void> set(String key, dynamic value) async {
    await _storage.write(key, value);
  }

  static dynamic get(String key, {dynamic defaultValue}) {
    return _storage.read(key) ?? defaultValue;
  }

  static Future<void> delete(String key) async {
    await _storage.remove(key);
  }

  static Future<void> clearAll() async {
    await _storage.erase();
  }

  // Language-specific methods
  static const String _languageKey = 'language';
  
  static Future<void> saveLanguage(String language) async {
    await _storage.write(_languageKey, language);
  }

  static String? getLanguage() {
    return _storage.read(_languageKey);
  }
}