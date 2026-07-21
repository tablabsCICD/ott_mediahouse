import 'package:shared_preferences/shared_preferences.dart';

import 'storage_keys.dart';

class PreferencesService {
  PreferencesService(this._preferences);

  final SharedPreferences _preferences;

  static Future<PreferencesService> create() async =>
      PreferencesService(await SharedPreferences.getInstance());

  String get selectedLanguage =>
      _preferences.getString(StorageKeys.selectedLanguage) ??
      _preferences.getString('langCode') ??
      'en';

  Future<bool> setSelectedLanguage(String value) =>
      _preferences.setString(StorageKeys.selectedLanguage, value);

  bool get isDarkMode =>
      _preferences.getBool(StorageKeys.themeMode) ??
      _preferences.getBool('isDark') ??
      true;

  Future<bool> setDarkMode(bool value) =>
      _preferences.setBool(StorageKeys.themeMode, value);

  String get dashboardPeriod =>
      _preferences.getString(StorageKeys.dashboardPeriod) ?? 'month';

  Future<bool> setDashboardPeriod(String value) =>
      _preferences.setString(StorageKeys.dashboardPeriod, value);

  int get tablePageSize => _preferences.getInt(StorageKeys.tablePageSize) ?? 10;

  Future<bool> setTablePageSize(int value) =>
      _preferences.setInt(StorageKeys.tablePageSize, value.clamp(5, 100));

  int get migrationVersion =>
      _preferences.getInt(StorageKeys.migrationVersion) ?? 0;

  Future<bool> setMigrationVersion(int value) =>
      _preferences.setInt(StorageKeys.migrationVersion, value);

  bool getBool(String key, {bool fallback = false}) =>
      _preferences.getBool(key) ?? fallback;

  String? getString(String key) => _preferences.getString(key);

  Future<bool> setBool(String key, bool value) =>
      _preferences.setBool(key, value);

  Future<bool> setString(String key, String value) =>
      _preferences.setString(key, value);

  Future<bool> remove(String key) => _preferences.remove(key);
}
