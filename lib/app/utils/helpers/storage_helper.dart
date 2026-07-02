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

  // 🔔 Gestion des Alertes Sonores (Réutilisable : Cuisine & Distribution)
  static const String _soundAlertKey = 'sound_alerts_enabled';

  static Future<void> saveSoundAlertStatus(bool isEnabled) async {
    await _storage.write(_soundAlertKey, isEnabled);
  }

  static bool getSoundAlertStatus() {
    return _storage.read<bool>(_soundAlertKey) ?? true; 
  }

  // 🍳 Gestion de l'Auto-Next (Spécifique Cuisine)
  static const String _autoNextKey = 'cuisine_auto_next_enabled';

  static Future<void> saveAutoNextStatus(bool isEnabled) async {
    await _storage.write(_autoNextKey, isEnabled);
  }

  static bool getAutoNextStatus() {
    return _storage.read<bool>(_autoNextKey) ?? false; 
  }
}