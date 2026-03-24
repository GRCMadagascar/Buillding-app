import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/hive_database.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  // Default to Dark mode as requested.
  ThemeCubit() : super(ThemeMode.dark);

  static const _key = 'isDarkMode';

  void loadFromPersistence() {
    final box = HiveDatabase.settingsBox;
    // Default to dark if not persisted.
    final isDark = box.get(_key, defaultValue: true) as bool;
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    try {
      final box = HiveDatabase.settingsBox;
      await box.put(_key, mode == ThemeMode.dark);
    } catch (_) {}
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }
}
