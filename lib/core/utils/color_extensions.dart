import 'package:flutter/material.dart';

/// Small helper to centralize a replacement API used by the codebase.
///
/// Some lint/hint suggestions requested using `withValues(opacity: x)` instead
/// of calling `withOpacity` directly across the code. Provide a tiny
/// convenience extension so callers can migrate incrementally.
extension ColorExtensions on Color {
  /// Returns a color with the provided opacity (0.0 - 1.0) or alpha (0-255).
  /// First parameter is treated as opacity when provided.
  Color withValues([double? opacity, int? alpha]) {
    if (opacity != null) return withOpacity(opacity);
    if (alpha != null) return withAlpha(alpha);
    return this;
  }
}
