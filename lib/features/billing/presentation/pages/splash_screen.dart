import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:billing_app/l10n/app_localizations.dart';

import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_event.dart';
import 'home_page.dart';
import '../../../../core/locale/language_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // Run initialization after first frame so context is available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Ensure SharedPreferences is available
      try {
        await SharedPreferences.getInstance();
      } catch (_) {
        // ignore
      }

      // Try to initialize SettingsBloc (if provided) and LanguageCubit
      try {
        // Load settings if a SettingsBloc exists higher in the tree
        try {
          context.read<SettingsBloc>().add(LoadSettingsEvent());
        } catch (_) {
          // SettingsBloc not provided here; ignore
        }

        // Ensure LanguageCubit loads persisted language
        try {
          await context.read<LanguageCubit>().loadFromPersistence();
        } catch (_) {
          // ignore
        }
      } catch (_) {}

      // Wait a minimum of 3 seconds so the splash is visible
      _timer = Timer(const Duration(seconds: 3), () {
        _goToHome();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToHome() {
    if (_navigated) return;
    _navigated = true;
    if (!mounted) return;

    // Navigate using Navigator so router won't interfere with the initial flow
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check whether AppLocalizations is ready. We avoid accessing generated
    // getters here because gen-l10n may not have been run in the workspace yet.
    if (AppLocalizations.of(context) == null) {
      // Localizations not available yet; fall back to English literals below.
    }
    final appName = 'GRC POS System';
    final copyright = '© ranto nandrianina 2026';

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/Fond.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // Centered logo + app name
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/grc_logo.png',
                    height: 120,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    appName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom copyright
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Center(
                child: Text(
                  copyright,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
