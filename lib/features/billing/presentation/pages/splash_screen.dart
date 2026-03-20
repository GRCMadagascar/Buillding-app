import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  StreamSubscription? _shopSub;
  Timer? _fallbackTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1), // animation duration
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Wait for the ShopBloc to load shop data (or error) before navigating.
    // This surfaces any initialization issues (e.g., Hive / generated adapter errors)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final shopBloc = context.read<ShopBloc>();

        // If already loaded, navigate immediately
        if (shopBloc.state is ShopLoaded) {
          _navigateHome();
          return;
        }

        // Listen for the first loaded or error state
        _shopSub = shopBloc.stream.listen((state) {
          if (state is ShopLoaded || state is ShopError) {
            _navigateHome();
          }
        });

        // Fallback: navigate after 4 seconds even if ShopBloc didn't emit
        _fallbackTimer = Timer(const Duration(seconds: 4), () {
          _navigateHome();
        });
      } catch (e) {
        // If reading the bloc fails, fallback to navigate after a short delay
        _fallbackTimer = Timer(const Duration(seconds: 2), () {
          _navigateHome();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _shopSub?.cancel();
    _fallbackTimer?.cancel();
    super.dispose();
  }

  void _navigateHome() {
    if (_navigated) return;
    _navigated = true;
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3F0354),
      body: SafeArea(
        child: FadeTransition(
          opacity: _animation,
          child: ScaleTransition(
            scale: _animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top area: logo and app name
                Padding(
                  padding: const EdgeInsets.only(top: 48.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/grc_logo.png',
                        height: 120,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'GRC POS System',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom area: copyright
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    '© ranto nandrianina 2026',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
