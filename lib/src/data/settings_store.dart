import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings.dart';

const _kSettingsKey = 'settings_v1';

class SettingsStore {
  final SharedPreferences prefs;
  SettingsStore(this.prefs);

  static Future<SettingsStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsStore(prefs);
  }

  AppSettings get() {
    final raw = prefs.getString(_kSettingsKey);
    if (raw == null) return AppSettings.defaults;
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(AppSettings s) async {
    await prefs.setString(_kSettingsKey, jsonEncode(s.toJson()));
  }
}
