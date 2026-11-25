import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MotionPreference { full, reduced, off }

class AppSettings extends ChangeNotifier {
  AppSettings._(this._store, this.themeMode, this.accentKey, this.motion,
      this.backgroundEffects);

  final SharedPreferencesAsync _store;
  ThemeMode themeMode;
  String accentKey;
  MotionPreference motion;
  bool backgroundEffects;

  static const accents = <String, Color>{
    'lime': Color(0xFF9BCB55),
    'coral': Color(0xFFE98268),
    'aqua': Color(0xFF59B7A6),
    'amber': Color(0xFFE0AD4F),
  };

  Color get accentColor => accents[accentKey] ?? accents['lime']!;

  static Future<AppSettings> load() async {
    final store = SharedPreferencesAsync();
    final theme = await store.getString('dropx.theme') ?? 'system';
    final accent = await store.getString('dropx.accent') ?? 'lime';
    final motion = await store.getString('dropx.motion') ?? 'full';
    final effects = await store.getBool('dropx.effects') ?? true;

    return AppSettings._(
      store,
      switch (theme) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      accents.containsKey(accent) ? accent : 'lime',
      MotionPreference.values.firstWhere(
        (item) => item.name == motion,
        orElse: () => MotionPreference.full,
      ),
      effects,
    );
  }

  Future<void> setTheme(ThemeMode value) async {
    themeMode = value;
    notifyListeners();
    await _store.setString('dropx.theme', value.name);
  }

  Future<void> setAccent(String value) async {
    if (!accents.containsKey(value)) return;
    accentKey = value;
    notifyListeners();
    await _store.setString('dropx.accent', value);
  }

  Future<void> setMotion(MotionPreference value) async {
    motion = value;
    notifyListeners();
    await _store.setString('dropx.motion', value.name);
  }

  Future<void> setEffects(bool value) async {
    backgroundEffects = value;
    notifyListeners();
    await _store.setBool('dropx.effects', value);
  }
}
