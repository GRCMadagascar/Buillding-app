import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

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
  bool _lottieScheduled = false;

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

      // We'll navigate when the Lottie animation finishes. The Lottie widget
      // will schedule the navigation via the onLoaded callback.
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
    // Localization removed — using hardcoded French and fixed app name below.
    const appName = 'GRC POS System';
    const copyright = '© ranto nandrianina 2026';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie animation centered. When loaded, schedule navigation
              // to home after the animation duration.
              Lottie.asset(
                'assets/splash_screen.json',
                width: 260,
                height: 260,
                fit: BoxFit.contain,
                repeat: false,
                onLoaded: (composition) {
                  if (_lottieScheduled) return;
                  _lottieScheduled = true;
                  _timer?.cancel();
                  _timer = Timer(composition.duration, () {
                    _goToHome();
                  });
                },
              ),
              const SizedBox(height: 12),
              const Text(appName,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(copyright, style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
