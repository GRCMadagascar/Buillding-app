import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Lottie removed: use a simple progress animation with background image

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
  bool _navigated = false;
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    // Initialize a 3-second progress controller that goes from 0.0 -> 1.0
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    // Using the controller's value directly for linear progress.

    // Run initialization after first frame so context is available then start
    // the progress animation once any persistence loads are done.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Ensure SharedPreferences is available (best-effort)
      try {
        await SharedPreferences.getInstance();
      } catch (_) {}

      // Capture and call bloc/cubit references synchronously before any
      // awaits to avoid using BuildContext across async gaps.
      try {
        try {
          final settingsBloc = context.read<SettingsBloc>();
          settingsBloc.add(LoadSettingsEvent());
        } catch (_) {}
        try {
          final languageCubit = context.read<LanguageCubit>();
          await languageCubit.loadFromPersistence();
        } catch (_) {}
      } catch (_) {}

      // Start the 3s progress animation and navigate when complete.
      _progressController.forward();
      _progressController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _goToHome();
        }
      });
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _goToHome() {
    if (_navigated) return;
    _navigated = true;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Localization removed — using hardcoded French and fixed app name below.
    const appName = 'GRC POS SYSTEM';
    const footer = 'BY RANTO NANDRIANINA | GRC 2026';

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen background image
          Positioned.fill(
            child: Image.asset(
              'assets/fond_splash.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              // Subtle dark overlay to make gold elements pop
              color: Colors.black.withValues(alpha: 0.3),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Image.asset(
                    'assets/grc_logo.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),

                  // Title
                  const Text(appName,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37))),
                  const SizedBox(height: 18),

                  // Progress indicator with percentage
                  SizedBox(
                    width: 260,
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        final progress =
                            _progressController.value.clamp(0.0, 1.0);
                        final percent = (progress * 100).round();
                        return Column(
                          children: [
                            LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFD4AF37)),
                            ),
                            const SizedBox(height: 8),
                            Text('$percent %',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer
          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
            child: Center(
              child: Text(
                footer,
                style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
