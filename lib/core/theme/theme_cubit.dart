import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/hive_database.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  static const _key = 'isDarkMode';

  void loadFromPersistence() {
    final box = HiveDatabase.settingsBox;
    final isDark = box.get(_key, defaultValue: false) as bool;
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
