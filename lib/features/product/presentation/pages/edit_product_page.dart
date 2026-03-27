import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/current_user_service.dart';
import '../../../../core/utils/app_validators.dart';

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
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      final updatedProduct = Product(
        id: widget.product.id,
        name: _name.trim(),
        barcode: _barcode.trim(),
        price: _price,
        imageUrl: widget.product.imageUrl,
      );

      context.read<ProductBloc>().add(UpdateProduct(updatedProduct));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleStr =
        CurrentUserService.userData?['role'] as String? ?? 'vendeur';
    final isStaff = roleStr == 'vendeur';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left,
              size: 32, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
        title: const Text('Modifier le produit',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _barcode,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      color: AppTheme.primaryColor,
                      onPressed: isStaff
                          ? null
                          : () async {
                              final newVal = await showDialog<String>(
                                context: context,
                                builder: (ctx) {
                                  String edited = _barcode;
                                  return AlertDialog(
                                    title:
                                        const Text('Modifier le code-barres'),
                                    content: TextFormField(
                                      initialValue: edited,
                                      keyboardType: TextInputType.text,
                                      onChanged: (v) => edited = v,
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Annuler')),
                                      ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, edited),
                                          child: const Text('Enregistrer')),
                                    ],
                                  );
                                },
                              );
                              if (newVal != null && newVal.trim().isNotEmpty) {
                                setState(() => _barcode = newVal.trim());
                              }
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const InputLabel(text: 'Nom du produit'),
                TextFormField(
                  initialValue: _name,
                  readOnly: isStaff,
                  textCapitalization: TextCapitalization.words,
                  validator: AppValidators.required('Veuillez saisir le nom'),
                  onSaved: (value) => _name = value ?? '',
                ),
                const SizedBox(height: 24),
                const InputLabel(text: 'Prix'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _price.toStringAsFixed(0),
                        readOnly: isStaff,
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
                        onSaved: (value) =>
                            _price = double.tryParse(value ?? '0') ?? 0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('MGA',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700])),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const InputLabel(text: 'Image (URL)'),
                TextFormField(
                  initialValue: widget.product.imageUrl ?? '',
                  readOnly: isStaff,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(hintText: 'https://...'),
                  onSaved: (v) {},
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: PrimaryButton(
          onPressed: isStaff ? null : _submit,
          icon: Icons.save,
          label: isStaff ? 'Lecture seule' : 'Enregistrer les modifications',
        ),
      ),
    );
  }
}
