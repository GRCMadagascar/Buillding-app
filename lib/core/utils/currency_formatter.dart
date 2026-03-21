import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../locale/language_cubit.dart';

/// Format number into Malagasy Ariary style using dots as thousand separators.
/// Examples: 1000 -> '1.000', 1000000 -> '1.000.000'
String formatMGA(num value) {
  final formatter = NumberFormat('#,##0', 'en_US');
  final formatted = formatter.format(value);
  return formatted.replaceAll(',', '.');
}

/// Format price according to selected language/currency.
/// Assumes stored amounts are in Ariary (MGA). Conversion rates are easy to update.
String formatPrice(BuildContext context, num amountInAriary) {
  final lang = context.read<LanguageCubit>().state.code;

  // Conversion rates (modifiable)
  const double arPerEur = 5000.0; // 1 EUR = 5000 Ar
  const double arPerUsd = 4000.0; // 1 USD = 4000 Ar

  if (lang == 'mg') {
    return '${formatMGA(amountInAriary)} Ar';
  } else if (lang == 'fr') {
    final eur = amountInAriary / arPerEur;
    final f =
        NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2);
    return f.format(eur);
  } else {
    // default: English / USD
    final usd = amountInAriary / arPerUsd;
    final f =
        NumberFormat.currency(locale: 'en_US', symbol: '4', decimalDigits: 2);
    return f.format(usd);
  }
}
