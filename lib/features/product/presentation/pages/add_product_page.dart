import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/product_firestore_service.dart';
import '../../../../core/services/current_shop_service.dart';

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
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  bool _isUploading = false;

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
    if (!mounted) return;
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
      _saveProduct();
    }
  }

  Future<void> _pickImage(ImageSource src) async {
    try {
      final picked = await _picker.pickImage(
        source: src,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _pickedImage = picked);
      }
    } catch (_) {}
  }

  Future<String?> _uploadImage(String id) async {
    if (_pickedImage == null) return null;
    try {
      setState(() => _isUploading = true);
      final file = File(_pickedImage!.path);
      final ref = FirebaseStorage.instance.ref().child('products/$id.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      return null;
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _saveProduct() async {
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

    final id = const Uuid().v4();
    String? imageUrl;
    if (_pickedImage != null) {
      imageUrl = await _uploadImage(id);
    }

    final product = Product(
      id: id,
      name: _name,
      barcode: _barcode,
      price: _price,
      imageUrl: imageUrl,
    );

    // Save locally via Bloc/Hive
    context.read<ProductBloc>().add(AddProduct(product));

    // Also persist to Firestore products collection for PRO analytics (attach shopId)
    try {
      final prefs = await SharedPreferences.getInstance();
      final sp = prefs.getString('current_shop_id');
      final shopId = sp ?? CurrentShopService.shopId ?? '';
      final productWithShop = Product(
        id: id,
        name: _name,
        barcode: _barcode,
        price: _price,
        stock: product.stock,
        imageUrl: imageUrl,
        shopId: shopId,
      );
      await ProductFirestoreService.addProduct(productWithShop);
    } catch (_) {}

    if (!mounted) return;
    context.pop();
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
                  // Image preview and picker
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFFFFD700), width: 3),
                            color: Theme.of(context).cardColor,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: _pickedImage != null
                                ? Image.file(
                                    File(_pickedImage!.path),
                                    fit: BoxFit.cover,
                                  )
                                : const Center(
                                    child: Icon(Icons.photo,
                                        size: 48, color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF1600),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () async {
                                // choose from gallery or camera
                                showModalBottomSheet(
                                  context: context,
                                  builder: (ctx) {
                                    return SafeArea(
                                      child: Wrap(
                                        children: [
                                          ListTile(
                                            leading:
                                                const Icon(Icons.photo_library),
                                            title: const Text('Galerie'),
                                            onTap: () {
                                              Navigator.of(ctx).pop();
                                              _pickImage(ImageSource.gallery);
                                            },
                                          ),
                                          ListTile(
                                            leading:
                                                const Icon(Icons.camera_alt),
                                            title: const Text('Appareil photo'),
                                            onTap: () {
                                              Navigator.of(ctx).pop();
                                              _pickImage(ImageSource.camera);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Choisir une photo'),
                            ),
                            const SizedBox(width: 12),
                            if (_pickedImage != null)
                              OutlinedButton(
                                onPressed: () =>
                                    setState(() => _pickedImage = null),
                                child: const Text('Retirer'),
                              ),
                          ],
                        ),
                        if (_isUploading) const SizedBox(height: 8),
                        if (_isUploading) const LinearProgressIndicator(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
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
                          color: AppTheme.primaryColor.withOpacity(0.1),
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
                            .withOpacity(0.8),
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

class FirebaseStorage {
  static get instance => null;
}
