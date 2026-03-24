import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageState {
  final String code; // 'mg', 'fr',
  final String name;
  final String currencySymbol;
  final Locale locale;

  const LanguageState({
    required this.code,
    required this.name,
    required this.currencySymbol,
    required this.locale,
  });
}

class LanguageCubit extends Cubit<LanguageState> {
  static const _key = 'app_language_code';

  LanguageCubit()
      : super(const LanguageState(
            code: 'fr',
            name: 'Français',
            currencySymbol: 'Ar',
            locale: Locale('fr')));

  Future<void> loadFromPersistence() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'fr';
    switch (code) {
      case 'mg':
        emit(const LanguageState(
            code: 'mg',
            name: 'Malagasy',
            currencySymbol: 'Ar',
            locale: Locale('mg')));
        break;
      case 'fr':
        emit(const LanguageState(
            code: 'fr',
            name: 'Français',
            currencySymbol: 'Ar',
            locale: Locale('fr')));
        break;
      default:
        // Default to French for first-run experience
        emit(const LanguageState(
            code: 'fr',
            name: 'Français',
            currencySymbol: 'Ar',
            locale: Locale('fr')));
    }
  }

  Future<void> setLanguageCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
    await loadFromPersistence();
  }
}
