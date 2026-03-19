import 'package:intl/intl.dart';

/// Format number into Malagasy Ariary style using dots as thousand separators.
/// Examples: 1000 -> '1.000', 1000000 -> '1.000.000'
String formatMGA(num value) {
  // Use a locale that groups thousands with comma, then replace commas with dots.
  final formatter = NumberFormat('#,##0', 'en_US');
  final formatted = formatter.format(value);
  return formatted.replaceAll(',', '.');
}
