import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
// Localization removed — using hardcoded French strings.

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
    // Accept all supported barcode formats (QR, EAN, Code128, etc.) so the
    // scanner works for both QR codes and traditional barcodes.
    formats: BarcodeFormat.values,
  );
  bool _isScanned = false;
  bool _hasCameraPermission = false;
  bool _permissionDenied = false;
  bool _isCameraInitialized = false;
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Use a Tween to drive the opacity between two values and apply a curve.
    // This guarantees an Animation<double> with defined range for FadeTransition.
    _animation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Make a subtle pulsating fade
    _animationController.repeat(reverse: true);

    // Initialize camera and permissions
    _initCamera();
  }

  Locale? _lastLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If the app locale changed (e.g., user switched language), ensure the
    // camera controller is re-initialized. Some platform camera previews may
    // lose their surface when widgets rebuild during locale changes.
    final locale = Localizations.localeOf(context);
    if (_lastLocale == null) {
      _lastLocale = locale;
      return;
    }

    if (locale != _lastLocale) {
      _lastLocale = locale;
      // Restart the camera safely after locale change.
      Future.microtask(() async {
        try {
          await controller.stop();
        } catch (_) {}
        // Re-request permission and start camera again
        if (mounted) await _initCamera();
      });
    }
  }

  Future<void> _initCamera() async {
    try {
      final status = await Permission.camera.request();

      if (status.isGranted) {
        setState(() {
          _hasCameraPermission = true;
          _permissionDenied = false;
        });

        try {
          await controller.start();
          setState(() => _isCameraInitialized = true);
        } catch (e) {
          // Could not start camera - mark as denied/error so UI can show fallback
          setState(() {
            _permissionDenied = true;
            _isCameraInitialized = false;
          });
        }
      } else {
        setState(() {
          _hasCameraPermission = false;
          _permissionDenied = true;
        });
      }
    } catch (e) {
      setState(() {
        _hasCameraPermission = false;
        _permissionDenied = true;
      });
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _isScanned = true;
        // Vibrate
        final canVibrate = await Vibrate.canVibrate;
        // Trigger a short haptic feedback using the platform API.
        // This runs regardless of whether the device has advanced vibration
        // capabilities; `HapticFeedback.lightImpact()` is lightweight and
        // supported broadly.
        try {
          HapticFeedback.lightImpact();
        } catch (_) {}

        // Also try the optional vibrate package for richer feedback when
        // available on the device.
        if (canVibrate) {
          Vibrate.feedback(FeedbackType.success);
        }

        if (mounted) {
          // Return the detected raw value (non-null by earlier check).
          context.pop(barcode.rawValue);
        }
        break; // Only take first one
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
          Theme.of(context).primaryColor,
      body: _permissionDenied
          ? SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning, size: 64, color: Colors.white),
                      const SizedBox(height: 16),
                      const Text(
                        "L'application a besoin d'accéder à la caméra pour scanner les codes-barres.",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          // Open app settings so the user can grant permission
                          await openAppSettings();
                        },
                        child: const Text(
                            "Ouvrir les paramètres de l'application"),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => _initCamera(),
                        child: const Text("Réessayer",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : (!_hasCameraPermission || !_isCameraInitialized)
              ? const SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 12),
                        Text("Ouverture de la caméra...",
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    // Camera preview
                    if (_hasCameraPermission)
                      MobileScanner(
                        controller: controller,
                        onDetect: _onDetect,
                      ),

                    // Overlay: logo + copyright (kept from original design)
                    // --- LOGO SY ANARANA APP EO AFOWOANY ---
                    Center(
                      child: FadeTransition(
                        opacity: _animation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/grc_logo.png',
                              height: 120,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "SYSTÈME POS GRC",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(141, 255, 255, 255),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- COPYRIGHT EO AMBANY INDRINDRA ---
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: FadeTransition(
                        opacity: _animation,
                        child: const Text(
                          "©ranto nandrianina 2026",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  // removed unused corner helper
}
