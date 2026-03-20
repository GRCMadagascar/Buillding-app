import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/shop.dart';
import '../bloc/shop_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';

class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({super.key});

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _phoneController;
  late TextEditingController _upiController;
  late TextEditingController _footerController;
  late TextEditingController _mvolaController;
  late TextEditingController _orangeController;
  late TextEditingController _airtelController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _address1Controller = TextEditingController();
    _address2Controller = TextEditingController();
    _phoneController = TextEditingController();
    _upiController = TextEditingController();
    _footerController = TextEditingController();
    _mvolaController = TextEditingController(text: '');
    _orangeController = TextEditingController(text: '');
    _airtelController = TextEditingController(text: '');

    // Load shop data
    context.read<ShopBloc>().add(LoadShopEvent());
  }

  void _updateControllers(Shop? shop) {
    // Defensive: shop may be null in some states; use safe defaults.
    if (shop == null) return;

    // Only populate controllers when they are empty so we don't overwrite user edits.
    if (_nameController.text.isEmpty && shop.name.isNotEmpty) {
      _nameController.text = shop.name;
    }
    if (_address1Controller.text.isEmpty && (shop.addressLine1).isNotEmpty) {
      _address1Controller.text = shop.addressLine1;
    }
    if (_address2Controller.text.isEmpty && (shop.addressLine2).isNotEmpty) {
      _address2Controller.text = shop.addressLine2;
    }
    if (_phoneController.text.isEmpty && (shop.phoneNumber).isNotEmpty) {
      _phoneController.text = shop.phoneNumber;
    }
    if (_upiController.text.isEmpty && (shop.upiId).isNotEmpty) {
      _upiController.text = shop.upiId;
    }
    if (_footerController.text.isEmpty && (shop.footerText).isNotEmpty) {
      _footerController.text = shop.footerText;
    }

    // Payment numbers: use null-safe access and avoid overwriting user edits
    if (_mvolaController.text.isEmpty) {
      _mvolaController.text = shop.mvolaNumber;
    }
    if (_orangeController.text.isEmpty) {
      _orangeController.text = shop.orangeMoneyNumber;
    }
    if (_airtelController.text.isEmpty) {
      _airtelController.text = shop.airtelMoneyNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _phoneController.dispose();
    _upiController.dispose();
    _footerController.dispose();
    _mvolaController.dispose();
    _orangeController.dispose();
    _airtelController.dispose();
    super.dispose();
  }

  void _saveShop() {
    if (_formKey.currentState!.validate()) {
      final shop = Shop(
        name: _nameController.text,
        addressLine1: _address1Controller.text,
        addressLine2: _address2Controller.text,
        phoneNumber: _phoneController.text,
        upiId: _upiController.text,
        footerText: _footerController.text,
        mvolaNumber: _mvolaController.text,
        orangeMoneyNumber: _orangeController.text,
        airtelMoneyNumber: _airtelController.text,
      );

      context.read<ShopBloc>().add(UpdateShopEvent(shop));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Shop Details'),
        ),
        body: BlocConsumer<ShopBloc, ShopState>(
          listener: (context, state) {
            if (state is ShopLoaded) {
              _updateControllers(state.shop);
            } else if (state is ShopOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Shop details saved!'),
                  backgroundColor: Colors.green));
              context.pop();
            } else if (state is ShopError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          buildWhen: (previous, current) =>
              current is ShopLoading || current is ShopLoaded,
          builder: (context, state) {
            if (state is ShopLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('General Information',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: const Color.fromARGB(255, 165, 96, 6)
                              .withOpacity(0.8),
                        )),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'These details will appear on your digital and printed receipts.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 24),
                    const InputLabel(text: 'Shop Name'),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Shop Name',
                      validator: AppValidators.required('Required'),
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'Address Line 1'),
                    _buildTextField(
                      controller: _address1Controller,
                      hint: 'Address',
                      validator: AppValidators.required('Required'),
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'Address Line 2 (Optional)'),
                    _buildTextField(
                      controller: _address2Controller,
                      hint: 'Address (Optional)',
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'Phone Number'),
                    _buildTextField(
                      controller: _phoneController,
                      hint: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      validator: AppValidators.required('Required'),
                    ),
                    const SizedBox(height: 15),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text('Payment Settings',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppTheme.primaryColor)),
                              subtitle: const Text(
                                  'Mobile money numbers used during checkout'),
                            ),
                            const Divider(),
                            // MVola
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: TextFormField(
                                controller: _mvolaController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.phone_android),
                                  labelText: 'MVola Number',
                                  hintText: '0383664786',
                                ),
                                validator: AppValidators.required('Required'),
                              ),
                            ),
                            // Orange
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: TextFormField(
                                controller: _orangeController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.phone_android),
                                  labelText: 'Orange Money Number',
                                  hintText: '0372177785',
                                ),
                                validator: AppValidators.required('Required'),
                              ),
                            ),
                            // Airtel
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: TextFormField(
                                controller: _airtelController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.phone_android),
                                  labelText: 'Airtel Money Number',
                                  hintText: '0332177785',
                                ),
                                validator: AppValidators.required('Required'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // const SizedBox(height: 15),
                    // const InputLabel(text: 'UPI ID'),
                    // _buildTextField(
                    //   controller: _upiController,
                    //   hint: 'dineshsowndar@oksbi',
                    // ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const InputLabel(text: 'Receipt Footer Text'),
                        Text('Max 150 chars',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[400])),
                      ],
                    ),
                    _buildTextField(
                      controller: _footerController,
                      hint: 'Thank you, Visit again!!!',
                      maxLines: 4,
                      maxLength: 100,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: PrimaryButton(
          onPressed: _saveShop,
          icon: Icons.save,
          label: 'Save Details',
        ));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.words,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color:
              Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6) ??
                  Colors.grey[500],
          fontWeight: FontWeight.w500,
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}
