import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/shop.dart';
import '../../../../core/data/hive_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../bloc/shop_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';

class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({super.key});

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

// Top-level processor used with compute to avoid blocking the UI isolate.
// Takes the original image bytes, decodes and processes pixels, and returns
// encoded PNG bytes with transparent background and black logo pixels.
Uint8List _processLogoBytes(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;

  final working = img.Image.from(decoded);

  const int bgThreshold = 240;
  const double luminanceThreshold = 128.0;

  for (int y = 0; y < working.height; y++) {
    for (int x = 0; x < working.width; x++) {
      final pixel = working.getPixel(x, y);
      final int r = pixel.r as int;
      final int g = pixel.g as int;
      final int b = pixel.b as int;

      if (r >= bgThreshold && g >= bgThreshold && b >= bgThreshold) {
        working.setPixelRgba(x, y, 0, 0, 0, 0);
        continue;
      }

      final luminance = 0.299 * r + 0.587 * g + 0.114 * b;
      if (luminance < luminanceThreshold) {
        working.setPixelRgba(x, y, 0, 0, 0, 255);
      } else {
        working.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }

  final png = img.encodePng(working, level: 1);
  return Uint8List.fromList(png);
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _address1Controller;
  // late TextEditingController _emailController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _facebookController;
  late TextEditingController _instagramController;
  late TextEditingController _tiktokController;
  late TextEditingController _whatsappController;
  late TextEditingController _adminController;
  late TextEditingController _upiController;
  late TextEditingController _footerController;
  late TextEditingController _mvolaController;
  late TextEditingController _orangeController;
  late TextEditingController _airtelController;
  String? _logoPath;
  bool _isProcessingLogo = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _address1Controller = TextEditingController();
    _emailController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _facebookController = TextEditingController();
    _instagramController = TextEditingController();
    _tiktokController = TextEditingController();
    _whatsappController = TextEditingController();
    _adminController = TextEditingController();
    _upiController = TextEditingController();
    _footerController = TextEditingController();
    _mvolaController = TextEditingController(text: '');
    _orangeController = TextEditingController(text: '');
    _airtelController = TextEditingController(text: '');

    // Load shop data
    context.read<ShopBloc>().add(LoadShopEvent());

    // Load settings (logo/socials/admin)
    final settings = HiveDatabase.settingsBox;
    _logoPath = settings.get('shop_logo');
    _facebookController.text = settings.get('shop_facebook') ?? '';
    _instagramController.text = settings.get('shop_instagram') ?? '';
    _tiktokController.text = settings.get('shop_tiktok') ?? '';
    _whatsappController.text = settings.get('shop_whatsapp') ?? '';
    _adminController.text = settings.get('shop_admin') ?? '';
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
    if (_emailController.text.isEmpty && (shop.email).isNotEmpty) {
      // Previously email was used; treat it as email now
      _emailController.text = shop.email;
      if (_emailController.text.isEmpty) _emailController.text = shop.email;
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
    _emailController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    _whatsappController.dispose();
    _adminController.dispose();
    _upiController.dispose();
    _footerController.dispose();
    _mvolaController.dispose();
    _orangeController.dispose();
    _airtelController.dispose();
    super.dispose();
  }

  Future<void> _saveShop() async {
    if (_formKey.currentState!.validate()) {
      final shop = Shop(
        name: _nameController.text,
        addressLine1: _address1Controller.text,
        // store email in email for backward compatibility
        email: _emailController.text.isNotEmpty
            ? _emailController.text
            : _emailController.text,
        phoneNumber: _phoneController.text,
        upiId: _upiController.text,
        footerText: _footerController.text,
        mvolaNumber: _mvolaController.text,
        orangeMoneyNumber: _orangeController.text,
        airtelMoneyNumber: _airtelController.text,
      );

      // Persist socials, admin and logo into settingsBox
      // final settings = HiveDatabase.settingsBox;
      // await settings.put('shop_facebook', _facebookController.text);
      // await settings.put('shop_instagram', _instagramController.text);
      // await settings.put('shop_tiktok', _tiktokController.text);
      // await settings.put('shop_whatsapp', _whatsappController.text);
      // await settings.put('shop_admin', _adminController.text);
      // if (_logoPath != null) await settings.put('shop_logo', _logoPath);

      context.read<ShopBloc>().add(UpdateShopEvent(shop));
    }
  }

  /// Process the picked image file to remove near-white background and convert
  /// the visible pixels into high-contrast black (transparent elsewhere).
  Future<String> _processAndSaveLogo(String originalPath) async {
    final originalFile = File(originalPath);
    if (!await originalFile.exists()) return originalPath;
    final bytes = await originalFile.readAsBytes();

    // Offload CPU-heavy pixel processing to a background isolate using compute
    Uint8List pngBytes;
    try {
      pngBytes = await compute(_processLogoBytes, bytes);
    } catch (e) {
      // If compute fails for any reason, fallback to saving original bytes
      pngBytes = bytes;
    }

    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/shop_logo_processed.png';
    final outFile = File(savePath);
    await outFile.writeAsBytes(pngBytes, flush: true);

    return savePath;
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

            final bottomPad = MediaQuery.of(context).viewInsets.bottom + 96;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPad),
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
                    const InputLabel(text: 'Email (Optional)'),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'email@yourshop.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'Admin Name'),
                    _buildTextField(
                      controller: _adminController,
                      hint: 'Admin name for receipts',
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'Shop Logo'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _logoPath != null
                            ? Image.file(File(_logoPath!),
                                width: 72, height: 72)
                            : Container(
                                width: 72,
                                height: 72,
                                color: Theme.of(context).cardColor,
                                child: const Icon(Icons.image, size: 36),
                              ),
                        const SizedBox(width: 12),
                        _isProcessingLogo
                            ? const SizedBox(
                                width: 120,
                                height: 40,
                                child: Center(
                                    child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ))),
                              )
                            : ElevatedButton.icon(
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final XFile? file = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 80);
                                  if (file != null) {
                                    setState(() => _isProcessingLogo = true);
                                    try {
                                      final processedPath =
                                          await _processAndSaveLogo(file.path);
                                      setState(() => _logoPath = processedPath);
                                      // Persist immediately so other parts of the app can use it
                                      await HiveDatabase.settingsBox
                                          .put('shop_logo', processedPath);
                                    } catch (e) {
                                      // If processing fails, fallback to original path and persist
                                      setState(() => _logoPath = file.path);
                                      await HiveDatabase.settingsBox
                                          .put('shop_logo', file.path);
                                    } finally {
                                      if (mounted) {
                                        setState(
                                            () => _isProcessingLogo = false);
                                      }
                                    }
                                  }
                                },
                                icon: const Icon(Icons.upload_file),
                                label: const Text('Upload Logo'),
                              ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Receipt Preview
                    const InputLabel(text: 'Receipt Preview'),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            if (_logoPath != null)
                              Center(
                                child: Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(8),
                                  child: Image.file(
                                    File(_logoPath!),
                                    width: 140,
                                    height: 80,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 140,
                                height: 80,
                                color: Theme.of(context).cardColor,
                                child: const Icon(Icons.image, size: 48),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              _nameController.text.isNotEmpty
                                  ? _nameController.text
                                  : 'Shop Name',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(_emailController.text.isNotEmpty
                                ? _emailController.text
                                : ''),
                          ],
                        ),
                      ),
                    ),
                    // const SizedBox(height: 15),
                    // const InputLabel(text: 'Social Links'),
                    // const SizedBox(height: 8),
                    // _buildTextField(
                    //   controller: _facebookController,
                    //   hint: 'Facebook link or handle',
                    //   keyboardType: TextInputType.url,
                    // ),
                    // const SizedBox(height: 12),
                    // _buildTextField(
                    //   controller: _instagramController,
                    //   hint: 'Instagram handle',
                    //   keyboardType: TextInputType.url,
                    // ),
                    // const SizedBox(height: 12),
                    // _buildTextField(
                    //   controller: _tiktokController,
                    //   hint: 'TikTok handle',
                    //   keyboardType: TextInputType.url,
                    // ),
                    // const SizedBox(height: 12),
                    // _buildTextField(
                    //   controller: _whatsappController,
                    //   hint: 'WhatsApp number or link',
                    //   keyboardType: TextInputType.phone,
                    // ),
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
                              title: Text(
                                  AppLocalizations.of(context)!.paymentSettings,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppTheme.primaryColor)),
                              subtitle: Text(AppLocalizations.of(context)!
                                  .paymentSettingsSubtitle),
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
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(12),
          child: PrimaryButton(
            onPressed: _saveShop,
            icon: Icons.save,
            label: 'Save Details',
          ),
        ));
  }
}
