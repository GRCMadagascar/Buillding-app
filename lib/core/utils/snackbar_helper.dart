import 'package:flutter/material.dart';

/// Global ScaffoldMessenger key. Provide this to `MaterialApp.scaffoldMessengerKey`
/// so snackbars can be shown without a BuildContext using the helper below.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Shows a floating, pill-shaped SnackBar matching the app's global style.
///
/// - [message]: text to display (centered, bold, white)
/// - [isError]: if true uses the default error red background; otherwise uses a
///   green success color.
/// - [duration]: optional duration for the SnackBar.
void showAppSnackBar(
  String message, {
  bool isError = true,
  Duration? duration,
}) {
  final state = scaffoldMessengerKey.currentState;
  if (state == null) return;

  // Hide any current snack before showing the new one.
  state.hideCurrentSnackBar();

  final snack = SnackBar(
    behavior: SnackBarBehavior.floating,
    shape: const StadiumBorder(),
    backgroundColor: isError ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    elevation: 6.0,
    duration: duration ?? const Duration(seconds: 3),
    // Centered bold white text
    content: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 15.0,
      ),
    ),
  );

  state.showSnackBar(snack);
}

/// Convenience variant that shows the snack using a BuildContext.
void showAppSnackBarWithContext(BuildContext context, String message,
    {bool isError = true, Duration? duration}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(SnackBar(
    behavior: SnackBarBehavior.floating,
    shape: const StadiumBorder(),
    backgroundColor: isError ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    elevation: 6.0,
    duration: duration ?? const Duration(seconds: 3),
    content: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 15.0,
      ),
    ),
  ));
}
