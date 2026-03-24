import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:app_settings/app_settings.dart';
// Localization removed — using hardcoded French strings in this app.

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/locale/language_cubit.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../bloc/printer_bloc.dart';
import '../bloc/printer_event.dart';
import '../bloc/printer_state.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  XFile? _coverImage;
  XFile? _profileImage;
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnim;
  late final AnimationController _ctaController;
  @override
  void initState() {
    super.initState();
    // Re-initialize printer state whenever settings page opens
    context.read<PrinterBloc>().add(InitPrinterEvent());
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _ctaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    // CTA pulse animation controller. We compute scale from controller value
    // directly in the builder to keep things simple and avoid unused fields.
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _ctaController.dispose();
    super.dispose();
  }

  Widget _buildPremiumCard() {
    const gold1 = Color(0xFFD4AF37);
    const gold2 = Color(0xFFF9F06B);
    const gold3 = Color(0xFFB8860B);

    return GestureDetector(
      onTap: _showProSheet,
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return LayoutBuilder(builder: (context, constraints) {
            final w = constraints.maxWidth;
            final shimmerX = _shimmerAnim.value * w;
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Container(
                    height: 92,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [gold1, gold2, gold3],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.emoji_events,
                              color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Passer à la Version PRO',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              SizedBox(height: 4),
                              Text('Avantages exclusifs',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white70),
                      ],
                    ),
                  ),

                  // Shimmer streak
                  Positioned(
                    left: shimmerX - (w * 0.35),
                    top: 0,
                    bottom: 0,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Container(
                        width: w * 0.35,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.75),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  void _showProSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF111215),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        Text('GRC POS PRO',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD4AF37),
                              shadows: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    offset: const Offset(2, 2),
                                    blurRadius: 6),
                                const BoxShadow(
                                    color: Colors.white24,
                                    offset: Offset(-1, -1),
                                    blurRadius: 1),
                              ],
                            )),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close, color: Colors.white),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Fonctionnalités PRO',
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: const [
                          ListTile(
                            leading: Icon(Icons.check_circle,
                                color: Color(0xFFD4AF37)),
                            title: Text('Historique illimité',
                                style: TextStyle(color: Colors.white)),
                          ),
                          ListTile(
                            leading: Icon(Icons.check_circle,
                                color: Color(0xFFD4AF37)),
                            title: Text('Rapports PDF',
                                style: TextStyle(color: Colors.white)),
                          ),
                          ListTile(
                            leading: Icon(Icons.check_circle,
                                color: Color(0xFFD4AF37)),
                            title: Text('Cloud Sync',
                                style: TextStyle(color: Colors.white)),
                          ),
                          ListTile(
                            leading: Icon(Icons.check_circle,
                                color: Color(0xFFD4AF37)),
                            title: Text('Bluetooth illimité',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // CTA with pulse animation
                    AnimatedBuilder(
                      animation: _ctaController,
                      builder: (context, child) {
                        final scale = 1 + (_ctaController.value * 0.06);
                        return Transform.scale(
                          scale: scale,
                          child: SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4AF37),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                // local feedback pulse
                                _ctaController.forward(from: 0.0);
                              },
                              child: const Text('Bientôt disponible',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>(
            create: (_) => SettingsBloc()..add(LoadSettingsEvent())),
      ],
      child: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          // Update local XFile representations when settings change
          if (state.coverImagePath != null &&
              state.coverImagePath!.isNotEmpty) {
            _coverImage = XFile(state.coverImagePath!);
          }
          if (state.profileImagePath != null &&
              state.profileImagePath!.isNotEmpty) {
            _profileImage = XFile(state.profileImagePath!);
          }
          // minimal setState to refresh UI when bloc provides new paths
          if (mounted) setState(() {});
        },
        child: Builder(builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Paramètres',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.chevron_left,
                    size: 28, color: Theme.of(context).primaryColor),
                onPressed: () => context.pop(),
              ),
              actions: [
                PopupMenuButton<String>(
                  tooltip: 'Langue',
                  icon: const Icon(Icons.language),
                  onSelected: (code) {
                    // Capture cubit synchronously and call it inside the
                    // post-frame callback to avoid using BuildContext after
                    // an async/frame gap.
                    try {
                      final languageCubit = context.read<LanguageCubit>();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        try {
                          languageCubit.setLanguageCode(code);
                        } catch (_) {}
                      });
                    } catch (_) {}
                  },
                  itemBuilder: (ctx) => const [
                    PopupMenuItem(
                      value: 'mg',
                      child: Text('🇲🇬  Malagasy (MGA / Ar)'),
                    ),
                    PopupMenuItem(
                      value: 'fr',
                      child: Text('🇫🇷  Français (EUR / €)'),
                    ),
                    PopupMenuItem(
                      value: 'en',
                      child: Text('🇬🇧  English (USD / \$)'),
                    ),
                  ],
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Section (cover + profile + edit buttons)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SizedBox(
                      height: 220,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          // Rounded card background for luxury feel
                          Positioned.fill(
                            child: Container(
                              margin: const EdgeInsets.only(top: 28),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: _coverImage != null
                                  ? ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                      child: Image.file(
                                        File(_coverImage!.path),
                                        height: 152,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                      child: Image.asset(
                                        'assets/Fond.jpg',
                                        height: 152,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                          ),

                          // Pencil button for cover (smaller, with subtle white bg)
                          Positioned(
                            top: 18,
                            right: 16,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                padding: const EdgeInsets.all(4),
                                icon: const Icon(Icons.edit, size: 14),
                                color: AppTheme.primaryColor,
                                onPressed: () async {
                                  final picked = await _picker.pickImage(
                                      source: ImageSource.gallery);
                                  if (picked != null) {
                                    // Persist via SettingsBloc
                                    context.read<SettingsBloc>().add(
                                        UpdateImageEvent(
                                            coverImagePath: picked.path));
                                  }
                                },
                              ),
                            ),
                          ),

                          // Profile circle overlapping the cover
                          Positioned(
                            top: 86,
                            child: BlocBuilder<ShopBloc, ShopState>(
                              builder: (context, state) {
                                String shopName = 'Diary Fashion';
                                if (state is ShopLoaded &&
                                    state.shop.name.isNotEmpty) {
                                  shopName = state.shop.name;
                                }

                                return Column(
                                  children: [
                                    SizedBox(
                                      width: 120,
                                      height: 120,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          // Border circle matching scaffold background (so it adapts to dark mode)
                                          Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                // white gap to make the profile image pop
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                            alpha: 0.03),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          // Profile image
                                          Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              width: 104,
                                              height: 104,
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryColor,
                                                shape: BoxShape.circle,
                                                image: _profileImage != null
                                                    ? DecorationImage(
                                                        image: FileImage(File(
                                                            _profileImage!
                                                                .path)),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : null,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                            alpha: 0.08),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                                border: Border.all(
                                                    color: Colors.white24,
                                                    width: 0.5),
                                              ),
                                              alignment: Alignment.center,
                                              child: _profileImage == null
                                                  ? Text(
                                                      shopName.isNotEmpty
                                                          ? shopName
                                                              .split(' ')
                                                              .map((p) =>
                                                                  p.isNotEmpty
                                                                      ? p[0]
                                                                      : '')
                                                              .take(2)
                                                              .join()
                                                              .toUpperCase()
                                                          : 'S',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 30,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  : null,
                                            ),
                                          ),

                                          // Pencil for profile (bottom right)
                                          Positioned(
                                            right: 8,
                                            bottom: 8,
                                            child: Container(
                                              width: 34,
                                              height: 34,
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withValues(alpha: 0.8),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                            alpha: 0.08),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: IconButton(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                icon: const Icon(Icons.edit,
                                                    size: 14),
                                                color: AppTheme.primaryColor,
                                                onPressed: () async {
                                                  final picked =
                                                      await _picker.pickImage(
                                                          source: ImageSource
                                                              .gallery);
                                                  if (picked != null) {
                                                    context
                                                        .read<SettingsBloc>()
                                                        .add(UpdateImageEvent(
                                                            profileImagePath:
                                                                picked.path));
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Shop name overlay styled like a button
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor,
                                        borderRadius: BorderRadius.circular(28),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryColor
                                                .withValues(alpha: 0.12),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
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
                  ),

                  const SizedBox(height: 24),

                  // Management Section
                  _buildSectionHeader('Gestion'),
                  _buildListGroup(
                    children: [
                      _buildListItem(
                        icon: Icons.qr_code_scanner,
                        title: 'Produits',
                        subtitle: 'Gérer le stock et les codes-barres',
                        onTap: () => context.push('/products'),
                      ),
                      _buildDivider(),
                      _buildListItem(
                        icon: Icons.history,
                        title: 'Historique des Ventes',
                        subtitle: 'Voir les ventes récentes (30 dernières)',
                        onTap: () => context.push('/sales_history'),
                      ),
                      _buildDivider(),
                      _buildListItem(
                        icon: Icons.storefront,
                        title: 'Détails du magasin',
                        subtitle:
                            'Modifier les informations et l\'adresse de l\'entreprise',
                        onTap: () => context.push('/shop'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Hardware Section
                  _buildSectionHeader('Matériel'),
                  BlocConsumer<PrinterBloc, PrinterState>(
                    listener: (context, state) {
                      if (state.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(state.errorMessage!),
                            backgroundColor: Colors.red));
                      } else if (state.status == PrinterStatus.connected) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Connecté à l'imprimante"),
                                backgroundColor: Colors.green));
                      }
                    },
                    builder: (context, state) {
                      return _buildListGroup(
                        children: [
                          _buildListItem(
                            icon: Icons.print,
                            title: 'Imprimante',
                            subtitleWidget: Row(
                              children: [
                                // Make the status text flexible so long localized
                                // strings (e.g., Malagasy) don't overflow the row.
                                Expanded(
                                  child: Text(
                                    state.connectedMac != null
                                        ? (state.connectedName ??
                                            'Imprimante connectée')
                                        : 'Aucune imprimante connectée',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[500]),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (state.connectedMac != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.teal[100],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.teal[200]!)),
                                    child: Text(
                                      'CONNECTÉ',
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
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Text(
                      "Pour connecter un nouvel appareil, ouvrez les paramètres Bluetooth du téléphone, puis revenez et appuyez sur Actualiser.",
                      style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[500]),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Appearance / Dark Mode
                  _buildSectionHeader('Apparence'),
                  _buildListGroup(
                    children: [
                      BlocBuilder<ThemeCubit, ThemeMode>(
                          builder: (context, mode) {
                        final isDark = mode == ThemeMode.dark;
                        return _buildListItem(
                          icon: Icons.dark_mode,
                          title: 'Mode sombre',
                          subtitle: isDark ? 'Activé' : 'Désactivé',
                          trailingWidget: Switch(
                            value: isDark,
                            activeThumbColor: const Color(0xFF6C63FF),
                            onChanged: (v) {
                              context.read<ThemeCubit>().setThemeMode(
                                  v ? ThemeMode.dark : ThemeMode.light);
                            },
                          ),
                        );
                      }),
                    ],
                  ),

                  // Premium Gold Card
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: _buildPremiumCard(),
                  ),

                  const SizedBox(height: 24),

                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 30.0),
                    child: Center(
                      child: Text(
                        "Edited by | Ranto Nandrianina 2026",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6C63FF),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        }),
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
        color: Theme.of(context).cardColor,
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
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: subtitleWidget ??
            (subtitle != null
                ? Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                : null),
        trailing: trailingWidget ??
            (trailingIcon != null
                ? Icon(trailingIcon, color: Colors.grey[400])
                : null),
      ),
    );
  }
}
