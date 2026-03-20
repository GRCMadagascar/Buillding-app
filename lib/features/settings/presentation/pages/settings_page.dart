import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:app_settings/app_settings.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../bloc/printer_bloc.dart';
import '../bloc/printer_event.dart';
import '../bloc/printer_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _coverImage;
  XFile? _profileImage;
  @override
  void initState() {
    super.initState();
    // Re-initialize printer state whenever settings page opens
    context.read<PrinterBloc>().add(InitPrinterEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left,
              size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section (cover + profile + edit buttons)
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Cover image with rounded corners
                Positioned(
                  top: 0,
                  left: 16,
                  right: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: (_coverImage != null)
                        ? Image.file(
                            File(_coverImage!.path),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/Fond.jpg',
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),

                // Pencil button for cover
                Positioned(
                  top: 8,
                  right: 24,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      color: AppTheme.primaryColor,
                      onPressed: () async {
                        final picked = await _picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) setState(() => _coverImage = picked);
                      },
                    ),
                  ),
                ),

                // Profile circle overlapping the cover
                Positioned(
                  top: 100,
                  child: BlocBuilder<ShopBloc, ShopState>(
                    builder: (context, state) {
                      String shopName = 'Diary Fashion';
                      if (state is ShopLoaded && state.shop.name.isNotEmpty) {
                        shopName = state.shop.name;
                      }

                      return Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // White border circle
                              Container(
                                width: 110,
                                height: 110,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              // Profile image
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                  image: _profileImage != null
                                      ? DecorationImage(
                                          image: FileImage(File(_profileImage!.path)),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: _profileImage == null
                                    ? Text(
                                        shopName.isNotEmpty
                                            ? shopName.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase()
                                            : 'S',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),

                              // Pencil for profile
                              Positioned(
                                right: -6,
                                bottom: -6,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white,
                                  child: IconButton(
                                    icon: const Icon(Icons.edit, size: 16),
                                    color: AppTheme.primaryColor,
                                    onPressed: () async {
                                      final picked = await _picker.pickImage(source: ImageSource.gallery);
                                      if (picked != null) setState(() => _profileImage = picked);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Shop name overlay styled like a button
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                )
                              ],
                            ),
                            child: Text(
                              shopName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

            const SizedBox(height: 24),

            // Management Section
            _buildSectionHeader('Management'),
            _buildListGroup(
              children: [
                _buildListItem(
                  icon: Icons.qr_code_scanner,
                  title: 'Products',
                  subtitle: 'Manage stock and barcodes',
                  onTap: () => context.push('/products'),
                ),
                _buildDivider(),
                _buildListItem(
                  icon: Icons.storefront,
                  title: 'Shop Details',
                  subtitle: 'Edit business info & address',
                  onTap: () => context.push('/shop'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Hardware Section
            _buildSectionHeader('Hardware'),
            BlocConsumer<PrinterBloc, PrinterState>(
              listener: (context, state) {
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: Colors.red));
                } else if (state.status == PrinterStatus.connected) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Connected to printer'),
                      backgroundColor: Colors.green));
                }
              },
              builder: (context, state) {
                return _buildListGroup(
                  children: [
                    _buildListItem(
                      icon: Icons.print,
                      title: 'Print Device',
                      subtitleWidget: Row(
                        children: [
                          Text(
                            state.connectedMac != null
                                ? (state.connectedName ?? 'Printer connected')
                                : 'No printer connected',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[500]),
                          ),
                          if (state.connectedMac != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.teal[100],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.teal[200]!)),
                              child: Text(
                                'CONNECTED',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal[700]),
                              ),
                            ),
                          ]
                        ],
                      ),
                      trailingWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.status == PrinterStatus.scanning ||
                              state.status == PrinterStatus.connecting)
                            const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                          else
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () => context
                                  .read<PrinterBloc>()
                                  .add(RefreshPrinterEvent()),
                              color: AppTheme.primaryColor,
                            ),
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () {
                              AppSettings.openAppSettings(
                                  type: AppSettingsType.bluetooth);
                            },
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                "To connect a new device, tap on the Settings gear to pair in phone's Bluetooth settings, then return and hit Refresh.",
                style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[500]),
              ),
            ),

            const SizedBox(height: 16),

            // Appearance / Dark Mode
            _buildSectionHeader('Appearance'),
            _buildListGroup(
              children: [
                BlocBuilder<ThemeCubit, ThemeMode>(builder: (context, mode) {
                  final isDark = mode == ThemeMode.dark;
                  return _buildListItem(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    subtitle: isDark ? 'Enabled' : 'Disabled',
                    trailingWidget: Switch(
                      value: isDark,
                      activeThumbColor: const Color(0xFF6C63FF),
                      onChanged: (v) {
                        context.read<ThemeCubit>().setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
                      },
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 24),

          const SizedBox(height: 20),
          const Center(
            child: Text(
              "Edited by | Ranto Nandrianina 2026",
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF6C63FF),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _buildListGroup({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey[50], indent: 64);
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? subtitleWidget,
    Widget? trailingWidget,
    IconData? trailingIcon = Icons.chevron_right,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: subtitleWidget ?? (subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])) : null),
        trailing: trailingWidget ?? (trailingIcon != null ? Icon(trailingIcon, color: Colors.grey[400]) : null),
      ),
    );
  }
}
