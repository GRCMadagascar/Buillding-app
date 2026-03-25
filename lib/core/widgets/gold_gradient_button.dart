import 'package:flutter/material.dart';

class GoldGradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double height;

  const GoldGradientButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.height = 54,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFFD4AF37), Color(0xFFF9F06B), Color(0xFFB8860B)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onPressed,
          child: child,
        ),
      ),
    );
  }
}
