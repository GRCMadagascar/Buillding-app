import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';
import 'package:flutter/services.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late double _price;
  late String _barcode;

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _price = widget.product.price;
    _barcode = widget.product.barcode;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedProduct = Product(
        id: widget.product.id,
        name: _name,
        barcode: _barcode,
        price: _price,
      );

      context.read<ProductBloc>().add(UpdateProduct(updatedProduct));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left,
                size: 32, color: Theme.of(context).primaryColor),
            onPressed: () => context.pop(),
          ),
          title: const Text('Edit Product',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barcode display with edit action
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_scanner,
                            color: AppTheme.primaryColor, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('BARCODE',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor
                                          .withValues(alpha: 0.7))),
                              const SizedBox(height: 4),
                              Text(_barcode,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'monospace')),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          color: AppTheme.primaryColor,
                          onPressed: () async {
                            final newVal = await showDialog<String>(
                              context: context,
                              builder: (ctx) {
                                String edited = widget.product.barcode;
                                return AlertDialog(
                                  title: const Text('Edit Barcode'),
                                  content: TextFormField(
                                    initialValue: edited,
                                    keyboardType: TextInputType.text,
                                    onChanged: (v) => edited = v,
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancel')),
                                    ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, edited),
                                        child: const Text('Save')),
                                  ],
                                );
                              },
                            );
                            if (newVal != null && newVal.trim().isNotEmpty) {
                              setState(() {
                                // Update local barcode variable; submit will persist
                                _barcode = newVal.trim();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const InputLabel(text: 'Product Name'),

                  TextFormField(
                    initialValue: _name,
                    textCapitalization: TextCapitalization.words,
                    validator: AppValidators.required('Please enter a name'),
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 24),

                  const InputLabel(text: 'Price'),

                  // Price row: value on left, fixed currency unit on far right
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _price.toStringAsFixed(0),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: false),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          textAlign: TextAlign.left,
                          decoration: const InputDecoration(
                            hintText: '0',
                            border: OutlineInputBorder(),
                          ),
                          validator: AppValidators.price,
                          onSaved: (value) => _price = double.parse(value!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Ariary',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: PrimaryButton(
          onPressed: _submit,
          icon: Icons.save,
          label: 'Save Changes',
        ));
  }
}
