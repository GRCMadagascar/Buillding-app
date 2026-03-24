import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _barcode = '';
  double _price = 0.0;

  void _scanBarcode() async {
    // Ensure any focused text fields are unfocused first so the push is
    // reliably handled on the first tap.
    FocusScope.of(context).unfocus();
    // Small delay to let the focus change propagate on some devices and to
    // ensure the keyboard has time to dismiss. 150ms is a conservative
    // value that works reliably on slower devices; if you notice it feels
    // too slow we can reduce it to ~80-100ms.
    await Future.delayed(const Duration(milliseconds: 150));

    // Use a post-frame callback to ensure navigation happens after the
    // current UI update (defensive on some platforms where focus/unfocus
    // completes on the next frame).
    String? result;
    await Future<void>.delayed(Duration.zero);
    result = await context.push<String>('/scanner');
    if (result != null && result.isNotEmpty) {
      setState(() {
        // Trim whitespace and assign the scanned value (works for both
        // QR codes and barcodes).
        _barcode = result!.trim();
      });
      // Provide quick visual feedback for a successful scan.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text('Scan réussi')),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(milliseconds: 1100),
      ));
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final productState = context.read<ProductBloc>().state;
      final existingProduct =
          productState.products.where((p) => p.barcode == _barcode).firstOrNull;

      if (existingProduct != null) {
        final msg = 'Produit avec le code-barres "$_barcode" existe déjà !';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final product = Product(
        id: const Uuid().v4(),
        name: _name,
        barcode: _barcode,
        price: _price,
      );

      context.read<ProductBloc>().add(AddProduct(product));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left,
                size: 28, color: Theme.of(context).primaryColor),
            onPressed: () => context.pop(),
          ),
          title: const Text('Ajouter un Produit',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const InputLabel(text: 'Code-barres'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: ValueKey(_barcode),
                          initialValue: _barcode,
                          decoration: const InputDecoration(
                            hintText: 'Scanner ou entrer le code-barres',
                          ),
                          validator: AppValidators.required(
                              'Veuillez entrer un code-barres'),
                          onSaved: (value) => _barcode = value!,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          // Use a more general camera icon to reflect support for
                          // both QR codes and traditional barcodes.
                          icon: const Icon(Icons.camera_alt,
                              color: AppTheme.primaryColor),
                          onPressed: _scanBarcode,
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Appuyez sur l\'icône pour ouvrir le scanner',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4C669A))),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Veuillez entrer un nom'),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Ranto Rice',
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: AppValidators.required('Veuillez entrer un nom'),
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Veuillez entrer un prix'),
                  TextFormField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      suffixText: 'Ar',
                      suffixStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: (Theme.of(context).textTheme.bodySmall?.color ??
                                Colors.black)
                            .withValues(alpha: 0.8),
                      ),
                    ),
                    // remove any prefix so the unit sits on the right
                    validator: AppValidators.price,
                    onSaved: (value) =>
                        _price = double.parse(value!.replaceAll(',', '')),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: PrimaryButton(
          onPressed: _submit,
          icon: Icons.add_circle,
          label: 'Ajouter',
        ));
  }
}
